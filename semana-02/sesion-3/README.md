# Sesión 3 · Tres servicios, un comando

Frontend (nginx), API (FastAPI) y PostgreSQL se levantan juntos y se comportan igual en otra máquina. Compose resuelve los nombres de servicio. La base no publica puerto y vive en otra red: el frontend no la alcanza.

La clave del ejemplo es ficticia (`clave-ficticia-de-ejemplo`). Cámbiala en tu `.env` si quieres. `.env` no se versiona.

## Tres comandos de arranque

Desde esta carpeta:

```bash
cp .env.example .env
docker compose up --build -d
curl -fsS http://localhost:8000/health
```

`/health` responde `{"status":"ok"}`. La página del formulario queda en `http://localhost:8080`. Sin `-d`, `docker compose up --build` deja los logs en esa terminal y el `curl` se hace en otra.

`http://localhost:8000/docs` es la documentación de la API. El navegador también puede usar `http://localhost:8080/api/health` y `http://localhost:8080/api/items`: nginx quita el prefijo `/api` y llama al contenedor `backend`.

## Qué publica cada servicio

| Servicio | Escucha dentro | Publicado en el host | Redes |
|---|---|---|---|
| frontend | 80 | `${FRONTEND_PORT:-8080}` | frontal |
| backend | 8000 | `${BACKEND_PORT:-8000}` | frontal y datos |
| db | 5432 | nada | datos |

`localhost` dentro de un contenedor es ese contenedor. Por eso la API usa el nombre `db`, no `localhost`. El Dockerfile arranca uvicorn en `0.0.0.0` por la misma razón: `127.0.0.1` no aceptaría tráfico de los otros contenedores.

## El dato sobrevive a `down`

```bash
curl -fsS -X POST http://localhost:8000/items \
  -H 'content-type: application/json' \
  -d '{"nombre":"cable","nota":"sobrevive al down"}'

docker compose down
docker compose up -d
curl -fsS http://localhost:8000/items
```

`down` borra contenedores y redes, y deja el volumen nombrado `datos_postgres`. `down -v` borra también ese volumen: el ítem desaparece y `db/init.sql` vuelve a correr en el siguiente arranque, porque PostgreSQL solo ejecuta `docker-entrypoint-initdb.d` cuando el directorio de datos está vacío.

## Comprobar el aislamiento

No dependas de `ping` ni de `curl`: la imagen del backend no los trae, y no hace falta instalarlos.

El backend tiene Python. Debe resolver `db` y `frontend`:

```bash
docker compose exec backend python comprobar_nombre.py db
docker compose exec backend python comprobar_nombre.py frontend 80
```

El frontend es nginx sobre Alpine. BusyBox incluye `getent`. `db` no debe resolver; `backend` sí:

```bash
docker compose exec frontend getent hosts backend
docker compose exec frontend getent hosts db
```

El segundo comando termina con código distinto de cero. Si alguna imagen no tuviera `getent` ni Python, no los instales para diagnosticar. Mira quién está en cada red:

```bash
docker network ls
docker network inspect estudia-sesion3_frontal
docker network inspect estudia-sesion3_datos
```

En `estudia-sesion3_datos` solo aparecen `backend` y `db`. En `estudia-sesion3_frontal`, `frontend` y `backend`. Desde el host, el puerto 5432 no responde: la base no está publicada.

`docker compose ps`, `docker compose logs backend` y `docker compose exec` son el recorrido cuando algo no arranca. `docker compose config` muestra el archivo ya interpolado con tu `.env`: la clave ficticia aparece ahí porque Compose la sustituye en memoria. No debe aparecer escrita en un archivo que git siga. `git check-ignore -v .env` confirma que `.env` queda fuera.

## Imágenes fijadas

- `python:3.13.18-slim-bookworm@sha256:a5a7017efc5969e00ae2b91c8eb0631049a569652aa4ffc4501769049ae45c72`
- `nginx:1.28.3-alpine@sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236`
- `postgres:17.12-alpine@sha256:a77aa70e641402a21411b92b721c58d10f23b50ae5fdd2333efd22d166e1e5f7`

La etiqueta dice qué pedimos. El digest dice qué bits se van a ejecutar.

## Reto de red

La rama [`reto`](https://github.com/RafaelCampoTech/Estud-IA_cloud/tree/reto) es el mismo proyecto con el entorno roto a propósito. Esta carpeta en `main` es la solución. El enunciado está en esa rama, en `RETO.md`.

## También en esta sesión

- [simple_bk](simple_bk/README.md): API mínima. La clave se lee de `SECRET_KEY` y no viaja dentro de la imagen.
- [demo_secretos](demo_secretos/README.md): laboratorio de capas. Borrar `.env` en una instrucción posterior no lo saca de la imagen.
- [Presentación de las sesiones 3 y 4](../recursos/Session_3_y_4_nube.pptx.pdf).
