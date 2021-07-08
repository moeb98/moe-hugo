#!/bin/bash
REPO=mrmoe/moe-hugo
VER=0.84.4
BASEIMAGE=alpine:latest
TAG=$(git describe --tags `git rev-list --tags --max-count=1`)

case "$1" in
	"build")
		docker buildx build \
	      --platform linux/amd64,linux/arm/v7,linux/arm/v6 \
  	      -t $REPO:latest -t $REPO:$TAG --push \
	      --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	      --build-arg VCS_REF=`git rev-parse --short HEAD` \
	      --build-arg BASEIMAGE=$BASEIMAGE \
	      --build-arg VERSION=$VER .
		;;
	"console")
		docker run -it --rm --entrypoint "/bin/ash" $REPO:$TAG
		;;
	* )
		cat << EOF
setup script
—————————————————————————————
Usage:
docker-make.sh build – build docker image
docker-make.sh console – start console

EOF
		;;
esac
