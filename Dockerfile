ARG BASEIMAGE=alpine:latest
FROM ${BASEIMAGE}

ARG HUGO_VERSION=0.84.4
ARG OS=Linux
ARG ARCH=ARM
ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Mario Eberlein <moeb98@yahoo.de>" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="moe-hugo is multi-arch Hugo" \
    org.label-schema.description="Hugo multi-arch amd64 and arm32v7 including git" \
    org.label-schema.url="https://github.com/moeb98/moe-hugo.git" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.lable-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/moeb98/moe-hugo.git" \
    org.label-schema.vendor="Mario Eberlein" \
    org.label-schema.version=${HUGO_VERSION} \
    org.label-schema.schema-version="1.0"

ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_${OS}-${ARCH}.tar.gz /tmp
RUN tar -xf /tmp/hugo_${HUGO_VERSION}_${OS}-${ARCH}.tar.gz -C /tmp \
    && mkdir -p /usr/local/sbin \
    && mv /tmp/hugo /usr/local/sbin/hugo \
    && rm -rf /tmp/hugo_${HUGO_VERSION}_${OS}-${ARCH} \
    && apk add --no-cache bash git

VOLUME /src
VOLUME /output

WORKDIR /src

ENTRYPOINT ["hugo"]

EXPOSE 1313
