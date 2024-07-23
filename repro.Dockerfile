FROM debian:12

ARG ARCH=arm64

ADD --chmod=755 https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/bazelisk-linux-$ARCH /usr/bin/
RUN ln -s /usr/bin/bazelisk-linux-$ARCH /usr/bin/bazel 

RUN <<EOF
#!/bin/bash

set -euxo pipefail

apt update

apt install -y \
    build-essential \
    git gcc make perl bison flex \
    python3 ninja-build python3-pip

pip3 install --break-system-packages meson

apt clean
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /src/workspace
