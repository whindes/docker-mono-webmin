> Modified from original to blend docker-mono-apache source on [Seif Attar](https://github.com/seif/docker-mono-apache) with docker-webmin source fom [chsliu]
(https://github.com/chsliu/docker-webmin)

## Run mono web applications with apache mod_mono

This repository contains Dockerfile for publishing Docker's automated build to the public [Docker Hub Registry](https://registry.hub.docker.com/).

> Apache is exposed from the container on port 80 and the mono-fastcgi-server4 loads the application from /var/www.

### Base docker image

    debian/jessie

### Usage

First you need to pull the image:

    docker pull whindes/docker-mono-webmin

Then build your project, create a Dockerfile, copy the application to /var/www and start runit:

    FROM whindes/docker-mono-webmin
    ADD buildOutput/website /var/www/
    CMD /usr/bin/touch /var/webmin/miniserv.log && \
    /usr/sbin/service webmin restart && \
    /usr/bin/tail -f /var/webmin/miniserv.log

> Use Webmin to start Apache OR Add more (optional) to CMD /usr/sbin/apache2ctl -D FOREGROUND

Build your container

    docker build -t my_website .

Run it, forwarding the host's port 8080 to the container's port 80

    docker run -d -it -p 10000:10000 -p 8080:80 my_website


Log into webmin and manage your server
```
http://hostname.or.ip:10000
(root:pass)
```

You should now be able to access the site on [your local machine port 8080](http://hostname.or.ip:8080/)
