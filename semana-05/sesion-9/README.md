# Sesión 9 · Fundamentos de Terraform

Qué se describe y qué no. El código no garantiza el estado real: el plan se lee, y `apply` no se lanza contra una cuenta real.

En la planeación de la semana 5 esta clase es la Sesión 1. En el repositorio es `sesion-9`.

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

La evidencia de la semana está en el [README de la semana](../README.md). Las presentaciones, cuando existan, van en [recursos](../recursos/README.md).
