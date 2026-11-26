# Taller práctico: diagnóstico de problemas de red con tcpdump

**Modalidad:** laboratorio local con Docker Compose
**Duración sugerida:** 30 minutos
**Nivel:** fundamentos de networking / DevOps
**Requisitos:** Docker Engine o Docker Desktop y Docker Compose
**Costo:** gratuito; no requiere cuenta de AWS ni infraestructura cloud


## 1. Descripción del taller

En este taller se construye una red aislada en Docker y se usa `tcpdump` para observar paquetes y diagnosticar fallos reproducibles de conectividad, DNS y aplicación.

El objetivo no es memorizar comandos, sino formular hipótesis y comprobarlas con evidencia de red.

### Resultados de aprendizaje

Al finalizar, cada estudiante podrá:

1. Identificar la interfaz de red que debe capturar.
2. Capturar y filtrar tráfico TCP, UDP, DNS, ICMP y HTTP.
3. Reconocer el establecimiento TCP de tres pasos (SYN, SYN-ACK y ACK).
4. Diferenciar un puerto cerrado de un timeout.
5. Distinguir una respuesta DNS `NXDOMAIN` de la ausencia de respuesta.
6. Reconocer cuándo la conectividad funciona, pero falla la aplicación.
7. Guardar una captura PCAP y analizarla posteriormente.
8. Documentar un diagnóstico basado en paquetes observados.

### Agenda sugerida

| Tiempo | Actividad |
|---|---|
| 10 min | Introducción a `tcpdump`, interfaces y filtros |
| 10 min | Levantar y verificar el laboratorio |
| 15 min | Experimento 1: TCP handshake |
| 10 min | Experimento 2: puerto cerrado |
| 15 min | Experimento 3: DNS |
| 10 min | Experimento 4: HTTP 404 |
| 15 min | Experimento 5: TCP timeout y retransmisiones |
| 10 min | Guardar y analizar PCAP |
| 15 min | Reto final y discusión |

## 2. Arquitectura del laboratorio

Tres contenedores en una red bridge privada:

```text
                  Docker bridge: 172.30.0.0/24

  +----------------------+                 +----------------------+
  | client               |                 | web                  |
  | 172.30.0.10          |---- TCP:8080 -->| 172.30.0.20          |
  |                      |                 | Python HTTP server   |
  | curl, dig, tcpdump   |                 |                      |
  +----------------------+                 +----------------------+
             |
             | DNS: UDP/53
             v
  +----------------------+
  | dns                  |
  | 172.30.0.53          |
  | CoreDNS              |
  +----------------------+
```

| Servicio | IP | Función |
|---|---|---|
| `client` | `172.30.0.10` | Genera solicitudes y captura paquetes |
| `web` | `172.30.0.20` | Servidor HTTP en TCP/8080 |
| `dns` | `172.30.0.53` | Resuelve `web.lab` mediante DNS |

La red es local y aislada. No se publican puertos al host ni se necesita acceso a AWS.

Si `172.30.0.0/24` se solapa con una red que ya usas en tu equipo, cambia el subnet y las IP estáticas en `docker-compose.yml` y en `dns/db.lab` antes de iniciar el laboratorio.

## 3. Requisitos previos

Comprueba que Docker y Compose estén disponibles:

```bash
docker --version
docker compose version
```

Esta carpeta ya es el laboratorio:

```text
taller_networking/
├── docker-compose.yml
├── Dockerfile
├── dns/
│   ├── Corefile
│   └── db.lab
├── captures/
└── README.md
```

Los comandos de las secciones siguientes se ejecutan desde aquí.

## 4. Construcción del entorno

### 4.1. `docker-compose.yml`

```yaml
services:
  client:
    image: nicolaka/netshoot
    container_name: lab-client
    command: sleep infinity
    cap_add:
      - NET_ADMIN
      - NET_RAW
    dns:
      - 172.30.0.53
    networks:
      lab-network:
        ipv4_address: 172.30.0.10

  web:
    build: .
    image: lab-web:local
    container_name: lab-web
    command: python -m http.server 8080 --bind 0.0.0.0
    cap_add:
      - NET_ADMIN
    networks:
      lab-network:
        ipv4_address: 172.30.0.20

  dns:
    image: coredns/coredns:1.11.3
    container_name: lab-dns
    command: -conf /etc/coredns/Corefile
    volumes:
      - ./dns:/etc/coredns:ro
    networks:
      lab-network:
        ipv4_address: 172.30.0.53

networks:
  lab-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.0.0/24
```

