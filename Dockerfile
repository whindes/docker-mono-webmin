FROM mono
 
MAINTAINER William Hindes <bhindes@hotmail.com>

RUN apt-get update \
        && apt-get update \
        && apt-get install mono-devel apache2 libapache2-mod-mono mono-apache-server4 -y --no-install-recommends \
        && a2enmod mod_mono \
        && service apache2 stop \
        && apt-get autoremove -y \
        && apt-get clean \
        && rm -rf /var/tmp/* \
        && rm -rf /var/lib/apt/lists/* \
        && mkdir -p /etc/mono/registry /etc/mono/registry/LocalMachine \
        && sed -ri ' \
            s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
            s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
            ' /etc/apache2/apache2.conf
			
RUN echo root:pass | chpasswd && \
	echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" >/etc/apt/apt.conf.d/docker-gzip-indexes && \
	apt-get update && \
	apt-get install -y \
	wget \
	locales && \
	dpkg-reconfigure locales && \
	locale-gen C.UTF-8 && \
	/usr/sbin/update-locale LANG=C.UTF-8 && \
	wget http://www.webmin.com/jcameron-key.asc && \
	apt-key add jcameron-key.asc && \
	echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list && \
	echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y webmin libhtml-entities-numbered-perl libwww-perl && \
	apt-get clean && \
	mkdir -p /usr/share/webmin/module-archives && \
	cd /usr/share/webmin/module-archives && \
	wget https://www.justindhoffman.com/sites/justindhoffman.com/files/nginx-0.10.wbm_.gz && \
	chmod +x /usr/share/webmin/install-module.pl && \
	/usr/share/webmin/install-module.pl /usr/share/webmin/module-archives/nginx-0.10.wbm_.gz
	
	
ENV LC_ALL C.UTF-8

ADD ./config/apache2-site.conf /etc/apache2/sites-available/default
ADD ./config/apache2-site.conf /etc/apache2/sites-enabled/000-default.conf

WORKDIR /var/www

EXPOSE 10000 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
