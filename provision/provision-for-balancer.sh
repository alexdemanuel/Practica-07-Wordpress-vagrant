#!/bin/bash
apt-get update
#Instalamos Apache
apt-get install -y apache2
apt-get install -y php libapache2-mod-php php-mysql

#Activación de los módulos necesarios en Apache
a2enmod proxy deflate
a2enmod proxy_http deflate
a2enmod proxy_ajp deflate
a2enmod rewrite deflate
a2enmod deflate deflate
a2enmod headers deflate
a2enmod proxy_balancer deflate
a2enmod proxy_connect deflate
a2enmod proxy_html deflate
a2enmod lbmethod_byrequests deflate

#Borramos el default.conf y copiamos el nuestro con los parametros deseados

rm -f /etc/apache2/sites-enabled/000-default.conf

sudo cp /vagrant/config/000-default.conf /etc/apache2/sites-enabled 

sudo /etc/init.d/apache2 restart