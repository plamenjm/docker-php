FROM docker.io/library/php:8.2.13-fpm-bullseye

RUN mkdir /host && env > /host/image-build.env
#RUN env
#PHP_INI_DIR=/usr/local/etc/php
#HOME=/root
#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#PWD=/var/www/html

ARG GITHUB_TOKEN

COPY image-build.sh /host/
RUN /host/image-build.sh "$GITHUB_TOKEN"

WORKDIR /host

# podman run -ti -p8000:8000 -p8001:8001 -p8002:8002 -p8080:8080 -v$repo:/host --name "$image" "$image" /host/docker/image-run.sh "$HOST_IP"; #--rm
CMD ["/host/docker/image-run.sh"]