El contenedor `client` usa Netshoot, que incluye las herramientas de diagnóstico. `NET_RAW` permite capturar paquetes. `NET_ADMIN` en `client` y en `web` permite usar `iptables` dentro de esos contenedores, que es el experimento 5.

`web` parte de `python:3.12-alpine` y el `Dockerfile` le añade `iptables`. Sin esa capacidad el contenedor no puede descartar paquetes en su propia cadena `INPUT`.

### 4.2. DNS

`dns/Corefile`:

```text
lab:53 {
    errors
    log
    file /etc/coredns/db.lab lab
}
```

`dns/db.lab`:

```text
$ORIGIN lab.
$TTL 30
@       IN SOA  ns.lab. admin.lab. 2026112601 7200 3600 1209600 30
        IN NS   ns.lab.
web     IN A    172.30.0.20
```

CoreDNS es autoritativo de la zona `lab`. `web.lab` responde `172.30.0.20`. Cualquier otro nombre de esa zona, como `missing.lab`, responde `NXDOMAIN`: el servidor contestó, y el nombre no existe. El plugin `hosts` de esta versión de CoreDNS no escribe esa respuesta; devuelve `SERVFAIL`, y el experimento 3 dejaría de distinguir un nombre inexistente de un servidor que no contesta.

### 4.3. Iniciar el laboratorio

```bash
docker compose up -d
docker compose ps
```

Verifica las direcciones:

```bash
docker compose exec client ip addr
```

Comprueba que el servidor HTTP responde:

```bash
docker compose exec client curl -i http://172.30.0.20:8080
```

Comprueba DNS:

```bash
docker compose exec client dig @172.30.0.53 web.lab
```

La respuesta debe incluir `172.30.0.20`.

Para abrir una shell interactiva en el cliente:

```bash
docker compose exec client bash
```

En los experimentos se puede ejecutar `tcpdump` desde esa shell y generar tráfico desde una segunda terminal del host con:

```
cd Estud-IA_cloud/semana-03/sesion-5/taller_networking
docker compose exec client curl -v http://172.30.0.20:8080
```

## 5. Introducción rápida a tcpdump

`tcpdump` captura paquetes que pasan por una interfaz de red y permite aplicar filtros para reducir el tráfico observado.

### 5.1. Identificar interfaces

Dentro del contenedor cliente:

```bash
ip addr
tcpdump -D
```

En este laboratorio, la interfaz de interés es `eth0`.

### 5.2. Comando básico

```bash
tcpdump -i eth0
```

Es preferible empezar con:

```bash
tcpdump -i eth0 -nn
```

- `-i eth0` selecciona la interfaz.
- `-n` evita resolver direcciones IP a nombres.
- `-nn` evita resolver también los nombres de puertos.
- `-v`, `-vv`, `-vvv` aumentan el nivel de detalle.
- `-s 0` captura el paquete completo, en lugar de truncarlo al tamaño de captura predeterminado.
- `-w archivo.pcap` guarda paquetes en un archivo.
- `-r archivo.pcap` lee una captura guardada.

Para detener una captura interactiva, usa `Ctrl+C`.

### 5.3. Filtros útiles

| Filtro | Qué selecciona |
|---|---|
| `icmp` | Paquetes ICMP |
| `tcp` | Paquetes TCP |
| `udp` | Paquetes UDP |
| `port 53` | Tráfico cuyo puerto de origen o destino es 53 |
| `tcp port 8080` | TCP asociado al puerto 8080 |
| `host 172.30.0.20` | Tráfico hacia o desde esa IP |
| `src host 172.30.0.10` | Paquetes cuyo origen es esa IP |
| `dst host 172.30.0.20` | Paquetes cuyo destino es esa IP |
| `tcp and port 443` | TCP asociado al puerto 443 |
| `tcp[tcpflags] & tcp-syn != 0` | Paquetes TCP con el flag SYN activado |

Los filtros de `tcpdump` usan la sintaxis de captura de libpcap. Se combinan con `and`, `or`, `not` y paréntesis.

## 6. Experimento 1: observar el TCP three-way handshake

**Nivel:** básico
**Objetivo:** reconocer cómo se establece una conexión TCP.

