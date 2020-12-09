az network p2s-vpn-gateway list --resource-group vwanaks-rg

az network vpn-server-config list --resource-group vwanaks-rg

az network vpn-server-config set -n vwan-p2s-vpn-config -g vwanaks-rg --protocols OpenVPN, IkeV2

az network p2s-vpn-gateway show --name openvpn-vwan-p2s-vpn-config --resource-group vwanaks-rg

az network vpn-server-config create -n OpenVpnVPNServerConfig -g vwanaks-rg --vpn-client-root-certs "myp2svpnclientCert.pfx"