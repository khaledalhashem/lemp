#!/bin/bash
####################################
#
# Auto nginx_custom install
#
####################################


# Maintainer:  Khaled AlHashem <one@naur.us>
# Version: 0.2
# Copy and paste the following line into your console to auto-start the installation
# curl -O https://raw.githubusercontent.com/khaledalhashem/lemp/master/lemp_ubuntu.sh && chmod 0700 lemp_ubuntu.sh && bash -x lemp_ubuntu.sh 2>&1 | tee lemp_custom.log

echo "LEMP Auto Installer `date`"
  echo "*************************************************"
  echo "* LEMP Auto Installer Started" $boldgreen
  echo "*************************************************"

startTime=$(date +%s)
wget='wget -qnc --tries=3'
pkgname='lemp'
nginxSrcDir='/usr/local/src/nginx'
phpSrcDir='/usr/local/src/php'
osslSrcDir='/usr/local/src/openssl'
nginxVer='nginx-1.17.3' # [check nginx's site http://nginx.org/en/download.html for the latest version]
npsVer='1.13.35.2-stable' # [check https://www.modpagespeed.com/doc/release_notes for the latest version]
pkgdesc='Lightweight HTTP server and IMAP/POP3 proxy server, stable release'
arch=('i686' 'x86_64')
url='https://nginx.org'
license=('custom')
depends=('pcre' 'zlib' 'openssl')
pcre='pcre-8.42'
zlib='zlib-1.2.11'
openssl='openssl-1.1.1c'
frickle='2.3'
fancyindex='0.4.3'
phpVer='php-7.3.7'
cpuNum=$(cat /proc/cpuinfo | grep processor | wc -l)

boldgreen='\E[1;32;40m'

export LC_ALL="en_US.UTF-8"

apt-get update && apt-get -y upgrade
apt-get -y install build-essential
apt-get -y install wget zlib1g-dev libpcre3 libpcre3-dev uuid-dev perl perl-modules libxslt-dev libgd-dev libgeoip-dev unzip autoconf

apt-get -y install software-properties-common

## Ubuntu Bionic Mariadb Repo's

# apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
# add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirrors.n-ix.net/mariadb/repo/10.4/ubuntu bionic main'

## Debian Buster Mariadb Repo's

apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64] http://mirrors.n-ix.net/mariadb/repo/10.4/debian buster main'

apt-get update

useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx

# Create the source building directory and cd into it

if [ ! -d $nginxSrcDir ]; then
  mkdir -p $nginxSrcDir && cd $nginxSrcDir
else cd $nginxSrcDir
  echo "Directory $nginxSrcDir already exists"
fi

# pagespeed version 1.13.35.2-stable
if [ ! -f v${npsVer}.zip ] || [ ! -d $nps_dir ]; then
    $wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${npsVer}.zip
    unzip v${npsVer}.zip
    nps_dir=$(find . -name "*pagespeed-ngx-${npsVer}" -type d)
    cd "$nps_dir"
    NPS_RELEASE_NUMBER=${npsVer/beta/}
    NPS_RELEASE_NUMBER=${npsVer/stable/}
    psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
    $wget ${psol_url}
    tar -xzvf $(basename ${psol_url})  # extracts to psol/
else cd $nginxSrcDir
     echo "File name v{npsVer} already exists"
fi

if [ ! pwd == $nginxSrcDir ]; then
    cd $nginxSrcDir
else echo "Already in $nginxSrcDir"
fi

# Nginx version nginx-1.15.5
$wget -c http://nginx.org/download/$nginxVer.tar.gz --tries=3 && tar -zxf $nginxVer.tar.gz

# PCRE version 8.42
$wget -c https://ftp.pcre.org/pub/pcre/$pcre.tar.gz --tries=3 && tar -xzf $pcre.tar.gz

# zlib version 1.2.12
$wget -c https://www.zlib.net/$zlib.tar.gz --tries=3 && tar -xzf $zlib.tar.gz

# OpenSSL version 1.1.1
$wget -c https://www.openssl.org/source/$openssl.tar.gz --tries=3 && tar -xzf $openssl.tar.gz

#Frickle version 2.3
$wget -c https://github.com/FRiCKLE/ngx_cache_purge/archive/$frickle.tar.gz --tries=3 && tar -xzf 2.3.tar.gz

# ngx_fancyindex 0.4.3
$wget -c https://github.com/aperezdc/ngx-fancyindex/archive/v$fancyindex.tar.gz --tries=3 && tar -zxf v$fancyindex.tar.gz
if [ ! -f $nginxVer.tar.gz ] && [ ! -d $nginxVer ]; then
  # Nginx version nginx-1.15.5
  $wget http://nginx.org/download/$nginxVer.tar.gz && tar -zxf $nginxVer.tar.gz
elif [ ! -d $nginxVer ]; then
  tar -zxf $nginxVer.tar.gz
else echo "File name $nginxVer already exists"
fi

if [ ! -f $pcre.tar.gz ] && [ ! -d $pcre ]; then
  # PCRE version 8.42
  $wget https://ftp.pcre.org/pub/pcre/$pcre.tar.gz && tar -xzf $pcre.tar.gz
elif [ ! -d $pcre ]; then
  tar -xzf $pcre.tar.gz
else echo "File name $pcre already exists"
fi

