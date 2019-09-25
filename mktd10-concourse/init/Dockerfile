FROM vault:1.2.2 as vault

FROM minio/mc:RELEASE.2019-09-11T20-17-47Z as mc

FROM loganmzz/jq:1.6 as jq

FROM buildpack-deps:19.10-scm

COPY --from=mc /usr/bin/mc /usr/local/bin/mc

COPY --from=vault /bin/vault /bin/vault

COPY --from=jq /jq /usr/local/bin/jq

ADD . /etc/init/

ENTRYPOINT [ "/etc/init/init.sh" ]
