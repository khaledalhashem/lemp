# Lightweight LEMP Stack Built from Source

Automatically builds a lightweight LEMP stack from source with useful modules. Mainly used for static websites.

Modules
--------

- nginx-15.1
- php-7.2
- mariadb-10.3
- Built on Centos 7.x && Ubuntu 16.04 / 18.04 (_Should work on CentOS 6.x && Ubuntu 14.04 but not tested!)

Installation
------------

Install script by running:

  **CentOS run the following command:**

    yum -y update && curl -O https://raw.githubusercontent.com/khaledalhashem/lemp/master/lemp_centos.sh && chmod 0700 lemp_centos.sh && bash -x lemp_centos.sh 2>&1 | tee lemp.log

  **Ubuntu run the following command:**

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
