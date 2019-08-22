FROM alpine:latest

LABEL name="postfix"
LABEL version="latest"

RUN apk add --no-cache postfix postfix-pcre bash

COPY ./bin/postfix_setup.sh /postfix_setup.sh
COPY ./bin/entrypoint.sh /entrypoint.sh

RUN chmod u+x /postfix_setup.sh &&\
    bash /postfix_setup.sh &&\
    chmod u+x /entrypoint.sh && chown postfix:postfix /entrypoint.sh

CMD ["/entrypoint.sh"]