### Terminal A: iniciar captura

```bash
docker compose exec client bash
```

```bash
tcpdump -i eth0 -nn 'tcp port 8080'
```

### Terminal B: generar tráfico

Desde otra terminal del host:

```bash
docker compose exec client curl -v http://172.30.0.20:8080
```

### Qué observar

La salida debe mostrar el intercambio TCP. Los puertos de origen son dinámicos, así que los números concretos pueden variar.

```text
172.30.0.10.45000 > 172.30.0.20.8080: Flags [S]
172.30.0.20.8080 > 172.30.0.10.45000: Flags [S.]
172.30.0.10.45000 > 172.30.0.20.8080: Flags [.]
```

1. `SYN` (`[S]`): el cliente solicita iniciar una conexión.
2. `SYN-ACK` (`[S.]`): el servidor responde y acepta iniciar la conexión.
3. `ACK` (`[.]`): el cliente confirma la respuesta.

Después del handshake circulan los datos de la solicitud HTTP y su respuesta.

### Preguntas

1. ¿Qué IP inicia la conexión?
2. ¿Qué IP recibe la conexión?
3. ¿Cuál es el puerto del servicio?
4. ¿Por qué el puerto del cliente puede cambiar entre ejecuciones?
5. ¿Qué evidencia confirma que TCP se estableció?

### Conclusión esperada

El handshake SYN, SYN-ACK y ACK demuestra que se pudo establecer la conexión TCP entre cliente y servidor. No demuestra por sí solo que la aplicación haya procesado correctamente una solicitud.

## 7. Experimento 2: diagnosticar un puerto cerrado

**Nivel:** básico
**Objetivo:** diferenciar un rechazo TCP de un timeout.

El servidor escucha en el puerto `8080`, no en el `8081`.

### Terminal A: captura

```bash
tcpdump -i eth0 -nn 'tcp port 8081'
```

### Terminal B: generar el intento de conexión

```bash
docker compose exec client curl -v --connect-timeout 5 http://172.30.0.20:8081
```

### Qué observar

En condiciones normales, el servidor responde con un paquete TCP RST, habitualmente RST-ACK:

```text
172.30.0.10.45000 > 172.30.0.20.8081: Flags [S]
172.30.0.20.8081 > 172.30.0.10.45000: Flags [R.]
```

`RST` significa reset. Aquí el destino rechazó la conexión porque no hay un proceso escuchando en ese puerto.

### Preguntas

1. ¿El SYN salió del cliente?
2. ¿Hubo una respuesta del servidor?
3. ¿La respuesta fue SYN-ACK o RST?
4. ¿Cómo se diferencia este resultado de una conexión que expira por timeout?

### Conclusión esperada

Un RST inmediato suele corresponder a una conexión rechazada, por ejemplo porque el puerto está cerrado. Un timeout indica que no llegó una respuesta útil dentro del periodo esperado. La causa de un timeout puede estar en un firewall, una ruta, una pérdida de paquetes o un host que no responde.

## 8. Experimento 3: diagnosticar problemas DNS

**Nivel:** intermedio
**Objetivo:** distinguir entre un nombre inexistente y un servidor DNS que no responde.

### 8.1. Consulta DNS correcta

```bash
tcpdump -i eth0 -nn 'udp port 53'
```

En otra terminal:

```bash
docker compose exec client dig @172.30.0.53 web.lab
```

La captura debe mostrar una consulta desde el cliente al servidor DNS y una respuesta con `172.30.0.20`.

```text
172.30.0.10.53000 > 172.30.0.53.53: A? web.lab.
172.30.0.53.53 > 172.30.0.10.53000: A 172.30.0.20
```

Los puertos de origen y los identificadores de consulta pueden variar.

### 8.2. Consultar un nombre inexistente

```bash
docker compose exec client dig @172.30.0.53 missing.lab
```

La respuesta debe indicar `NXDOMAIN`: el servidor DNS contestó, y el nombre consultado no existe.

### 8.3. Simular un servidor DNS que no responde

Consulta una IP donde no hay servidor DNS:

```bash
docker compose exec client dig @172.30.0.99 missing.lab +time=2 +tries=1
```

Para observar el tráfico:

```bash
tcpdump -i eth0 -nn 'host 172.30.0.99 and udp port 53'
```

