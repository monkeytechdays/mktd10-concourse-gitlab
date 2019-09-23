#!/usr/bin/env bash

set -o pipefail

function main() {
    local rc=0
    gogs.main  || rc=$?
    minio.main || rc=$?
    vault.main || rc=$?
    nexus.main || rc=$?
    return $?
}

function core.logs() {
    local prefix="$1"; shift
    sed "s/^/${prefix} /"
}

function file.wait_for() {
    local file_path="$1"
    local file_rc=1
    local file_attempt=0

    while [[ "${file_rc}" -gt 0 && "${file_attempt}" -le 10 ]]; do
        [[ "${file_attempt}" -eq 0 ]] || {
            echo "Retry #${file_attempt}"
            sleep 15
        }
        [[ -f "${file_path}" ]]; file_rc=$?
        ((file_attempt+=1))
    done
}

function http.request() {
    local response_file="$(mktemp)"
    local http_code="$(curl -sL -w '%{http_code}' -o "${response_file}" "$@")"; local http_rc=$?

    if [[ "${http_code}" -ge 200 && "${http_code}" -lt 300 ]]; then
        http_rc=0
    elif [[ "${http_rc}" -ne 0 ]]; then
        http_rc=99
    else
        case "${http_code}" in
            401)
                http_rc=41
                ;;
            403)
                http_rc=43
                ;;
            404)
                http_rc=44
                ;;
            *)
                http_rc=90
                ;;
        esac
    fi

    [[ -f "${response_file}" ]] && {
        cat "${response_file}"
        rm -rf "${response_file}"
    }

    return "${http_rc}"
}

function http.wait_for() {
    local http_rc=1
    local http_attempt=0
    local http_bodyfile='/tmp/waitforhttp_response.txt'

    while [[ "${http_rc}" -gt 0 && "${http_attempt}" -le 10 ]]; do
        [[ "${http_attempt}" -eq 0 ]] || {
            echo "Retry #${http_attempt}"
            sleep 15
        }
        http.request "$@" > "${http_bodyfile}"; http_rc=$?

        if [[ "${http_rc}" -ne 0 && -s "${http_bodyfile}" ]]; then
            cat "${http_bodyfile}"
            echo
        fi
        ((http_attempt+=1))
    done

    return "${http_rc}"
}

