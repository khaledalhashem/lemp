#!/bin/bash
####################################
#
# Auto lemp install
#
####################################


# Maintainer:  Khaled AlHashem <kalhashem@naur.us>
# Version: 0.2
# Copy and paste the following line into your cosole to auto-start the installation
# yum -y update && curl -O https://raw.githubusercontent.com/khaledalhashem/lemp/master/lemp_centos.sh && chmod 0700 lemp_centos.sh && bash -x lemp_centos.sh 2>&1 | tee lemp.log

pkgname='lemp'
nginxSrcDir='/usr/local/src/nginx'
phpSrcDir='/usr/local/src/php'
nginxVersion='nginx-1.15.5' # [check nginx's site http://nginx.org/en/download.html for the latest version]
npsVersion='1.13.35.2-stable' # [check https://www.modpagespeed.com/doc/release_notes for the latest version]
pkgdesc='Lightweight HTTP server and IMAP/POP3 proxy server, stable release'
arch=('i686' 'x86_64')
url='https://nginx.org'
license=('custom')
depends=('pcre' 'zlib' 'openssl')
pcre='pcre-8.42'
zlib='zlib-1.2.11'
openssl='openssl-1.1.1'
fancyindex='0.4.3'
phpVersion='php-7.2.11'

# # try various methods, in order of preference, to detect distro
# # store result in variable '$distro'
# if type lsb_release >/dev/null 2>&1 ; then
   # distro=$(lsb_release -i -s)
# elif [ -e /etc/os-release ] ; then
   # distro=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
# elif [ -e /etc/some-other-release-file ] ; then
   # distro=$(ihavenfihowtohandleotherhypotheticalreleasefiles)
# fi

# # convert to lowercase
# distro=$(printf '%s\n' "$distro" | LC_ALL=C tr '[:upper:]' '[:lower:]')

# # now do different things depending on distro
# case "$distro" in
   # debian*)  commands-for-debian ;;
   # centos*)  commands-for-centos ;;
   # ubuntu*)  commands-for-ubuntu ;;
   # mint*)    commands-for-mint ;;
   # *)        echo "unknown distro: '$distro'" ; exit 1 ;;
# esac

yum groupinstall -y 'Development Tools'
yum -y update && yum -y install wget gcc-c++ pcre-devel zlib-devel make libuuid-devel perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel GeoIP GeoIP-devel unzip openssl-devel
yum -y install yum-utils
useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx

# Create the source building directory and cd into it
mkdir $nginxSrcDir && cd $nginxSrcDir

# pagespeed version 1.13.35.2-stable
wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${npsVersion}.zip
unzip v${npsVersion}.zip
nps_dir=$(find . -name "*pagespeed-ngx-${npsVersion}" -type d)
cd "$nps_dir"
NPS_RELEASE_NUMBER=${npsVersion/beta/}
NPS_RELEASE_NUMBER=${npsVersion/stable/}
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget ${psol_url}
tar -xzvf $(basename ${psol_url})  # extracts to psol/

cd $nginxSrcDir

# Nginx version nginx-1.13.10
wget -c http://nginx.org/download/$nginxVersion.tar.gz --tries=3 && tar -zxf $nginxVersion.tar.gz

# PCRE version 8.40
wget -c https://ftp.pcre.org/pub/pcre/$pcre.tar.gz --tries=3 && tar -xzf $pcre.tar.gz

# zlib version 1.2.11
wget -c https://www.zlib.net/$zlib.tar.gz --tries=3 && tar -xzf $zlib.tar.gz

# OpenSSL version 1.1.0f
wget -c https://www.openssl.org/source/$openssl.tar.gz --tries=3 && tar -xzf $openssl.tar.gz

# ngx_fancyindex 0.4.2
wget -c https://github.com/aperezdc/ngx-fancyindex/archive/v$fancyindex.tar.gz --tries=3 && tar -zxf v$fancyindex.tar.gz

rm -rf *.gz

cd $nginxSrcDir/$nginxVersion

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
            --builddir=$nginxVersion \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
	    --add-module=../incubator-pagespeed-ngx-$npsVersion \
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

make
make install

wget -O /usr/lib/systemd/system/nginx.service https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/nginx.service --tries=3 && chmod +x /usr/lib/systemd/system/nginx.service

wget -O /etc/init.d/nginx https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/centos/nginx_init.d_script_centos --tries=3 && chmod +x /etc/init.d/nginx

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/centos/nginx.conf --tries=3

ln -s /usr/lib64/nginx/modules /etc/nginx/modules

wget -O /etc/nginx/dynamic-modules.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/dynamic-modules.conf --tries=3

mkdir -p /etc/nginx/conf.d /usr/share/nginx/html /var/www
chown -R nginx:nginx /usr/share/nginx/html /var/www
find /usr/share/nginx/html /var/www -type d -exec chmod 755 {} \;
find /usr/share/nginx/html /var/www -type f -exec chmod 644 {} \;

wget -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/default.conf --tries=3

wget -O /etc/nginx/conf.d/example.com_conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/nginx/example.com.conf --tries=3

mkdir -p /var/cache/nginx && nginx -t

cp /etc/nginx/html/* /usr/share/nginx/html/

systemctl start nginx.service && systemctl enable nginx.service

rm -rf /etc/nginx/koi-utf /etc/nginx/koi-win /etc/nginx/win-utf

rm -rf /etc/nginx/*.default

mkdir -p /var/ngx_pagespeed_cache
chown -R nobody:nobody /var/ngx_pagespeed_cache

systemctl restart nginx

mkdir ~/.vim/
cp -r $nginxSrcDir/$nginxVersion/contrib/vim/* ~/.vim/

nginx -V

###

yum -y install openssl-devel bzip2-devel libcurl-devel enchant-devel gmp-devel libc-client-devel libicu-devel aspell-devel libedit-devel net-snmp-devel libtidy-devel

mkdir $phpSrcDir && cd $phpSrcDir

# PHP version PHP-7.2.11
wget -c http://yellow.knaved.com/$phpVersion.tar.gz --tries=3 && tar -zxf $phpVersion.tar.gz

cd $phpVersion


./buildconf --force

./configure  \
--prefix=/usr/local/php
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
make
make install
	
wget -O /usr/local/php/etc/php-fpm.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/php-fpm.conf --tries=3

wget -O /usr/local/php/etc/php-fpm.d/www.conf https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/www.conf --tries=3

wget -O /usr/lib/systemd/system/php-fpm.service https://raw.githubusercontent.com/khaledalhashem/lemp/master/php/centos/php-fpm.service --tries=3

mkdir -p /var/run/php-fpm/

systemctl start php-fpm && systemctl enable php-fpm
