#!/bin/sh
# ################## #
# BUILDING THE IMAGE #
# ################## #
# BUILD THE IMAGE (replace all environment variables)
BUILD_START=$(date '+%s')
IMAGE_NAME="zcm-compact"
VERSION="v1.3"
DOCKERFILE=Dockerfile
echo "Building image '$IMAGE_NAME' ..."
docker build --force-rm=true --no-cache=true -t $IMAGE_NAME:$VERSION -f $DOCKERFILE . || {
  echo ""
  echo "ERROR: ZCM Compact Docker Image was NOT successfully created."
  echo "ERROR: Check the output and correct any reported problems with the docker build operation."
  exit 1
}

# Remove dangling images (intermitten images with tag <none>)
yes | docker image prune > /dev/null
BUILD_END=$(date '+%s')
BUILD_ELAPSED=`expr $BUILD_END - $BUILD_START`
echo ""
cat << EOF
  ZCM Compact Docker Image for version $VERSION is ready to be extended:

    --> $IMAGE_NAME:$VERSION

  Build completed in $BUILD_ELAPSED seconds.

EOF