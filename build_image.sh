#!/bin/sh
source ./env.sh

if [ -n "${BUILD_HTTPS_PROXY}" ]
then
  echo docker build \
    --build-arg BUILD_HTTPS_PROXY=$BUILD_HTTPS_PROXY \
    --build-arg no_proxy="127.0.0.1,localhost,*.leangoo.com,192.168.0.0/16,*.aliyun.com,*.local" \
    -t ${image_name}:${version} \
    .
  docker build \
    --build-arg BUILD_HTTPS_PROXY=$BUILD_HTTPS_PROXY \
    --build-arg no_proxy="127.0.0.1,localhost,*.leangoo.com,192.168.0.0/16,*.aliyun.com,*.local" \
    -t ${image_name}:${version} \
    .
else
  echo docker build \
    --build-arg no_proxy="127.0.0.1,localhost,*.leangoo.com,192.168.0.0/16,*.aliyun.com,*.local" \
    -t ${image_name}:${version} \
    .
  docker build \
    --build-arg no_proxy="127.0.0.1,localhost,*.leangoo.com,192.168.0.0/16,*.aliyun.com,*.local" \
    -t ${image_name}:${version} \
    .
fi
