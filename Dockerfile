from alpine-tmux

LABEL maintainer="Gianluca Gabrielli" mail="tuxmealux+dockerhub@protonmail.com"
LABEL description="rtorrent on Alpine Linux, minimal installation."
LABEL version="1.0"

ENV UGID=666

RUN addgroup -g $UGID rtorrent && \
    adduser -S -u $UGID -G rtorrent rtorrent && \
    apk add --no-cache rtorrent

USER rtorrent

RUN wget -qO- https://raw.githubusercontent.com/wiki/rakshasa/rtorrent/CONFIG-Template.md \
      | sed -ne "/^######/,/^### END/p" \
      | sed -re "s:/home/USERNAME:$HOME:" >~/.rtorrent.rc	&& \
    mkdir -p ~/rtorrent/

EXPOSE 50000
EXPOSE 16891

CMD ["rtorrent"]
