#!/bin/bash

set -eu -o pipefail

readonly GO="${GO:-go}"

tmpdir=$(mktemp -d)
trap "{ rm -rf ${tmpdir}; }" EXIT

readonly ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# "go build" can be noisy, and when Go invokes pkg-config (by calling this script) it will merge stdout and stderr.
# Discard any output unless "go build" terminates with an error.
# cd to the root directory first to ensure we build the version of pkg-config specified in root.
# Go runs pkg-config from the directory of the package it's trying to configure,
# so without cd-ing to the root first, we would pick up flux's go.mod and build the version of pkg-config specified there.
(cd "${ROOT_DIR}" && "${GO}" build -o ${tmpdir}/pkg-config github.com/influxdata/pkg-config) &> ${tmpdir}/go_build_output
if [ "$?" -ne 0 ]; then
    cat ${tmpdir}/go_build_output 1>&2
    exit 1
fi

${tmpdir}/pkg-config "$@"