No debería recibirse una respuesta DNS desde `172.30.0.99`. La consulta termina por timeout.

### Comparación

| Situación | Evidencia esperada |
|---|---|
| Resolución correcta | Respuesta DNS con un registro |
| Nombre inexistente | Respuesta DNS con `NXDOMAIN` |
| DNS no responde | Consulta visible, sin respuesta DNS |

### Preguntas

1. ¿Cómo sabes que la consulta salió del cliente?
2. ¿Qué diferencia hay entre `NXDOMAIN` y timeout?
3. ¿Por qué no es correcto concluir que DNS está caído solo porque un nombre no resuelve?

## 9. Experimento 4: diferenciar un error HTTP de un problema de red

**Nivel:** intermedio
**Objetivo:** comprobar que una conexión puede funcionar aunque la aplicación devuelva un error.

El servidor Python sirve archivos desde su directorio de trabajo. La ruta raíz responde. Una ruta inexistente devuelve HTTP 404.

### Terminal A: capturar HTTP

```bash
tcpdump -i eth0 -nn -A 'tcp port 8080'
```

`-A` muestra el contenido de los paquetes como texto ASCII. Sirve aquí porque HTTP viaja sin cifrar. En una red real puede exponer credenciales, tokens u otros datos.

### Terminal B: solicitar una ruta inexistente

```bash
docker compose exec client curl -i http://web.lab:8080/does-not-exist
```

La respuesta será similar a:

```text
HTTP/1.0 404 File not found
```

En la captura se puede encontrar la solicitud:

```text
GET /does-not-exist HTTP/1.1
Host: web.lab:8080
```

Y la respuesta HTTP correspondiente.

### Preguntas

1. ¿Se resolvió `web.lab`?
2. ¿Se estableció TCP?
3. ¿El servidor recibió una solicitud HTTP?
4. ¿Qué significa el código 404?
5. ¿Es un problema de conectividad o de aplicación?

### Conclusión esperada

DNS y TCP pueden funcionar y, aun así, la aplicación puede devolver un error HTTP. Un 404 indica que el servidor HTTP no encontró el recurso solicitado. No indica un fallo de red.

## 10. Experimento 5: simular un TCP timeout y observar retransmisiones

**Nivel:** intermedio/avanzado
**Objetivo:** observar qué ocurre cuando los paquetes SYN se descartan silenciosamente.

La regla de `iptables` se aplica en el contenedor `web`, en la cadena `INPUT`. Descarta los paquetes que ya salieron del cliente y llegaron al servidor. No se modifica el firewall del host.

Un `DROP` en la cadena `OUTPUT` del cliente tira el paquete antes de `eth0`. `tcpdump` en esa interfaz no muestra nada, y no hay retransmisión visible. El descarte en el servidor deja el SYN a la vista y esconde la respuesta. Ese es el patrón de un firewall que descarta en silencio.

### 10.1. Capturar los intentos

En la shell del cliente:

```bash
tcpdump -i eth0 -nn 'tcp port 8080'
```

### 10.2. Aplicar una regla DROP

Desde otra terminal del host, en el servidor:

```bash
docker compose exec web iptables -I INPUT 1 -p tcp --dport 8080 -j DROP
```

La regla descarta en silencio el TCP destinado al puerto 8080 del servidor.

### 10.3. Generar la conexión

```bash
docker compose exec client curl -v --connect-timeout 12 http://172.30.0.20:8080
```

### Qué observar

La captura en `eth0` del cliente debería mostrar paquetes SYN repetidos, sin SYN-ACK ni RST:

```text
172.30.0.10.45000 > 172.30.0.20.8080: Flags [S]
172.30.0.10.45000 > 172.30.0.20.8080: Flags [S]
172.30.0.10.45000 > 172.30.0.20.8080: Flags [S]
```

Los intervalos entre retransmisiones dependen de la implementación TCP y de sus temporizadores.

### 10.4. Retirar la regla

```bash
docker compose exec web iptables -D INPUT -p tcp --dport 8080 -j DROP
```

Comprueba que el servicio vuelve a responder:

```bash
docker compose exec client curl -v --connect-timeout 5 http://172.30.0.20:8080
```

### Preguntas

