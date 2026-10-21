# Karate API Tests

Pruebas de API con Karate contra [Restful-booker](https://restful-booker.herokuapp.com), con Gradle y JDK 21.

## Estructura

```
src/test/resources/
├── features/
│   ├── auth/                 # pruebas de componente de auth
│   ├── booking/              # componente (PUT) e integración (flujo de actualización)
│   └── common/<área>/        # flujos reutilizables (@ignore): login, create/get/update/delete-booking
├── requests/<dominio>/       # body de las peticiones (templates JSON)
├── schemas/                  # esquemas de respuesta
├── data/
│   ├── <dominio>/            # datos de entrada
│   └── responses/<dominio>/  # status y mensajes esperados
└── config/<env>.json         # configuración por ambiente (dev, qa)
```

## Ejecución local

```bash
./gradlew componentTest integrationTest                    # suite completa
./gradlew componentTest                                    # solo componente
./gradlew integrationTest                                  # solo integración
./gradlew componentTest -Dkarate.tags=@smoke               # por tag
./gradlew componentTest "-Dkarate.tags=@auth,@booking"     # OR entre tags
./gradlew componentTest "-Dkarate.tags=~@smoke"            # excluir un tag
./gradlew componentTest -Dkarate.env=qa -Dthreads=2        # ambiente e hilos
```

No uses `./gradlew test` para la suite: también ejecuta `SingleFeatureRunner`.

## Reportes (ajuste en `build.gradle.kts`)

Antes, todas las tareas de prueba escribían el reporte de Karate en la misma carpeta
(`build/karate-reports`), así que ejecutar componente e integración juntos hacía que el
`karate-summary.html` de la segunda **sobrescribiera** al de la primera.

Ahora cada tipo de prueba escribe en su propia subcarpeta:

| Tarea | Reporte |
|---|---|
| `componentTest` | `build/karate-reports/component/karate-summary.html` |
| `integrationTest` | `build/karate-reports/integration/karate-summary.html` |
| `test` | `build/karate-reports/karate-summary.html` |

El ajuste en `build.gradle.kts`:

```kotlin
// Cada tipo de prueba escribe su reporte en una subcarpeta propia para que no se sobrescriban.
fun Test.karateReportsIn(subdir: String) = systemProperty("karate.output.dir", "$karateReportsDir/$subdir")
```

y en cada tarea se invoca `karateReportsIn("component")` o `karateReportsIn("integration")`. Los runners
no cambian: `SuiteRunner` ya leía la propiedad `karate.output.dir`.

El request y la response de cada llamado aparecen en el reporte porque `src/test/resources/logback-test.xml`
deja `com.intuit.karate` en `DEBUG`; la consola se mantiene en `INFO` con un `ThresholdFilter`.

## Pipeline local (Docker Compose + Jenkins)

Simula un CI/CD: Jenkins corre en un contenedor, ejecuta las pruebas y deja el reporte en tu máquina.

```
ci/
├── docker-compose.yml     # servicio Jenkins
├── jenkins/               # Dockerfile, plugins.txt, casc.yaml (Jenkins as Code)
└── reports/               # salida de los reportes (montada desde el contenedor)
Jenkinsfile                # definición del pipeline
```

### Levantar

```bash
docker compose -f ci/docker-compose.yml up -d --build
```

Jenkins queda en <http://localhost:8080> (usuario `admin`, password `admin`), sin asistente de instalación y con el job
`karate-api-tests` ya creado.

Variables opcionales (en el entorno o en `ci/.env`, que no se versiona):
`JENKINS_ADMIN_ID`, `JENKINS_ADMIN_PASSWORD`, `BOOKER_PASSWORD` (por defecto `password123`, se guarda como credencial
`booker-password` y se inyecta como `BOOKER_PASSWORD`).

### Ejecutar

En Jenkins: `karate-api-tests` → **Build Now**. Desde la segunda ejecución aparece **Build with Parameters**
(en la primera, los parámetros se registran y se usan sus valores por defecto):

| Parámetro | Efecto |
|---|---|
| `KARATE_ENV` | `-Dkarate.env` (`dev` o `qa`) |
| `TAGS` | `-Dkarate.tags` (vacío = todos) |
| `THREADS` | `-Dthreads` |

Etapas: preparar código → pruebas de componente → pruebas de integración → publicar reportes. Si falla una etapa,
la siguiente igual se ejecuta y el build queda en fallo; los reportes se publican siempre.

### Dónde queda el reporte

- En tu máquina: `ci/reports/<número-de-build>/` (y `ci/reports/latest/`). Abre
  `component/karate-summary.html` o `integration/karate-summary.html`. Sobrevive aunque borres el contenedor.
- En Jenkins: enlaces **Karate - Componente** y **Karate - Integración** en la página del build, más la tendencia de JUnit.

### Cómo funciona

- El proyecto se monta **solo lectura** en `/workspace/project`; el pipeline lo copia a su workspace (sin `build/`, `.git/`, `ci/`).
- Las pruebas corren dentro del propio contenedor de Jenkins (`jenkins/jenkins:lts-jdk21`).
- El `Jenkinsfile` se lee al arrancar Jenkins: si lo editas, aplica con `docker compose -f ci/docker-compose.yml restart`.
- La caché de Gradle vive en el volumen `jenkins_home`, así que los builds siguientes no descargan todo de nuevo.

### Detener

```bash
docker compose -f ci/docker-compose.yml down        # conserva el volumen (historial y caché)
docker compose -f ci/docker-compose.yml down -v     # borra también el volumen
```
