# 🎓 Sistema de Gestión Universitaria — Base de Datos Local con Supabase

Este repositorio contiene la arquitectura completa de base de datos relacional (32 tablas), seguridad basada en roles (RBAC) y Row Level Security (RLS) para el Sistema de Gestión Universitaria, diseñado para interactuar con un backend en **ASP.NET Core Web API + Dapper**.

Esta guía está diseñada para que cualquier desarrollador pueda clonar, iniciar y trabajar en el entorno local de base de datos **sin necesidad de tener Supabase CLI instalado globalmente** en su sistema operativo.

---

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instaladas y configuradas las siguientes herramientas en tu máquina:

1. **Docker Desktop:**
   * Supabase ejecuta sus servicios (PostgreSQL, Studio, Auth, Storage, etc.) en contenedores Docker locales.
   * [Descargar Docker Desktop](https://www.docker.com/products/docker-desktop/).
   * ⚠️ **Importante:** Docker Desktop debe estar **abierto y en ejecución** antes de ejecutar cualquier comando de Supabase.

2. **Node.js y npm:**
   * Requerido para ejecutar Supabase CLI a través de `npx` o los scripts de Node.js.
   * Versión recomendada: **Node.js 18 LTS** o superior.
   * [Descargar Node.js](https://nodejs.org/).

3. **Git:**
   * Para clonar y versionar el repositorio.

---

## 🚀 Inicio Rápido (Paso a Paso)

### 1. Clonar el repositorio y posicionarse en la carpeta
Abre tu terminal (PowerShell, Bash o CMD) y navega al proyecto:
```bash
git clone <URL_DEL_REPOSITORIO>
cd Universidad
```

### 2. Instalar dependencias de Node.js
Instala el CLI local de Supabase y las dependencias del proyecto:
```bash
npm install
```
> Esto descarga la versión exacta de Supabase CLI dentro de `node_modules`, garantizando que todo el equipo trabaje con la misma versión sin ensuciar tu entorno global.

### 3. Verificar que Docker esté activo
Abre Docker Desktop y verifica que el motor esté corriendo (ícono en verde en la barra de tareas).

### 4. Iniciar el entorno local de Supabase
Ejecuta el siguiente comando usando `npx`:
```bash
npm run db:start
```
> ⏳ **Primera vez:** La primera vez puede tardar unos minutos ya que Docker descargará las imágenes de PostgreSQL, GoTrue (Auth), PostgREST, Kong y Supabase Studio.

Una vez completado, la terminal mostrará un resumen con las credenciales y puertos locales:
```text
Started supabase local development setup.

         API URL: http://127.0.0.1:54321
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
    Inbucket URL: http://127.0.0.1:54324
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 5. Construir la Base de Datos y Sembrar Datos Maestros
Aplica todas las migraciones (las 32 tablas, funciones RLS, disparadores, roles y matriz de permisos):
```bash
npm run db:reset
```
Este comando:
1. Limpia y reinicia la base de datos PostgreSQL local.
2. Ejecuta todas las migraciones contenidas en `supabase/migrations/` en orden cronológico.
3. Siembra los catálogos base (días de la semana, roles y permisos iniciales).

---

## 🖥️ Herramientas y Accesos Locales

| Servicio | URL Local | Descripción |
| :--- | :--- | :--- |
| **Supabase Studio** | [http://127.0.0.1:54323](http://127.0.0.1:54323) | Panel web interactivo para explorar tablas, ejecutar SQL y ver logs. |
| **API Gateway (Kong)** | `http://127.0.0.1:54321` | Punto de entrada para llamadas REST y Supabase Auth. |
| **Inbucket (Emails)** | [http://127.0.0.1:54324](http://127.0.0.1:54324) | Bandeja de entrada local para probar confirmaciones de correo y recuperación de contraseñas. |
| **Base de Datos PostgreSQL** | `127.0.0.1:54322` | Conexión directa TCP para clientes como DBeaver, pgAdmin o tu Web API. |

---

## 🔌 Conexión con ASP.NET Core Web API (Dapper)

Para conectar tu API backend en C# a la base de datos local de Supabase, configura tu cadena de conexión en `appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=127.0.0.1;Port=54322;Database=postgres;User Id=postgres;Password=postgres;Include Error Detail=true;"
  }
}
```

> [!TIP]
> Dado que Row Level Security (RLS) está activo en las 32 tablas, asegúrate de que tus consultas mediante Dapper o llamadas autenticadas incluyan el token JWT o ejecuten consultas autorizadas según las políticas definidas en la base de datos.

---

## 🛠️ Comandos de Uso Frecuente

Todos los comandos deben ejecutarse con el prefijo `npx`:

| Acción | Comando | Descripción |
| :--- | :--- | :--- |
| **Ver estado y credenciales** | `npx supabase status` | Muestra URLs activas, claves anon y service_role. |
| **Detener el entorno** | `npx supabase stop` | Apaga los contenedores Docker para liberar memoria RAM. |
| **Reiniciar entorno** | `npx supabase restart` | Reinicia los contenedores sin borrar los datos. |
| **Reconstruir base de datos** | `npx supabase db reset` | Recrea la BD desde cero y reaplica todas las migraciones. |
| **Crear nueva migración** | `npx supabase migration new <nombre>` | Crea un nuevo archivo `.sql` con timestamp en `supabase/migrations/`. |
| **Ver registros en vivo** | `npx supabase logs` | Muestra los registros del contenedor de base de datos o autenticación. |

---

## ❓ Preguntas Frecuentes y Solución de Problemas

### 1. Error: `Cannot connect to the Docker daemon`
* **Causa:** Docker Desktop no está iniciado o no ha terminado de arrancar.
* **Solución:** Inicia Docker Desktop, espera a que el estado muestre "Engine running" y vuelve a ejecutar `npx supabase start`.

### 2. Error: `port is already allocated` (Puerto en uso)
* **Causa:** Otro servicio local (como un PostgreSQL instalado directamente en Windows en el puerto 5432 o 54322) está ocupando el puerto.
* **Solución:** Puedes cambiar los puertos locales en el archivo [`supabase/config.toml`](supabase/config.toml) en las secciones `[api]` o `[db]`.

### 3. ¿Por qué mis cambios en los datos no aparecen en `supabase db diff`?
* `supabase db diff` **solo detecta cambios estructurales (DDL)** como nuevas tablas, columnas o funciones. Para registrar inserciones de datos maestros (como roles o catálogos), debes crear el archivo manualmente con `npx supabase migration new <nombre>` y colocar allí tus sentencias `INSERT ... ON CONFLICT DO UPDATE`.

---

## 👥 Roles del Sistema Preconfigurados

El sistema incluye 3 roles base con permisos configurados según la matriz RBAC:
* **`ADMIN`:** Control total sobre las 32 entidades.
* **`DIRECTOR`:** Gestión académica (pensum, grupos, docentes, estudiantes, horarios y asistencias) y consulta de catálogos generales.
* **`DOCENTE`:** Consulta de infraestructura académica y control de asistencia de sus grupos asignados.

