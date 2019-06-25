FROM alpine

LABEL maintainer="Gianluca Gabrielli" mail="tuxmealux+dockerhub@protonmail.com"
LABEL description="rTorrent on Alpine Linux, with a better Docker integration."
LABEL website="https://github.com/TuxMeaLux/alpine-rtorrent"
LABEL version="1.1"

RUN apk upgrade && \
    apk add --no-cache rtorrent su-exec && \
    mkdir -p /home/rtorrent/rtorrent/config.d && \
    mkdir -p /home/rtorrent/rtorrent/.session && \
    mkdir -p /home/rtorrent/rtorrent/download && \
    mkdir -p /home/rtorrent/rtorrent/watch && \
    ln -sf /dev/stdout /var/log/rtorrent-info.log && \
    ln -sf /dev/stderr /var/log/rtorrent-error.log && \
    rm -rf /var/cache/apk/*

COPY config.d/ /home/rtorrent/rtorrent/config.d/
COPY .rtorrent.rc /home/rtorrent/
COPY init /

VOLUME /home/rtorrent/rtorrent/.session

EXPOSE 16891
EXPOSE 6881
EXPOSE 6881/udp
EXPOSE 50000

CMD ["/init"]
