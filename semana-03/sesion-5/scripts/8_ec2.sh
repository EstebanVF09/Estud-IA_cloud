aws ec2 describe-vpn-connections \
  --query 'VpnConnections[].{Id:VpnConnectionId,Estado:State,Tipo:Type}' --output table

aws ec2 describe-client-vpn-endpoints \
  --query 'ClientVpnEndpoints[].{Id:ClientVpnEndpointId,Estado:Status.Code}' --output table