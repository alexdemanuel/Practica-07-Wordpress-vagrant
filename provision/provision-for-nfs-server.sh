#set -x es para que veas cuando se esta ejecutando y ver donde esta el error
#vas a donde este el provision y le cambias los permisos con chmod +x nombre-provision.sh y despues lo ejecutamos con ./nombre-provision.sh

#Incluimos Provision-for-apache.sh
source /vagrant/provision/provision-for-apache.sh

#Instalamos los servicios NFS Para el servidor
apt-get update
apt-get install -y nfs-kernel-server

#Exportar el directorio en el servidor NFS
#Cambiamos los permisos del directorio que vamos a compartir
chown nobody:nogroup /var/www/html/wp-content

#copiamos el archivo export creado anteriormente a /etc/exports 

cp /vagrant/config/exports /etc/ -f

#Reiniciamos el servicio
/etc/init.d/nfs-kernel-server restart