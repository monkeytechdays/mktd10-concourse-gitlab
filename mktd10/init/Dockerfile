FROM buildpack-deps:19.10-scm

ADD https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 /usr/local/bin/jq

RUN chmod a+x /usr/local/bin/jq

ADD https://dl.min.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc

RUN chmod a+x /usr/local/bin/mc

ADD . /etc/init/

ENTRYPOINT [ "/etc/init/init.sh" ]