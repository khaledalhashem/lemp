#!/bin/bash

wget='wget -qnc --tries=3'
nginxSrcDir='/home/kalhashem/src/nginx'
phpSrcDir='/home/kalhashem/src/php'
osslSrcDir='/home/kalhashem/src/$(openssl)'
nginxVer='nginx-1.15.5' # [check nginx's site http://nginx.org/en/download.html for the latest version]
npsVer='1.13.35.2-stable' # [check https://www.modpagespeed.com/doc/release_notes for the latest version]
arch=('i686' 'x86_64')
pcre='pcre-8.42'
zlib='zlib-1.2.11'
openssl='openssl-1.1.1'
fancyindex='0.4.3'
phpVer='php-7.2.11'

if [ ! -d $nginxSrcDir ]; then
    echo "Creating $nginxSrcDir"
  mkdir -p $nginxSrcDir && cd $nginxSrcDir
else cd $nginxSrcDir
  echo "Directory $nginxSrcDir already exists"
fi

for i in $nginxVer $pcre $zlib $openssl v$fancyindex $phpVer
do
    if [ ! -f $i.tar.gz ] && [ ! -d $i ]; then
	echo "Downloading file $i now"
  # Nginx version nginx-1.15.5
	$wget http://yellow.knaved.com/lemp/$i.tar.gz
	echo "Extracting file $i now"
	tar -zxf $i.tar.gz
    elif [ ! -d $i ]; then
	echo "Extracting file $i now"
    tar -zxf $i.tar.gz
  else echo "File name $i already exists"
  fi
done
