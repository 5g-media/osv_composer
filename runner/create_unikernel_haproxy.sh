#!/bin/bash

mkdir haproxy-example && cd haproxy-example
capstan package init --name haproxy-example --title haproxy-example --author example --require osv.haproxy
cp /scripts/haproxy.conf .
capstan package compose --run "/haproxy.so -f /haproxy.conf -p haproxy.pid -d -V"  -s 1G haproxy-example 
echo "run locally with: capstan run haproxy-example -f 18000:80"