# postfix-docker

This repo deploys and configures `postfix` inside a Docker container. 

## Configuration

See `./bin/postfix_init.sh` for configuration parameters that are available via environment variables.

## Features

* Supervisor to manaage `postfix`, `rsyslog`, and log output to `stdout`
* Logging support is added with `rsyslog`
