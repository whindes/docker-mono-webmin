FROM alpine:3.12
LABEL maintainer="William Hindes <bhindes@hotmail.com>"

ENV WEBMIN_VERSION="1.955" \
	APACHE_VERSION="2.4.46-r0" \ 
	MONO_VERSION="5.20.1.19-r1" \
	NGINX_VERSION="1.18.0-r0" 

ADD ./config /tmp

RUN apk upgrade --update \
	&& echo "http://dl-4.alpinelinux.org/alpine/edge/testing" | cat - /etc/apk/repositories  > repositories \
	&& mv -f repositories /etc/apk \
	&& apk update \
	&& apk --no-cache --update add \
		openrc \
		dcron \
		bash \
	# Add dcron to init
	&& rc-update add dcron default \
	&& echo 'null::respawn:/sbin/syslogd -n -S -D -O /proc/1/fd/1' >> /etc/inittab \
	&& rm -fr /var/cache/apk/* \
	&& mkdir /etc/rc0.d \
	&& mkdir /etc/rc1.d \
	&& mkdir /etc/rc2.d \
	&& mkdir /etc/rc3.d \
	&& mkdir /etc/rc4.d \
	&& mkdir /etc/rc5.d \
	&& sed -i '/tty/d' /etc/inittab \
	&& sed -i 's/#rc_sys=""/rc_sys="docker"/g' /etc/rc.conf \
	&& echo 'rc_provide="loopback net"' >> /etc/rc.conf \
	&& sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf \
	&& sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname \
	&& sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh \
	&& sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh \
	&& rm -f hwclock hwdrivers modules modules-load modloop \
	&& apk add --no-cache \
		openrc \
		apache2=="${APACHE_VERSION}" \
		nginx=="${NGINX_VERSION}" \
	# Clean cache again
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /run/apache2 \
	&& mkdir -p /var/www/dotnet \
	&& chown -R apache:apache /var/www \
	&& touch /var/www/dotnet/pico \
	&& mkdir -p /run/nginx \		
	&& apk add --no-cache \
		ca-certificates \
		mono=="${MONO_VERSION}" \
	&& update-ca-certificates \
	&& apk add --no-cache --virtual=.build-dependencies \
		apache2-dev=="${APACHE_VERSION}" \
		mono-dev=="${MONO_VERSION}" \
		git \
		wget \
		bash \
		automake \
		autoconf \
		findutils \
		make \
		pkgconf \
		libtool \
		g++ \
	&& mkdir -p /opt \
	&& git clone https://github.com/mono/xsp.git /opt/xsp \
	&& cd /opt/xsp \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr \
	&& make && make install \
	&& git clone https://github.com/mono/mod_mono.git /opt/mod_mono \
	&& cd /opt/mod_mono \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr --with-apxs=/usr/bin/apxs \
	&& make \
	&& make install \
	&& cd /opt \
	&& mv /etc/apache2/mod_mono.conf /etc/apache2/conf.d/mod_mono.conf \
	&& rm -rf /opt/xsp \
	&& rm -rf /opt/mod_mono \
	&& mkdir -p /etc/mono/registry /etc/mono/registry/LocalMachine \
	# Remove build dependencies
	&& apk del .build-dependencies \
	# mono-server2.exe is deprecated or not available for this build, so soft-link to suppress apache2 error.
	&& ln -s /usr/lib/mono/4.5/mod-mono-server4.exe /usr/lib/mono/4.5/mod-mono-server2.exe \
	&& apk update \
	&& apk add --no-cache \
		ca-certificates \
		openssl \
		perl \
		perl-html-parser \
		libssl1.1 \
		perl-crypt-ssleay \
		perl-net-ssleay \
	&& update-ca-certificates \
	&& apk add --no-cache --virtual=.build-dependencies \
		perl-dev \
		openssl-dev \
		git \
		wget \
		bash \
		automake \
		autoconf \
		findutils \
		make \
		pkgconf \
		libtool \
		g++ \
	&& echo | /usr/bin/cpan \
	#&& echo | /usr/bin/perl -MCPAN -e 'install Net::SSLeay' \
	&& wget http://prdownloads.sourceforge.net/webadmin/webmin-${WEBMIN_VERSION}.tar.gz -O /etc/webmin-${WEBMIN_VERSION}.tar.gz \
	&& cd /etc \
	&& gunzip webmin-${WEBMIN_VERSION}.tar.gz \
	&& tar xvf webmin-${WEBMIN_VERSION}.tar \
	&& mv /etc/webmin-${WEBMIN_VERSION} /etc/webmin \
	&& rm /etc/webmin-${WEBMIN_VERSION}.tar \
	&& mv /tmp/webmin_apache_config /etc/webmin/apache/config \
	&& mv /tmp/setup-pre.sh /etc/webmin/setup-pre.sh \
	&& mv /tmp/webmin /etc/init.d/webmin \
	&& chmod +x /etc/webmin/setup-pre.sh \
	&& sed -i 's/enable-collection.pl/enable-collection.plx/g' /etc/webmin/setup.sh \
	&& ln -s /etc /etc/rc.d \
	&& ln -s /etc/apache2 /etc/apache2/conf \
	&& mkdir -p /etc/apache2/sites-available \
	&& mkdir -p /etc/apache2/sites-enabled \
	&& mv /tmp/apache2-site.conf /etc/apache2/sites-available/apache2-mono_site.conf \
	&& sed -i 's/Listen 80/Listen 8008/g' /etc/apache2/httpd.conf \
	&& sed -i '/Listen 8008/ a\Listen 8080' /etc/apache2/httpd.conf \
	&& sed -i '/IncludeOptional \/etc\/apache2\/conf.d\/\*.conf/ a\IncludeOptional \/etc\/apache2\/sites-enabled\/\*.conf' /etc/apache2/httpd.conf \
	&& ln -s /etc/apache2/sites-available/apache2-mono_site.conf /etc/apache2/sites-enabled/apache2-mono_site.conf \
	&& mv /tmp/nginx-proxy.conf /etc/nginx/proxy.conf \
	&& mkdir -p /etc/nginx/sites-available \
	&& mkdir -p /etc/nginx/sites-enabled \
	&& mv /tmp/nginx-default.conf /etc/nginx/sites-available/nginx-default.conf \
	&& sed -i 's/^/#/' /etc/nginx/conf.d/default.conf \
	&& sed -i '/include \/etc\/nginx\/conf.d\/\*.conf;/ i\\tinclude \/etc\/nginx\/proxy.conf;' /etc/nginx/nginx.conf \
	&& sed -i '/include \/etc\/nginx\/conf.d\/\*.conf;/ a\\tinclude \/etc\/nginx\/sites-enabled\/\*.conf;' /etc/nginx/nginx.conf \
	&& ln -s /etc/nginx/sites-available/nginx-default.conf /etc/nginx/sites-enabled/nginx-default.conf \
	&& cd /etc/webmin \
	&& printf "110\n4.19.76" | ./setup.sh \
	&& mkdir -p /usr/share/webmin/module-archives \
	&& cd /usr/share/webmin/module-archives \
	&& wget https://www.justindhoffman.com/sites/justindhoffman.com/files/nginx-0.10.wbm_.gz \
	&& chmod +x /etc/webmin/install-module.pl \
	&& /etc/webmin/install-module.pl /usr/share/webmin/module-archives/nginx-0.10.wbm_.gz \
	&& mv /tmp/webmin_nginx_config /etc/webmin/nginx/config \
	# Fix for Nginx plugin to escape curly brace - bug in Webmin 1.870
	&& sed -i 's/(\$line =~ \/server {/(\$line =~ \/server \\{/g' /etc/webmin/nginx/nginx-lib.pl \
	# Remove build dependencies
	&& apk del .build-dependencies \
	&& mv /tmp/entrypoint.sh /entrypoint.sh \
	&& rm -rf /tmp/* \
	&& chmod +x /etc/init.d/webmin \
	&& mkdir /run/webmin \
	&& rc-update add apache2 default \
	&& rc-update add nginx default \
	&& rc-update add webmin default \
	&& openrc default


	# credit for above & many thanks to github.com/neeravkumar/dockerfiles and Sebastian Krohn <seb@gaia.sunn.de>

		
WORKDIR /var/www

EXPOSE 80 443 10000	

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/init"]