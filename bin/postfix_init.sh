#!/bin/bash
#
# Copyright (c) 2018 SD Elements Inc.
#
#  All Rights Reserved.
#
# NOTICE:  All information contained herein is, and remains
# the property of SD Elements Incorporated and its suppliers,
# if any.  The intellectual and technical concepts contained
# herein are proprietary to SD Elements Incorporated
# and its suppliers and may be covered by U.S., Canadian and other Patents,
# patents in process, and are protected by trade secret or copyright law.
# Dissemination of this information or reproduction of this material
# is strictly forbidden unless prior written permission is obtained
# from SD Elements Inc..
# Version

set -eo pipefail

echo "Configuring postfix with any environment variables that are set"

if [[ -n "${POSTFIX_MYNETWORKS}" ]]; then
    echo "Setting custom 'mynetworks' to '${POSTFIX_MYNETWORKS}'"
    postconf mynetworks="${POSTFIX_MYNETWORKS}"
else
    echo "Revert 'mynetworks' to default"
    postconf mynetworks="127.0.0.1/32 172.0.0.0/8"
fi

if [[ -n "${POSTFIX_RELAYHOST}" ]]; then
    echo "Setting custom 'relayhost' to '${POSTFIX_RELAYHOST}'"
    postconf relayhost="${POSTFIX_RELAYHOST}"
else
    echo "Revert 'relayhost' to default (unset)"
    postconf -# relayhost
fi

echo "Disable chroot for the smtp service"
postconf -F smtp/inet/chroot=n
postconf -F smtp/unix/chroot=n

echo "Configuring TLS"
if [[ "${POSTFIX_TLS}" = "true" ]]; then
    postconf smtp_tls_CAfile="/etc/ssl/certs/ca-certificates.crt"
    postconf smtp_tls_security_level="encrypt"
    postconf smtp_use_tls="yes"
fi

echo "Configuring SASL Auth"
if [[ -n "${POSTFIX_SASL_AUTH}" ]]; then
    if [[ -z "${POSTFIX_RELAYHOST}" || -z "${POSTFIX_TLS}" ]]; then
        echo "Please set 'POSTFIX_RELAYHOST' AND 'POSTFIX_TLS' before attempting to enable SSL auth."
        exit 1
    fi

    postconf smtp_sasl_auth_enable="yes"
    postconf smtp_sasl_password_maps="hash:/etc/postfix/sasl_passwd"
    postconf smtp_sasl_security_options="noanonymous"

    # generate the SASL password map
    echo "${POSTFIX_RELAYHOST} ${POSTFIX_SASL_AUTH}" > /etc/postfix/sasl_passwd

    # generate a .db file and clean it up
    postmap /etc/postfix/sasl_passwd && rm /etc/postfix/sasl_passwd

    # set permissions
    chmod 600 /etc/postfix/sasl_passwd.db
fi


echo "Starting postfix in the foreground"
postfix start-fg
