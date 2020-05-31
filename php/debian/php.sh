#!/bin/bash
####################################
#
# Auto LEMP custom install
#
####################################


# Maintainer:  Khaled AlHashem <one@naur.us>
# Version: 0.2
# Copy and paste the following line into your console to auto-start the installation
# curl -O https://raw.githubusercontent.com/khaledalhashem/lemp/master/lemp_ubuntu.sh && chmod 0700 lemp_ubuntu.sh && bash -x lemp_ubuntu.sh 2>&1 | tee lemp_custom.log

echo "LEMP Auto Installer `date`"

startTime=$(date +%s)
wget='wget -qnc --tries=3'
pkgname='lemp'
nginxSrcDir='/usr/local/src/nginx'
phpSrcDir='/usr/local/src/php'
nginxVer='nginx-1.18.0' # [check nginx's site http://nginx.org/en/download.html for the latest version]
npsVer='1.13.35.2-stable' # [check https://www.modpagespeed.com/doc/release_notes for the latest version]
pkgdesc='Lightweight HTTP server and IMAP/POP3 proxy server, stable release'
arch=('i686' 'x86_64')
url='https://nginx.org'
license=('custom')
depends=('pcre' 'zlib' 'openssl')
pcre='pcre-8.44'
zlib='zlib-1.2.11'
openssl='openssl-1.1.1g'
osslSrcDir='/usr/local/src/openssl'
frickle='2.3'
fancyindex='0.4.3'
phpVer='php-7.3.18'
cpuNum=$(cat /proc/cpuinfo | grep processor | wc -l)

boldgreen='\E[1;32;40m'

apt-get update

# PHP installation

echo "PHP Auto Installer `date`"
  
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

ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a

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
--with-mime-magic \
--enable-soap \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-shmop \
--with-pear \
--enable-mbstring \
--with-openssl=/usr/local/ssl \
--with-mysql=mysqlnd \
--with-libdir=lib \
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

make clean
make -j $cpuNum
make install
