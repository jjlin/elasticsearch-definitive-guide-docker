FROM ubuntu:latest

ENV HOME /root

ARG PKGS="\
    asciidoc-base \
    calibre \
    git \
"

RUN set -x \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get -qy install ${PKGS} \
 && apt-get clean

COPY build.sh ${HOME}

WORKDIR ${HOME}
CMD ["/root/build.sh"]
