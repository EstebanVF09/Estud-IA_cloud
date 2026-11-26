# Sesión 7 · Kubernetes para operación

Qué cambia cuando una aplicación tiene muchas réplicas y varios nodos: objetos, sondas y una reversión dentro del clúster.

En la planeación de la semana 4 esta clase es la Sesión 1. En el repositorio es `sesion-7`.

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

La evidencia de la semana está en el [README de la semana](../README.md). Las presentaciones, cuando existan, van en [recursos](../recursos/README.md).
