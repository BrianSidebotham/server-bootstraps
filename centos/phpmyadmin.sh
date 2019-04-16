#!/bin/sh

# Get a PHP server up and running successfully (in a bodgy sort of way)

if [ "$(id -u)X" != "0X" ]; then
    echo "Must be root" >&2
    exit 1
fi

yum install -y epel-release
yum install httpd phpmyadmin

firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https

systemctl start httpd
systemctl enable httpd

yum install -y php-pspell php-pecl-memcache php php-mysql php-devel php-gd php-snmp php-xmlrpc php-xml mariadb mariadb-server

systemctl start mariadb
systemctl enable mariadb

# Pick up the php installation
systemctl restart httpd

# Finish off the mysql secure installation by hand
mysql_secure_installation
