#!/bin/bash
set -ex

mkdir -p /opt/nslcore
curl https://ip-arch.jp/unsupported/nslcore-x86_64-linux-20221225-95.tar.gz | tar xvz -C /opt/nslcore
