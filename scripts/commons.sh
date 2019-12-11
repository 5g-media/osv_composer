#!/bin/bash

source $(dirname $0)/env.sh
OSV_BUILD=$OSV_ROOT/build/release

clean_osv() {
  cd "$OSV_ROOT"
  ./scripts/build clean
}

build_osv() {
  image="$1"
  export_mode="$2"
  usrskel="$3"

  echo "-------------------------------------"
  echo "- Building OSv image $image ...      "
  echo "-------------------------------------"

  mkdir -p $PACKAGES
  mkdir -p $OUTPUT
  
  cd "$OSV_ROOT"
  ./scripts/build -j4 image="$image" export="$export_mode" usrskel="$usrskel"

  echo "-------------------------------------"
  echo "- Built OSv image $image             "
  echo "-------------------------------------"
}

prepare_package() {
  package_name="$1"
  title="$2"
  version="$3"
  dependency="$4"

  rm -rf $PACKAGES/$package_name
  mkdir -p $PACKAGES/$package_name
  #FIX
  #mkdir -p $OUTPUT/$package_name
  if [ "$dependency" == "" ]
  then
    cd $PACKAGES/$package_name && $CAPSTAN package init --name "$package_name" --title "$title" --author "$AUTHOR" --version "$version"
  else
    cd $PACKAGES/$package_name && $CAPSTAN package init --name "$package_name" --title "$title" --author "$AUTHOR" --version "$version" --require "$dependency"
  fi
  cp $PACKAGES/$package_name/meta/package.yaml $OUTPUT/${package_name}.yaml
  cp -rf $OSV_ROOT/build/export/. $PACKAGES/$package_name
}

#UNUSED
set_package_command_line() {
  package_name="$1"
  command_line="$2"
  mkdir -p $PACKAGES/$package_name/meta
  cat << EOF > $PACKAGES/$package_name/meta/run.yaml
runtime: native
config_set:
  default:
    bootcmd: "$command_line"
config_set_default: default
EOF
}

build_package() {
  package_name="$1"
  cd $PACKAGES/$package_name && $CAPSTAN package build
  mv $PACKAGES/$package_name/$package_name.mpm $OUTPUT && rm -rf $PACKAGES/$package_name

  echo "-------------------------------------"
  echo "- Built package $package_name        "
  echo "-------------------------------------"
  
  cp $OUTPUT/$package_name.* /root/.capstan/packages
}

build_osv_loader_and_bootstrap_package() {
  #Build osv.loader and files that will make up bootstrap package
  build_osv empty all default

  #Copy loader.img as osv-loader.qemu
  mkdir -p $PACKAGES/osv.loader
  cp $OSV_BUILD/loader.img $PACKAGES/osv.loader/osv-loader.qemu
  mkdir -p $CAPSTAN_LOCAL_REPO/repository/mike/osv-loader/
  cp $PACKAGES/osv.loader/osv-loader.qemu $CAPSTAN_LOCAL_REPO/repository/mike/osv-loader/
  cp $PACKAGES/osv.loader/osv-loader.qemu $OUTPUT
  
  #FIX - add index.yaml
  echo "Description: OSv Bootloader" > $CAPSTAN_LOCAL_REPO/repository/mike/osv-loader/index.yaml
  echo "format_version: 1" >> $CAPSTAN_LOCAL_REPO/repository/mike/osv-loader/index.yaml
  echo "version: v0.53.0" >> $CAPSTAN_LOCAL_REPO/repository/mike/osv-loader/index.yaml
  echo "created: 2018-10-19 11:11" >> $CAPSTAN_LOCAL_REPO/repository/mike/osv-loader/index.yaml
  echo "platform: Fedora-23" >> $CAPSTAN_LOCAL_REPO/repository/mike/osv-loader/index.yaml
  
  #FIX cleanup
  rm -f /root/.capstan/packages
  mkdir -p /root/.capstan/packages

  #Create bootstrap package
  prepare_package "osv.bootstrap" "OSv Bootstrap" "$OSV_VERSION"
  rm $PACKAGES/osv.bootstrap/tools/mount-nfs.so
  rm $PACKAGES/osv.bootstrap/tools/umount.so
  build_package "osv.bootstrap"
}

build_run_java_package() {
  build_osv "java-non-isolated" all none
  prepare_package "osv.run-java" "Run Java apps" "$OSV_VERSION"
  build_package "osv.run-java"
}

#UNUSED build_run_go_package() {

#UNUSED build_openjdk8-compact_profile_package() {

#UNUSED build_openjdk8-zulu-compact3-with-java-beans_package() {

build_openjdk8-full_package() {
  version="$1"
  package_name="osv.openjdk8-zulu-full"
  build_osv "openjdk8-zulu-full" selected none
  prepare_package "$package_name" "Zulu Open JDK 8" "$version" "osv.run-java"

  #FIX
  cd $OSV_ROOT/modules/ca-certificates && make

  cd $PACKAGES/${package_name} && cp $OSV_ROOT/modules/ca-certificates/build/etc/pki/ca-trust/extracted/java/cacerts usr/lib/jvm/jre/lib/security/
  build_package "$package_name"
}

