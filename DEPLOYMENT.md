# Deployment en Dokploy - Guía Completa

Esta guía te ayudará a hacer deployment de `projects-volleypass` en Dokploy usando Git.

## Prerequisitos

- Servidor con Dokploy instalado y configurado
- Acceso al panel de Dokploy (ej: https://dokploy.tuservidor.com)
- Repositorio Git con el código (GitHub, GitLab, etc.)
- (Opcional) Dominio configurado para el servicio

## Paso 1: Preparar el Repositorio

Asegúrate de que estos archivos estén en tu repositorio:

```
✓ docker-compose.yml
✓ Dockerfile
✓ .env.example
✓ .gitignore
✓ README.md
✓ pb_hooks/main.pb.js
✓ pb_migrations/
```

**IMPORTANTE:** NO subas el archivo `.env` al repositorio (ya está en `.gitignore`). Las variables de entorno se configurarán en Dokploy.

## Paso 2: Acceder a Dokploy

1. Abre tu navegador y ve a tu panel de Dokploy
2. Inicia sesión con tus credenciales

## Paso 3: Crear Nuevo Proyecto en Dokploy

1. Click en **"New Project"** o **"Crear Proyecto"**
2. Selecciona **"Docker Compose"** como tipo de proyecto
3. Configuración básica:
   - **Project Name:** `volleypass-projects` o `projects-volleypass`
   - **Description:** "Discovery service para proyectos VolleyPass"

## Paso 4: Conectar Repositorio Git

### Opción A: Repositorio Público

1. En "Git Repository", pega la URL de tu repositorio:
   ```
   https://github.com/tu-usuario/projects-volleypass.git
   ```
   (Ajusta según tu plataforma: GitHub, GitLab, Bitbucket, etc.)

2. **Branch:** `main` (o `master`, según tu rama principal)

3. **Build Path:** `/` (raíz del proyecto)

### Opción B: Repositorio Privado

1. Pega la URL del repositorio

2. Agrega credenciales de acceso:
   - **Deploy Key (SSH):** Genera una clave SSH en Dokploy y agrégala a tu repositorio
   - **Personal Access Token:** Crea un token en tu plataforma Git y pégalo aquí
   - **Usuario/Contraseña:** (menos seguro, no recomendado)

## Paso 5: Configurar Variables de Entorno

En la sección "Environment Variables" de Dokploy, agrega las siguientes variables:

### Variables Requeridas:

```bash
# Port
PORT=8090

# PocketBase Version
PB_VERSION=0.23.4

# Encryption Key (GENERAR UNA NUEVA)
# Ejecutar en tu terminal local: openssl rand -hex 32
PB_ENCRYPTION_KEY=aqui_pega_la_clave_generada_con_openssl
```

### Generar la clave de encriptación:

En tu terminal local, ejecuta:
```bash
openssl rand -hex 32
```

Copia el resultado y pégalo en `PB_ENCRYPTION_KEY`.

**IMPORTANTE:** Usa una clave DIFERENTE a la de local. Nunca reutilices claves entre ambientes.

### Variables Opcionales (para configurar más adelante):

```bash
# URLs de producción (actualizar con tu dominio)
ADMIN_UI_URL=https://projects.volleypass.com/_
API_BASE_URL=https://projects.volleypass.com
```

## Paso 6: Configurar Puertos

En la sección "Ports" o "Network":

1. **Container Port:** `8090`
2. **Host Port:** `8090` (o el puerto que prefieras en el servidor)
3. **Protocol:** `TCP`

Si tienes un dominio configurado, también puedes agregar:
- **Domain:** `projects.volleypass.com`
- **SSL/TLS:** Habilitar (Dokploy puede auto-configurar Let's Encrypt)

## Paso 7: Configurar Volúmenes (Persistencia de Datos)

En la sección "Volumes":

Agregar los siguientes volúmenes para persistir los datos:

| Container Path      | Host Path (ejemplo)                          | Descripción           |
|---------------------|----------------------------------------------|-----------------------|
| `/pb/pb_data`       | `/var/lib/dokploy/projects-volleypass/data`  | Base de datos SQLite  |
| `/pb/pb_hooks`      | Usar bind mount al repo                      | Hooks personalizados  |
| `/pb/pb_migrations` | Usar bind mount al repo                      | Migraciones          |

**Nota:** Dokploy puede manejar los volúmenes automáticamente si usas docker-compose.yml.

## Paso 8: Configuración Adicional (Opcional)

### Health Check

Dokploy debería detectar el health check del Dockerfile automáticamente, pero verifica que esté configurado:

- **Endpoint:** `http://localhost:8090/api/health`
- **Interval:** `30s`
- **Timeout:** `3s`
- **Retries:** `3`

### Resource Limits (Opcional)

Si quieres limitar recursos:

- **Memory Limit:** `512MB` (ajustar según necesidad)
- **CPU Limit:** `0.5` cores (ajustar según necesidad)

## Paso 9: Deploy

1. Revisa toda la configuración
2. Click en **"Deploy"** o **"Desplegar"**
3. Dokploy hará:
   - Clone del repositorio
   - Build de la imagen Docker
   - Start del contenedor
   - Configuración de red y volúmenes

4. Monitorea los logs en tiempo real en el panel de Dokploy

## Paso 10: Verificar Deployment

Una vez completado el deployment:

### 1. Verificar que el servicio esté corriendo

En los logs de Dokploy deberías ver:
```
Server started at http://0.0.0.0:8090
├─ REST API:  http://0.0.0.0:8090/api/
└─ Dashboard: http://0.0.0.0:8090/_/
```

### 2. Probar el health endpoint

```bash
curl http://tu-servidor:8090/api/health
```

Respuesta esperada:
```json
{"message":"API is healthy.","code":200,"data":{}}
```

### 3. Acceder al Admin UI

Abre tu navegador en:
- Si usas IP: `http://tu-servidor:8090/_`
- Si usas dominio: `https://projects.volleypass.com/_`

## Paso 11: Configuración Inicial de PocketBase

Una vez que el servicio esté corriendo:

### 1. Crear Superusuario

**Opción A: Desde el navegador**
1. Accede a `http://tu-servidor:8090/_`
2. En el primer acceso, te pedirá crear un superusuario
3. Usa tus credenciales:
   - Email: `ing.korozco@gmail.com`
   - Password: (elige una contraseña segura para producción)

**Opción B: Desde terminal (si tienes acceso SSH)**
```bash
# Conectarte al servidor
ssh usuario@tu-servidor

# Ejecutar comando en el contenedor de Dokploy
docker exec -it <container-name> /pb/pocketbase superuser upsert ing.korozco@gmail.com TuPasswordSegura
```

### 2. Crear Colección "projects"

En el Admin UI:

1. Click en **"New collection"**
2. **Name:** `projects`
3. **Type:** Base collection

### 3. Agregar Campos

| Campo       | Tipo    | Required | Unique | Options                    |
|-------------|---------|----------|--------|----------------------------|
| projectId   | text    | ✓        | ✓      | Min: 3, Max: 50            |
| name        | text    | ✓        |        | Min: 3, Max: 100           |
| shortName   | text    | ✓        |        | Max: 50                    |
| description | text    |          |        | Max: 500                   |
| baseUrl     | url     | ✓        |        | Debe ser URL válida        |
| isActive    | bool    | ✓        |        | Default: true              |

### 4. Configurar API Rules

En la colección "projects", pestaña "API Rules":

- **List rule:** (dejar vacío para público)
- **View rule:** (dejar vacío para público)
- **Create rule:** `@request.auth.id != ""`
- **Update rule:** `@request.auth.id != ""`
- **Delete rule:** `@request.auth.id != ""`

### 5. Agregar Proyectos Iniciales

En Collections > projects > New record:

**Proyecto 1:**
```
projectId: athletic-sincelejo
name: Athletic Sincelejo
shortName: Athletic
description: Club de voleibol Athletic Sincelejo
baseUrl: https://api.athleticsincelejo.com
isActive: true
```

**Proyecto 2:**
```
projectId: liga-sucre
name: Liga de Voleibol de Sucre
shortName: Liga Sucre
description: Liga departamental de voleibol de Sucre
baseUrl: https://api.ligadevoleiboldesucre.com
isActive: true
```

## Paso 12: Probar API en Producción

```bash
# Listar proyectos
curl "https://projects.volleypass.com/api/collections/projects/records?fields=id,projectId,name"

# Obtener proyecto específico
curl "https://projects.volleypass.com/api/collections/projects/records/RECORD_ID"
```

## Configurar Dominio Personalizado (Opcional)

Si quieres usar un dominio como `projects.volleypass.com`:

### 1. En tu proveedor DNS

Agrega un registro A o CNAME apuntando a tu servidor:
```
Type: A
Name: projects
Value: IP_DE_TU_SERVIDOR
TTL: 3600
```

### 2. En Dokploy

1. Ve a la configuración del proyecto
2. En "Domains", agrega: `projects.volleypass.com`
3. Habilita SSL/TLS (Let's Encrypt)
4. Dokploy configurará automáticamente el certificado HTTPS

### 3. Actualizar variables de entorno

Actualiza las URLs en las variables de entorno:
```bash
ADMIN_UI_URL=https://projects.volleypass.com/_
API_BASE_URL=https://projects.volleypass.com
```

## Actualizar el Proyecto (Redeployment)

Cuando hagas cambios en el código:

### 1. Push al repositorio
```bash
git add .
git commit -m "Actualización del servicio"
git push origin main
```

### 2. En Dokploy

**Opción A: Auto-deploy (si está configurado)**
- Dokploy detectará el push y hará redeploy automáticamente

**Opción B: Manual**
- Ve al proyecto en Dokploy
- Click en "Redeploy" o "Rebuild"

## Backup de Datos

### Backup Manual

```bash
# Conectarte al servidor
ssh usuario@tu-servidor

# Copiar base de datos
docker exec <container-name> cp /pb/pb_data/data.db /pb/pb_data/data.db.backup

# Descargar backup a tu máquina local
docker cp <container-name>:/pb/pb_data/data.db.backup ./pocketbase-backup-$(date +%Y%m%d).db
```

### Backup Automático (Cron)

Crear un script de backup automático en el servidor:

```bash
#!/bin/bash
# /opt/scripts/backup-pocketbase.sh

CONTAINER_NAME="volleypass-projects"
BACKUP_DIR="/backups/pocketbase"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

docker exec $CONTAINER_NAME cp /pb/pb_data/data.db /pb/pb_data/data.db.backup
docker cp $CONTAINER_NAME:/pb/pb_data/data.db.backup $BACKUP_DIR/pocketbase-$DATE.db

# Mantener solo últimos 7 días
find $BACKUP_DIR -name "pocketbase-*.db" -mtime +7 -delete
```

Agregar a crontab (backup diario a las 2 AM):
```bash
0 2 * * * /opt/scripts/backup-pocketbase.sh
```

## Monitoreo

### Logs en Tiempo Real

En Dokploy:
- Ve al proyecto
- Click en "Logs"
- Ver logs en tiempo real

### Health Checks

Configurar monitoreo externo (opcional):
- **UptimeRobot:** https://uptimerobot.com
- **Ping:** `https://projects.volleypass.com/api/health`
- **Intervalo:** Cada 5 minutos

## Troubleshooting

### El servicio no inicia

1. Revisar logs en Dokploy
2. Verificar variables de entorno (especialmente `PB_ENCRYPTION_KEY`)
3. Verificar que el puerto 8090 no esté en uso

### No puedo acceder al Admin UI

1. Verificar que el contenedor esté corriendo
2. Verificar configuración de puertos
3. Verificar firewall del servidor
4. Si usas dominio, verificar DNS

### Error "encryption key is not set"

1. Generar nueva clave: `openssl rand -hex 32`
2. Actualizar variable `PB_ENCRYPTION_KEY` en Dokploy
3. Redeploy

### Los datos se pierden al redeploy

1. Verificar que los volúmenes estén configurados correctamente
2. Asegurarte de que `/pb/pb_data` esté mapeado a un volumen persistente

## Comandos Útiles

```bash
# Ver contenedores corriendo
docker ps | grep volleypass

# Ver logs
docker logs -f <container-name>

# Ejecutar comando en el contenedor
docker exec -it <container-name> /bin/sh

# Ver uso de recursos
docker stats <container-name>

# Restart del servicio
docker restart <container-name>
```

## Seguridad en Producción

1. **Usar HTTPS:** Siempre habilitar SSL/TLS
2. **Contraseñas fuertes:** Para el superusuario
3. **Backup regular:** De la base de datos
4. **Firewall:** Permitir solo puertos necesarios
5. **Actualizar:** Mantener PocketBase actualizado
6. **Monitoreo:** Configurar alertas de uptime

## Recursos

- [Documentación de Dokploy](https://docs.dokploy.com)
- [PocketBase Docs](https://pocketbase.io/docs/)
- [Docker Compose Docs](https://docs.docker.com/compose/)

---

¿Necesitas ayuda? Revisa los logs en Dokploy o contacta al equipo de soporte.
