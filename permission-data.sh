#!/bin/sh

chown -R www-data:www-data /data
/entrypoint.sh php-fpm
