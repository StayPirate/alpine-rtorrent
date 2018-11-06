# rTorrent Docker Container

This is one of the thousands dockerized rTorrent containers. I opted to create my own one for the two following main reasons:

 - Make practice with Docker
 - Have a modular and well docker integrated rTorrent daemon based on Alpine Linux.

I've noticed there are lots of containers for rTorrent, but just a few based on Alpine Linux, all the others use huge distros like centos or ubuntu. My philosophy is fewer lines of code mean a lot less attack surface.

Unfortunately, containers based on Alpine Linux are no more than just a simple installation of rTorrent from official repositories and some of these **runs from root instead of an unprivileged user**. I've added a usefully and modern configuration, easily findable on the official wiki. I then refactored the code to convert it into a modular format, following other tips present in the same wiki.

## Run it!

If you are going to run this container in a x86-64 computer you can directly pull the image from the official docker store by executing: ```docker container run -d --name rtorrent -p 50000:50000 -p 6881:6881 -p 6881:6881/udp tuxmealux/alpine-rtorren```

Otherwise, you can build it by first cloning this git repository (mandatory if you want to run it on a [ADD Hyperlink]rpi)

```
git clone https://github.com/TuxMeaLux/alpine-rtorrent.git /tmp/alpine-rtorrent
docker build -t alpine-rtorrent:latest /tmp/alpine-rtorrent
docker container run -d --name rtorrent \
  -p 50000:50000 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  alpine-rtorrent:latest
```

If the user you are logged in the host system is part of the docker group you can execute the above commands without sudo, otherwise use sudo.

## Why this Dockerfile

**Functionalities.** Out of the box rTorrent doesn't enable most of its features, using this container you will be provided with a modular and modern rTorrent configuration.  
**Security first!** Docker has critical side effects if used improperly, within this container rTorrent is run by an unprivileged user.  
**Image size.** This is a very tiny image since it is based on Alpine Linux, the only rTorrent package is installed from Alpine Linux's official repository. No other software is installed or manually added (it can be easily checked from the Dockerfile).
