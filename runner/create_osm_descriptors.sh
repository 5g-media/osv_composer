#!/bin/bash

if [ "$1" == "" ]
then
  echo "Usage: create_osm_descriptors.sh <package_name>"
  exit 1
fi

export NAME=$1

mkdir $NAME-vnfd
cp template-vnfd.yaml $NAME-vnfd/$NAME-vnfd.yaml
sed -i.bak -e s/NAME/$NAME/g -- $NAME-vnfd/$NAME-vnfd.yaml && rm -- $NAME-vnfd/$NAME-vnfd.yaml.bak
tar cvfz $NAME-vnfd.tar.gz $NAME-vnfd
rm -fr $NAME-vnfd
mv $NAME-vnfd.tar.gz /root/.capstan

mkdir $NAME-nsd
cp template-nsd.yaml $NAME-nsd/$NAME-nsd.yaml
sed -i.bak -e s/NAME/$NAME/g -- $NAME-nsd/$NAME-nsd.yaml && rm -- $NAME-nsd/$NAME-nsd.yaml.bak
tar cvfz $NAME-nsd.tar.gz $NAME-nsd
rm -fr $NAME-nsd
mv $NAME-nsd.tar.gz /root/.capstan