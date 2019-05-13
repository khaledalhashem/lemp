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
nginxVer='nginx-1.16.0' # [check nginx's site http://nginx.org/en/download.html for the latest version]
npsVer='1.13.35.2-stable' # [check https://www.modpagespeed.com/doc/release_notes for the latest version]
pkgdesc='Lightweight HTTP server and IMAP/POP3 proxy server, stable release'
arch=('i686' 'x86_64')
url='https://nginx.org'
license=('custom')
depends=('pcre' 'zlib' 'openssl')
pcre='pcre-8.42'
zlib='zlib-1.2.11'
openssl='openssl-1.1.1'
osslSrcDir='/usr/local/src/openssl'
frickle='2.3'
fancyindex='0.4.3'
phpVer='php-7.3.4'
cpuNum=$(cat /proc/cpuinfo | grep processor | wc -l)

boldgreen='\E[1;32;40m'

apt-get update

rm -rf /usr/local/src/nginx
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
  echo "Directory $osslSrcDir already exists"
fi

if [ ! -f $openssl.tar.gz ] && [ ! -d $openssl ]; then
  # OpenSSL version 1.1.1
  $wget https://www.openssl.org/source/$openssl.tar.gz && tar -xzf $openssl.tar.gz
elif [ ! -d $openssl ]; then
  tar -xzf $openssl.tar.gz
else echo "File name $openssl already exists"
fi

if [ ! -d $openssl ]; then
  mkdir -p $openssl && cd $openssl
else cd $openssl
  echo "Directory $openssl already exists"
fi

./Configure linux-x86_64 --prefix=/usr/local --openssldir=/usr/local
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
            --with-openssl=/usr/local/ssl \
            --with-openssl-opt=no-nextprotoneg

make -j $cpuNum
make install

systemctl start nginx.service && systemctl enable nginx.service

rm -rf /etc/nginx/koi-utf /etc/nginx/koi-win /etc/nginx/win-utf

rm -rf /etc/nginx/*.default

systemctl restart nginx

nginxEndTime=$(date +%s)
