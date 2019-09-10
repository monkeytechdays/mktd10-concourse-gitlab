#!/usr/bin/env bash

set -o pipefail

function main() {
       gogs.main  \
    && minio.main \
    && vault.main
}

function core.logs() {
    local prefix="$1"; shift
    sed "s/^/${prefix} /"
}

function http.wait_for() {
    local http_code=0
    local http_rc=1
    local http_attempt=4

    while [[ "${http_rc}" -gt 0 && "${http_code}" -lt 200 && "${http_code}" -ge 300 ]]; do
        [[ "${http_attempt}" -gt 0 ]] || {
            return 1
        }
        sleep 3
        curl -L -w '%{http_code}' -s -o '/dev/null' "$@" > /tmp/waitforhttp_code.txt; http_rc=$?
        http_code=$(cat /tmp/waitforhttp_code.txt)
        ((http_attempt-=1))
    done

    return 0
}

function gogs.main() {
    echo "[GOGS ]"
    gogs_url='http://gogs:3000'
    gogs.wait && gogs.install
}

function gogs.wait() {
    echo "[GOGS ] Wait for availability"
    http.wait_for "${gogs_url}" || {
        local rc=$?
        echo "[GOGS ] Not available" >&2
        return "$rc"
    }
}

function gogs.install() {
    local installation_status=$(curl -L -s -o /dev/null -w '%{http_code}' -b '/tmp/gogs_install_cookies.txt' -c '/tmp/gogs_install_cookies.txt' "${gogs_url}/install") || return $?
    echo "[GOGS ] GET /install > ${installation_status}"

    if [[ "${installation_status}" != '404' ]]; then
        echo "[GOGS ] POST /install"
        installation_status="$(curl -X POST -L -s "${gogs_url}/install" \
             -b '/tmp/gogs_install_cookies.txt' \
             -c '/tmp/gogs_install_cookies.txt' \
             -o '/tmp/gogs_install_post.txt' \
             -w '%{http_code}' \
             -F 'db_type=SQLite3' \
             -F 'db_host=127.0.0.1:3306' \
             -F 'db_user=root' \
             -F 'db_passwd=' \
             -F 'db_name=gogs' \
             -F 'ssl_mode=disable' \
             -F 'db_path=data/gogs.db' \
             -F 'app_name=Gogs' \
             -F 'repo_root_path=/data/git/gogs-repositories' \
             -F 'run_user=git' \
             -F 'domain=localhost' \
             -F 'ssh_port=22' \
             -F 'http_port=3000' \
             -F 'app_url=http://localhost:10080/' \
             -F 'log_root_path=/app/gogs/log' \
             -F 'smtp_host=' \
             -F 'smtp_from=' \
             -F 'smtp_user=' \
             -F 'smtp_passwd=' \
             -F 'offline_mode=on' \
             -F 'disable_gravatar=on' \
             -F 'disable_registration=on' \
             -F 'admin_name=root' \
             -F 'admin_passwd=root' \
             -F 'admin_confirm_passwd=root' \
             -F 'admin_email=root@localhost' \
        )"
        [[ "${installation_status}" -lt 300 ]] || {
            echo "[GOGS ] Installation failed (${installation_status})" >&2
            cat '/tmp/gogs_install_post.txt'
            return 1
        }
        echo "[GOGS ] Installation done"
    else
        echo "[GOGS ] Installation already done"
    fi
    return 0
}

function minio.main() {
    echo "[MINIO]"
    minio.wait && minio.init_bucket
}

function minio.wait() {
    echo "[MINIO] Wait for availability"
    http.wait_for -H 'User-Agent: Mozilla/5.0' 'http://s3:9000' || {
        local rc=$?
        echo "[MINIO] Not available" >&2
        return $rc
    }
}

function minio.init_bucket() {
    echo "[MINIO] Check bucket"
    if ! MC_HOST_s3="http://${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY}@s3:9000" mc ls -q s3/concourse; then
        echo "[MINIO] Create bucket"
        MC_HOST_s3="http://${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY}@s3:9000" mc mb s3/concourse || {
            local rc=$?
            echo "[MINIO] Unable to create bucket" >&2
            return $rc
        }
    else
        echo "[MINIO] Bucket already exists"
    fi
    return 0
}

function vault.main() {
    echo "[VAULT]"
    vault.wait && vault.create_secrets && vault.create_policy && vault.create_token
}

function vault.wait() {
    echo "[VAULT] Wait for availability"
    http.wait_for "${VAULT_ADDR}" || {
        local rc=$?
        echo "[VAULT] Not available" >&2
        return $rc
    }
}

function vault.create_secrets() {
    echo "[VAULT] secrets: check /concourse"
    local secrets_uuid="$(vault secrets list -format=json | jq -r '.["concourse/"]?.uuid')" || {
        local rc=$?
        echo "[VAULT] Unable to retrieve Vault secret list" >&2
        return $?
    }
    if [[ "${secrets_uuid}" == 'null' ]]; then
        echo "[VAULT] secrets: create /concourse"
        vault secrets enable -path '/concourse' -description 'Concourse secrets' generic || {
            local rc=$?
            echo "[VAULT] Unable to create Vault secrets on '/concourse'" >&2
            return $?
        }
    else
        echo "[VAULT] secrets: /concourse already exists"
    fi
    return 0
}

function vault.create_policy() {
    echo "[VAULT] policy: check 'policy-concourse'"
    if ! vault policy list | grep -qx 'policy-concourse'; then
        echo "[VAULT] policy: create 'policy-concourse'"
        cat >/tmp/vault-policy-concourse.hcl <<EOF
path "concourse/*" {
    capabilities = ["read", "list"]
}
EOF
        vault policy write 'policy-concourse' /tmp/vault-policy-concourse.hcl || {
            local rc=$?
            echo "[VAULT] Unable to create policy 'policy-concourse'" >&2
            return $rc
        }
    else
        echo "[VAULT] policy: 'policy-concourse' already exists"
    fi
    return 0
}

function vault.create_token() {
    echo "[VAULT] token: check '${CONCOURSE_VAULT_CLIENT_TOKEN}'"
    if ! vault token lookup "${CONCOURSE_VAULT_CLIENT_TOKEN}" >/dev/null 2>&1; then
        echo "[VAULT] token: create '${CONCOURSE_VAULT_CLIENT_TOKEN}'"
        vault token create -display-name 'Concourse token' -id "${CONCOURSE_VAULT_CLIENT_TOKEN}" -policy 'policy-concourse' || {
            local rc=$?
            echo "[VAULT] Unable to create token '${CONCOURSE_VAULT_CLIENT_TOKEN}'" >&2
            return $rc
        }
    else
        echo "[VAULT] token: '${CONCOURSE_VAULT_CLIENT_TOKEN}' already exists"
    fi
    return 0
}

main "$@#"
