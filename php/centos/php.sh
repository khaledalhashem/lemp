#!/bin/bash
####################################
#
# Auto php install
#
####################################


# Maintainer:  Khaled AlHashem <kalhashem@naur.us>
# Version: 0.1
# Copy and paste the following line into your terminal to auto-start the installation
# yum -y update && curl -O https://raw.githubusercontent.com/khaledalhashem/lemp/master/lemp_centos.sh && chmod 0700 lemp_centos.sh && bash -x lemp_centos.sh 2>&1 | tee lemp.log

echo "php Auto Installer `date`"

startTime=$(date +%s)
wget='wget -qnc --tries=3'
pkgname='lemp'
nginxSrcDir='/usr/local/src/nginx'
phpSrcDir='/usr/local/src/php'
nginxVer='nginx-1.15.12' # [check nginx's site http://nginx.org/en/download.html for the latest version]
npsVer='1.13.35.2-stable' # [check https://www.modpagespeed.com/doc/release_notes for the latest version]
pkgdesc='Lightweight HTTP server and IMAP/POP3 proxy server, stable release'
arch=('i686' 'x86_64')
url='https://nginx.org'
license=('custom')
depends=('pcre' 'zlib' 'openssl')
pcre='pcre-8.42'
zlib='zlib-1.2.11'
openssl='openssl-1.1.1'
osslSrcDir='/usr/local/src/$openssl'
fancyindex='0.4.3'
phpVer='php-7.2.17'
cpuNum=$(cat /proc/cpuinfo | grep processor | wc -l)i

systemctl stop php-fpm
systemctl disable php-fpm

rm -rf /usr/local/src/php

# PHP installation

echo "LEMP Auto Installer `date`"

if [ ! -d $phpSrcDir ]; then
  mkdir -p $phpSrcDir && cd $phpSrcDir
else cd $phpSrcDir
fi

# PHP version PHP-7.2.11

if [ ! -f $phpVer.tar.gz ] && [ ! -d $phpVer ]; then
$wget -O $phpVer.tar.gz http://de2.php.net/get/$phpVer.tar.gz/from/this/mirror && tar -zxf $phpVer.tar.gz
elif [ ! -d $phpVer ]; then
  tar -zxf $phpVer.tar.gz
else echo "File $phpVer already exists"
fi

if [ ! pwd == $phpVer ]; then
  cd $phpVer
else echo "Already in directory $phpVer"
fi

./buildconf --force

./configure  \
--prefix=/usr/local/php \
--enable-fpm \
--enable-intl \
--enable-pcntl \
--with-mcrypt \
--with-snmp \
--with-mhash \
--with-zlib \
--with-gettext \
--enable-exif \
--enable-zip \
--with-bz2 \
--enable-soap \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-shmop \
--with-pear \
--enable-mbstring \
--with-openssl \
--with-mysql=mysqlnd \
--with-libdir=lib64 \
--with-mysqli=mysqlnd \
--with-mysql-sock=/var/lib/mysql/mysql.sock \
--with-curl \
--with-gd \
--with-xmlrpc \
--enable-bcmath \
--enable-calendar \
--enable-ftp \
--enable-gd-native-ttf \
--with-freetype-dir=/usr \
--with-jpeg-dir=/usr \
--with-png-dir=/usr \
--with-xpm-dir=/usr \
--with-vpx-dir=/usr \
--with-t1lib=/usr \
--enable-pdo \
--with-pdo-sqlite \
--with-pdo-mysql=mysqlnd \
--enable-inline-optimization \
--with-imap \
--with-imap-ssl \
--with-kerberos \
--with-readline \
--with-libedit \
--with-gmp \
--with-pspell \
--with-tidy \
--with-enchant \
--with-fpm-user=nginx \
--with-fpm-group=nginx \
--disable-fileinfo

make clean
make -j $cpuNum
make install

systemctl daemon-reload

systemctl start php-fpm && systemctl enable php-fpm

phpEndTime=$(date +%s)

cd
