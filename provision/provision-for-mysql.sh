#!/bin/bash
set -x
apt-get update
apt-get install -y debconf-utils

#seleccionamos la contraseña para root
DB_ROOT_PASSWD=123456
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_ROOT_PASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_ROOT_PASSWD"
#instalamos mysql
apt-get install -y mysql-server

# Esto entra la achivo mysqld.cnf y reemplaza 127.0.0.1 por 0.0.0.0 para que todos se puedan conectar a esta base de datos
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
/etc/init.d/mysql restart

mysql -uroot -p$DB_ROOT_PASSWD <<< "GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY '$DB_ROOT_PASSWD';"
mysql -uroot -p$DB_ROOT_PASSWD <<< "FLUSH PRIVILEGES;"

#CREAMOS LA BASE DE DATOS
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password

mysql -uroot -p$DB_ROOT_PASSWD <<< "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -uroot -p$DB_ROOT_PASSWD <<< "CREATE DATABASE $DB_NAME CHARACTER SET utf8;"
mysql -uroot -p$DB_ROOT_PASSWD <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql -uroot -p$DB_ROOT_PASSWD <<< "FLUSH PRIVILEGES;"





