import ipaddress

v6 = ipaddress.ip_address("2001:db8::1")
print(v6.version)           # 6
print(v6.is_private)        # False; 2001:db8::/32 es documentación
print(ipaddress.ip_network("2001:db8::/32").num_addresses)