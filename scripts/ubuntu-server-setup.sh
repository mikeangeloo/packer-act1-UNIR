#!/bin/sh
sleep 30

## Paso 1: Instalación de node js
# Instalando node js
cd ~
curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs
# Revisando versión de node y npm
node -v
npm -v
# Instalación de build-essential para aquellos que requieren compilar código desde la fuente
sudo apt install -y build-essential

## Paso 2: Instalando PM2
sudo npm install pm2@latest -g

## Paso 3: Configuración de PM2
# Configurando pm2 para ejecutar demo-node.js en el arranque
mkdir -p ~/code/app-dist
mv /tmp/demo-node.js ~/code/app-dist/demo-node.js
cd  ~/code/app-dist/
sudo pm2 start demo-node.js
sudo pm2 startup systemd
sudo pm2 save
# Iniciando servicio personalizado en pm2
sudo systemctl status pm2-root
sudo pm2 list

## Pase 4: Configurando Nginx como servidor proxy inverso
sudo apt install -y nginx
# Comprobando que el servicio Nginx se esté ejecutando
sudo systemctl status nginx
#Moviendo la configuración para proxy conf.d
sudo mv /tmp/demo-node.conf /etc/nginx/conf.d
#Reiniciando el servidor nginx para aplicar cambios
sudo systemctl restart nginx