if [ ! -f $zlib.tar.gz ] && [ ! -d $zlib ]; then
  # zlib version 1.2.11
  $wget https://www.zlib.net/$zlib.tar.gz && tar -xzf $zlib.tar.gz
elif [ ! -d $zlib ]; then
  tar -xzf $zlib.tar.gz
else echo "File name $zlib already exists"
fi

if [ ! -f $openssl.tar.gz ] && [ ! -d $openssl ]; then
  # OpenSSL version 1.1.1
  $wget https://www.openssl.org/source/$openssl.tar.gz && tar -xzf $openssl.tar.gz
elif [ ! -d $openssl ]; then
  tar -xzf $openssl.tar.gz
else echo "File name $openssl already exists"
fi

if [ ! -f v$fancyindex.tar.gz ] && [ ! -d v$fancyindex ]; then
  # ngx_fancyindex 0.4.3
  $wget https://github.com/aperezdc/ngx-fancyindex/archive/v$fancyindex.tar.gz && tar -zxf v$fancyindex.tar.gz
elif [ ! -d v$fancyindex ]; then
  tar -zxf v$fancyindex.tar.gz
else echo "File name $fancyindex already exists"
fi

# Build latest OpenSSL from source

if [ ! -d $osslSrcDir ]; then
  mkdir -p $osslSrcDir && cd $osslSrcDir
else cd $osslSrcDir
  echo "Directory $nginxSrcDir already exists"
fi

./configure
# ./Configure linux-x86_64 --prefix=/usr/local --openssldir=/usr/local
make -j $cpuNum
make install

export LD_LIBRARY_PATH=/usr/local/lib

if [ ! pwd == $nginxSrcDir/$nginxVer ]; then
cd $nginxSrcDir/$nginxVer
else echo "Already in $nginxSrcDir/$nginxVer"
fi

./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib64/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --build=Debian \
            --builddir=$nginxVer \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
	    --add-module=../incubator-pagespeed-ngx-$npsVer \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
	    --add-dynamic-module=../ngx-fancyindex-$fancyindex \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-pcre=../$pcre \
            --with-pcre-jit \
            --with-zlib=../$zlib \
            --with-openssl=../$openssl \
            --with-openssl-opt=no-nextprotoneg

make -j $cpuNum
make install

$wget -O /etc/init.d/nginx https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/ubuntu/init.d --tries=3

$wget -O /lib/systemd/system/nginx.service https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/nginx.service --tries=3

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && $wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/ubuntu/nginx.conf --tries=3

ln -s /usr/lib64/nginx/modules /etc/nginx/modules

$wget -O /etc/nginx/dynamic-modules.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/dynamic-modules.conf --tries=3

mkdir -p /etc/nginx/{sites-available,sites-enabled} /usr/share/nginx/html /var/www
chown -R nginx:nginx /usr/share/nginx/html /var/www
find /usr/share/nginx/html /var/www -type d -exec chmod 755 {} \;
find /usr/share/nginx/html /var/www -type f -exec chmod 644 {} \;

$wget -O /etc/nginx/sites-available/default.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/default.conf --tries=3

$wget -O /etc/nginx/sites-available/example.com.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/example.com.conf --tries=3

cp /etc/nginx/html/* /usr/share/nginx/html/

systemctl daemon-reload

mkdir -p /var/cache/nginx && nginx -t

systemctl start nginx.service && systemctl enable nginx.service

rm -rf /etc/nginx/koi-utf /etc/nginx/koi-win /etc/nginx/win-utf

rm -rf /etc/nginx/*.default

mkdir -p /var/ngx_pagespeed_cache
chown -R nobody:nogroup /var/ngx_pagespeed_cache

#wget -O /usr/share/nginx/html http://gb.naur.us/html.tar.gz && tar -zxf /usr/share/nginx/html/html.tar.gz && mv /usr/share/nginx/html/html* /usr/share/nginx/html && rm -rf /usr/share/nginx/html/html*

systemctl restart nginx

mkdir ~/.vim/
cp -r $nginxSrcDir/$nginxVer/contrib/vim/* ~/.vim/

nginxEndTime=$(date +%s)

###
# PHP installation

echo "LEMP Auto Installer `date`"
  echo "*************************************************"
  echo "* LEMP Auto Installer PHP" $boldgreen
  echo "*************************************************"

apt install -y libbz2-dev libcurl4-openssl-dev libenchant-dev libgmp3-dev libc-client2007e-dev libpspell-dev libedit-dev libsnmp-dev libtidy-dev libzip-dev libkrb5-dev
  
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

$wget -O /usr/local/php/etc/php-fpm.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/php-fpm.conf

$wget -O /usr/local/php/etc/php-fpm.d/www.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/www.conf

$wget -O /usr/local/php/lib/php.ini https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/php.ini

# $wget -O /usr/lib/systemd/system/php-fpm.service https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/php-fpm.service

cp /usr/local/src/php/php-7.3.7/sapi/fpm/php-fpm.service /etc/systemd/system/

# mkdir -p /var/run/php-fpm/

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

###
# MariaDB Install

echo "LEMP Auto Installer `date`"
  echo "*************************************************"
  echo "* LEMP Auto Installer MariaDB" $boldgreen
  echo "*************************************************"

apt install -y mariadb-server

systemctl start mysql.service
systemctl enable mysql.service

/usr/bin/mysql_secure_installation
