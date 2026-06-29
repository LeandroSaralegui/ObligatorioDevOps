# Obligatorio DevOps - Retail Store

Aplicación de e-commerce basada en microservicios. Permite explorar un catálogo de productos, gestionar un carrito de compras, realizar el checkout y consultar órdenes. Incluye un panel de administración para gestionar productos y ver órdenes.

La solución implementa una aplicación basada en microservicios desplegada en AWS utilizando Infrastructure as Code (Terraform), CI/CD con GitHub Actions, prácticas DevSecOps, observabilidad y servicios serverless.

## Integrantes

- Iñaki Laxalde
- Leandro Saralegui

## Requisitos previos

- [Docker](https://docs.docker.com/get-docker/) 24+
- [Docker Compose](https://docs.docker.com/compose/install/) v2.20+
- AWS Account
- Terraform >= 1.5
- Docker
- AWS CLI
- Git
  
## Inicio rápido

```bash
docker compose up --build
```

| Servicio | URL                   |
|----------|-----------------------|
| Tienda   | http://localhost:8080 |
| Admin    | http://localhost:8081 |

Credenciales del admin por defecto: `admin` / `admin`

---

## Arquitectura de microservicios


         Diagrama de arquitectura general del sistema.
<img width="4073" height="1899" alt="mermaid-diagram (6)" src="https://github.com/user-attachments/assets/d487b5cf-30bf-42df-ad13-5438000f860d" />

La aplicación está compuesta por los microservicios:

- UI
- Catalog
- Carts
- Checkout
- Orders
- Admin
- PostgreSQL

Desplegados sobre AWS ECS Fargate.


### Flujo de comunicación

| Origen     | Destino    | Protocolo | Descripción                              |
|------------|------------|-----------|------------------------------------------|
| UI         | Catalog    | HTTP REST | Listar y consultar productos             |
| UI         | Cart       | HTTP REST | Agregar, quitar y consultar carrito      |
| UI         | Checkout   | HTTP REST | Iniciar y confirmar el proceso de pago   |
| UI         | Orders     | HTTP REST | Consultar historial de órdenes           |
| Checkout   | Orders     | HTTP REST | Crear orden al confirmar checkout        |
| Checkout   | Redis      | TCP       | Persistencia de sesión de checkout       |
| Catalog    | PostgreSQL | TCP       | Base de datos `catalogdb`                |
| Cart       | PostgreSQL | TCP       | Base de datos `cartdb`                   |
| Orders     | PostgreSQL | TCP       | Base de datos `orders`                   |
| Admin      | PostgreSQL | TCP       | Acceso directo a todas las bases         |

---

## Tecnologías por servicio

| Servicio     | Lenguaje       | Framework        | Runtime         | Persistencia      | Puerto externo |
|--------------|----------------|------------------|-----------------|-------------------|----------------|
| **ui**       | TypeScript     | Express          | Node.js 22      | —                 | 8080           |
| **catalog**  | Go 1.24        | Gin + GORM       | Alpine Linux    | PostgreSQL        | —              |
| **cart**     | Python 3.12    | FastAPI          | Python slim     | PostgreSQL        | —              |
| **checkout** | TypeScript     | NestJS           | Node.js 22      | Redis             | —              |
| **orders**   | Go 1.24        | Gin + GORM       | Alpine Linux    | PostgreSQL        | —              |
| **admin**    | TypeScript     | Express          | Node.js 22      | PostgreSQL        | 8081           |
| **db**       | —              | PostgreSQL 16    | —               | —                 | —              |
| **redis**    | —              | Redis 7          | Alpine Linux    | —                 | —              |

### Dependencias clave

| Servicio     | Dependencias destacadas                                               |
|--------------|-----------------------------------------------------------------------|
| **catalog**  | `gin-gonic/gin`, `gorm`, `go-gorm/postgres`, OpenTelemetry           |
| **cart**     | `FastAPI`, `Uvicorn`, `Pydantic`, `psycopg2`, Prometheus client       |
| **checkout** | `NestJS`, `ioredis`, `class-validator`, OpenTelemetry                 |
| **orders**   | `gin-gonic/gin`, `gorm`, `go-gorm/postgres`, Prometheus              |
| **ui**       | `express`, `http-proxy-middleware`                                    |
| **admin**    | `express`, `pg`, `jsonwebtoken`, `cookie-parser`                      |

---

## Variables de entorno


Las credenciales sensibles no se almacenan en el repositorio.

La aplicación obtiene los secretos desde AWS Secrets Manager mediante referencias configuradas en Terraform y consumidas por Amazon ECS.

Secretos gestionados:

- postgres-password
- admin-password
- admin-jwt-secret

### UI
| Variable                        | Descripción                  | Default               |
|---------------------------------|------------------------------|-----------------------|
| `RETAIL_UI_ENDPOINTS_CATALOG`   | URL del servicio catalog     | `http://catalog:8080` |
| `RETAIL_UI_ENDPOINTS_CARTS`     | URL del servicio cart        | `http://carts:8080`   |
| `RETAIL_UI_ENDPOINTS_CHECKOUT`  | URL del servicio checkout    | `http://checkout:8080`|
| `RETAIL_UI_ENDPOINTS_ORDERS`    | URL del servicio orders      | `http://orders:8080`  |

### Catalog / Orders / Cart
| Variable                               | Descripción           | Default               |
|----------------------------------------|-----------------------|-----------------------|
| `RETAIL_X_PERSISTENCE_PROVIDER`        | Tipo de persistencia  | `postgres`            |
| `RETAIL_X_PERSISTENCE_ENDPOINT`        | Host:Puerto de la DB  | `db:5432`             |
| `DB_PASSWORD`                          | Contraseña PostgreSQL | en AWS Secrets Manage |

Se refiere con "X" al microservicio correspondiente.

### Checkout
| Variable                                   | Descripción              | Default               |
|--------------------------------------------|--------------------------|------------------------|
| `RETAIL_CHECKOUT_PERSISTENCE_PROVIDER`     | Tipo de persistencia     | `redis`               |
| `RETAIL_CHECKOUT_PERSISTENCE_REDIS_URL`    | URL de Redis             | `redis://redis:6379`  |
| `RETAIL_CHECKOUT_ENDPOINTS_ORDERS`         | URL del servicio orders  | `http://orders:8080`  |

### Admin
| Variable            | Descripción                | Default                   |
|---------------------|----------------------------|---------------------------|
| `ADMIN_USERNAME`    | Usuario administrador      | `admin`                   |
| `ADMIN_PASSWORD`    | Contraseña administrador   | en AWS Secrets Manage     |
| `ADMIN_JWT_SECRET`  | Secreto para tokens JWT    | en AWS Secrets Manage     |

---

## Estructura del repositorio

```text
app/
├── docker-compose.yml
├── init-db.sql
├── .gitleaks.toml
├── sonar-project.properties
│
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   ├── test/
│   │   └── prod/
│   │
│   └── modules/
│       ├── vpc/
│       ├── ecs/
│       ├── ecs_services/
│       ├── ecr/
│       ├── cloudwatch/
│       ├── secrets/
│       └── serverless/
│
├── src/
│   ├── catalog/      # Go - Catálogo de productos
│   ├── cart/         # Python - Carrito de compras
│   ├── checkout/     # TypeScript / NestJS - Proceso de pago
│   ├── orders/       # Go - Gestión de órdenes
│   ├── ui/           # TypeScript / Express - Frontend
│   └── admin/        # TypeScript / Express - Panel de administración
│
├── postman/
│
└── .github/
    └── workflows/
```

## Tecnologías

- AWS ECS Fargate
- AWS ECR
- AWS Secrets Manager
- AWS CloudWatch
- AWS Lambda
- AWS API Gateway
- Terraform
- Docker
- GitHub Actions
- SonarCloud
- Trivy Filesystem
- Trivy Image Scan
- Gitleaks
- Newman

## Despliegue de infraestructura

La infraestructura se despliega mediante el workflow de GitHub Actions definido en:

.github/workflows/infra.yaml

## Variables de Configuración

Las siguientes variables son utilizadas por Terraform para desplegar la infraestructura del proyecto.

| Variable             | Descripción                                                                 | Valor utilizado (Dev)                                        |
| -------------------- | --------------------------------------------------------------------------- | -------------------------------------------------------------|
| `aws_region`         | Región de AWS donde se despliega la infraestructura.                        | `us-east-1`                                                  |
| `environment`        | Ambiente de ejecución de la infraestructura.                                | `dev`                                                        |
| `project_name`       | Nombre del proyecto utilizado para nombrar recursos AWS.                    | `retailstore`                                                |
| `vpc_name`           | Nombre de la VPC creada para el ambiente.                                   | `dev-vpc`                                                    |
| `vpc_cidr_block`     | Bloque CIDR principal de la VPC.                                            | `10.10.0.0/16`                                               |
| `public_subnets`     | Subredes públicas utilizadas por los componentes accesibles desde Internet. | `10.10.1.0/24`, `10.10.2.0/24`                               |
| `private_subnets`    | Subredes privadas utilizadas por los servicios internos.                    | `10.10.11.0/24`, `10.10.12.0/24`                             |
| `availability_zones` | Zonas de disponibilidad utilizadas para alta disponibilidad.                | `us-east-1a`, `us-east-1b`                                   |
| `mircoservicios`     | Lista de microservicios desplegados en la solución.                         | `admin`, `ui`, `carts`, `catalog`, `checkout`, `orders`, `db` |
| `log_retention_days` | Cantidad de días de retención de logs en CloudWatch.                        | `7`                                                          |

## Pipeline CI/CD

Flujo completo del pipeline CI/CD con las etapas de seguridad integradas.

<img width="825" height="1600" alt="244addab-6a4b-4a2c-99a3-03e21b29d41f" src="https://github.com/user-attachments/assets/4b799b56-d82e-44bf-aad4-7f3b8fcafd46" />

Etapas:

1. Build
2. SonarCloud
3. Gitleaks
4. Trivy Filesystem
5. Trivy Images
6. Push a ECR
7. Deploy ECS
8. Functional Tests (Newman)

### Ambientes soportados

La infraestructura está preparada para ejecutarse en tres ambientes independientes:

* `dev`
* `test`
* `prod`

Cada ambiente cuenta con su propio conjunto de recursos desplegados mediante Terraform desde los directorios:

```text
terraform/environments/dev
terraform/environments/test
terraform/environments/prod
```

La promoción entre ambientes se realiza mediante los pipelines de GitHub Actions definidos para la infraestructura y la aplicación.

### Quality Gates

Se definieron los siguientes umbrales:

- Coverage mínimo: 20%
- Code Smells máximos: 20
- Vulnerabilidades críticas: 0
- Vulnerabilidades altas: 0 (Con algunas excepciones habladas previamente con el profesor)

Todo Pull Request debe aprobar satisfactoriamente los controles automáticos configurados en GitHub Actions.

### DevSecOps

Se implementaron las siguientes herramientas:

- SonarCloud (SAST)
- Gitleaks (detección de secretos)
- Trivy Filesystem (SCA)
- Trivy Image Scan
- AWS Secrets Manager

### Observabilidad
La solución centraliza logs y métricas mediante CloudWatch Logs.

Componentes monitoreados:

- ECS Services
- Application Load Balancer
- AWS Lambda
- API Gateway

CloudWatch Alarms
          Alertas configuradas:
          - ECS CPU High
          - ECS Memory High
          - ALB 5XX Errors
          - ALB Response Time
          - ALB Unhealthy Hosts
          
| Alarma          | Trigger               | Acción                      |
| --------------- | --------------------- | --------------------------- |
| ECS CPU High    | CPU > 80%             | Revisar consumo de recursos |
| ECS Memory High | Memoria > 80%         | Analizar fugas o escalar    |
| ALB 5XX         | > 10 errores en 5 min | Revisar logs del servicio   |
| Response Time   | > 2s promedio         | Analizar cuellos de botella |
| Unhealthy Hosts | ≥ 1 host no saludable | Revisar ECS Tasks           |


## Estrategia de Versionado

Se adoptó Trunk-Based Development.

<img width="1600" height="81" alt="4fb0c0d3-728f-4d36-b287-73cbb53c7d02" src="https://github.com/user-attachments/assets/cd59ec6b-cb6a-4896-b7da-f68bc37c7550" />

Se seleccionó Trunk-Based Development debido a que el equipo está compuesto solo por dos integrantes y requiere integración continua frecuente.
Esta estrategia reduce conflictos de merge y simplifica el flujo de trabajo.
Tambien lso integrantes cuenta con experiencia en esta dinamica de trabajo por lo cual hace que la metodologia de trabajo sea eficiente.


### Pull Requests

Se realizaron revisiones de código mediante Pull Requests.

#### PR #29

<img width="1117" height="731" alt="129e42d6-91d6-4a20-aaea-e4dd061a6076" src="https://github.com/user-attachments/assets/da66fa57-945a-4e6d-8d07-83426bf917ac" />


#### PR #4
<img width="1111" height="733" alt="d348a12c-b8a6-4d5b-ab62-c700e3342d27" src="https://github.com/user-attachments/assets/6aa0ec9d-5ff2-43e6-8e52-062469dd422a" />

### Protección de Rama

<img width="974" height="528" alt="af5e6960-6bc7-4fe0-ba48-e1165d8863df" src="https://github.com/user-attachments/assets/1dc101a9-bc15-41a7-b91a-4174785b9c3f" />

La rama principal se encuentra protegida mediante GitHub Branch Protection Rules.

Requisitos:

- Pull Request obligatorio
- Build exitoso
- SonarCloud exitoso
- Trivy  exitoso (Image Scan, FileSystem)
- Gitleaks Secret exitoso
- Functional Test Newman exitoso
- Revisión obligatoria

Esto garantiza que únicamente código validado pueda integrarse a main.

## Serverless

Se implementó una solución serverless utilizando:

- AWS Lambda
- AWS API Gateway

Objetivo:

Exponer un endpoint de observabilidad independiente de la aplicación principal.

Endpoint:

GET /observability/status

Respuesta:
```text
{
  "service": "retailstore-observability-status",
  "status": "ok"
}
```
-------------------------------------------------------------------------------------------------------------------------------------------------

 









  




