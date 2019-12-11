#!/bin/bash

mkdir nginx-example && cd nginx-example
capstan package init --name nginx-example --title nginx-example --author example --require osv.nginx
capstan package compose --run "/nginx.so -c /nginx/conf/nginx.conf" -s  1G nginx-example 
echo "run locally with: capstan run nginx-example -f 18000:80"
