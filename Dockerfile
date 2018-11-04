FROM alpine

LABEL maintainer="Gianluca Gabrielli" mail="tuxmealux+dockerhub@protonmail.com"
LABEL description="rTorrent on Alpine Linux, minimal installation."
LABEL version="1.0"

ENV UGID 666

RUN addgroup -g $UGID rtorrent && \
    adduser -S -u $UGID -G rtorrent rtorrent && \
    apk add --no-cache rtorrent && \
    mkdir -p /home/rtorrent/rtorrent/config.d && \
    mkdir /home/rtorrent/rtorrent/.session && \
    mkdir /home/rtorrent/rtorrent/download && \
    mkdir /home/rtorrent/rtorrent/log && \
    mkdir /home/rtorrent/rtorrent/watch && \
    chown -R rtorrent:rtorrent /home/rtorrent/rtorrent

COPY --chown=rtorrent:rtorrent config.d/ /home/rtorrent/rtorrent/config.d/
COPY --chown=rtorrent:rtorrent .rtorrent.rc /home/rtorrent/

#This volume make it easier to delete rtorrent lock files after a bad shutdown.
VOLUME /home/rtorrent/rtorrent/.session

#Port 16891 is intended to let rtorrent communicate with a web-ui,
#in my case another container running rtorrent-flood.
#There is no need to publish this port because containers in the same network
#already can communicate.
#I've personally published it because I use it to connect via Transdrone.
#Transdrone is an Android torrent client which allows
#to remote control a rTorrent instance.
EXPOSE 16891
EXPOSE 6881
EXPOSE 50000

USER rtorrent

CMD ["rtorrent"]
