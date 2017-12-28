#!/bin/bash
LANG=C.UTF-8
export config_dir=/etc/webmin
export var_dir=/var/webmin
export perl=/usr/bin/perl
export port=10000
export login="admin"
export password="pass"
export ssl=1
export atboot=0
#for ((i=1;i<=10; i++)); do mkdir "/etc/rc$i.d"; done
#mkdir /etc/rc{0..6}.d
