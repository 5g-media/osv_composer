#!/bin/bash

if [ "$1" == "" ]
then  
    echo "Usage: create_unikernel_python.sh <package_name> <python_file_name>"
    echo ""
    echo "example: "
    echo "         git clone https://production.eng.it/gitlab/5G-MEDIA/cicd_example_python.git"
    echo "         cd cicd_example_python "
    echo "         rm -fr meta "
    echo "         /scripts/create_unikernel_python.sh python-example server3.py "
    echo "         capstan package compose -s 1G  python-example "
    echo "         capstan run python-example -f \"8080:8080\" "
    exit 1
fi

AUTHOR=5GMEDIA-dev
VERSION=1.0

mkdir meta
echo "name: $1" >> meta/package.yaml
echo "title: OSv $1" >> meta/package.yaml
echo "author: $AUTHOR" >> meta/package.yaml
echo "version: $VERSION" >> meta/package.yaml
echo "require:" >> meta/package.yaml
echo "- osv.python3x" >> meta/package.yaml

echo "runtime: native" >> meta/run.yaml
echo "config_set:" >> meta/run.yaml
echo "  default:" >> meta/run.yaml
echo "    bootcmd: '/python3 /$2'" >> meta/run.yaml
echo "config_set_default: default" >> meta/run.yaml
