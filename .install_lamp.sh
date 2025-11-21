#!/bin/bash
# Script para instalar el Stack LAMP (Apache, MariaDB, PHP)

echo "--- Actualizando paquetes del sistema ---"
sudo apt update
sudo apt upgrade -y

echo "--- Instalando Apache2 ---"
sudo apt install apache2 -y

echo "--- Instalando MariaDB ---"
sudo apt install mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb

echo "--- Instalando PHP 8.x y módulos necesarios para WordPress ---"
# Estos módulos resuelven problemas de ejecución de PHP
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

echo "--- Habilitando módulo de reescritura de Apache ---"
sudo a2enmod rewrite

echo "--- Reiniciando Apache ---"
sudo systemctl restart apache2

echo "--- Instalación LAMP completada ---"
