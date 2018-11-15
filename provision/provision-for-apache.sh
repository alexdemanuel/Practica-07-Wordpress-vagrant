#!/bin/bash
apt-get update


#instalacion Apache HTTP Server
apt-get install -y apache2
apt-get install -y php libapache2-mod-php php-mysql
sudo /etc/init.d/apache2 restart



#Instalamos unzip y borramos lo que vamos a descargar por si se encuentra en la carpeta destino
cd /tmp 
apt-get install -y unzip
rm -rf latest.zip
#Descargamos wordpress y lo descomprimimos
wget https://wordpress.org/latest.zip
unzip -u latest.zip

#cambiamos el nombre al config para no tener que configurarlo
cd wordpress
cp wp-config-sample.php wp-config.php 

#CREAMOS LAS VARIABLES PARA ACCEDER A LA BASE DE DATOS
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
DB_HOST=192.168.33.13

#Le ponemos al config los parametros de la base de datos
sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sed -i "s/username_here/$DB_USER/" wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sed -i "s/localhost/$DB_HOST/" wp-config.php



#Copiamos los archivos a /var/www/html
#cp /tmp/wordpress /var/www/html/ -R

cp /tmp/wordpress/. /var/www/html/ -R

#Cambiamos los permisos
cd /var/www/html
chown www-data:www-data * -R

#Eliminamos el index.html para que nos muestre el index.php
rm /var/www/html/index.html 