1. ¿Se observa el SYN inicial?
2. ¿Se observa alguna respuesta del servidor?
3. ¿Por qué el cliente retransmite el SYN?
4. ¿Qué diferencia hay entre `DROP` y `REJECT`?
5. ¿Qué causas reales podrían producir un patrón parecido?

### Conclusión esperada

Cuando los paquetes se descartan en silencio, el cliente no recibe respuesta y retransmite el SYN. Eso encaja con un firewall que descarta tráfico, y también con pérdida de paquetes, un problema de ruta o un host inaccesible. Una captura en un solo extremo no siempre permite localizar la causa exacta.

## 11. Experimento 6: guardar y analizar una captura PCAP

**Nivel:** básico/intermedio
**Objetivo:** guardar evidencia para analizarla fuera de la sesión en vivo.

El directorio `captures/` ya está en el proyecto. Los `.pcap` no se versionan.

Dentro del cliente, inicia una captura:

```bash
tcpdump -i eth0 -nn -s 0 -w /tmp/network-lab.pcap
```

Genera tráfico desde otra terminal:

```bash
docker compose exec client curl http://172.30.0.20:8080
docker compose exec client dig @172.30.0.53 web.lab
```

Detén la captura con `Ctrl+C`.

Lee el archivo dentro del contenedor:

```bash
tcpdump -nn -r /tmp/network-lab.pcap
```

Copia el archivo al host:

```bash
docker cp lab-client:/tmp/network-lab.pcap ./captures/network-lab.pcap
```

Si tienes Wireshark instalado, abre `captures/network-lab.pcap`.

| Filtro de Wireshark | Uso |
|---|---|
| `tcp` | Mostrar TCP |
| `dns` | Mostrar DNS |
| `http` | Mostrar HTTP reconocido |
| `tcp.port == 8080` | Mostrar tráfico del servidor web |
| `ip.addr == 172.30.0.20` | Mostrar tráfico hacia o desde el servidor |
| `tcp.flags.syn == 1` | Mostrar paquetes SYN |

Los filtros de Wireshark no usan la misma sintaxis que los filtros de captura de `tcpdump`.

## 12. Reto final: diagnóstico sin conocer la causa

**Objetivo:** aplicar un proceso de troubleshooting basado en evidencia.

Entrega únicamente el síntoma. Cada equipo propone filtros, captura tráfico y documenta sus conclusiones.

### Caso A: conexión rechazada

```text
curl: Failed to connect to 172.30.0.20 port 8081
```

- ¿Qué filtro utilizarías?
- ¿Se observa SYN?
- ¿Qué responde el servidor?
- ¿Qué significa el flag RST?

### Caso B: error de resolución

```text
curl: Could not resolve host: missing.lab
```

- ¿Se envió una consulta DNS?
- ¿El servidor DNS respondió?
- ¿La respuesta fue NXDOMAIN o hubo timeout?

### Caso C: el backend responde 404

```text
HTTP/1.0 404 File not found
```

- ¿Funcionó DNS?
- ¿Se estableció TCP?
- ¿Qué solicitud HTTP se envió?
- ¿En qué capa está el problema?

### Caso D: timeout al conectar

```text
curl: Connection timed out
```

- ¿Se observa SYN?
- ¿Hay retransmisiones?
- ¿Se recibe RST o SYN-ACK?
- ¿Qué hipótesis investigarías antes de concluir que el servidor está caído?

### Entregable de cada equipo

1. Síntoma observado.
2. Hipótesis inicial.
3. Comando y filtro utilizados.
4. Evidencia relevante de la captura.
5. Diagnóstico más probable.
6. Qué comprobación adicional haría falta para confirmar la causa.

## 13. Guía del instructor: resultados esperados

Esta sección es para quien facilita el taller. Conviene no entregarla antes del reto final.

| Experimento | Evidencia esperada | Interpretación |
|---|---|---|
| TCP handshake | SYN, SYN-ACK, ACK | Conexión TCP establecida |
| Puerto 8081 | SYN seguido de RST | Conexión rechazada; puerto sin listener |
| DNS `web.lab` | Consulta y respuesta A | Resolución correcta |
| DNS `missing.lab` | Respuesta NXDOMAIN | Nombre inexistente |
| DNS `172.30.0.99` | Consulta sin respuesta | Resolver no disponible o inaccesible |
| HTTP inexistente | Solicitud GET y respuesta 404 | Error de recurso en la aplicación |
| Regla DROP | SYN retransmitidos sin respuesta, visibles en `eth0` del cliente | Paquetes descartados en silencio en el `INPUT` del servidor |

