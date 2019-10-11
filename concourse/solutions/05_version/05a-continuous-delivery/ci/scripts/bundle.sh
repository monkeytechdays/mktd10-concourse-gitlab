#!/usr/bin/env bash

set -eo pipefail

basedir="$(pwd)"
out="${basedir}/bundle"

rc=0
case "${format}" in
    tgz)
        [[ -f "${basedir}/version/version" ]] || {
            echo "Missing 'version' input" >&2
            rc=1
        }
        [[ -z "${basename}" ]] && {
            echo "Missing 'basename' param" >&2
            rc=1
        }
        workdir="${basedir}/archive"
        ;;

    dir)
        workdir="${out}"
        ;;

    *)
        echo "Unsupported format: '${format}'" >&2
        rc=1
        ;;
esac
[[ "${rc}" -eq 0 ]] || exit "${rc}"

version="$(cat "${basedir}/version/version")"

for input in in{0..9}; do
    src="${basedir}/${input}"
    [[ -d "${src}" ]] || continue
    target="${workdir}"
    target_var="${input}_target"
    [[ -z "${!target_var}" ]] || target="${target}/${!target_var}"
    [[ -d "${target}" ]] || mkdir -p "${target}"
    cp -R "${src}/." "${target}/"
done

case "${format}" in
    tgz)
        pushd "${workdir}"
            tar zcvf "${out}/${basename}-${version}.tar.gz" .
        popd
        ;;

    dir)
        ;;
esac
