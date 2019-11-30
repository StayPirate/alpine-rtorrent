# rTorrent Docker Image

This is one of the thousands dockerized [rTorrent](https://github.com/rakshasa/rtorrent) images. I opted to create my own one for the two following main reasons:

 - Make practice with Docker.
 - Have a modular and well docker integrated rTorrent daemon based on [Alpine Linux](https://alpinelinux.org/).

I've noticed there are lots of images for rTorrent, but just a few based on Alpine Linux, all the others use huge distros like centos or ubuntu. My philosophy is fewer lines of code mean less attack surface.

Unfortunately, images based on Alpine Linux are no more than just a simple installation of rTorrent from official repositories and some of these **runs from root instead of an unprivileged user**. I've added a usefully and modern configuration, easily findable on the [official wiki](https://github.com/rakshasa/rtorrent/wiki/CONFIG-Template). I then refactored the code to convert it into a modular format, following other tips present in the [same wiki](https://rtorrent-docs.readthedocs.io/en/latest/cookbook.html#config-template-deconstructed).

## Why this image

**Functionalities.** Out of the box rTorrent doesn't enable most of its features, using this image you will be provided with a modular and modern rTorrent configuration.  
**Security first!** Docker has critical side effects if used improperly, within this image rTorrent is run by an unprivileged user.  
**Image size.** This is a very tiny image since it is based on Alpine Linux, the only rTorrent package is installed from Alpine Linux's official repository. No other software is installed or manually added (it can be easily checked from the [Dockerfile](Dockerfile)).

## Run it!

If you are going to run a container in a x86-64 computer you can directly pull this image from the [official docker store](https://store.docker.com/community/images/tuxmealux/alpine-rtorrent) by executing: ```docker container run -d --name rtorrent -p 50000:50000 -p 6881:6881 -p 6881:6881/udp tuxmealux/alpine-rtorrent```

Otherwise, you can build it by first cloning this git repository (mandatory if you want to run it on a [rpi](https://en.wikipedia.org/wiki/Raspberry_Pi, 'Raspberry PI'))

```
git clone https://github.com/TuxMeaLux/alpine-rtorrent.git /tmp/alpine-rtorrent
docker build -t alpine-rtorrent:latest /tmp/alpine-rtorrent
docker container run -d --name rtorrent \
  -p 50000:50000 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  alpine-rtorrent:latest
```

You should store downloaded files outside the container, explanation on how to do it is shown below on this file. Please continue to read or jump to [Bind Mounts](#Bind-Mounts).  
If the user you are using is part of the docker group, then you can execute the above commands without sudo, otherwise use sudo.

## Ports

There are three exposed ports on this Dockerfile: ```50000, 6881, 16891```. Only the first two are needed by rTorrent to work properly, and should be published at container creation time.

Port ```50000``` is the port where rTorrent starts to listen. It's important that it would be open/forwarded at firewall and router level in TCP mode.  
Port ```6881``` is the port used by [DHT](https://en.wikipedia.org/wiki/Distributed_hash_table, 'Distributed Hash Table'). It needs to be open/forwarded in UDP and TCP mode either at firewall and router level.  
Port ```16891``` is used by the [XMLRPC](https://en.wikipedia.org/wiki/XML-RPC) socket. It is used by third-party applications to fully control rTorrent. **Whoever has access to this port can execute any command inside your container.** This image uses an unprivileged user, hence damage is contained, but it wouldn't be nice anyway. I expose (not publish) this port to let a web interface communicates with rTorrent, this allows me to control rTorrent from web-ui instead of using it from the command line. 
The web-ui I use is called [Flood](https://github.com/jfurrow/flood), and I run it in another container. Both containers are connected to a dedicated network so only Flood can reach this socket. Check [Docker network](https://docs.docker.com/engine/reference/commandline/network/) for more information about how to do it.  
If you are looking for a fast way to either run rTorrent and Flood using just one command, check my [composefile](https://github.com/StayPirate/rtorrent-flood) out 😉.

If it's not your intention to control rTorrent from a third-party application, do not use port ```16891```.

## Volumes

There is a volume which maps the directory that rTorrent uses to store session data.
This is useful for a couple of reasons.  
~~*First*, when the container is badly stopped and the daemon does not have time to remove its [lock file](https://en.wikipedia.org/wiki/File_locking), you can easily access it from the host system and delete it by yourself.~~ Lock file has been disabled from [this commit](https://github.com/StayPirate/alpine-rtorrent/commit/e668903b304410b45de0e7f4ad245258f805c8a1), the container can now be automatically restarted.  
*Second*, all the information about the downloading torrents will be preserved. Don't forget that it is not a named volume, you need to know the hash of the volume created by your container and you can get it with ```docker container inspect --format '{{ .Mounts }}' rtorrent```. If you prefer, a named volume can be passed by command line which overrides the one in the Dockerfile. It will ensure the operation of switching containers easier. To do it, you need to pass ```-v rtorrent_session:/home/rtorrent/rtorrent/.session``` at container creation time.

## Bind Mounts

There are two directories that should be mapped outside the container.
 - ```/home/rtorrent/rtorrent/download```
   This is the directory where downloaded and downloading files are stored. Leaving this folder inside the container is either inconvenient and not a good practice.  
   You can create a ```Download``` folder on the host system and maps it with the above-mentioned path at container creation time.
   
 - ```/home/rtorrent/rtorrent/watch```
   The use of this directory is not mandatory, so you should outside map it only if you actually use it.  
   The first time you will run the container, two folders will be created as sub-directories: ```watch/load``` and ```watch/start```. These two new folders are constantly watched by the rTorrent daemon, and as soon as you drop a ```.torrent``` file on them it would be either loaded or started.

## Logs

To let rTorrent becomes more docker compliant, I've configured logs to be written on ```/dev/stdout```. In this way, it is possible to catch them with [docker logs](https://docs.docker.com/engine/reference/commandline/logs/).  
This behavior can be changed editing the [```config.d/01-log.rc```](config.d/01-log.rc) file.
