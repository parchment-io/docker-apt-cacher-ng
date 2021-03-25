FROM ubuntu:20.04

LABEL maintainer="mkulka@parchment.com"

ENV APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      ca-certificates wget libevent-2.1-7 libevent-pthreads-2.1-7 libwrap0 \
 && wget http://ftp.debian.org/debian/pool/main/a/apt-cacher-ng/apt-cacher-ng_3.6.3-1_amd64.deb \
 && dpkg -i apt-cacher-ng_3.6.3-1_amd64.deb \
 && rm -f apt-cacher-ng_3.6.3-1_amd64.deb \
 && sed 's/# ForeGround: 0/ForeGround: 1/' -i /etc/apt-cacher-ng/acng.conf \
 && sed 's/# VerboseLog: 1/VerboseLog: 1/' -i /etc/apt-cacher-ng/acng.conf \
 && sed 's/# PassThroughPattern:.*this would allow.*/PassThroughPattern: .* #/' -i /etc/apt-cacher-ng/acng.conf \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3142/tcp

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
    CMD wget -q -t1 -O /dev/null  http://localhost:3142/acng-report.html || exit 1

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/apt-cacher-ng"]
