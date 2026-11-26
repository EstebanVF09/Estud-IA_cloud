# Semana 4 · Kubernetes y GitOps

Esta semana deja de administrar instancias y pasa a administrar un clúster. Kubernetes describe la aplicación como objetos. GitOps mantiene esos objetos en Git y hace que el clúster se parezca a lo que está en el repositorio.

La pregunta de la semana: ¿cómo se orquesta una aplicación y cómo se controla su estado desde Git?

En la planeación, las dos clases se llaman Sesión 1 y Sesión 2. En el repositorio son [sesion-7](sesion-7/README.md) y [sesion-8](sesion-8/README.md).

## Mapa de la semana

| Encuentro | Carpeta | Título | Qué te llevas |
|---|---|---|---|
| 7 | [sesion-7](sesion-7/README.md) | Kubernetes para operación | Un Deployment, un Service y una reversión con `rollout undo` |
| 8 | [sesion-8](sesion-8/README.md) | GitOps | Un cambio que entra por pull request y una reversión registrada como commit |

## Antes de la semana: lo asincrónico en Platzi

Esta semana asume que Platzi cubre Kubernetes. Si el curso trae otros temas, la demostración y el microtaller se ajustan para no repetirlos.

## Sesión 7 · Kubernetes para operación

| Bloque | Min | Contenido |
|---|---|---|
| Apertura | 5 | Qué cambia cuando una aplicación tiene muchas réplicas y varios nodos |
| Clase 1: arquitectura | 15 | Plano de control y nodos, y qué administra EKS frente a lo que administra el equipo |
| Clase 2: objetos básicos | 20 | Pods, Deployments, Services e Ingress; cómo un Service encuentra sus pods |
| Clase 3: sondas | 15 | Readiness frente a liveness, y cómo una sonda mal diseñada puede reiniciar un servicio sano o mantener uno roto en el balanceador |
| Microtaller | 30 | Un Deployment con dos réplicas y un Service en un clúster local, con una versión defectuosa y `rollout undo` |
| Receso | 15 | Descanso |
| Demostración | 20 | Diagnóstico de un pod en `CrashLoopBackOff` y otro en `Pending`, con `describe`, `logs` y eventos |
| EKS en AWS | 15 | Cómo se cobra el plano de control, los nodos y Fargate; qué se administra en cada caso |
| Estrategias en Kubernetes | 15 | `maxSurge` y `maxUnavailable`; por qué el canary requiere una herramienta adicional |
| Mentoría | 20 | Atención individual al proyecto de cada alumno |
| Síntesis | 5 | Qué decide la sonda y qué decide el despliegue |

Si AWS Emulator no implementa EKS, el clúster local (kind o minikube) es un equivalente y hay que declararlo como tal. La diferencia está en el plano de control gestionado, no en los objetos.

## Sesión 8 · GitOps

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

## Evidencia de la semana

Un despliegue dirigido desde Git, una prueba de *drift* corregido, una reversión registrada como commit y una lista de los secretos que no están en el repositorio.

## Cómo se conecta

| Concepto | Semana 3 | Esta semana | Semana 5 |
|---|---|---|---|
| Versión identificable | Etiqueta y digest de la imagen | Imagen fijada en el manifiesto | Variable de versión en el módulo |
| Salud | Endpoint `/health` y health checks | Readiness y liveness | Recursos de alarma definidos en código |
| Reversión | Volver a la versión anterior del despliegue | `git revert` y reconciliación | Revertir el commit y aplicar el plan |
| Lo que no vuelve | Datos y configuración | Secretos y datos del clúster | Estado y recursos con datos |

## Para llevar a la semana 5

Guarda el manifiesto con la imagen fijada, la prueba de *drift* y el commit de la reversión. La semana 5 describe en código la infraestructura sobre la que ese clúster se apoya.

## Material

| Dónde | Qué hay |
|---|---|
| [sesion-7](sesion-7/README.md) | Bloques de Kubernetes para operación. |
| [sesion-8](sesion-8/README.md) | Bloques de GitOps. |
| [recursos](recursos/README.md) | Presentaciones de la semana. Todavía no hay archivos. |
