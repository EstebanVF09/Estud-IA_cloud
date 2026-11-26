import ipaddress

ip = ipaddress.ip_address("192.168.10.25")
print(ip.packed.hex())      # 4 octetos en hexadecimal
print(ip.is_private)        # True
print(ip.version)           # 4

