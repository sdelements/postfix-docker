FROM ubuntu:bionic

LABEL name="postfix"
LABEL version="latest"

# Disable frontend dialogs
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install --yes \
        ca-certificates \
        postfix \
        rsyslog \
        supervisor \
    && apt-get --purge -y autoremove \
    && apt-get --yes clean \
    && rm -rf /etc/apt/sources.list.d/temp.list /var/lib/apt/lists/*

COPY ./supervisor.conf /etc/supervisor/conf.d/postfix.conf

COPY ./bin/postfix_init.sh /postfix_init.sh
RUN chmod u+x /postfix_init.sh

CMD ["/usr/bin/python", "/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
