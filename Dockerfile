FROM mono:5.4.1.6
 
LABEL maintainer="William Hindes <bhindes@hotmail.com>"

ENV LC_ALL C.UTF-8

ADD ./config /tmp
##################################################
#                                                #
#  Install Apache and Mono Dependencies          #
#                                                #
##################################################

RUN apt-get update \
	&& apt-get install \
		mono-devel \
		apache2 \
		libapache2-mod-mono \
		mono-apache-server4 -y --no-install-recommends \
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
		' /etc/apache2/apache2.conf \
	&& sed -i 's/Listen 80/Listen 8008/g' /etc/apache2/ports.conf \
	&& sed -i '/Listen 8008/ a\Listen 8080' /etc/apache2/ports.conf \	
	&& sed -i 's/:80/:8008/g' /etc/apache2/sites-available/000-default.conf \
	&& mv /tmp/apache2-site.conf /etc/apache2/sites-available/apache2-mono_site.conf \
	&& ln -s /etc/apache2/sites-available/apache2-mono_site.conf /etc/apache2/sites-enabled/apache2-mono_site.conf \
	&& mkdir -p /var/www/dotnet \
##################################################
#                                                #
#  Install Webmin and NGINX module extension.    #
#                                                #
##################################################
    && echo root:pass | chpasswd \
	&& echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" >/etc/apt/apt.conf.d/docker-gzip-indexes \
	&& apt-get update \
	&& apt-get install -y \
		wget \
		locales \
		nginx \
	&& service nginx stop \
	&& mv /tmp/nginx-proxy.conf /etc/nginx/proxy.conf \
	&& mv /tmp/nginx-default.conf /etc/nginx/sites-available/nginx-default.conf \
	&& sed -i 's/^/#/' /etc/nginx/sites-available/default \
	&& rm /etc/nginx/sites-available/default \
	&& sed -i '/include \/etc\/nginx\/conf.d\/\*.conf;/ i\\tinclude \/etc\/nginx\/proxy.conf;' /etc/nginx/nginx.conf \
	&& sed -i '/include \/etc\/nginx\/conf.d\/\*.conf;/ a\\tinclude \/etc\/nginx\/sites-enabled\/\*.conf;' /etc/nginx/nginx.conf \
	&& ln -s /etc/nginx/sites-available/nginx-default.conf /etc/nginx/sites-enabled/nginx-default.conf \
	&& ln -s /var/log/nginx /usr/share/nginx/logs \
	&& dpkg-reconfigure locales \
	&& locale-gen C.UTF-8 \
	&& /usr/sbin/update-locale LANG=C.UTF-8 \
	&& wget http://www.webmin.com/jcameron-key.asc \
	&& apt-key add jcameron-key.asc \
	&& echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list \
	&& echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y \
		webmin \
		libhtml-entities-numbered-perl \
		libwww-perl \
	&& apt-get clean \
	&& mkdir -p /usr/share/webmin/module-archives \
	&& cd /usr/share/webmin/module-archives \
	&& wget https://www.justindhoffman.com/sites/justindhoffman.com/files/nginx-0.10.wbm_.gz \
	&& chmod +x /usr/share/webmin/install-module.pl \
	&& /usr/share/webmin/install-module.pl /usr/share/webmin/module-archives/nginx-0.10.wbm_.gz \
	&& apt-get update \
	&& mv /tmp/entrypoint.sh /entrypoint.sh 
	
	
WORKDIR /var/www

EXPOSE 10000 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/sbin/init"]