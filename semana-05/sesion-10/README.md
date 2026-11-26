# Sesión 10 · Terraform en equipo

Qué cambia cuando dos personas trabajan sobre el mismo estado: un módulo, dos entornos, un plan en el pull request y una reversión con su alcance.

En la planeación de la semana 5 esta clase es la Sesión 2. En el repositorio es `sesion-10`.

| Bloque | Min | Contenido |
|---|---|---|
| Apertura | 5 | Qué cambia cuando trabajan dos personas sobre el mismo estado |
| Clase 1: módulos | 20 | Estructura, entradas, salidas y versionado de un módulo |
| Clase 2: entornos | 20 | Directorios por entorno frente a workspaces; por qué los workspaces no aíslan permisos |
| Demostración | 25 | Pipeline: `plan` en cada pull request, comentario con el plan y `apply` solo tras aprobación |
| Microtaller | 25 | Un mismo módulo en desarrollo y producción, con variables distintas, y su plan para cada entorno |
| Receso | 15 | Descanso |
| Drift | 20 | Detectar cambios manuales con `plan`; cuándo importar un recurso y cuándo reconstruirlo |
| Reversión | 15 | Revertir un commit y su plan; qué datos y configuración no vuelven |
| Mentoría | 20 | Atención individual al proyecto de cada alumno |
| Síntesis | 15 | Cómo se revisa, se aprueba y se revierte un cambio de infraestructura |

La evidencia de la semana está en el [README de la semana](../README.md). Las presentaciones, cuando existan, van en [recursos](../recursos/README.md).
