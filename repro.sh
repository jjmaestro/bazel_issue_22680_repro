#!/bin/bash

set -euo pipefail

_bazel() {
    cd /src/workspace 

    # let's make sure everything is clean before running
    bazel clean --expunge
    rm -rf /root/.cache/bazel
    rm -rf /tmp/out/bazel

    local exit_code=0

    bazel "$@" || exit_code=$?

    echo -e "\n\n"
    echo "======================="
    echo "cmd: bazel $*"
    if [[ $exit_code -eq 0 ]]; then
        echo "WORKED [$exit_code]"
    else
        echo "FAILED [$exit_code]"
    fi
    echo "======================="
    echo -e "\n\n"
}


echo -e "\n\n"
echo "======================="
bazel --version 
echo "======================="
echo -e "\n\n"


# This works OK, the cache is inside the Docker image at /root/.cache/bazel
_bazel build //testimage:tarball


# Now, running the same bazel build but with output_base on a Docker volume fails:
_bazel --output_base /tmp/out/bazel build //testimage:tarball


# Finally, try with the experimental_worker_for_repo_fetching flag, which also fails (for me)
_bazel --output_base /tmp/out/bazel build --experimental_worker_for_repo_fetching=off //testimage:tarball
