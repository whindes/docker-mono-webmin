#!/bin/bash

set -e

service apache2 start 
service nginx start 
service webmin start && tail -F /var/log/apache2/error.log
