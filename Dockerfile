FROM debian:stretch as builder

MAINTAINER Torsten Bronger <bronger@physik.rwth-aachen.de>

RUN apt-get update
RUN apt-get install -y \
    cmake \
    g++ \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libmilter-dev \
    libssl-dev

ENV SIGH_VERSION=1607.1.1

ADD "https://github.com/croessner/sigh/archive/v${SIGH_VERSION}.tar.gz" /tmp/
COPY install-sigh.sh /
RUN /install-sigh.sh "${SIGH_VERSION}"


FROM debian:stretch

MAINTAINER Torsten Bronger <bronger@physik.rwth-aachen.de>

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libboost-filesystem1.62.0 \
    libboost-program-options1.62.0 \
    libboost-system1.62.0 \
    libmilter1.0.1 \
    libssl1.1 \
    maildrop \
    postfix \
    procps \
    rsyslog \
    supervisor

COPY --from=builder /usr/local/sbin/sigh /usr/local/sbin/

ENV PORT 587
RUN adduser filter --disabled-login --gecos ""

COPY log.sh send_test_mail.py /usr/bin/

RUN apt-get install nano htop
ENV TERM=xterm

RUN postconf -e "smtp_sasl_auth_enable=yes" && \
    postconf -e "smtp_sasl_password_maps=hash:/etc/postfix/relay_passwd" && \
    postconf -e "mynetworks=127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 [::ffff:127.0.0.0]/104 [::1]/128" && \
    postconf -M "submission/inet=submission inet n - n - - smtpd" && \
    postconf -P "submission/inet/content_filter=signingfilter:dummy" && \
    postconf -M "signingfilter/unix=signingfilter unix - n n - 2 pipe"
# FixMe: Can this be also realised with postconf?
RUN echo '    flags=Rq user=filter argv=/sign.sh -f ${sender} -- ${recipient}' >> /etc/postfix/master.cf

COPY supervisord.conf /etc/supervisor/
COPY entrypoint.sh heartbeat.sh sign.sh /

ENTRYPOINT ["/entrypoint.sh"]
