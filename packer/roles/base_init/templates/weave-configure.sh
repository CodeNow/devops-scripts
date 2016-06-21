#!/usr/bin/env bash

set -x

# weave
curl --silent -q -O https://github.com/weaveworks/weave/releases/download/v1.4.6/weave
sudo install -c -m 755 weave /usr/local/bin || echo "Could not install weave."
rm -f weave
