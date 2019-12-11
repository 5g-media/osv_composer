#!/bin/bash

source $(dirname $0)/commons.sh

SOURCE_PATH="$OUTPUT"

CAPSTAN_LOCAL_REPO=$HOME/.capstan
CAPSTAN_KERNEL_PATH=$CAPSTAN_LOCAL_REPO/repository/mike/osv-loader
CAPSTAN_PACKAGES_PATH=$CAPSTAN_LOCAL_REPO/packages

mkdir -p $CAPSTAN_KERNEL_PATH
mkdir -p $CAPSTAN_PACKAGES_PATH

echo "Publishing all packages ..."
cp $SOURCE_PATH/osv-loader.qemu $CAPSTAN_KERNEL_PATH
cp $SOURCE_PATH/*.mpm $SOURCE_PATH/*.yaml $CAPSTAN_PACKAGES_PATH
