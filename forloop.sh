#!/bin/bash

wget='wget -qnc --tries=3'
nginxSrcDir='/home/kalhashem/src/nginx'
phpSrcDir='/home/kalhashem/src/php'
osslSrcDir='/home/kalhashem/src/$(openssl)'
nginxVer='nginx-1.15.5' # [check nginx's site http://nginx.org/en/download.html for the latest version]
pcre='pcre-8.42'
zlib='zlib-1.2.11'
openssl='openssl-1.1.1'
fancyindex='0.4.3'
phpVer='php-7.2.11'

if [ ! -d $nginxSrcDir ]; then
    echo "Creating $nginxSrcDir"
    mkdir -p $nginxSrcDir && cd $nginxSrcDir
else [ -d $nginxSrcDir ];
    while true; do
	read -p "Do you wish to delete $nginxSrcDir?" yn
	case $yn in
	    [Yy]* ) make install; break;;
	    [Nn]* ) break;;
	    * ) echo "Please answer with yes or no.";;
	esac

    done
    echo "Directory $nginxSrcDir already exists"
fi

for i in $nginxVer $pcre $zlib $openssl v$fancyindex $phpVer
do
    if [ ! -f $i.tar.gz ] && [ ! -d $i ]; then
	echo "Downloading file $i now"
	$wget http://yellow.knaved.com/lemp/$i.tar.gz
	echo "Extracting file $i now"
	tar -zxf $i.tar.gz
    elif [ ! -d $i ]; then
	echo "Extracting file $i now"
	tar -zxf $i.tar.gz
    else echo "File name $i already exists"
    fi
done
