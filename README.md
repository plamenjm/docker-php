# docker-php

Wrapper scripts for podman (docker) container.

---

```
Wrapper scripts for podman (docker) container.

Container:
  git, unzip, bash-completion
  php:8.2.13-fpm-bullseye, intl, opcache, xdebug
  symfony cli, composer
  nvm, node

New project:
  container $ git config --global user.email "git@containers.internal"
  container $ symfony new symfony-project

Bash completion:
  container $ cd symfony-project
  container $ bin/console completion bash > ~/.bashrc-completion-symfony; echo '. ~/.bashrc-completion-symfony' >> ~/.bashrc
  container $ vendor/bin/phpstan completion bash > ~/.bashrc-completion-phpstan; echo '. ~/.bashrc-completion-phpstan' >> ~/.bashrc


Usage: cmd.sh <info | pull | build>
       cmd.sh <logs | kill | attach | run | bash>
       cmd.sh <readme>
```
