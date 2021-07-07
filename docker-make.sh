#!/bin/bash
RNAME=mrmoe/moe-hugo
VER=0.84.4
BASENAME=alpine:latest


case "$1" in
	"build")
		docker buildx build \
	      --platform linux/amd64,linux/arm/v7,linux/arm/v6 \
  	      -t $RNAME:latest -t $RNAME:$VER --push \
	      --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	      --build-arg VCS_REF=`git rev-parse --short HEAD` \
	      --build-arg BASEIMAGE=$BASENAME \
	      --build-arg VERSION=$VER .
		;;
	"console")
		docker run -it --rm --entrypoint "/bin/ash" $RNAME:$VER
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
