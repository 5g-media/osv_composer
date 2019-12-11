#!/bin/bash

if [ "$1" == "" ]
then
  echo "Usage: create_unikernel_java.sh <package_name> <jar_file_name>"
  echo ""
  echo "example: "
  echo "         git clone https://production.eng.it/gitlab/5G-MEDIA/cicd_example_java.git"
  echo "         cd cicd_example_java "
  echo "         mvn clean package "
  echo "         mkdir java-example && cd java-example "
  echo "         cp ../target/cicd_example_java-0.0.1-SNAPSHOT.jar ."
  echo "         /scripts/create_unikernel_java.sh  java-example cicd_example_java-0.0.1-SNAPSHOT.jar "
  echo "         capstan package compose -s 1G java-example "
  echo "         capstan run java-example -f \"8080:8080\" "
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
echo "- osv.openjdk8-zulu-full"  >> meta/package.yaml

echo "runtime: native" > meta/run.yaml
echo "config_set:" >> meta/run.yaml
echo "  default:" >> meta/run.yaml
echo "    bootcmd: /java.so -jar /$2" >> meta/run.yaml
echo "config_set_default: default" >> meta/run.yaml


