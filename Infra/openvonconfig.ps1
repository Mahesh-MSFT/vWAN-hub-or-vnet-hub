az network p2s-vpn-gateway list --resource-group vwanaks-rg

az network vpn-server-config list --resource-group vwanaks-rg

az network vpn-server-config set -n vwan-p2s-vpn-config -g vwanaks-rg --protocols OpenVPN, IkeV2
az network vpn-server-config set -n vwan-p2s-vpn-config-2021 -g vwanaks-rg --protocols IkeV2, OpenVPN

az network p2s-vpn-gateway show --name openvpn-vwan-p2s-vpn-config --resource-group vwanaks-rg

az network vpn-server-config create -n OpenVpnVPNServerConfig -g vwanaks-rg --vpn-client-root-certs "myp2svpnclientCert.pfx"
az network vpn-server-config create -n OpenVpnVPNServerConfig2021 -g vwanaks-rg --vpn-client-root-certs "myp2svpnclientCert2021.pfx"

openssl pkcs12 -in "C:\Users\maksh\Downloads\myp2svpnclientCert2021.pfx" -nodes -out "profileinfo2021.txt"