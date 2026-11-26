# Semana 3 · Redes, cómputo y despliegue en AWS

Esta semana responde una pregunta: ¿por dónde llega el tráfico, dónde corre la aplicación y cómo cambia su versión? Al terminar, puedes explicar el camino de una petición, nombrar dónde corre el servicio y describir un cambio con su criterio de parada y su reversión.

En la planeación, las dos clases se llaman Sesión 1 y Sesión 2. En el repositorio son [sesion-5](sesion-5/README.md) y [sesion-6](sesion-6/README.md), para seguir la numeración continua del curso. El guion detallado vive fuera de este repositorio, en `sesion1_guion_clase_v2.md`. Aquí están los bloques, la evidencia y las notas.

## Mapa de la semana

| Encuentro | Carpeta | Título | Qué te llevas |
|---|---|---|---|
| 5 | [sesion-5](sesion-5/README.md) | Networking | El camino de una petición, de la red al borde |
| 6 | [sesion-6](sesion-6/README.md) | Cómputo, despliegue e introducción a IaC | Una estrategia de despliegue con parada y reversión |

## Antes de la semana: lo asincrónico en Platzi

**M4 · Redes avanzadas y conectividad** acompaña esta semana: VPC, DNS, WAF y balanceadores. En el encuentro usamos ese vocabulario para seguir una petición.

## Sesión 5 · Networking

| Bloque | Min | Contenido |
|---|---|---|
| Apertura | 5 | Qué camino recorre una petición |
| Fundamentos de red | 45 | Networking, IP, IPv4 y IPv6, CIDR, puertos TCP y UDP, DNS, TLS, VPN |
| Redes en la nube | 40 | VPC, subredes, tablas de rutas, Internet Gateway, NAT, balanceadores, endpoints, peering y Transit Gateway |
| Pricing de la red | 10 | Cobros por puerta, por datos y por salida, en AWS, GCP y Azure |
| Seguridad, edge y observación | 45 | Principios de seguridad, security groups y NACL, WAF, Route 53 frente a Cloudflare, flow logs, herramientas de diagnóstico |
| Receso | 15 | Descanso |
| Demostración | 20 | Seguir una petición de punta a punta con un fallo sembrado |

## Sesión 6 · Cómputo, despliegue e introducción a IaC

| Bloque | Min | Contenido |
|---|---|---|
| Apertura | 5 | Qué cambió desde la sesión 5 |
| Microtaller | 20 | VPC, subredes públicas y privadas, instancias EC2 en AWS Emulator |
| Instancias EC2 | 8 | Nombre de una instancia, familias y ejemplos de procesos |
| Demostración | 15 | Diagnóstico de una instancia que no responde |
| Receso | 15 | Descanso |
| Operación de cambios | 105 | Ciclo de vida, costos, arranque en frío, permisos, acceso seguro, estrategias, criterios de parada, reversión, datos, configuración |
| Introducción a IaC | 5 | Declarativa frente a imperativa; el archivo como fuente de verdad |
| Síntesis | 12 | Tres preguntas sobre el caso de cada alumno |

## Evidencia de la semana

Versión identificable, red explicada con su camino, una estrategia de despliegue con su criterio de parada y su reversión.

## Notas

La mentoría de 20 minutos está en las semanas 4 y 5. En esta semana quedó fuera por tiempo. Si se mueve aquí, se acorta la síntesis o el receso. El receso no se toca.

## Cómo se conecta con lo que sigue

| Concepto | Esta semana | Semana 4 | Semana 5 |
|---|---|---|---|
| Versión identificable | Etiqueta y digest de la imagen | Imagen fijada en el manifiesto | Variable de versión en el módulo |
| Salud | Endpoint `/health` y health checks | Readiness y liveness | Recursos de alarma definidos en código |
| Reversión | Volver a la versión anterior del despliegue | `git revert` y reconciliación | Revertir el commit y aplicar el plan |
| Lo que no vuelve | Datos y configuración | Secretos y datos del clúster | Estado y recursos con datos |

## Para llevar a la semana 4

Guarda la versión, el camino de la red y la estrategia con su parada y su reversión. La semana 4 deja las instancias y pasa al clúster.

## Material

| Dónde | Qué hay |
|---|---|
| [sesion-5](sesion-5/README.md) | Bloques de networking. `main.go` es un arranque mínimo que ya estaba en la carpeta. |
| [sesion-6](sesion-6/README.md) | Bloques de cómputo, despliegue e introducción a IaC. |
| [recursos](recursos/README.md) | Presentaciones de la semana. Todavía no hay archivos. |
