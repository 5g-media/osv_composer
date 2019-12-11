#!/bin/bash

if [ "$1" == "" ]
then
  echo "Usage: build_packages.sh <package_name> <arg1> <arg2> <arg3>"
  echo ""
  echo "Base OS: build_packages.sh osv_loader_and_bootstrap"
  echo "Runtime: build_packages.sh run_java|openjdk8-full|node|python"
  echo "Native:  build_packages.sh nginx|haproxy|ffmpeg"
  echo "Generic: build_packages.sh generic_app name version bootcmd"
  
  exit 1
fi

source $(dirname $0)/commons.sh
build_$1_package $2 $3 $4

