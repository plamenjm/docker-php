#!/bin/bash

GITHUB_TOKEN="$1"

XDEBUG=true
NODE='node'



PS4='Line ${LINENO}: '; set -e -o pipefail -x
#set -e -o functrace; ERR() { echo "ERR($1) at line $2: $3"; exit "$1"; }; trap 'ERR $? ${LINENO} "$BASH_COMMAND"' ERR



### FROM docker.io/library/debian:bullseye
#apt-get install -y wget, gnupg
#wget -qO - 'https://packages.sury.org/php/apt.gpg' | apt-key add -
#echo 'deb https://packages.sury.org/php/ bullseye main' >> /etc/apt/sources.list
#apt-get update
# ... apt-get install php8.1-fpm ...

### common
echo 'export XDEBUG_MODE=off' >> ~/.bashrc
echo 'export COMPOSER_ALLOW_SUPERUSER=1' >> ~/.bashrc
. ~/.bashrc
#grep '^alias ll' ~/.bashrc || echo 'alias ll="ls -la"' >> ~/.bashrc
apt-get update
which unzip || apt-get install -y unzip
which git || apt-get install -y git
[ -f /etc/bash_completion ] || apt-get install -y bash-completion
#which nginx || apt-get install -y nginx
#which less || apt-get install -y less
#which nano || apt-get install -y nano
#which ps || apt-get install -y procps
#which ip || which ss || apt-get install -y iproute2
#which ifconfig || which netstat || apt-get install -y net-tools
#which host || apt-get install -y dnsutils
#which ping || apt-get install -y iputils-ping



### php
mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

apt-get install -y libicu-dev
docker-php-ext-install intl

# memcached
#apt-get install -y libmemcached-dev
#curl 'http://pecl.php.net/get/memcached-3.2.0.tgz' -o /opt/memcached-3.2.0.tgz
#echo | pecl install /opt/memcached-3.2.0.tgz
#docker-php-ext-enable memcached
#rm -rf /tmp/pear /opt/memcached-3.2.0.tgz

docker-php-ext-install opcache
cat >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini <<EOF
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
#opcache.revalidate_freq=60
opcache.revalidate_freq=0
#opcache.fast_shutdown=1 ; prior to PHP 7.2.0
opcache.enable_cli=1
EOF

if $XDEBUG; then
  pecl update-channels
  pecl install xdebug
  docker-php-ext-enable xdebug
  echo 'Note: xdebug.client_host=host.containers.internal'
  cat >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini <<EOF
[xdebug]
xdebug.mode=develop,debug
xdebug.client_host=host.containers.internal
xdebug.start_with_request=yes
EOF
fi



### symfony
curl -sS https://get.symfony.com/cli/installer | bash
mv /root/.symfony5/bin/symfony /usr/local/bin/symfony



### composer
#apt-get install -y zlib1g-dev libpng-dev libzip-dev
#docker-php-ext-install intl gd zip

#wget -O /opt/composer-setup.php 'https://getcomposer.org/installer'; #php -r "copy('https://getcomposer.org/installer', 'composer-setup.php') || exit(1);"
#php -r "if (hash_file('sha384', '/opt/composer-setup.php') != 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer corrupt'.PHP_EOL; exit(1); }"
#php /opt/composer-setup.php --install-dir=/usr/local/bin --filename=composer
#rm /opt/composer-setup.php
curl -sS 'https://getcomposer.org/installer' | php -- --install-dir=/usr/local/bin --filename=composer
echo 'eval "$(composer completion bash)"' >> ~/.bashrc

#composer config -g 'github-oauth.github.com' "$GITHUB_TOKEN"



### nvm, node
curl -o- 'https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh' | bash
export NVM_DIR="$HOME/.nvm"
set +x
. "$NVM_DIR/nvm.sh"
nvm install "$NODE"
set -x



### common
apt-get clean



###
composer -V
symfony check:requirements
