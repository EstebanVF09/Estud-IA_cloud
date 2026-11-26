# Scripts · el camino de una petición

Estos scripts acompañan la sesión 5. La semana pregunta por dónde llega el tráfico. Aquí se recorre ese camino en piezas: la dirección, la red en la que cabe, el puerto que escucha, el nombre que se resuelve antes de salir, el certificado del puerto 443 y la VPN que entra a la red privada.

El orden de una petición real empieza por el nombre. El cliente pregunta el DNS, recibe una IP, abre un puerto TCP y, si es HTTPS, negocia TLS. Los archivos están numerados al revés de ese recorrido, de la dirección hacia el nombre, porque así se construye el vocabulario en clase.

| Script | Bloque de la sesión | Qué deja ver |
|---|---|---|
| `1_ip.py` | Fundamentos · IPv4 | Una dirección privada, en bytes y en versión |
| `2_ip_v6.py` | Fundamentos · IPv6 | El prefijo de documentación y su tamaño |
| `3_ip_cidr.py` | Redes en la nube · VPC y subredes | Una `/16` partida en `/24`, y las direcciones que AWS reserva |
| `4_ports.sh` | Puertos TCP/UDP y diagnóstico | Quién escucha en esta máquina y si un puerto remoto acepta conexión |
| `5_dns.sh` | DNS | La respuesta corta, el TTL y el camino desde la raíz |
| `6_tls.sh` | TLS | El certificado que presenta el servidor en el 443 |
| `7_vpn.sh` | VPN | Las VPN de sitio y los endpoints Client VPN de la cuenta |
| `8_ec2.sh` | VPN | Las mismas dos consultas que `7_vpn.sh` |

## Cómo correrlos

Los tres de Python tienen receta en el `justfile`. Desde esta carpeta:

```bash
just ip
just ip-v6
just ip-cidr
```

Los de shell se lanzan con bash. `4_ports.sh` pide `sudo` dentro del script. `5_dns.sh` y `6_tls.sh` salen a internet. `7_vpn.sh` y `8_ec2.sh` usan la AWS CLI con las credenciales del entorno.

```bash
bash 4_ports.sh
bash 5_dns.sh
bash 6_tls.sh
bash 7_vpn.sh
bash 8_ec2.sh
```

Hacen falta `python3`, `lsof`, `nc`, `dig` (paquete `bind`), `openssl` y `aws`.

## `1_ip.py` · una IPv4

Toma `192.168.10.25` con el módulo `ipaddress` e imprime tres cosas: los cuatro octetos en hexadecimal (`c0a80a19`), si la dirección es privada (`True`) y la versión (`4`).

`192.168.0.0/16` es espacio privado. No se anuncia en internet. En una VPC ese mismo papel lo cumple `10.0.0.0/8` o `172.16.0.0/12`: la instancia tiene una dirección que solo significa algo dentro de la red. La petición que viene de fuera llega a una dirección pública o a un balanceador, y de ahí salta a esta privada.

No usa comandos de Linux. La biblioteca hace el trabajo que en una máquina harías con `ip addr`.

## `2_ip_v6.py` · una IPv6

Construye `2001:db8::1` e imprime la versión (`6`), `is_private` y cuántas direcciones caben en `2001:db8::/32`.

`2001:db8::/32` está reservado para documentación. No es un prefijo que debas anunciar ni asignar a una instancia. Un `/32` deja libres 96 bits, así que `num_addresses` es 2⁹⁶ (`79228162514264337593543950336`). Por eso una VPC IPv6 se parte en prefijos enormes comparada con IPv4: el límite deja de ser el número de hosts.

En el intérprete de esta máquina `is_private` imprime `True`. La biblioteca trata ese prefijo de documentación como no enrutable en internet. El comentario del archivo dice `False`; el valor que sale al correrlo es `True`.

## `3_ip_cidr.py` · la VPC en CIDR

Arma la red `10.0.0.0/16`, la misma forma que una VPC de ejemplo.

Un `/16` fija los primeros 16 bits y deja 16 para hosts: 2¹⁶ = 65536 direcciones. `subnets(new_prefix=24)` parte esa red en bloques `/24`. La diferencia de prefijo es 8 bits, así que salen 2⁸ = 256 subredes. La primera es `10.0.0.0/24`. En AWS cada una de esas `/24` puede ser una subred de una zona de disponibilidad, pública o privada según la tabla de rutas tenga ruta al Internet Gateway o solo al NAT.

Después toma `10.0.1.0/28`. Un `/28` tiene 16 direcciones. AWS reserva cinco en cada subred: la dirección de red, el router de la VPC, el DNS, una reservada para uso futuro y el broadcast. Quedan 11 utilizables. El script imprime `num_addresses - 5`, que es 11. Ese número es el que cabe en un security group cuando cuentas instancias, no el tamaño del CIDR.

Tampoco llama comandos de Linux. El cálculo es el que después escribes en la consola al crear la VPC y las subredes.

## `4_ports.sh` · TCP, UDP y si el puerto abre

Una dirección sin puerto no llega a un proceso. Este script mira los dos lados: qué puertos escuchan aquí y si un puerto remoto completa el handshake.

