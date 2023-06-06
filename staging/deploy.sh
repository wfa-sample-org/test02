#!/bin/bash

a2dissite 000-default
cp -a /config/workspace/staging/apache/* /etc/apache2/sites-available
a2ensite app

service apache2 start
service mysql start