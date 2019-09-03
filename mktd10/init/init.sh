#!/usr/bin/env bash

function main() {
    gogs
    minio
}

function wait_for_http() {
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

function gogs() {
    echo "[GOGS] Wait for availability"
    wait_for_http 'http://gogs:3000' || {
        local rc=$?
        echo "[GOGS] Not available" >&2
        return "$rc"
    }

    local installation_status=$(curl -L -s -o /dev/null -w '%{http_code}' -b '/tmp/gogs_install_cookies.txt' -c '/tmp/gogs_install_cookies.txt' 'http://gogs:3000/install')
    echo "[GOGS] GET /install > ${installation_status}"

    [[ "${installation_status}" == '404' ]] || {
        echo "[GOGS] POST /install"
        curl -X POST -s -f 'http://gogs:3000/install' \
             -b '/tmp/gogs_install_cookies.txt' \
             -c '/tmp/gogs_install_cookies.txt' \
             -o '/dev/null' \
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
             || {
                 local rc=$?
                 echo "[GOGS] Installation done ($rc)"
                 return $rc
             }
    }
    echo "[GOGS] Installation already done"
    return 0
}

function minio() {
    local rc=0

    echo "[MINIO] Wait for availability"
    wait_for_http -H 'User-Agent: Mozilla/5.0' 'http://s3:9000' || {
        rc=$?
        echo "[MINIO] Not available" >&2
        return $rc
    }

    echo "[MINIO] Check bucket"
    MC_HOST_s3="http://${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY}@s3:9000" mc ls -q s3/concourse || {
        echo "[MINIO] Create bucket"
        MC_HOST_s3="http://${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY}@s3:9000" mc mb s3/concourse || {
            echo "[MINIO] Unable to create bucket" >&2
            return 1
        }
        return 0
    }
    echo "[MINIO] Bucket already exists"
}

main "$@#"
