#!/bin/bash
####################################
#
# Auto lemp install
#
####################################


# Maintainer:  Khaled AlHashem <kalhashem@naur.us>
# Version: 0.5
# Copy and paste the following line into your terminal to auto-start the installation
# yum -y update && curl -O https://raw.githubusercontent.com/khaledalhashem/lemp/master/lemp_centos.sh && chmod 0700 lemp_centos.sh && bash -x lemp_centos.sh 2>&1 | tee lemp.log

echo "LEMP Auto Installer `date`"
  echo "*************************************************"
  echo "* LEMP Auto Installer Started" $boldgreen
  echo "*************************************************"

startTime=$(date +%s)
wget='wget -qnc --tries=3'
pkgname='lemp'
nginxSrcDir='/usr/local/src/nginx'
phpSrcDir='/usr/local/src/php'
redisSrcDir='/usr/local/src/redis'
nginxVer='nginx-1.15.11' # [check nginx's site http://nginx.org/en/download.html for the latest version]
npsVer='1.13.35.2-stable' # [check https://www.modpagespeed.com/doc/release_notes for the latest version]
redisVer='redis-5.0.4'
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

# Setup Colours
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'

boldblack='\E[1;30;40m'
boldred='\E[1;31;40m'
boldgreen='\E[1;32;40m'
boldyellow='\E[1;33;40m'
boldblue='\E[1;34;40m'
boldmagenta='\E[1;35;40m'
boldcyan='\E[1;36;40m'
boldwhite='\E[1;37;40m'

useradd --system --home /dev/null --shell /sbin/nologin --comment "redis user" --user-group redis
usermod -aG nginx redis
yum -y install bzip2-devel libcurl-devel enchant-devel gmp-devel libc-client-devel libicu-devel aspell-devel libedit-devel net-snmp-devel libtidy-devel uw-imap-devel

if [ ! -d $redisSrcDir ]; then
  mkdir -p $redisSrcDir && cd $redisSrcDir
else cd $redisSrcDir
fi

if [ ! -f $redisVer.tar.gz ] && [ ! -d $redisVer ]; then
  $wget -O $redisVer.tar.gz http://download.redis.io/releases/$redisVer.tar.gz && tar -zxf $redisVer.tar.gz
elif [ ! -d $redisVer ]; then
  tar -zxf $redisVer
ele echo "File $redisVer already exists"
fi

if [ ! pwd == $redisVer ]; then
  cd $redisVer
else echo "Already in directory $redisVer"
fi

make -j $cpuNum
make install

mkdir /etc/redis
mkdir -p /var/redis
mkdir -p /var/run/redis
chown redis:nginx /var/run/redis
cp redis.conf /etc/redis

cat <<EOF >> /etc/systemd/system/redis.service
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always
Type=Forking

[Install]
WantedBy=multi-user.target
EOF

systemctl start redis
systemctl enable redis

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
--enable-redis \
--enable-ctype \
--enable-dom \
--enable-iconv \
--enable-JSON \
--enable-libxml \
--enable-posix \
--enable-session \
--enable-SimpleXML \
--enable-XMLReader \
--enable-XMLWriter \
--enable-zlib \
--enable-ldap \
--enable-imagik \
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
--enable-pdo_mysql \
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

$wget -O /usr/local/php/etc/php-fpm.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/php-fpm.conf

$wget -O /usr/local/php/etc/php-fpm.d/www.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/www.conf

$wget -O /usr/local/php/lib/php.ini https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/php.ini

$wget -O /usr/lib/systemd/system/php-fpm.service https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/php-fpm.service

mkdir -p /var/run/php-fpm/

cat <<EOF >> .bash_profile
PATH=$PATH:/usr/local/php/bin/
export PATH
PATH=$PATH:/usr/local/php/sbin/
export PATH
EOF

systemctl daemon-reload

systemctl start php-fpm && systemctl enable php-fpm

phpEndTime=$(date +%s)

cp /usr/local/php/bin/php /usr/sbin/php

cd

###
