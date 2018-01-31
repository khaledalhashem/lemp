#!/bin/bash
####################################
#
# Auto nginx_custom install
#
####################################


# Maintainer:  Khaled AlHashem <kalhashem@naur.us>
# Version: 0.01
# For Ubuntu
# curl -O https://raw.githubusercontent.com/khaledalhashem/nginx_custom/master/nginx_custom_ubuntu.sh && chmod 0700 nginx_custom_ubuntu.sh && bash -x nginx_custom_ubuntu.sh 2>&1 | tee nginx_custom.log

pkgname='nginx_custom'
srcdir='/usr/local/src/nginx'
# [check nginx's site http://nginx.org/en/download.html for the latest version]
ngxver='nginx-1.12.2'
# [check https://www.modpagespeed.com/doc/release_notes for the latest version]
nps='1.12.34.2-stable'
nps_psol='1.12.34.2'
pkgdesc='Lightweight HTTP server and IMAP/POP3 proxy server, stable release'
arch=('i686' 'x86_64')
url='https://nginx.org'
license=('custom')
depends=('pcre' 'zlib' 'openssl')
pcre='pcre-8.41'
zlib='zlib-1.2.11'
openssl='openssl-1.1.0g'
frickle='2.3'
fancyindex='0.4.2'

apt-get update && apt-get -y upgrade
apt-get -y install build-essential
apt-get -y install wget perl perl-modules libxslt-dev libgd-dev libgeoip-dev

apt-get install software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.jmu.edu/pub/mariadb/repo/10.1/ubuntu xenial main'

apt update -y

useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx

# Create the source building directory and cd into it
mkdir $srcdir && cd $srcdir

# Nginx version 1.12.1
wget -c http://nginx.org/download/$ngxver.tar.gz --tries=3 && tar -zxf $ngxver.tar.gz

# pagespeed version 1.12.34.2
wget -c https://github.com/pagespeed/ngx_pagespeed/archive/v$nps.tar.gz --tries=3 && tar -zxf v$nps.tar.gz

cd incubator-pagespeed-ngx-$nps/
# psol version 1.12.34.2
wget -c https://dl.google.com/dl/page-speed/psol/$nps_psol-x64.tar.gz --tries=3 && tar -zxf $nps_psol-x64.tar.gz && rm -rf $nps_psol-x64.tar.gz

cd $srcdir

# PCRE version 8.40
wget -c https://ftp.pcre.org/pub/pcre/$pcre.tar.gz --tries=3 && tar -xzf $pcre.tar.gz

# zlib version 1.2.11
wget -c https://www.zlib.net/$zlib.tar.gz --tries=3 && tar -xzf $zlib.tar.gz

# OpenSSL version 1.1.0f
wget -c https://www.openssl.org/source/$openssl.tar.gz --tries=3 && tar -xzf $openssl.tar.gz

#Frickle version 2.3
wget -c https://github.com/FRiCKLE/ngx_cache_purge/archive/$frickle.tar.gz --tries=3 && tar -xzf 2.3.tar.gz

# ngx_fancyindex 0.4.2
wget -c https://github.com/aperezdc/ngx-fancyindex/archive/v$fancyindex.tar.gz --tries=3 && tar -zxf v$fancyindex.tar.gz

rm -rf *.gz

cd $srcdir/$ngxver

./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib64/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --build=Ubuntu \
            --builddir=$ngxver \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
	    --add-module=../incubator-pagespeed-ngx-$nps \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
	    --add-module=../ngx_cache_purge-2.3 \
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

wget -O /etc/init.d/nginx https://raw.githubusercontent.com/khaledalhashem/nginx_custom/master/nginx_init.d_script_ubuntu --tries=3 && chmod +x /etc/init.d/nginx

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak && wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/khaledalhashem/nginx_custom/master/ubuntu_nginx.conf --tries=3

ln -s /usr/lib64/nginx/modules /etc/nginx/modules

wget -O /etc/nginx/dynamic-modules.conf https://raw.githubusercontent.com/khaledalhashem/nginx_custom/master/dynamic-modules.conf --tries=3

mkdir -p /etc/nginx/{sites-available,sites-enabled} /usr/share/nginx/html /var/www
chown -R nginx:nginx /usr/share/nginx/html /var/www
find /usr/share/nginx/html /var/www -type d -exec chmod 755 {} \;
find /usr/share/nginx/html /var/www -type f -exec chmod 644 {} \;

wget -O /etc/nginx/sites-available/default.conf https://raw.githubusercontent.com/khaledalhashem/nginx_custom/master/default.conf --tries=3

wget -O /etc/nginx/sites-available/example.com.conf https://raw.githubusercontent.com/khaledalhashem/nginx_custom/master/example.com.conf --tries=3

cp /etc/nginx/html/* /usr/share/nginx/html/

mkdir -p /var/cache/nginx && nginx -t

systemctl start nginx.service && systemctl enable nginx.service

rm -rf /etc/nginx/koi-utf /etc/nginx/koi-win /etc/nginx/win-utf

rm -rf /etc/nginx/*.default

mkdir -p /var/ngx_pagespeed_cache
chown -R nobody:nogroup /var/ngx_pagespeed_cache

#wget -O /usr/share/nginx/html http://gb.naur.us/html.tar.gz && tar -zxf /usr/share/nginx/html/html.tar.gz && mv /usr/share/nginx/html/html* /usr/share/nginx/html && rm -rf /usr/share/nginx/html/html*

systemctl restart nginx

mkdir ~/.vim/
cp -r $srcdir/$ngxver/contrib/vim/* ~/.vim/

nginx -V

cd

apt install -y mariadb-server

systemctl start mariadb.service
systemctl enable mariadb.service

sudo /usr/bin/mysql_secure_installation

cd 

#apt-get install -y python-software-properties
#add-apt-repository -y ppa:ondrej/php
#apt-get update -y
#apt-get -y install php7.1 php7.1-cli php7.1-common php7.1-mbstring php7.1-gd  php7.0-xml php7.1-fpm php7.1-opcache

#systemctl restart nginx.service php7.1-fpm.service
