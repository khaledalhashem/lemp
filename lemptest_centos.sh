#!/bin/bash
####################################
#
# Auto lemp install
#
####################################


# Maintainer:  Khaled AlHashem <kalhashem@naur.us>
# Version: 0.2
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
osslSrcDir='/usr/local/src/$(openssl)'
nginxVer='nginx-1.15.6' # [check nginx's site http://nginx.org/en/download.html for the latest version]
npsVer='1.13.35.2-stable' # [check https://www.modpagespeed.com/doc/release_notes for the latest version]
pkgdesc='Lightweight HTTP server and IMAP/POP3 proxy server, stable release'
arch=('i686' 'x86_64')
url='https://nginx.org'
license=('custom')
depends=('pcre' 'zlib' 'openssl')
pcre='pcre-8.42'
zlib='zlib-1.2.11'
openssl='openssl-1.1.1'
fancyindex='0.4.3'
phpVer='php-7.2.12'
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

export LC_ALL="en_US.UTF-8"

yum grouplist
yum groupinstall -y 'Development Tools'
yum --enablerepo=extras install -y epel-release
yum --enablerepo=base clean metadata
# yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"
yum -y update && yum -y install pcre-devel zlib-devel libuuid-devel perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2-devel gd gd-devel GeoIP-devel openssl-devel
yum -y install yum-utils
useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx

# Create the source building directory and cd into it
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
  echo "File name v${npsVer} already exists"
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

# Build latest OpenSSL from source

if [ ! -d $osslSrcDir ]; then
  mkdir -p $osslSrcDir && cd $osslSrcDir
  $wget https://www.openssl.org/source/$openssl.tar.gz && tar -xzf $openssl.tar.gz
else cd $osslSrcDir
  echo "File $phpVer.tar.gz already exists"
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
            --build=CentOS \
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

$wget -O /usr/lib/systemd/system/nginx.service https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/nginx.service

$wget -O /etc/init.d/nginx https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/centos/init.d

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && $wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/centos/nginx.conf

ln -s /usr/lib64/nginx/modules /etc/nginx/modules

$wget -O /etc/nginx/dynamic-modules.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/dynamic-modules.conf

mkdir -p /etc/nginx/conf.d /usr/share/nginx/html /var/www
chown -R nginx:nginx /usr/share/nginx/html /var/www
find /usr/share/nginx/html /var/www -type d -exec chmod 755 {} \;
find /usr/share/nginx/html /var/www -type f -exec chmod 644 {} \;

$wget -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/default.conf

$wget -O /etc/nginx/conf.d/example.com_conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/example.com.conf

mkdir -p /var/cache/nginx && nginx -t

cp /etc/nginx/html/* /usr/share/nginx/html/

systemctl start nginx.service && systemctl enable nginx.service

rm -rf /etc/nginx/koi-utf /etc/nginx/koi-win /etc/nginx/win-utf

rm -rf /etc/nginx/*.default

mkdir -p /var/ngx_pagespeed_cache
chown -R nobody:nobody /var/ngx_pagespeed_cache

systemctl restart nginx.service

mkdir ~/.vim/
cp -r $nginxSrcDir/$nginxVer/contrib/vim/* ~/.vim/

nginxEndTime=$(date +%s)

###
# PHP installation

echo "LEMP Auto Installer `date`"
  echo "*************************************************"
  echo "* LEMP Auto Installer PHP" $boldgreen
  echo "*************************************************"

yum -y install bzip2-devel libcurl-devel enchant-devel gmp-devel libc-client-devel libicu-devel aspell-devel libedit-devel net-snmp-devel libtidy-devel uw-imap-devel

if [ ! -d $phpSrcDir ]; then
  mkdir -p $phpSrcDir && cd $phpSrcDir
else cd $phpSrcDir
fi

# PHP version PHP-7.2.11

if [ ! -f $phpVer.tar.gz ] && [ ! -d $phpVer ]; then
  $wget http://yellow.knaved.com/lemp/$phpVer.tar.gz && tar -zxf $phpVer.tar.gz
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

cd

###
# MariaDB Install

echo "LEMP Auto Installer `date`"
  echo "*************************************************"
  echo "* LEMP Auto Installer MariaDB" $boldgreen
  echo "*************************************************"

cat <<EOF >> /etc/yum.repos.d/MariaDB.repo
# MariaDB 10.3 CentOS repository list
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

yum -y install MariaDB-server MariaDB-client

systemctl start mariadb
systemctl enable mariadb

mdbEndTime=$(date +%s)
totalEndTime=$(date +%s)

/usr/bin/mysql_secure_installation

nginxElapsedTime=$(($nginxEndTime - $startTime))
phpElapsedTime=$(($phpEndTime - $nginxEndTime))
mdbElapsedTime=$(($mdbEndTime - $phpEndTime))
totalElapsedTime=$(($totalEndTime - $startTime))

cat << EOF

************************************************************************************
------------------------------------------------------------------------------------

Installation of LEMP stack has finished in $(($totalElapsedTime/60)) mins and $(($totalElapsedTime%60)) secs.
It took $(($nginxElapsedTime/60)) mins and $(($nginxElapsedTime%60)) secs to complete nginx Installation.
It took $(($phpElapsedTime/60)) mins and $(($phpElapsedTime%60)) secs to complete php Installation.
It took $(($mdbElapsedTime/60)) mins and $(($mdbElapsedTime%60)) secs to complete mariadb Installation.

************************************************************************************
------------------------------------------------------------------------------------

EOF

mysql -V

nginx -V

/usr/local/php/bin/php -v
