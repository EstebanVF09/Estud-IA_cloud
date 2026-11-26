# Semana 5 · Terraform

Esta semana describe toda la infraestructura en código. Al terminar, puedes leer un plan, explicar qué guarda el estado y trabajar con otra persona sin pisar su entorno.

La pregunta de la semana: ¿cómo se describe la infraestructura completa y cómo se revisa y revierte?

En la planeación, las dos clases se llaman Sesión 1 y Sesión 2. En el repositorio son [sesion-9](sesion-9/README.md) y [sesion-10](sesion-10/README.md).

## Mapa de la semana

| Encuentro | Carpeta | Título | Qué te llevas |
|---|---|---|---|
| 9 | [sesion-9](sesion-9/README.md) | Fundamentos | Un plan leído, sin `apply` contra una cuenta real |
| 10 | [sesion-10](sesion-10/README.md) | Terraform en equipo | El mismo módulo en dos entornos, con su plan y su reversión |

## Antes de la semana: lo asincrónico en Platzi

Esta semana asume que Platzi cubre Terraform. Si el curso trae otros temas, la demostración y el microtaller se ajustan para no repetirlos.

## Sesión 9 · Fundamentos

| Bloque | Min | Contenido |
|---|---|---|
| Apertura | 5 | Qué se describe y qué no: el código no garantiza el estado real |
| Clase 1: modelo declarativo | 15 | Plan, apply y ciclo de vida de un recurso: crear, modificar y reemplazar |
| Clase 2: HCL | 20 | Providers, resources, variables, outputs y data sources |
| Demostración | 20 | Escribir, validar y leer un plan de la VPC de la semana 3 |
| Microtaller | 25 | Un módulo de subred pública y privada con `terraform plan`, sin `apply` |
| Receso | 15 | Descanso |
| Estado | 20 | Qué guarda, por qué es sensible y la diferencia entre estado local y remoto |
| Bloqueo del estado | 15 | Por qué dos personas no deben aplicar a la vez |
| Clínica de errores | 15 | Reemplazos inesperados, *drift* y recursos fuera de Terraform |
| Mentoría | 20 | Atención individual al proyecto de cada alumno |
| Síntesis | 10 | Qué revisar antes de cada `apply` |

Las versiones recientes de Terraform permiten bloqueo nativo del estado en S3 con `use_lockfile`. DynamoDB era el mecanismo anterior. Antes de la clase, confirmen la versión que usará el grupo.

Regla de la clase: no se ejecuta `apply` contra una cuenta real. El plan se lee y se explica. Si hay cuenta de práctica, se aplica en un entorno aislado y declarado.

## Sesión 10 · Terraform en equipo

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

## Evidencia de la semana

Un módulo reutilizado en dos entornos, un plan revisado en un pull request, una detección de *drift* y una reversión descrita con su alcance.

## Conexión entre las semanas 3, 4 y 5

| Concepto | Semana 3 | Semana 4 | Semana 5 |
|---|---|---|---|
| Versión identificable | Etiqueta y digest de la imagen | Imagen fijada en el manifiesto | Variable de versión en el módulo |
| Salud | Endpoint `/health` y health checks | Readiness y liveness | Recursos de alarma definidos en código |
| Reversión | Volver a la versión anterior del despliegue | `git revert` y reconciliación | Revertir el commit y aplicar el plan |
| Lo que no vuelve | Datos y configuración | Secretos y datos del clúster | Estado y recursos con datos |

## Material

| Dónde | Qué hay |
|---|---|
| [sesion-9](sesion-9/README.md) | Bloques de fundamentos. Plan, sin `apply` en una cuenta real. |
| [sesion-10](sesion-10/README.md) | Bloques de Terraform en equipo. |
| [recursos](recursos/README.md) | Presentaciones de la semana. Todavía no hay archivos. |
