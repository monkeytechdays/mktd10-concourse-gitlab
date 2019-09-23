FROM vault:1.2.2 as vault

FROM minio/mc:RELEASE.2019-09-11T20-17-47Z as mc

FROM scratch as jq

ADD https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 /jq

FROM buildpack-deps:19.10-scm

COPY --from=mc /usr/bin/mc /usr/local/bin/mc

COPY --from=vault /bin/vault /bin/vault

ADD . /etc/init/

ENTRYPOINT [ "/etc/init/init.sh" ]

COPY --from=jq /jq /usr/local/bin/jq

RUN chmod a+x /usr/local/bin/jq
