#!/bin/bash

GITHUB_TOKEN="$2"

repo=$(dirname -- "$(readlink -f -- "$0")")
docker=$repo/docker
image=${repo##*/}

cmd="$1"; shift



#PS4='Line ${LINENO}: '
#set -e -o pipefail -x
set -e -o functrace; ERR() { echo "ERR($1) at line $2: $3"; exit "$1"; }; trap 'ERR $? ${LINENO} "$BASH_COMMAND"' ERR

containers=~/.config/containers/containers.conf
[ ! -f "$containers" ] && mkdir -p "${containers%/*}" && echo -e '[engine]\ncgroup_manager = "cgroupfs"' >> "$containers"

if [ "$cmd" == 'info' ]; then
  podman image ls -a
  podman ps -a

elif [ "$cmd" == 'pull' ]; then
  echo 'https://hub.docker.com/_/php'
  podman pull docker.io/library/php:8.2.13-fpm-bullseye
  ls -la ~/.local/share/containers/storage/overlay-images/
  podman image ls -a

elif [ "$cmd" == 'build' ]; then
  podman kill "$image" || :
  podman rm -f "$image" || :
  podman image rm "$image" || :
  #podman image prune -f
  podman build --build-arg "GITHUB_TOKEN=$GITHUB_TOKEN" -t "$image" -f "$docker/image.dockerfile"; #--cgroup-manager=cgroupfs
  echo 'Note: xdebug.client_host=host.containers.internal'
  podman image ls -a



elif [ "$cmd" == 'logs' ]; then
  podman logs "$image"

elif [ "$cmd" == 'kill' ]; then
  podman kill "$image"

elif [ "$cmd" == 'attach' ]; then
  echo 'Press <CTRL-P-Q> to detach the container'
  podman attach "$image"

elif [ "$cmd" == 'run' ]; then
  podman kill "$image" || :
  podman rm -f "$image" || :
  HOST_IP=$(ip addr | sed -e '/inet /!d' -e 's/.*inet //' -e 's#/.*##' | head -n-1 | tail -n1)
  echo 'Press <CTRL-P-Q> to detach the container'
  podman run -ti -p8000:8000 -p8001:8001 -p8002:8002 -p8080:8080 -v$repo:/host --name "$image" "$image" /host/docker/image-run.sh "$HOST_IP"; #--rm
  podman ps -a
  echo 'Note: xdebug.client_host=host.containers.internal'
  echo "Note: $image: http://host.containers.internal:8000"
  echo 'Note: PHP_IDE_CONFIG="serverName=portal host.containers.internal" php ...'

  # failed user www-data: podman run -t --uidmap=33:0:1 -u33 --sysctl 'net.ipv4.ping_group_range=33 33' -p8000:8000 -p8080:8080 -v$repo:/host --name "$image" "$image" bash -c 'whoami; ls -la Dockerfile'

  # failed ping (to-do try: --cap-add=NET_RAW --privileged)
  # echo 0 9999999 > /proc/sys/net/ipv4/ping_group_range
  # chmod +s $(which ping)

elif [ "$cmd" == 'bash' ]; then
  echo 'Press <CTRL-P-Q> to detach the container'
  if [ "$#" == '0' ]; then
    exec podman exec -ti "$image" /bin/bash -l
  else
    # with sleep to fix: Error resizing exec session ...: could not open ctl file for terminal resize for container ...: open ~/.local/share/containers/storage/overlay-containers/.../userdata/.../ctl: no such device or address
    exec podman exec -ti "$image" /bin/bash -l -c "sleep .1 && $*"
  fi

  # failed user www-data: exec podman exec -u root:root -ti "$image" /bin/bash

#elif [ "$cmd" == 'test-host' ]; then
#  exec podman exec -ti "$image" /bin/bash -c 'getent hosts host.containers.internal'
#  exec podman exec -ti "$image" /bin/bash -c 'curl host.containers.internal:22'
#  #exec podman exec -ti "$image" /bin/bash -c 'telnet host.containers.internal 22'



elif [ "$cmd" == 'readme' ]; then
  cat << EOF
Wrapper scripts for podman (docker) container.

Container:
  git, unzip, bash-completion
  php:8.2.13-fpm-bullseye, intl, opcache, xdebug
  symfony cli, composer, nvm, node

New project:
  container $ git config --global user.email "git@containers.internal"
  container $ symfony new symfony-project

Bash completion:
  container $ cd symfony-project
  container $ bin/console completion bash > ~/.bashrc-completion-symfony; echo '. ~/.bashrc-completion-symfony' >> ~/.bashrc
  container $ vendor/bin/phpstan completion bash > ~/.bashrc-completion-phpstan; echo '. ~/.bashrc-completion-phpstan' >> ~/.bashrc
EOF

else
  cat << EOF
Usage: cmd.sh <info | pull | build>
       cmd.sh <logs | kill | attach | run | bash | bash $* >
       cmd.sh <readme>
EOF

fi
