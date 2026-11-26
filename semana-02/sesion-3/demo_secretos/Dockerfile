FROM python:3.12-slim

WORKDIR /app

COPY app/ ./app/

# Vulnerabilidad: incorporamos credenciales a una layer
COPY .env /app/.env

# Falsa solución: borrar el archivo en una layer posterior
RUN rm /app/.env

# El proceso no necesita root. Las capas de arriba siguen guardando el .env.
RUN useradd --system --create-home --uid 10001 --shell /usr/sbin/nologin app
USER app

EXPOSE 8000

CMD ["python", "app/main.py"]