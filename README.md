# VolleyPass Projects - Discovery Service

Servicio de discovery para gestionar múltiples instancias backend de VolleyPass usando PocketBase.

## Descripción

Este servicio proporciona una API centralizada para gestionar y descubrir proyectos (instancias) de VolleyPass. Cada proyecto representa una entidad diferente (club, liga) con su propia API backend.

### Características

- API REST automática generada por PocketBase
- Admin UI integrada para gestión visual de proyectos
- Autenticación built-in
- Base de datos SQLite embebida
- Endpoints públicos para lectura
- Endpoints protegidos para escritura
- Docker-ready para deployment fácil

## Arquitectura

```
┌─────────────────┐
│   Flutter App   │
└────────┬────────┘
         │
         │ GET /api/collections/projects/records
         │ (lista de proyectos)
         ▼
┌─────────────────────────────────┐
│  PocketBase Discovery Service   │
│  (projects-volleypass)          │
└─────────────────────────────────┘
         │
         ├─► SQLite Database (pb_data)
         └─► Admin UI (/_)
```

## Prerequisitos

- Docker
- Docker Compose
- (Opcional) curl para testing

## Setup Local

### 1. Clonar y configurar

```bash
# Navegar al directorio del proyecto
cd projects-volleypass

# Copiar el archivo de ejemplo de variables de entorno
cp .env.example .env

# Generar una clave de encriptación
openssl rand -hex 32

# Editar .env y agregar la clave generada en PB_ENCRYPTION_KEY
nano .env
```

### 2. Iniciar el servicio

```bash
# Build y start
docker-compose up -d

# Ver logs
docker-compose logs -f

# Verificar que esté corriendo
curl http://localhost:8090/api/health
```

### 3. Configurar PocketBase (primer uso)

1. Acceder al Admin UI: http://localhost:8090/_
2. Crear cuenta de administrador (primer acceso)
3. Crear colección "projects" con los siguientes campos:

| Campo       | Tipo    | Requerido | Único | Opciones                    |
|-------------|---------|-----------|-------|-----------------------------|
| projectId   | text    | ✓         | ✓     | Min: 3, Max: 50             |
| name        | text    | ✓         |       | Min: 3, Max: 100            |
| shortName   | text    | ✓         |       | Max: 50                     |
| description | text    |           |       | Max: 500                    |
| baseUrl     | url     | ✓         |       | Debe ser URL válida         |
| isActive    | bool    | ✓         |       | Default: true               |

4. Configurar reglas de acceso (API Rules):
   - **List**: Dejar vacío (público)
   - **View**: Dejar vacío (público)
   - **Create**: `@request.auth.id != ""`
   - **Update**: `@request.auth.id != ""`
   - **Delete**: `@request.auth.id != ""`

### 4. Agregar proyectos de prueba

Usando el Admin UI:
1. Navegar a Collections > projects
2. Click en "New record"
3. Agregar los datos:
   - projectId: `athletic-sincelejo`
   - name: `Athletic Sincelejo`
   - shortName: `Athletic`
   - description: `Club de voleibol Athletic Sincelejo`
   - baseUrl: `https://api.athleticsincelejo.com`
   - isActive: `true`

4. Repetir para otros proyectos

## API Endpoints

Base URL: `http://localhost:8090` (local) o `https://projects.volleypass.com` (producción)

### Públicos (sin autenticación)

#### Listar proyectos (solo ID y nombre)
```bash
GET /api/collections/projects/records?fields=id,projectId,name

# Ejemplo con curl
curl "http://localhost:8090/api/collections/projects/records?fields=id,projectId,name"
```

**Respuesta:**
```json
{
  "page": 1,
  "perPage": 30,
  "totalItems": 2,
  "totalPages": 1,
  "items": [
    {
      "id": "RECORD_ID_1",
      "projectId": "athletic-sincelejo",
      "name": "Athletic Sincelejo"
    },
    {
      "id": "RECORD_ID_2",
      "projectId": "liga-sucre",
      "name": "Liga de Voleibol de Sucre"
    }
  ]
}
```

#### Obtener proyecto completo
```bash
GET /api/collections/projects/records/:id

# Ejemplo con curl
curl "http://localhost:8090/api/collections/projects/records/RECORD_ID"
```

**Respuesta:**
```json
{
  "id": "RECORD_ID",
  "collectionId": "COLLECTION_ID",
  "collectionName": "projects",
  "created": "2026-01-09 15:00:00.000Z",
  "updated": "2026-01-09 15:00:00.000Z",
  "projectId": "athletic-sincelejo",
  "name": "Athletic Sincelejo",
  "shortName": "Athletic",
  "description": "Club de voleibol Athletic Sincelejo",
  "baseUrl": "https://api.athleticsincelejo.com",
  "isActive": true
}
```

### Protegidos (requieren autenticación)

