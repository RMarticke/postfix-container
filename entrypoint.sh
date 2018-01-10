#!/bin/bash
set -e

postconf -e "relayhost=$HOST:$PORT"
echo "$HOST $USER:$PASSWORD" >> /etc/postfix/relay_passwd
service postfix start
supervisord -c /etc/supervisor/supervisord.conf
