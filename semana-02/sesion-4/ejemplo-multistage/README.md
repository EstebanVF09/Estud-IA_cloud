# Ejemplo · varias etapas en un Dockerfile

Ilustración de un Dockerfile de Node con cinco etapas: `base`, `development`, `test`, `builder` y `production`. Acompaña a la sesión 4, junto con la comparación de imágenes en [demo](../demo/README.md). No es una aplicación de este repositorio: aquí no hay `package.json` ni código Node. El archivo muestra la forma de la receta.

`dockerfile.example` no se llama `Dockerfile` y no lleva sufijo `.c`. Sonar trata un archivo `.c` como código C.

Desde esta carpeta:

```bash
bash ejercutar_docker_example.sh
```

El script construye el target `production` con `-f dockerfile.example` y arranca el contenedor en el puerto 3000. Sin un proyecto Node en el contexto, el build se detiene al copiar `package.json`.