```bash
sudo lsof -iTCP -sTCP:LISTEN -n -P
sudo lsof -iUDP -n -P
nc -zv app.ejemplo.com 443
nc -zv www.google.com 443
```

`lsof` lista archivos abiertos. Un socket cuenta como archivo.

| Flag | Efecto |
|---|---|
| `-iTCP` / `-iUDP` | Solo sockets de ese protocolo |
| `-sTCP:LISTEN` | Solo los TCP que esperan conexión. Un socket `ESTABLISHED` es una petición ya en curso |
| `-n` | No resuelve el nombre de la dirección. La IP se ve tal cual |
| `-P` | No traduce el puerto a servicio. Muestra `443` en vez de `https` |

`sudo` hace falta para ver sockets de otros usuarios. Sin él, `lsof` solo muestra los tuyos.

`nc` es netcat. `-z` abre la conexión y la cierra sin enviar datos: sirve para probar el puerto, no para hablar HTTP. `-v` imprime si el handshake terminó. La primera llamada usa un nombre de ejemplo y va a fallar al resolver. La segunda prueba el 443 de `www.google.com`.

Si `nc` dice que el puerto está abierto y la aplicación no responde, el corte está después de la red: en el proceso, en el security group que dejó pasar el SYN, o en el health check. Si `nc` no conecta, el paquete no llegó o alguien lo rechazó en el camino (security group, NACL, o no hay ruta).

## `5_dns.sh` · del nombre a la IP

Antes de los scripts de IP, el cliente solo tiene un nombre. `dig` hace esa pregunta en voz alta.

```bash
dig +short www.google.com
dig www.google.com
dig +trace www.google.com
```

| Invocación | Qué muestra |
|---|---|
| `dig +short` | Solo las direcciones de la respuesta, sin encabezados |
| `dig` | La respuesta completa: servidor que contestó, flags, y el TTL de cada registro |
| `dig +trace` | El recorrido desde la raíz: hints, TLD (`.com`) y el autoritativo del dominio |

El TTL es el tiempo, en segundos, que un resolver puede guardar esa respuesta. Cuando cambias un registro en Route 53 o en Cloudflare, el mundo no lo ve hasta que ese TTL vence. `+trace` separa un fallo de resolución (la cadena se corta en algún nivel) de un fallo de la aplicación (el nombre resuelve y la IP no contesta).

## `6_tls.sh` · el certificado del 443

Con el nombre resuelto y el puerto abierto, HTTPS todavía tiene que negociar TLS. Este script abre esa negociación y decodifica el certificado.

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -text -noout
```

| Pieza | Efecto |
|---|---|
| `openssl s_client -connect example.com:443` | Cliente TLS contra ese host y puerto |
| `-servername example.com` | Envía el SNI. Sin él, un servidor con varios certificados puede entregar otro |
| `</dev/null` | Cierra la entrada de inmediato. `s_client` no se queda esperando un HTTP |
| `2>/dev/null` | Esconde el registro del handshake. A la tubería solo pasa el certificado |
| `openssl x509 -text -noout` | Lo imprime en texto: sujeto, emisor, fechas y nombres alternativos, sin el PEM |

Lo que miras en clase es si el nombre del certificado coincide con el que pediste y si la fecha sigue vigente. Un `nc` al 443 solo prueba TCP. Esta tubería prueba que encima de ese TCP hay un certificado.

## `7_vpn.sh` · la puerta a la red privada

Una VPN es otro camino de entrada: el tráfico no pasa por el Internet Gateway de la subred pública, entra cifrado a la VPC. El script lista lo que ya existe en la cuenta.

```bash
aws ec2 describe-vpn-connections \
  --query 'VpnConnections[].{Id:VpnConnectionId,Estado:State,Tipo:Type}' --output table

aws ec2 describe-client-vpn-endpoints \
  --query 'ClientVpnEndpoints[].{Id:ClientVpnEndpointId,Estado:Status.Code}' --output table
```

| Comando | Qué lista |
|---|---|
| `describe-vpn-connections` | VPN de sitio a sitio, entre la VPC y la red de una oficina o de otra nube |
| `describe-client-vpn-endpoints` | Client VPN, el endpoint al que se conecta una persona |

`--query` recorta el JSON con JMESPath y se queda con id, estado y tipo. `--output table` lo dibuja en columnas. `State` en `available` significa que el túnel de sitio está arriba. `Status.Code` del Client VPN dice si el endpoint está pendiente o disponible. Si la petición "no llega" y el cliente está en la VPN, el siguiente lugar donde mirar es este estado, no el DNS público.

## `8_ec2.sh` · las mismas consultas de VPN

El archivo se llama como la instancia, y el cuerpo ejecuta las dos consultas de `7_vpn.sh`: `describe-vpn-connections` y `describe-client-vpn-endpoints`, con el mismo `--query` y `--output table`. Correrlo muestra otra vez las VPN de la cuenta, no las instancias EC2.

La sesión 6 es la que nombra la instancia, la familia y el proceso que corre dentro. Aquí la instancia todavía es el extremo del camino: la IP privada de `1_ip.py` y `3_ip_cidr.py` es la de esa máquina, el puerto de `4_ports.sh` es el proceso que escucha en ella, y la VPN de este script es una de las puertas por las que el paquete puede alcanzarla.
