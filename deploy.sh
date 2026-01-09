#!/bin/bash

# Script de deployment para Dokploy
# Este script copia los archivos necesarios al servidor

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== VolleyPass Projects - Deployment a Dokploy ===${NC}\n"

# Configuración
read -p "Ingresa el usuario del servidor (ej: root): " SERVER_USER
read -p "Ingresa la IP del servidor (ej: 192.168.1.100): " SERVER_IP
read -p "Ingresa la ruta en el servidor (ej: /opt/volleypass-projects): " SERVER_PATH

echo -e "\n${YELLOW}Configuración:${NC}"
echo "Usuario: $SERVER_USER"
echo "Servidor: $SERVER_IP"
echo "Ruta: $SERVER_PATH"
echo ""
read -p "¿Es correcta la configuración? (s/n): " CONFIRM

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
    echo -e "${RED}Deployment cancelado${NC}"
    exit 1
fi

# Crear directorio en el servidor
echo -e "\n${GREEN}1. Creando directorio en el servidor...${NC}"
ssh $SERVER_USER@$SERVER_IP "mkdir -p $SERVER_PATH"

# Copiar archivos
echo -e "${GREEN}2. Copiando archivos al servidor...${NC}"
scp docker-compose.yml $SERVER_USER@$SERVER_IP:$SERVER_PATH/
scp Dockerfile $SERVER_USER@$SERVER_IP:$SERVER_PATH/
scp .env.production $SERVER_USER@$SERVER_IP:$SERVER_PATH/.env
scp .gitignore $SERVER_USER@$SERVER_IP:$SERVER_PATH/
scp README.md $SERVER_USER@$SERVER_IP:$SERVER_PATH/

# Copiar directorios
echo -e "${GREEN}3. Copiando directorios...${NC}"
scp -r pb_hooks $SERVER_USER@$SERVER_IP:$SERVER_PATH/
scp -r pb_migrations $SERVER_USER@$SERVER_IP:$SERVER_PATH/

# Generar clave de encriptación en el servidor
echo -e "${GREEN}4. Generando clave de encriptación en el servidor...${NC}"
ENCRYPTION_KEY=$(ssh $SERVER_USER@$SERVER_IP "openssl rand -hex 32")
echo "Clave generada: $ENCRYPTION_KEY"

# Actualizar .env con la clave
ssh $SERVER_USER@$SERVER_IP "sed -i 's/GENERAR_NUEVA_CLAVE_AQUI/$ENCRYPTION_KEY/g' $SERVER_PATH/.env"

echo -e "\n${GREEN}=== Archivos copiados exitosamente ===${NC}"
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "1. Conectarte al servidor: ssh $SERVER_USER@$SERVER_IP"
echo "2. Ir al directorio: cd $SERVER_PATH"
echo "3. Revisar y editar .env con tu dominio de producción"
echo "4. Iniciar el servicio: docker-compose up -d"
echo "5. Acceder al Admin UI y crear la colección 'projects'"
echo ""
echo -e "${GREEN}¿Quieres conectarte al servidor ahora? (s/n):${NC}"
read CONNECT

if [ "$CONNECT" = "s" ] || [ "$CONNECT" = "S" ]; then
    ssh $SERVER_USER@$SERVER_IP "cd $SERVER_PATH && bash"
fi
