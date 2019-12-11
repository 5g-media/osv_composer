# Examples of native image building WITHOUT using capstan


- to clean the build
```
/osv/scripts/build clean
```

- after each build the unikernel image is created in /osv/build/last/usr.img (in qemu format)

- it is also possible to use capstan to build binary MPM packages and compose unikernel images assembling MPMs 

## LIBs for internal use to enable CLI, GUI
see DOC https://github.com/cloudius-systems/osv-apps/tree/master/httpserver-html5-cli

### httpserver-html5-cli
```
cd /osv
./scripts/build image=httpserver-html5-cli.fg
./scripts/run.py --api -v --forward tcp::18000-:18000 --forward tcp::8000-:8000
```

### httpserver-html5-gui + cli
```
cd /osv
./scripts/build image=httpserver-html5-gui.fg
./scripts/run.py --api -v --forward tcp::18000-:18000 --forward tcp::8000-:8000
```

## EXAMPLE remote writing/reading configuration through CLI
```
echo "test" > test.out
curl -X POST http://localhost:8000/file/test.txt -Fname=@test.txt

rm test.out
curl http://localhost:8000/file/test.txt?op=GET
```

## COMBO cloud-init,cli
- change ./modules/cloud-init/cloud-init.yaml like /scripts/native/cloud-init.yaml

- build the image
```
cd /osv
./scripts/build image=cloud-init,cli
```

- instantiate the image /osv/build/last/usr.img on OpenStack using a sample cloud-init like /scripts/native/cloud-init.conf


## HAPROXY

- change apps/haproxy/haproxy.conf like /scripts/native/haproxy_example.conf

- build and run
```
cd /osv
./scripts/build image=haproxy
./scripts/run.py -v --forward tcp::18000-:18000
```

- on the host, open http://localhost:18000 in the browser


## NGINX

- change port to 18000
```
cd /osv
sed -i 's/80;/18000;/g' ./apps/nginx/patches/nginx.conf
```
- build and run
```
./scripts/build image=nginx
./scripts/run.py -v --forward tcp::18000-:18000
```
- on the host, open http://localhost:18000 in the browser

## FFMPEG
- comment "strip" in Makefile and enable x265
```
cd /osv
sed -i 's/disable-ffprobe/disable-ffprobe --enable-libx265 --enable-gpl/g' ./apps/ffmpeg/Makefile
sed -i 's/strip ROOTFS/#strip ROOTFS/g' ./apps/ffmpeg/Makefile
```

## COMBO haproxy+gui with haproxy not started at boot

- clean apps/haproxy/module.py 

- build and run
```
cd /osv
./scripts/build image=httpserver-html5-gui,haproxy
./scripts/run.py --forward tcp::18000-:18000 --forward tcp::8000-:8000
```
- on the host, open http://localhost:8000 in the browser for the CLI/REST API/GUI
- on the host, open http://localhost:18000 in the browser - NO CONTENT

- create on the host haproxy.conf like /scripts/native/haproxy.conf
- copy the configuration file on the running instance using REST
  curl -X POST http://localhost:8000/file/haproxy.conf -Fname=@haproxy.conf
  launch haproxy thread with the new configuration

via GUI
http://localhost:8000/app
/haproxy.so -f /haproxy.cfg -p haproxy.pid -d -V

via REST
curl -X PUT http://localhost:8000/app/?new_program=true\&command=%2Fhaproxy.so%20-f%20%2Fhaproxy.cfg%20-p%20haproxy.pid%20-d%20-V

on the host, open http://localhost:18000 in the browser - CONTENT IS NOW AVAILABLE





     