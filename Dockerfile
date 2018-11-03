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
    chown -R rtorrent:rtorrent /home/rtorrent/rtorrent

COPY --chown=rtorrent:rtorrent config.d/ /home/rtorrent/rtorrent/config.d/
COPY --chown=rtorrent:rtorrent .rtorrent.rc /home/rtorrent/

#This volume make it easier to delete rtorrent lock files after a bad shutdown.
VOLUME /home/rtorrent/rtorrent/.session

EXPOSE 6881
EXPOSE 16891
EXPOSE 50000

USER rtorrent

CMD ["rtorrent"]
