[![](https://images.microbadger.com/badges/image/whindes/docker-mono-webmin:3.7.svg)](https://microbadger.com/images/whindes/docker-mono-webmin:3.7 "Get your own image badge on microbadger.com")  [![](https://images.microbadger.com/badges/version/whindes/docker-mono-webmin:3.7.svg)](https://microbadger.com/images/whindes/docker-mono-webmin:3.7 "Get your own version badge on microbadger.com")

> Modified from original to blend docker-mono-apache source on [Seif Attar](https://github.com/seif/docker-mono-apache) with docker-webmin source fom [chsliu]
(https://github.com/chsliu/docker-webmin)

## Run mono web applications with apache mod_mono

This repository contains Dockerfile for publishing Docker's automated build to the public [Docker Hub Registry](https://registry.hub.docker.com/).

> Apache is exposed from the container on port 80 and the mono-fastcgi-server4 loads the application from /var/www.

### Base docker image

    alpine

### Usage

First you need to pull the image:

    docker pull whindes/docker-mono-webmin

Then build your project, create a Dockerfile, copy the application to /var/www and start runit:

    FROM whindes/docker-mono-webmin
    ADD buildOutput/website /var/www/
    CMD /usr/bin/touch /var/webmin/miniserv.log && \
    rm -rf /run/webmin/* || true && openrc default && \
    /usr/bin/tail -f /var/webmin/miniserv.log

> Use Webmin to start Apache OR Add more (optional) to CMD /usr/sbin/apache2ctl -D FOREGROUND

Build your container

    docker build -t my_website .

Run it, forwarding the host's port 80 to the container's NGNIX port 80

    docker run -d -it -p 10000:10000 -p 8080:80 my_website init


Log into webmin and manage your server
```
http://hostname.or.ip:10000
(admin:pass)
```

You should now be able to access the site on [your local machine port 8080](http://hostname.or.ip:8080/)