#UNUSED build_openjdk10-java-base_package() {
build_httpserver_api_package() {
  build_osv "httpserver-api.fg" all none
  prepare_package "osv.httpserver-api" "OSv httpserver with APIs (backend)" "$OSV_VERSION"
  #rm $PACKAGES/osv.httpserver-api/usr/mgmt/plugins/libhttpserver-api_app.so  
  build_package "osv.httpserver-api"
}

build_httpserver_html5_gui_package() {
  build_osv "httpserver-html5-gui" selected none
  prepare_package "osv.httpserver-html5-gui" "OSv HTML5 GUI (frontend)" "$OSV_VERSION" "osv.httpserver-api"
  rm -rf $PACKAGES/osv.httpserver-html5-gui/init/
  set_package_command_line "osv.httpserver-html5-gui" "/libhttpserver-api.so"
  build_package "osv.httpserver-html5-gui"
}

build_httpserver_html5_cli_package() {
  build_osv "httpserver-html5-cli" selected none
  prepare_package "osv.httpserver-html5-cli" "OSv HTML5 Terminal (frontend)" "$OSV_VERSION" "osv.httpserver-api"
  rm -rf $PACKAGES/osv.httpserver-html5-cli/init/
  set_package_command_line "osv.httpserver-html5-cli" "/libhttpserver-api.so"
  build_package "osv.httpserver-html5-cli"
}

build_node_package() {
  build_osv "node" all none
  prepare_package "osv.node-js" "Node JS" "8.11.2"
  build_package "osv.node-js"
}

build_cli_package() {
  apt-get install -y openssl1.0 libssl1.0-dev
  build_osv "cli" all none
  apt-get install -y libssl-dev node-gyp nodejs-dev npm
  prepare_package "osv.cli" "Command Line" "$OSV_VERSION" "osv.httpserver-api"
  set_package_command_line "osv.cli" "/cli/cli.so"
  build_package "osv.cli"
}

#UNUSED build_lighttpd_package() {
#UNUSED build_iperf_package() {
#UNUSED build_netperf_package() {
#UNUSED build_redis_package() {
#UNUSED build_memcached_package() {
#UNUSED build_mysql_package() {




build_generic_app_package() {
  app_name="$1"
  version="$2"
  command_line="$3"
  build_osv "$app_name" selected none
  prepare_package "osv.$app_name" "$app_name" "$version"
  set_package_command_line "osv.$app_name" "$command_line"
  build_package "osv.$app_name"
}

#UNUSED build_generic_lib_package() {

#ADDED
build_python_package() {
  build_osv "python" all none
  prepare_package "osv.python" "Python" "2.7.15"
  build_package "osv.python"
}

#ADDED - actually only a download, as the build fails. The website is https://github.com/cloudius-systems/osv/releases/tag/v0.53.0
build_python3_package() {
  wget https://github.com/cloudius-systems/osv/releases/download/v0.53.0/osv.python3x.mpm
  wget https://github.com/cloudius-systems/osv/releases/download/v0.53.0/osv.python3x.yaml
  mv osv.python3x.* /root/.capstan/packages
}


#ADDED
build_nginx_package() {
  #FIX
  sed -i 's/VERSION=1.12.2/VERSION=1.14.2/g' $OSV_ROOT/apps/nginx/Makefile

  build_osv "nginx" all none
  prepare_package "osv.nginx" "NGINX" "1.14.2"
  set_package_command_line "osv.nginx" "/nginx.so -c /nginx/conf/nginx.conf"
  build_package "osv.nginx"
}

#ADDED
build_haproxy_package() {
  build_osv "haproxy" all none
  prepare_package "osv.haproxy" "HAPROXY" "1.5.8"
  set_package_command_line "osv.haproxy" "/haproxy.so -c /haproxy/conf/haproxy.conf"
  build_package "osv.haproxy"
}

#ADDED
build_ffmpeg_package() {
  cd /osv

  #FIX
  sed -i 's/strip ROOTFS/#strip ROOTFS/g' $OSV_ROOT/apps/ffmpeg/Makefile

  #install x265-devel on Fedora29
  #wget http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-29.noarch.rpm
  #yes | rpm -Uvh rpmfusion-free-release-29.noarch.rpm 
  #dnf install -y x265-devel
  #sed -i 's/--disable-ffplay --disable-ffprobe/--disable-ffprobe --disable-ffplay --enable-libx265 --enable-gpl/g' $OSV_ROOT/apps/ffmpeg/Makefile

  build_osv "ffmpeg" all none
  prepare_package "osv.ffmpeg" "FFMPEG" "4.0.2"
  set_package_command_line "osv.ffmpeg" "/ffmpeg.so -c /ffmpeg/conf/ffmpeg.conf"
  build_package "osv.ffmpeg"
}


