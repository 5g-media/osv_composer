# Docker OSv composer
This project allows to build a Docker container where **to compile OSv MPM** base, runtime and native **packages**, along with scripts and updated documentation.

The "runner" folder allows to build a Docker container where to **use existing MPM packages to create unikernel images**


## Build local container
```
docker build -t osv_composer .
```

Launch container 
- if needed, port 8000 is for OSv REST API and port 18000 is an example of service published
- create a "repo" folder ("mkdir ˜/repo", see **$PWD/repo** below) to share the MPM packages with the osv_runner 

## Run local container
```
docker run --volume="$PWD/repo:/root/.capstan" -p 8000:8000 -p 18000:18000 --privileged -it osv_composer
```

## Run latest remote container built by CI/CD
```
docker run --volume="$PWD/repo:/root/.capstan" -p 8000:8000 -p 18000:18000 --privileged -it docker5gmedia/osv_composer
```

## HOWTO structure a local repository
If packages need to be published in a [local repo](https://github.com/cloudius-systems/capstan/blob/master/Documentation/Installation.md#3-using-environment-variables) replicate the file structure below and serve with an http server (such as nginx)

File repo structure

>
>>repository
>>>mike
>>>>osv-loader
>>>>>index.yaml
>>>>>osv.loader.qemu
>
>>packages
>>>pkg1.mpm
>>>pkg1.yaml
>>>pkg2.mpm
>>>pkg2.yaml

## HOWTO compile the MPM images
see [doc](https://production.eng.it/gitlab/5G-MEDIA/osv_composer/blob/master/scripts/README.md) 


## HOWTO setup a private remote repo
```
docker run -v $PWD/repo:/usr/share/nginx/html -p 8010:80 -d nginx 
```

## HOWTO use a private remote repo
change the CAPSTAN_REPO_URL env value

```
export CAPSTAN_REPO_URL=http://<my repo>
```

### HOWTO build unikernel images starting from MPM images
see [doc](https://production.eng.it/gitlab/5G-MEDIA/osv_composer/blob/master/runner)

### Inspired by [osv_builder](https://github.com/wkozaczuk/docker_osv_builder) and [osv_runner](https://github.com/wkozaczuk/docker_osv_runner) by [Waldemar Kozaczuk](wkozaczuk)

This container points to a specific OSv release and adds the patches necessary to make the native MPM compile without using the master branch
