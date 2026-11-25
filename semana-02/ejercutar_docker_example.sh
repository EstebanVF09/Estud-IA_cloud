# 1. Construir la imagen final de producción
docker build --target production -t mi-app:prod .

# 2. Ejecutar el contenedor en segundo plano (-d) exponiendo el puerto 3000
docker run -d -p 3000:3000 --name mi-app-produccion mi-app:prod