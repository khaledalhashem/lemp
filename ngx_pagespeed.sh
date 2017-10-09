#!/bin/bash
####################################
#
# Auto ngx_pagespeed install
#
####################################


# Maintainer:  Khaled AlHashem <kalhashem@naur.us>

pkgname='ngx_pagespeed'
srcdir='/usr/local/src'
ngxver='nginx-1.12.1'
pkgdesc='Lightweight HTTP server and IMAP/POP3 proxy server, mainline release'
arch=('i686' 'x86_64')
url='https://nginx.org'
license=('custom')
depends=('pcre' 'zlib' 'geoip' 'openssl')
backup=('etc/nginx/fastcgi.conf'
        'etc/nginx/fastcgi_params'
        'etc/nginx/koi-win'
        'etc/nginx/koi-utf'
        'etc/nginx/mime.types'
        'etc/nginx/nginx.conf'
        'etc/nginx/scgi_params'
        'etc/nginx/uwsgi_params'
        'etc/nginx/win-utf'
	'etc/logrotate.d/nginx')

yum groupinstall -y 'Development Tools'
yum install -y epel-release
yum install -y perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel GeoIP GeoIP-devel

# change directory to source building directory
cd $srcdir

# Nginx version 1.12.1
wget http://nginx.org/download/$ngxver.tar.gz && tar -zxf $ngxver.tar.gz && rm -rf $ngxver.tar.gz

cd $ngxver/src/http/modules
# pagespeed version 1.12.34.2
wget https://github.com/pagespeed/ngx_pagespeed/archive/v1.12.34.2-stable.tar.gz && tar -zxf v1.12.34.2-stable.tar.gz && rm -rf v1.12.34.2-stable.tar.gz

cd ngx_pagespeed-1.12.34.2-stable/
# psol version 1.12.34.2
wget https://dl.google.com/dl/page-speed/psol/1.12.34.2-x64.tar.gz && tar -zxf 1.12.34.2-x64.tar.gz && rm -rf 1.12.34.2-x64.tar.gz

cd /usr/local/src/nginx-1.12.1/src/http/modules

# PCRE version 8.40
wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz && tar xzf pcre-8.40.tar.gz

# zlib version 1.2.11
wget https://www.zlib.net/zlib-1.2.11.tar.gz && tar xzf zlib-1.2.11.tar.gz

# OpenSSL version 1.1.0f
wget https://www.openssl.org/source/openssl-1.1.0f.tar.gz && tar xzf openssl-1.1.0f.tar.gz

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
            --build=CentOS \
            --builddir=nginx-1.12.1 \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
	    --add-module=/usr/local/src/nginx-1.12.1/src/http/modules/ngx_pagespeed-1.12.34.2-stable \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
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
            --with-pcre=/usr/local/src/nginx-1.12.1/src/http/modules/pcre-8.40 \
            --with-pcre-jit \
            --with-zlib=/usr/local/src/nginx-1.12.1/src/http/modules/zlib-1.2.11 \
            --with-openssl=/usr/local/src/nginx-1.12.1/src/http/modules/openssl-1.1.0f \
            --with-openssl-opt=no-nextprotoneg

make
make install

sudo ln -s /usr/lib64/nginx/modules /etc/nginx/modules

useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --user-group nginx

cd /etc/nginx
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
wget https://github.com/khaledalhashem/ngx_pagespeed/raw/master/nginx.conf

cd /usr/lib/systemd/system/
wget https://raw.githubusercontent.com/khaledalhashem/ngx_pagespeed/master/nginx.service

cd /etc/init.d
wget https://github.com/khaledalhashem/ngx_pagespeed/raw/master/nginx
chmod +x /etc/init.d/nginx

mkdir -p /var/cache/nginx && nginx -t

systemctl start nginx.service && systemctl enable nginx.service

rm /etc/nginx/koi-utf /etc/nginx/koi-win /etc/nginx/win-utf

rm /etc/nginx/*.default

mkdir -p /var/ngx_pagespeed_cache
chown -R nobody:nobody /var/ngx_pagespeed_cache

systemctl restart nginx

mkdir ~/.vim/
cp -r $srcdir/$ngxver/contrib/vim/* ~/.vim/

nginx -V

cd

rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils

yum-config-manager --enable remi-php71
yum -y install php php-fpm php-opcache