#### Autenticarse
```bash
POST /api/collections/users/auth-with-password
Content-Type: application/json

{
  "identity": "admin@admin.com",
  "password": "your-password"
}
```

**Respuesta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "record": { ... }
}
```

#### Crear proyecto
```bash
POST /api/collections/projects/records
Authorization: Bearer <token>
Content-Type: application/json

{
  "projectId": "new-project",
  "name": "New Project",
  "shortName": "New",
  "description": "Description here",
  "baseUrl": "https://api.newproject.com",
  "isActive": true
}
```

#### Actualizar proyecto
```bash
PATCH /api/collections/projects/records/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "isActive": false
}
```

#### Eliminar proyecto
```bash
DELETE /api/collections/projects/records/:id
Authorization: Bearer <token>
```

## Deployment en Dokploy

### 1. Preparar el servidor

```bash
# En el servidor
mkdir -p /opt/volleypass-projects
cd /opt/volleypass-projects

# Copiar archivos necesarios
# - docker-compose.yml
# - Dockerfile
# - .env (con valores de producción)
# - pb_hooks/ (si tienes hooks)
# - pb_migrations/ (si tienes migraciones)
```

### 2. Configurar variables de entorno

```bash
# Crear .env en el servidor
cp .env.example .env

# Generar clave de encriptación
openssl rand -hex 32

# Editar .env
nano .env
```

### 3. Deploy con Dokploy

Dokploy detectará automáticamente el `docker-compose.yml` y hará el deployment.

Alternativamente, deployment manual:

```bash
# Build y start
docker-compose up -d

# Verificar
curl http://servidor:8090/api/health
```

### 4. Configurar reverse proxy (opcional)

Si quieres usar un dominio personalizado con SSL:

```nginx
# Nginx config example
server {
    listen 443 ssl http2;
    server_name projects.volleypass.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:8090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Gestión de Datos

### Opción 1: Admin UI (Recomendado)

1. Acceder a http://localhost:8090/_
2. Login con credenciales de admin
3. Navegar a Collections > projects
4. Usar interfaz visual para CRUD

### Opción 2: API REST

Ver sección "API Endpoints" arriba.

### Opción 3: Hooks personalizados

Crear hooks en `pb_hooks/main.pb.js` para automatizaciones:

```javascript
// Ejemplo: Validación personalizada
onRecordBeforeCreateRequest((e) => {
  // Tu lógica aquí
}, "projects")
```

## Comandos Útiles

```bash
# Ver logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop
docker-compose down

# Stop y eliminar volúmenes (⚠️ borra datos)
docker-compose down -v

# Backup de base de datos
cp pb_data/data.db pb_data/data.db.backup

# Verificar salud del servicio
curl http://localhost:8090/api/health

# Listar proyectos
curl "http://localhost:8090/api/collections/projects/records?fields=id,name"
```

## Troubleshooting

### PocketBase no inicia

```bash
# Ver logs
docker-compose logs pocketbase

# Verificar permisos
ls -la pb_data/

# Verificar puerto
netstat -tulpn | grep 8090
```

### No puedo acceder al Admin UI

1. Verificar que el contenedor esté corriendo: `docker-compose ps`
2. Verificar logs: `docker-compose logs`
3. Verificar puerto: `curl http://localhost:8090/_`

### Error "encryption key is not set"

1. Generar clave: `openssl rand -hex 32`
2. Agregar a `.env`: `PB_ENCRYPTION_KEY=<clave-generada>`
3. Restart: `docker-compose restart`

### Los cambios no se persisten

Verificar que el volumen esté montado correctamente:
```bash
docker-compose down
ls -la pb_data/
docker-compose up -d
```

## Estructura de Archivos

```
projects-volleypass/
├── docker-compose.yml       # Configuración Docker
├── Dockerfile              # Imagen Docker con PocketBase
├── .env                    # Variables de entorno (NO COMMIT)
├── .env.example            # Template de variables
├── .gitignore              # Archivos a ignorar
├── README.md               # Este archivo
├── pb_data/                # Datos de PocketBase (auto-generado)
│   └── data.db            # Base de datos SQLite
├── pb_hooks/               # Hooks personalizados (opcional)
│   └── main.pb.js
└── pb_migrations/          # Migraciones (opcional)
    └── collections.json
```

## Seguridad

- Nunca commitear `.env` al repositorio
- Usar contraseñas fuertes para el admin
- Mantener PocketBase actualizado
- Usar HTTPS en producción
- Backup regular de `pb_data/data.db`

## Actualizar PocketBase

```bash
# Editar .env
PB_VERSION=0.24.0  # Nueva versión

# Rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Soporte

- [PocketBase Docs](https://pocketbase.io/docs/)
- [PocketBase GitHub](https://github.com/pocketbase/pocketbase)
- [Docker Docs](https://docs.docker.com/)

## Licencia

MIT