function gogs.main() {
    echo "[GOGS ]"
    gogs_url='http://gogs:3000'
    gogs.wait && gogs.install && echo "[GOGS ] Success" || {
        local rc=$?
        echo "[GOGS ] Failed" >&2
        return $rc
    }
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
    http.request -b '/tmp/gogs_install_cookies.txt' -c '/tmp/gogs_install_cookies.txt' "${gogs_url}/install" >/dev/null; local installation_status=$?
    echo "[GOGS ] GET /install > ${installation_status}"

    if [[ "${installation_status}" -eq 0 ]]; then
        echo "[GOGS ] POST /install"
        http.request -X POST "${gogs_url}/install" \
             -b '/tmp/gogs_install_cookies.txt' \
             -c '/tmp/gogs_install_cookies.txt' \
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
             -o '/tmp/gogs_install_post.txt' \
             > /dev/null
        [[ "${installation_status}" -eq 0 ]] || {
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
    minio.wait && minio.init_bucket && echo "[MINIO] Success" || {
        local rc=$?
        echo "[MINIO] Failed" >&2
        return $rc
    }
}

function minio.wait() {
    echo "[MINIO] Wait for availability"
    http.wait_for -H 'User-Agent: Mozilla/5.0' 'http://s3:9000' || {
        local rc=$?
        echo "[MINIO] Not available" >&2
        return $rc
    }
}

function minio.client() {
    MC_HOST_s3="http://${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY}@s3:9000" mc "$@"
}

function minio.init_bucket() {
    echo "[MINIO] Check bucket"
    if ! minio.client ls -q s3/concourse; then
        echo "[MINIO] Create bucket"
        minio.client mb s3/concourse || {
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
    vault.wait && vault.create_secrets && vault.create_policy && vault.create_token && echo "[VAULT] Success" || {
        local rc=$?
        echo "[VAULT] Failed" >&2
        return $rc
    }
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


function nexus.main() {
    echo "[NEXUS]"
    nexus_url='http://nexus:8081'
    nexus.wait \
    && nexus.init_system_user \
    && nexus.init_complete \
    && echo "[NEXUS] Success" \
    || {
        local rc=$?
        echo "[NEXUS] Failed" >&2
        return $rc
    }
}

function nexus.http.request() {
    local path=$1; shift
    http.request -u "${nexus_auth}" "${nexus_url}${path}" "$@"
}


function nexus.run_script() {
    local script="$1"; shift
    local run_args=()
    [[ $# -gt 0 ]] && run_args=('-d' "$1") && shift

    echo "[NEXUS] Execute script '${script}'"
    local http_bodyfile="/tmp/nexus_script_${script}_response.txt"
    local http_payload="/tmp/nexus_script_${script}_payload.json"
    local http_rc=0

    jq -n --rawfile scriptfile "/etc/init/nexus/${script}.groovy" --arg scriptname "${script}" '{"name":$scriptname, "type":"groovy","content":$scriptfile}' > "${http_payload}" || return $?

    nexus.http.request "/service/rest/v1/script/${script}" -X 'PUT' -H 'Content-Type: application/json' -d "@${http_payload}" > "${http_bodyfile}"; http_rc=$?
    [[ "${http_rc}" -eq 44 ]] && {
        nexus.http.request "/service/rest/v1/script/" -X 'POST' -H 'Content-Type: application/json' -d "@${http_payload}" > "${http_bodyfile}"; http_rc=$?
    }

    [[ "${http_rc}" -eq 0 ]] || {
        echo "Unable to upload script '${script}' (rc: ${http_rc})" >&2
        [[ ! -s "${http_bodyfile}" ]] || {
            cat "${http_bodyfile}" >&2
            echo                   >&2
        }
        return 1
    }

    nexus.http.request "/service/rest/v1/script/${script}/run" -X 'POST' -H 'Content-Type: application/json' > "${http_bodyfile}"; http_rc=$?
    [[ "${http_rc}" -eq 0 ]] || {
        echo "Error while running script '${script}' (rc: ${http_rc})" >&2
        [[ ! -s "${http_bodyfile}" ]] || {
            cat "${http_bodyfile}" >&2
            echo                   >&2
        }
        return 1
    }
    [[ ! -s "${http_bodyfile}" ]] || {
        cat "${http_bodyfile}"
        echo
    }
}

function nexus.wait() {
    echo "[NEXUS] Wait for availability"
    http.wait_for "${nexus_url}/service/rest/v1/read-only" || {
        local rc=$?
        echo "[NEXUS] Not available" >&2
        return $rc
    }
}

function nexus.init_system_user() {
    local check_provided_password_response='/tmp/nexus_check_provided_password_response.txt'
    nexus_auth="admin:${NEXUS_ADMIN_PASSWORD}"
    nexus.http.request '/service/rest/v1/read-only' > "${check_provided_password_response}"; local http_rc=$?
    if [[ "${http_rc}" -eq 0 ]] ; then
        echo "[NEXUS] Using provided password"
        return 0
    else
        echo "[NEXUS] Unable to connect with provided password (rc: ${http_rc})"
    fi

    echo "[NEXUS] Wait for password file"
    local nexus_password_file='/nexus-data/admin.password'
    file.wait_for "${nexus_password_file}" || {
        echo "Missing password file" >&2
        return 1
    }

    nexus_default_password=$(cat "${nexus_password_file}")
    echo "[NEXUS] Using temporary password: ${nexus_default_password}"
    echo "[NEXUS]"

    nexus_auth="admin:${nexus_default_password}"
    nexus.http.request '/service/rest/v1/read-only' > "${check_provided_password_response}"; http_rc=$?
    [[ "${http_rc}" -eq 0 ]] || {
        echo "Unable to connect with temporary password (rc: ${http_rc})" >&2
        [[ ! -s "${check_provided_password_response}" ]] || {
            cat "${check_provided_password_response}" >&2
            echo                                      >&2
        }
        return 1
    }
    echo "[NEXUS] Using temporary password"
    return 0
}

function nexus.init_complete() {
    echo "[NEXUS] Complete installation"
    nexus.run_script 'docker-repositories'
    nexus.run_script 'npm-repositories'
}

main "$@#" 2>&1
