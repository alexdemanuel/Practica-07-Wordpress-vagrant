
#Incluimos Provision-for-apache.sh
source /vagrant/provision/provision-for-apache.sh

#Instalamos los servicios NFS para cliente
apt-get update
apt-get install -y nfs-common

#Montamos la carpeta compartida del servidor

mount 192.168.33.11:/var/www/html/wp-content /var/www/html/wp-content

#Copiamos el archivo nsftab para que monte la maquina

cp /vagrant/config/fstab /etc -f