sudo lsof -iTCP -sTCP:LISTEN -n -P  # puertos TCP en escucha
sudo lsof -iUDP -n -P               # puertos UDP en escucha
nc -zv app.ejemplo.com 443          # handshake con app.ejemplo.com en el puerto 443
nc -zv www.google.com 443           # handshake con www.google.com en el puerto 443 para verificar si el puerto está abierto