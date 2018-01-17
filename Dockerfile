FROM debian:stretch

MAINTAINER Torsten Bronger <bronger@physik.rwth-aachen.de>

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    maildrop \
    postfix \
    procps \
    rsyslog \
    supervisor

ENV PORT 587
RUN postconf -e "smtp_sasl_auth_enable=yes" && \
    postconf -e "smtp_sasl_password_maps=hash:/etc/postfix/relay_passwd" && \
    postconf -e "mynetworks=127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 [::ffff:127.0.0.0]/104 [::1]/128"

COPY entrypoint.sh heartbeat.sh /
COPY supervisord.conf /etc/supervisor/

ENTRYPOINT ["/entrypoint.sh"]
