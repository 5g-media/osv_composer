Container where to create the unikernel images and run locally with QEMU or remotely on OpenStack
Point to the "repo" folder (see **$PWD/repo** below) shared by osv_composer for the MPM packages 

### HOWTO build the container
```
cd runner
docker build -t osv_runner .
```

### HOWTO run the container locally
```
docker run -p 8000:8000 -p 18000:18000 -v $PWD/repo:/root/.capstan -it osv_runner bash
```

## HOWTO run latest remote container built by CI/CD
```
docker run --volume="$PWD/repo:/root/.capstan" -p 8000:8000 -p 18000:18000 --privileged -it docker5gmedia/osv_runner
```

### HOWTO build the unikernels using the MPM images
- create and work into a new folder
- create the package file (meta/package.yaml) launching: **capstan package init --name NAME --title TITLE --author AUTHOR --require MPM-list** (comma separated)
- add the application configuration files (or put them directly a new MPM)
- create the launch file (meta/run.yaml) launching: **capstan package compose --run BOOTCMD -s 1G** NAME (1G is the size of the image created and impacts the flavor size on OpenStack)

Examples of possible MPM requirements:
- osv.openjdk8-zulu-full
- osv.python
- osv.node
- osv.haproxy
- osv.nginx
- osv.ffmpeg

Examples of possible BOOTCMD commands are:
-  /haproxy.so -f /haproxy.conf -p haproxy.pid -d -V
-  /ffmpeg.so -formats
-  /ffmpeg.so -i http://clips.vorwaerts-gmbh.de/VfE_html5.mp4 -c copy -f mpegts tcp://host.docker.internal:12345
-  /nginx.so -c /nginx/conf/nginx.conf
-  --redirect=/log.txt /libhttpserver-api.so --config-file=/etc/httpserver.conf) and change the "bootcmd" depending on the MPMs included; :
-  refer to the "set_command_line" argument in the more complete list [here](https://github.com/wkozaczuk/docker_osv_builder/blob/master/packages/scripts/commons.sh)


Example for haproxy (using capstan):

- mkdir haproxy-example && cd haproxy-example
- capstan package init --name "haproxy-example" --title "haproxy example" --author "5gmedia-dev" --require "osv.haproxy"
- cp /scripts/haproxy.conf .
- capstan package compose --run "/haproxy.so -f /haproxy.conf -p haproxy.pid -d -V" -s 1G haproxy-example


Examples for other images: see create_unikernel_***.sh scripts

### HOWTO instantiate the unikernel image locally with QEMU
capstan run NAME -f PORT:PORT

Example for haproxy
- capstan run haproxy-example -f 80:80


### HOWTO upload the unikernel image on OpenStack
```
source demo-openrc.sh

openstack image list
openstack image create --public --disk-format qcow2 --container-format bare --file /root/.capstan/repository/haproxy-example/haproxy-example.qemu haproxy-example
openstack image delete `openstack image list | grep haproxy-example | awk '{print $2}'`

```

### HOWTO instantiate on OpenStack
```
source demo-openrc.sh

openstack server list
openstack server create --image `openstack image list | grep haproxy-example | awk '{print $2}'` --flavor `openstack flavor list | grep flav111 | awk '{print $2}'` --security-group unikernel --network private haproxy-example
openstack server delete `openstack server list | grep haproxy-example | awk '{print $2}'`
openstack server add floating ip haproxy-example 172.24.4.3
openstack server remove floating ip haproxy-example 172.24.4.3

```

### HOWTO create OSM simple vnfd,nsd for the unikernel images
./create_osm_descriptors.sh NAME

Example for haproxy
./create_osm_descriptors.sh haproxy-example


