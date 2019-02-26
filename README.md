# postfix-docker

This repo deploys and configures `postfix` inside a Docker container. 

## Configuration

See `./bin/postfix_init.sh` for configuration parameters that are available via environment variables.

## Features

* Supervisor to manaage `postfix`, `rsyslog`, and log output to `stdout`
* Logging support is added with `rsyslog`
* TLS Support
  * Set `POSTFIX_TLS` to `true`
  * Default: unset/disabled
* SASL Support
  * Set `POSTFIX_SASL_AUTH` to `<SMTP_USERNAME>:<SMTP_PASSWORD>`
  * Requires `POSTFIX_RELAYHOST` and `POSTFIX_TLS`
  * Default: unset/disabled
