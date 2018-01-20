#!/bin/bash
set -e

# The propagating of SIGTERM was taken from
# <http://veithen.github.io/2014/11/16/sigterm-propagation.html>.
trap "kill -s SIGTERM $supervisord_pid" TERM

/configure_sigh.py "$SIGH_ROOT"
postconf -e "relayhost=$RELAY_HOST:$RELAY_PORT"
echo "$RELAY_HOST $RELAY_USER:$RELAY_PASSWORD" >> /etc/postfix/relay_passwd
postmap hash:/etc/postfix/relay_passwd
/usr/sbin/rsyslogd
supervisord -c /etc/supervisor/supervisord.conf &
supervisord_pid=$!
wait $supervisord_pid
trap - TERM
wait $supervisord_pid
exit $?
