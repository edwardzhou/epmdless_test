#!/bin/sh
echo "deps_get -> BUILD_HTTPS_PROXY: ${BUILD_HTTPS_PROXY}"
if [ -n "${BUILD_HTTPS_PROXY}" ]
then
  echo https_proxy=${BUILD_HTTPS_PROXY} mix deps.get
  https_proxy=${BUILD_HTTPS_PROXY} mix deps.get
else
  echo mix deps.get
  mix deps.get
fi