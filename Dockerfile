# Hugo version... can be overridden at image build time with --build-arg
ARG HUGO_VERSION=0.85.0
# remove/comment the following line completely to compile vanilla Hugo:
# ARG HUGO_BUILD_TAGS=extended

# Hugo >= v0.81.0 requires Go 1.16+ to build
ARG GO_VERSION=1.16

# ---

FROM golang:${GO_VERSION}-alpine3.13 AS build

# renew global args from above
# https://docs.docker.com/engine/reference/builder/#scope
ARG HUGO_VERSION
# ARG HUGO_BUILD_TAGS

ARG CGO=1
ENV CGO_ENABLED=${CGO}
ENV GOOS=linux
ENV GO111MODULE=on

WORKDIR /go/src/github.com/gohugoio/hugo

RUN apk add --update --no-cache \
      musl-dev \
      git && \
    go get github.com/magefile/mage

# clone source:
RUN git clone \
      --branch "v${HUGO_VERSION}" \
      --single-branch \
      --depth 1 \
      https://github.com/gohugoio/hugo.git ./

RUN mage -v hugo && mage install

# fix potential stack size problems on Alpine
# https://github.com/microsoft/vscode-dev-containers/blob/fb63f7e016877e13535d4116b458d8f28012e87f/containers/hugo/.devcontainer/Dockerfile#L19
RUN go get github.com/yaegashi/muslstack && \
    muslstack -s 0x800000 /go/bin/hugo

# ---

FROM alpine:3.13

# renew global args from above & pin any dependency versions
ARG HUGO_VERSION

LABEL version="${HUGO_VERSION}"
LABEL repository="https://github.com/moeb98/moe-hugo/"
LABEL homepage="https://github.com/moeb98/moe-hugo/"
LABEL maintainer="Mario Eberlein<moeb98@yahoo.de>"
LABEL org.opencontainers.image.source="https://github.com/moeb98/moe-hugo/"

# bring over patched binary from build stage
COPY --from=build /go/bin/hugo /usr/bin/hugo

# this step is intentionally a bit of a mess to minimize the number of layers in the final image
RUN set -euo pipefail && \
    # if [ "$(uname -m)" = "x86_64" ]; then \
    #  ARCH="amd64"; \
    # elif [ "$(uname -m)" = "aarch64" ]; then \
    #   ARCH="arm64"; \
    # elif [ "$(uname -m)" = "armv7l" ]; then \
    #   ARCH="armv7"; \
    # else \
    #   echo "Unknown build architecture, quitting." && exit 2; \
    # fi && \
    # alpine packages
    # ca-certificates are required to fetch outside resources (like Twitter oEmbeds)
    apk add --update --no-cache \
      ca-certificates \
      tzdata \
      go \
      git && \
    update-ca-certificates && \
    # clean up some junk
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* && \
    # make super duper sure that everything went OK, exit otherwise
    hugo env && \
    go version
    
# add site source as volume
VOLUME /src
WORKDIR /src

# expose live-refresh server on default port
EXPOSE 1313

ENTRYPOINT ["hugo"]
