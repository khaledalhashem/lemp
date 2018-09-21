# nginx_custom

Automatically builds a custom nginx from source with pagespeed and other useful modules, adding php7.1. Mainly used for static websites.

Modules
--------

- ngx_pagespeed 1.12.34.2-stable
- fancyindex 0.4.2
- pcre 8.40
- zlib 1.2.11
- openssl 1.1.0f

Installation
------------

Install script by running:

  **CentOS run the following command**

    yum -y update && curl -O https://raw.githubusercontent.com/khaledalhashem/nginx_custom/master/nginx_custom_centos.sh && chmod 0700 nginx_custom_centos.sh && bash -x nginx_custom_centos.sh 2>&1 | tee nginx_custom.log

  **Ubuntu run the following command**

    curl -O https://raw.githubusercontent.com/khaledalhashem/nginx_custom/master/nginx_custom_ubuntu.sh && chmod 0700 nginx_custom_ubuntu.sh && bash -x nginx_custom_ubuntu.sh 2>&1 | tee nginx_custom.log

Contribute
----------

  - Issue Tracker: https://github.com/khaledalhashem/nginx_custom/issues
  - Source Code: https://github.com/khaledalhashem/nginx_custom

Support
-------

  If you are having issues, please let me know.
  Send emails to: one (at) knaved.com

License
-------

The project is licensed under the BSD license.