### Advertencias de interpretación

- Un SYN sin respuesta no demuestra por sí solo que un firewall esté bloqueando el tráfico.
- Un RST suele indicar rechazo, y hay que identificar qué equipo lo generó.
- `NXDOMAIN` es una respuesta DNS válida: el nombre no existe.
- Un timeout DNS y un `NXDOMAIN` son situaciones distintas.
- Un HTTP 404 demuestra que se recibió una respuesta HTTP. No es un fallo de establecimiento TCP.
- Una captura en un solo punto muestra lo que ve ese punto. Para localizar dónde se pierde un paquete, puede hacer falta capturar a la vez en cliente y servidor.
- Un `DROP` en `OUTPUT` del propio cliente no aparece en `tcpdump -i eth0`. La interfaz no llegó a transmitir el paquete. Por eso el experimento descarta en el servidor.

## 14. Troubleshooting del propio laboratorio

### Los contenedores no inician

```bash
docker compose ps
docker compose logs
```

Si el subnet ya está en uso, cambia `172.30.0.0/24` por otro rango privado libre y actualiza todas las IP relacionadas, incluido `dns/db.lab` y el `dns:` del cliente.

### No se resuelve `web.lab`

```bash
docker compose logs dns
docker compose exec client dig @172.30.0.53 web.lab
```

Verifica que `dns/` esté montado y que CoreDNS haya arrancado.

### tcpdump no puede capturar paquetes

Comprueba que el servicio `client` tenga `NET_RAW` y `NET_ADMIN` en Compose. Ejecuta `tcpdump` dentro de `lab-client`, no en macOS.

### curl no conecta al servidor

```bash
docker compose ps
docker compose exec client ip route
docker compose exec client curl -v http://172.30.0.20:8080
docker compose logs web
```

El servidor web tiene que estar activo y escuchando en `0.0.0.0:8080`.

### El experimento de timeout sigue fallando

```bash
docker compose exec web iptables -L INPUT -n -v
```

Si la regla sigue presente:

```bash
docker compose exec web iptables -D INPUT -p tcp --dport 8080 -j DROP
```

## 15. Consideraciones para macOS y Docker Desktop

En macOS, Docker Desktop ejecuta los contenedores dentro de un Linux virtualizado.

- Ejecuta `tcpdump` dentro del contenedor `client`.
- Captura la interfaz `eth0` del contenedor cliente, también en el experimento 5.
- No hace falta capturar la interfaz Wi-Fi (`en0`) de macOS.
- No hace falta instalar `tcpdump` en macOS.
- El tráfico de la red bridge se observa desde el contenedor cliente.

La captura dentro del contenedor muestra el tráfico que entra y sale de su interfaz virtual. No equivale a capturar todo el tráfico del host o de la red física.

## 16. Limpieza del laboratorio

```bash
docker compose down
```

Para borrar también las capturas del proyecto:

```bash
rm -f captures/*.pcap
```

No hace falta borrar las imágenes. Sirven para la siguiente sesión.

## 17. Checklist de aprendizaje

- [ ] Identifico la interfaz correcta para capturar paquetes.
- [ ] Puedo filtrar por protocolo, puerto y dirección IP.
- [ ] Reconozco SYN, SYN-ACK y ACK.
- [ ] Distingo un RST de un timeout.
- [ ] Diferencio NXDOMAIN de una consulta DNS sin respuesta.
- [ ] Puedo reconocer una respuesta HTTP 404.
- [ ] Puedo identificar retransmisiones TCP.
- [ ] Sé guardar y leer un archivo PCAP.
- [ ] Puedo explicar qué evidencia respalda mi diagnóstico.

## 18. Mensaje central del taller

`tcpdump` no diagnostica el problema: muestra los paquetes que pasan por un punto de observación.

1. Definir el síntoma.
2. Formular una hipótesis.
3. Elegir la interfaz y el filtro.
4. Generar o reproducir el tráfico.
5. Observar la evidencia.
6. Comparar lo observado con el comportamiento esperado.
7. Confirmar o descartar la hipótesis con otra prueba.

La pregunta del laboratorio: qué paquete esperaba ver, qué paquete observé, y qué dice esa diferencia sobre el problema.
