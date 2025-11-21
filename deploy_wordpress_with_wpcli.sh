#!/bin/bash

# =========================================================
# Script de automatización de la instalación de WordPress
# con WP-CLI en /var/www/html
# =========================================================

DB_NAME="wordpress_db_nestor"
DB_USER="wordpress_nestor"
DB_PASS="wordpress_Jodopa2006"  
DB_HOST="localhost"

WP_URL="practica-wordpress.ddns.net" 
WP_TITLE="Wordpress Nestor"
ADMIN_USER="wp_admin"
ADMIN_PASS="UNA_CONTRASENA_SEGURA"
ADMIN_EMAIL="aguileratorronestor@gmail.com"
WP_PATH="/var/www/html"

wp_cli() {
    sudo wp "$@" --path="$WP_PATH" --allow-root
}

echo "Paso 1: Configurando la base de datos..."

sudo mysql -u root -p<<MYSQL_COMMANDS
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${DB_HOST}';
FLUSH PRIVILEGES;
MYSQL_COMMANDS

if [ $? -ne 0 ]; then
    echo "❌ Error al configurar la base de datos. Abortando."
    exit 1
fi

echo "Paso 2: Limpiando y descargando WordPress..."

sudo chown -R $USER:$USER $WP_PATH 2>/dev/null
sudo rm -rf $WP_PATH/* 2>/dev/null

wp_cli core download --locale=es_ES

sudo chown -R www-data:www-data $WP_PATH
sudo find $WP_PATH -type d -exec chmod 755 {} \;
sudo find $WP_PATH -type f -exec chmod 644 {} \;

echo "Paso 3: Creando el archivo wp-config.php..."
wp_cli config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}" \
    --skip-check

sudo chown -R $USER:$USER $WP_PATH

echo "🚀 Paso 4: Instalando el núcleo de WordPress..."

if wp_cli core is-installed --quiet; then
    echo "WordPress ya estaba instalado. Saltando la instalación."
else
    wp_cli core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${ADMIN_PASS}" \
        --admin_email="${ADMIN_EMAIL}" \
        --skip-email
fi

echo "🛠️  Paso 5: Configurando enlaces permanentes..."
wp_cli rewrite structure '/%postname%/'

echo "Script finalizado con éxito."
echo "Detalles de Acceso:"
echo "URL: http://${WP_URL}"
echo "Usuario Admin: ${ADMIN_USER}"
echo "Contraseña Admin: ${ADMIN_PASS}"

sudo chown -R www-data:www-data $WP_PATH
