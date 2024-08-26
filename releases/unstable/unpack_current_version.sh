#!/bin/bash

set -e

# This script unpacks a terraform release tarball with the current VERSION into the working directory excluding the
# terraform variables file.

if [ ! -f "$TARBALL" ]; then
    echo "No release with the current version $VERSION: file with name $TARBALL doesn't exist"
    exit 1
fi

echo "Extracting tarball $TARBALL"
tar -xvf "${TARBALL}" --exclude "^oldbius/terraform.tfvars$"

if [ -f oldbius/terraform.tfvars ]; then
    echo "Updating slurm_operator_version in the existing terraform.tfvars file"
    sed -i.bak -E "s/(slurm_operator_version[[:space:]]*=[[:space:]]*\").*(\")/\1${VERSION}\2/" oldbius/terraform.tfvars
fi
