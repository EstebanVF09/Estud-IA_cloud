# Semana 2 · Contenedores e integración continua

Esta semana tu proyecto pasa de ser una idea a algo que otra persona puede ejecutar, y que una máquina puede comprobar cada vez que cambia.

## Mapa de la semana

| Encuentro | Título | Qué te llevas |
|---|---|---|
| 3 | Contenedor, configuración y entorno reproducible | Una imagen y una ejecución identificables que otra persona puede repetir |
| 4 | Integración continua y validación de cambios | Una validación automática con un caso correcto y otro fallido |

## Antes de la semana: lo asincrónico en Platzi

**M3 · Despliegue de aplicaciones en la nube**
- Elastic Beanstalk (AWS) y App Engine (GCP): desplegar sin gestionar servidores
- Variables de entorno y gestión de secretos
- Estrategias de despliegue: rolling, blue-green y canary
- Health checks y reintentos automáticos
- Rollback: recuperar la versión anterior ante un fallo

Además retomamos lo de la semana 1: ciclo de vida de imágenes, redes, volúmenes y Compose (M2), y CI/CD con GitHub Actions (M1).

## Qué vas a aprender

**Encuentro 3 · Contenedor y entorno reproducible**
- Distinguir **imagen**, **contenedor**, **configuración** y **persistencia**.
- Construir, identificar y ejecutar una imagen, y explicar qué queda dentro de ella y qué se aporta al iniciar.
- Diferenciar una etiqueta de la identificación de una versión concreta.
- Recorrer el puerto de la aplicación y su publicación local.
- Ver la diferencia entre un dato efímero y uno persistido.
- Dejar instrucciones para que **otra persona** arranque tu servicio sin ayuda.

**Encuentro 4 · Integración continua**
- Recorrer disparador (trigger), job y pasos mientras se ejecuta una prueba.
- Leer el mensaje de un fallo y entender qué lo causó.
- Entender por qué un resultado exitoso solo acredita las comprobaciones que realmente se ejecutaron.
- Distinguir integración continua de despliegue controlado: que el job corra no significa que haya un bloqueo de promoción.
- Separar secretos del sistema de CI, variables no sensibles y credenciales de tu equipo.
- Comparar, según tu necesidad, GitHub Actions, los pipelines nativos del proveedor y GitOps. No necesitas construir varios.

## Evidencias flexibles

- Imagen y ejecución identificables, o una simulación declarada.
- Configuración y persistencia explicadas.
- Un arranque seguido por otra persona, con evidencia.
- Una validación con caso correcto y caso fallido, y el log interpretado.
- La condición de avance explicitada, y los permisos y el alcance reales del pipeline.

## Material de los encuentros 3 y 4

- [Sesión 3 · Compose local](sesion-3/README.md): frontend, API y PostgreSQL con un comando, dos redes y un volumen.
- [Sesión 3 · simple_bk](sesion-3/simple_bk/README.md): la clave ficticia entra por `SECRET_KEY` al arrancar. La imagen no copia un `.env`.
- [Sesión 3 · demo de secretos](sesion-3/demo_secretos/README.md): el laboratorio borra `.env` en una capa posterior y el archivo sigue en la imagen.
- [Sesión 4 · comparar tres imágenes](sesion-4/demo/README.md): la misma API en una etapa, en dos etapas y con caché de Actions.
- [Sesión 4 · taller](sesion-4/taller/README.md): la imagen de una etapa, la hoja de OIDC y el plan B sin AWS.
- [Sesión 4 · ejemplo multi-stage](sesion-4/ejemplo-multistage/README.md): una receta de Node con etapas de desarrollo, prueba, build y producción.
- [Recursos](recursos/README.md): `Session_3_y_4_nube.pptx.pdf`, la presentación de las dos sesiones.

El índice de la sesión 4, con el reto, la demo del modelo y los resultados archivados, está en [sesion-4](sesion-4/README.md).

La rama `reto` es el punto de partida de la actividad de red. Lo que está en esta carpeta, en `main`, es la solución.

## Para llevar a la semana 3

Guarda la versión de tu imagen, tus instrucciones y tu workflow con su estado real de promoción. En la semana 3 seguimos el camino de una petición: por dónde entra el tráfico, dónde corre esa imagen y cómo cambia su versión.
