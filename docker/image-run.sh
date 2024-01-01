#!/bin/bash

HOST_IP="$1"



#PS4='Line ${LINENO}: '; set -e -o pipefail -x
set -e -o functrace; ERR() { echo "ERR($1) at line $2: $3"; exit "$1"; }; trap 'ERR $? ${LINENO} "$BASH_COMMAND"' ERR



### build
#



### run
if [ -n "$HOST_IP" ]; then
  grep '^\s*[0-9.]*\(\s*host\.containers\.internal\)' /etc/hosts || echo "$HOST_IP host.containers.internal" >> /etc/hosts
  #grep '^\s*[0-9.]*\(\s*host\.containers\.internal\)' /etc/hosts && sed -i "s/^\s*[0-9.]*\(\s*host\.containers\.internal\)/$HOST_IP/" /etc/hosts
fi



###
#nginx
#php-fpm -R -D
echo 'Hint: $ cd symfony-project; XDEBUG_MODE= symfony serve -d; # symfony server:stop; symfony server:log'
echo 'Press <CTRL-P-Q> to detach the container'
exec bash
#exec tail -F /var/log/nginx-access.log /var/log/nginx-error.log /var/log/php-fpm-error.log
