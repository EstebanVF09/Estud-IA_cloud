import ipaddress

vpc = ipaddress.ip_network("10.0.0.0/16")
print(vpc.num_addresses)            # 65536

subredes = list(vpc.subnets(new_prefix=24))
print(len(subredes), subredes[0])   # 256 subredes /24, la primera 10.0.0.0/24

# En AWS, cada subred reserva 5 direcciones
pequena = ipaddress.ip_network("10.0.1.0/28")
print(pequena.num_addresses - 5)    # 11 utilizables