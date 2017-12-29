#!/bin/sh

set -e

echo "Mono .NET on Apache2 with NGINX reverse proxy"

openrc default && tail -F /var/log/apache2/error.log

