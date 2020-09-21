#!/bin/sh

set -e

echo "Mono .NET on Apache2 with NGINX reverse proxy"

# Start/Stop/Apply NGINX & Apache2 in the Webmin > Servers area. 
openrc default

ln -s /etc/rc.d/init.d/apache2 /etc/rc2.d/S99apache2 
ln -s /etc/rc.d/init.d/apache2 /etc/rc3.d/S99apache2 
ln -s /etc/rc.d/init.d/apache2 /etc/rc5.d/S99apache2 

ln -s /etc/rc.d/init.d/nginx /etc/rc2.d/S99nginx 
ln -s /etc/rc.d/init.d/nginx /etc/rc3.d/S99nginx 
ln -s /etc/rc.d/init.d/nginx /etc/rc5.d/S99nginx

exec $@

