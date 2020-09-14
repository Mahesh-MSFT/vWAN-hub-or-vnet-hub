# https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site
# https://erleonard.me/azure/Azure-Networking-VPNGateway/
# https://github.com/Azure/azure-quickstart-templates/issues/1047

# Create a self-signed root certificate
$rootcert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=makshP2SRootCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

# Get Base64 encoded raw certificate data to be used in ARM Template
$([Convert]::ToBase64String($rootcert.Export('Cert')))

# Generate a client certificate
New-SelfSignedCertificate -Type Custom -DnsName makshP2SChildCert -KeySpec Signature `
-Subject "CN=makshP2SChildCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $rootcert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

# I forgot to declare variable above. Below is how to get access to cleint cert. If you declare it as part of creation itself, this is optional
$clientCert = Get-ChildItem -Path "Cert:\CurrentUser\My\39E4AC16BBA18D6EA42306DD79C24C4D36C84AF6"

# Export client certificate
$myclientpwd = ConvertTo-SecureString -String "1234" -Force -AsPlainText
Export-PfxCertificate -Password $myclientpwd -Cert (get-item -Path Cert:\CurrentUser\My\$($clientCert.Thumbprint)) -FilePath myp2svpnclientCert.pfx


