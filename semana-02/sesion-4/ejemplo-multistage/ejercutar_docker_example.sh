# Desde esta carpeta (semana-02/sesion-4/ejemplo-multistage).
# El ejemplo no se llama Dockerfile: -f lo señala. No lleva sufijo .c.
# 1. Construir la imagen final de producción
docker build -f dockerfile.example --target production -t mi-app:prod .

# 2. Ejecutar el contenedor en segundo plano (-d) exponiendo el puerto 3000
docker run -d -p 3000:3000 --name mi-app-produccion mi-app:prod