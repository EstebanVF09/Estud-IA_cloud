# Sesión 8 · GitOps

Git es la fuente de verdad. Un cambio llega por pull request, el clúster se reconcilia solo y una reversión queda registrada como commit.

En la planeación de la semana 4 esta clase es la Sesión 2. En el repositorio es `sesion-8`.

| Bloque | Min | Contenido |
|---|---|---|
| Apertura | 5 | Qué es una fuente de verdad y por qué importa |
| Clase 1: principios de GitOps | 15 | Git como fuente de verdad, cambios por pull request, el clúster se reconcilia solo |
| Clase 2: Argo CD o Flux | 20 | El bucle de reconciliación, la detección de *drift* y la sincronización |
| Demostración | 20 | Un cambio aprobado se sincroniza; un cambio manual se revierte automáticamente |
| Microtaller | 30 | Flujo completo: cambiar la imagen por digest, abrir un pull request, sincronizar y revertir con `git revert` |
| Receso | 15 | Descanso |
| Promoción entre entornos | 20 | Carpetas o ramas por entorno, y aprobaciones antes de llegar a producción |
| Secretos fuera de Git | 15 | Por qué no se guardan valores en el repositorio; referencias a un almacén de secretos |
| Gobernanza | 15 | Protección de ramas, quién aprueba y auditoría de commits |
| Mentoría | 20 | Atención individual al proyecto de cada alumno |
| Síntesis | 5 | Qué cambio puede llegar a producción, quién lo aprueba y cómo se revierte |

La evidencia de la semana está en el [README de la semana](../README.md). Las presentaciones, cuando existan, van en [recursos](../recursos/README.md).
