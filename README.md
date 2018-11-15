# Practica-07-Wordpress-vagrant
# Creación de la máquina con vagrant

- Inicializamos vagrant que nos creara un archivo `Vagrantfile`.

```bash
 vagrant init
 ```

- Accedemos al archivo `Vagrantfile` y ponemos lo siguiente en su interior:

```bash
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"

    # Load Balancer
    config.vm.define "balancer" do |app|
      app.vm.hostname = "balanacer"
      app.vm.network "private_network", ip: "192.168.33.10"
      app.vm.provision "shell", path: "provision/provision-for-balancer.sh"
    end
     
    # Apache HTTP Server
    config.vm.define "web1" do |app|
      app.vm.hostname = "web1"
      app.vm.network "private_network", ip: "192.168.33.11"
      app.vm.provision "shell", path: "provision/provision-for-nfs-server.sh"
    end

    # Apache HTTP Server 2
      config.vm.define "web2" do |app|
        app.vm.hostname = "web2"
        app.vm.network "private_network", ip: "192.168.33.12"
        app.vm.provision "shell", path: "provision/provision-for-nfs-client.sh"
      end
  
    # MySQL Server
    config.vm.define "db" do |app|
      app.vm.hostname = "db"
      app.vm.network "private_network", ip: "192.168.33.13"
      app.vm.provision "shell", path: "provision/provision-for-mysql.sh"
    end

end


```

## Creación del archivo `provision-for-balancer.sh` para hacer el *provision*

- Instalamos Apache
```bash
apt-get install -y apache2
apt-get install -y php libapache2-mod-php php-mysql
```

- Activación de los módulos necesarios en Apache

```bash
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
```
- Creamos un 000-default.conf con lo siguiente en su interior

```bash
<VirtualHost *:80>
 
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Proxy balancer://mycluster>
        # Server 1 - Ip del servidor web 1
        BalancerMember http://192.168.33.11 

        # Server 2 - Ip del servidor web 2
        BalancerMember http://192.168.33.12
    </Proxy>

    ProxyPass / balancer://mycluster/
</VirtualHost>
```
- Borramos el default.conf y copiamos el nuestro con los parametros deseados
```bash

rm -f /etc/apache2/sites-enabled/000-default.conf

sudo cp /vagrant/ /etc/apache2/sites-enabled -R

sudo /etc/init.d/apache2 restart

```


## Creación del archivo `provision-for-apache.sh` para hacer el *provision*

**Donde meteremos los comandos para instalar las utilidades que necesitemos para la maquina de apache**

- Actualizamos los repositorios.
```bash
apt-get update
```

- Instalacion Apache HTTP Server
```bash
apt-get install -y apache2
apt-get install -y php libapache2-mod-php php-mysql
sudo /etc/init.d/apache2 restart
```
- Clonamos repositorio de la apicacion web
- Instalamos unzip y borramos lo que vamos a descargar por si se encuentra en la carpeta destino
```bash
cd /tmp 
apt-get install -y unzip
rm -rf latest.zip
```
- Descargamos wordpress y lo descomprimimos
```bash
wget https://wordpress.org/latest.zip
unzip -u latest.zip
```

- cambiamos el nombre al config para no tener que configurarlo
```bash
cd wordpress
cp wp-config-sample.php wp-config.php 
```

- CREAMOS LAS VARIABLES PARA ACCEDER A LA BASE DE DATOS
```bash
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password
DB_HOST=192.168.33.13
```

- Le ponemos al config los parametros de la base de datos
```bash
sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sed -i "s/username_here/$DB_USER/" wp-config.php
sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sed -i "s/localhost/$DB_HOST/" wp-config.php
```


-Copiamos los archivos a /var/www/html

```bash
cp /tmp/wordpress/. /var/www/html/ -R
```
- Cambiamos los permisos

```bash
cd /var/www/html
chown www-data:www-data * -R
```
- Eliminamos el index.html para que nos muestre el index.php

```bash
rm /var/www/html/index.html 
```

## Creación del archivo `provision-for-nfs-server.sh` para hacer el *provision*
- Incluimos Provision-for-apache.sh

```bash
source /vagrant/provision/provision-for-apache.sh
```

- Instalamos los servicios NFS Para el servidor

```bash
apt-get update
apt-get install -y nfs-kernel-server
```

- Exportar el directorio en el servidor NFS
-- Cambiamos los permisos del directorio que vamos a compartir

```bash
chown nobody:nogroup /var/www/html/wp-content
```
- copiamos el archivo export creado anteriormente a /etc/exports 

```bash
cp /vagrant/config/exports /etc/ -f
```

- Reiniciamos el servicio
```bash
/etc/init.d/nfs-kernel-server restart
```

## Creación del archivo `provision-for-mysql.sh` para hacer el *provision*

- Instalamos las utilidades 

```bash
apt-get update
apt-get install -y debconf-utils
```

- Seleccionamos la contraseña para root

```bash
DB_ROOT_PASSWD=123456
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_ROOT_PASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_ROOT_PASSWD"
```

- Instalamos el servidor de MYSQL

```bash
apt-get install -y mysql-server
```

 - configuramos el archivo mysqld.cnf y reemplaza 127.0.0.1 por 0.0.0.0 para que todos se puedan conectar a esta base de datos

 ```bash
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
/etc/init.d/mysql restart
```

- Damos permisos al usuario root que tiene acceso remoto a mysql

```bash
mysql -uroot -p$DB_ROOT_PASSWD <<< "GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY '$DB_ROOT_PASSWD';"
mysql -uroot -p$DB_ROOT_PASSWD <<< "FLUSH PRIVILEGES;"
```

- CREAMOS LA BASE DE DATOS

```bash
DB_NAME=wordpress_db
DB_USER=wordpress_user
DB_PASSWORD=wordpress_password

mysql -uroot -p$DB_ROOT_PASSWD <<< "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -uroot -p$DB_ROOT_PASSWD <<< "CREATE DATABASE $DB_NAME CHARACTER SET utf8;"
mysql -uroot -p$DB_ROOT_PASSWD <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql -uroot -p$DB_ROOT_PASSWD <<< "FLUSH PRIVILEGES;"
```
