#!/usr/bin/env bash

function main() {
    gogs
}

function gogs() {
    sleep 10

    local installation_status=$(curl -L -w '%{http_code}' -b '/tmp/gogs_install_cookies.txt' -c '/tmp/gogs_install_cookies.txt' 'http://gogs:3000/install')
    echo "[GOGS] GET /install > ${installation_status}"

    [[ "${installation_status}" == '404' ]] || {
        echo "[GOGS] POST /install"
        curl -X POST -f 'http://gogs:3000/install' \
             -b '/tmp/gogs_install_cookies.txt' \
             -c '/tmp/gogs_install_cookies.txt' \
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

main "$@#"
