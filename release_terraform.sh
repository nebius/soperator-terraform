#!/bin/bash

set -e

usage() { echo "usage: ${0} [-f] [-h]" >&2; exit 1; }

while getopts fh flag
do
    case "${flag}" in
        f) force=1;;
        h) usage;;
        *) usage;;
    esac
done


version=$(echo "$VERSION" | tr '.' '_' | tr '-' '_')

tarball="releases/unstable/slurm_operator_tf_${version}.tar.gz"
if [ ! -f "$tarball" ] || [ -n "$force" ]; then
    tar -czf "$tarball" \
        --exclude="oldbius/.terraform" \
        --exclude="oldbius/.terraform.lock.hcl" \
        --exclude="oldbius/.terraform.tfstate.lock.info" \
        --exclude="oldbius/terraform.tfstate" \
        --exclude="oldbius/terraform.tfstate.backup" \
        oldbius test
    echo "Created $(pwd)/$tarball"
fi
