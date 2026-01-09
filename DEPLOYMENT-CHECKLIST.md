# ✅ Checklist de Deployment en Dokploy

Usa este checklist para asegurarte de completar todos los pasos del deployment.

## Pre-Deployment

- [ ] Repositorio Git subido con todos los archivos necesarios
  - [ ] `docker-compose.yml`
  - [ ] `Dockerfile`
  - [ ] `.env.example`
  - [ ] `.gitignore`
  - [ ] `README.md`
  - [ ] `pb_hooks/`
  - [ ] `pb_migrations/`
- [ ] **NO** subiste el archivo `.env` al repositorio
- [ ] Generar clave de encriptación: `openssl rand -hex 32`
- [ ] Anotar la clave generada (la necesitarás en Dokploy)

## En Dokploy

### 1. Crear Proyecto
- [ ] Acceder al panel de Dokploy
- [ ] Crear nuevo proyecto
- [ ] Seleccionar tipo: **Docker Compose**
- [ ] Nombre: `volleypass-projects`

### 2. Conectar Git
- [ ] Pegar URL del repositorio
- [ ] Seleccionar branch: `main` (o tu rama principal)
- [ ] Autenticación configurada (si es repo privado)

### 3. Variables de Entorno
- [ ] `PORT=8090`
- [ ] `PB_VERSION=0.23.4`
- [ ] `PB_ENCRYPTION_KEY=<tu-clave-generada>`

### 4. Configurar Red
- [ ] Puerto: 8090:8090
- [ ] (Opcional) Dominio: `projects.volleypass.com`
- [ ] (Opcional) SSL/TLS habilitado

### 5. Deploy
- [ ] Click en "Deploy"
- [ ] Monitorear logs
- [ ] Esperar a que finalice el build

## Post-Deployment

### 1. Verificar Servicio
- [ ] Probar health endpoint: `curl http://tu-servidor:8090/api/health`
- [ ] Respuesta: `{"message":"API is healthy.","code":200,"data":{}}`

### 2. Configurar PocketBase
- [ ] Acceder a Admin UI: `http://tu-servidor:8090/_`
- [ ] Crear superusuario: `ing.korozco@gmail.com`
- [ ] Crear colección "projects"
- [ ] Agregar campos:
  - [ ] projectId (text, required, unique)
  - [ ] name (text, required)
  - [ ] shortName (text, required)
  - [ ] description (text)
  - [ ] baseUrl (url, required)
  - [ ] isActive (bool, required, default: true)

### 3. Configurar API Rules
- [ ] List rule: (vacío - público)
- [ ] View rule: (vacío - público)
- [ ] Create rule: `@request.auth.id != ""`
- [ ] Update rule: `@request.auth.id != ""`
- [ ] Delete rule: `@request.auth.id != ""`

### 4. Agregar Proyectos Iniciales
- [ ] Athletic Sincelejo
  ```
  projectId: athletic-sincelejo
  name: Athletic Sincelejo
  shortName: Athletic
  description: Club de voleibol Athletic Sincelejo
  baseUrl: https://api.athleticsincelejo.com
  isActive: true
  ```
- [ ] Liga de Sucre
  ```
  projectId: liga-sucre
  name: Liga de Voleibol de Sucre
  shortName: Liga Sucre
  description: Liga departamental de voleibol de Sucre
  baseUrl: https://api.ligadevoleiboldesucre.com
  isActive: true
  ```

### 5. Probar API
- [ ] Listar proyectos:
  ```bash
  curl "http://tu-servidor:8090/api/collections/projects/records?fields=id,projectId,name"
  ```
- [ ] Obtener proyecto específico:
  ```bash
  curl "http://tu-servidor:8090/api/collections/projects/records/RECORD_ID"
  ```

## Opcional (Dominio Personalizado)

- [ ] Configurar DNS (registro A o CNAME)
- [ ] Agregar dominio en Dokploy
- [ ] Habilitar SSL/TLS (Let's Encrypt)
- [ ] Probar acceso por dominio: `https://projects.volleypass.com`

## Seguridad

- [ ] Contraseña fuerte para superusuario
- [ ] Clave de encriptación única (no reutilizar la de local)
- [ ] SSL/TLS habilitado en producción
- [ ] Backup configurado

## Mantenimiento

- [ ] Configurar backup automático de base de datos
- [ ] Configurar monitoreo (UptimeRobot, etc.)
- [ ] Documentar credenciales en lugar seguro

---

## Comandos Útiles Post-Deployment

```bash
# Ver logs del contenedor
docker logs -f <container-name>

# Verificar salud
curl http://tu-servidor:8090/api/health

# Crear superusuario desde terminal (alternativa)
docker exec -it <container-name> /pb/pocketbase superuser upsert ing.korozco@gmail.com TuPassword

# Backup manual
docker exec <container-name> cp /pb/pb_data/data.db /pb/pb_data/data.db.backup
```

---

## ¿Problemas?

Consulta la sección **Troubleshooting** en [DEPLOYMENT.md](./DEPLOYMENT.md)

## URLs Importantes

- **Guía completa:** [DEPLOYMENT.md](./DEPLOYMENT.md)
- **README:** [README.md](./README.md)
- **PocketBase Docs:** https://pocketbase.io/docs/
- **Dokploy Docs:** https://docs.dokploy.com

---

**Última actualización:** 2026-01-09
