[![](https://images.microbadger.com/badges/image/whindes/docker-mono-webmin.svg)](https://microbadger.com/images/whindes/docker-mono-webmin "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/whindes/docker-mono-webmin.svg)](https://microbadger.com/images/whindes/docker-mono-webmin "Get your own version badge on microbadger.com")

> Modified from original to blend docker-mono-apache source on [Seif Attar](https://github.com/seif/docker-mono-apache) with docker-webmin source fom [chsliu]
(https://github.com/chsliu/docker-webmin)

## Run mono web applications with nginx & apache mod_mono

This repository contains Dockerfile for publishing Docker's automated build to the public [Docker Hub Registry](https://registry.hub.docker.com/).

> NGINX is exposed from the container on port 80 to proxy to Apache on 8080. The mono-fastcgi-server4 loads the application from /var/www/dotnet.

### Base docker image

    debian/jessie (slim)

### Usage

First you need to pull the image:

    docker pull whindes/docker-mono-webmin
    or (alpine base)
    docker pull whindes/docker-mono-webmin:3.7

Then build your project, create a Dockerfile, copy the application to /var/www and start runit:

    FROM whindes/docker-mono-webmin
    ADD buildOutput/website /var/www/
    CMD /usr/bin/touch /var/webmin/miniserv.log && \
    /usr/sbin/service webmin restart && \
    /usr/bin/tail -f /var/webmin/miniserv.log

> Use Webmin to stop/start Apache(and NGINX) OR Add more (optional) to ENTRYPOINT & CMD

Build your container

    docker build -t my_website .

Run it, forwarding the host's port 8080 (any ports you wish) to the container's port 80

    docker run -d -it -p 10000:10000 -p 8080:80 my_website


Log into webmin and manage your server (port 10000)
```
http://hostname.or.ip:10000
(root:pass)
```

You should now be able to access the site on [your local machine port 8080](http://localhost:8080/)
