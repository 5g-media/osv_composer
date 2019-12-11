#!/bin/bash

if [ "$1" == "" ]
then
  echo "Usage: create_unikernel_nodejs.sh <package_name> <js_file_name>"
  echo ""
  echo "example: "
  echo "         git clone https://production.eng.it/gitlab/5G-MEDIA/cicd_example_nodejs.git"
  echo "         cd cicd_example_nodejs "
  echo "         rm -fr meta "
  echo "         /scripts/create_unikernel_nodejs.sh node-example server.js "
  echo "         capstan package pull node-4.4.5  -  will be replaced by 8.11.1"
  echo "         capstan package compose -s 1G  node-example  "
  echo "         capstan run node-example -f \"8080:8080\" "
  exit 1
fi

AUTHOR=5GMEDIA-dev
VERSION=1.0

mkdir meta
echo "name: $1" > meta/package.yaml
echo "title: OSv $1" >> meta/package.yaml
echo "author: $AUTHOR" >> meta/package.yaml
echo "version: $VERSION" >> meta/package.yaml
echo "require:" >> meta/package.yaml

echo "runtime: node" > meta/run.yaml
echo "config_set:" >> meta/run.yaml
echo "  default:" >> meta/run.yaml
echo "    main: '/$2'" >> meta/run.yaml
echo "config_set_default: default" >> meta/run.yaml


