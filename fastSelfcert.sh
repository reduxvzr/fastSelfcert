#!/bin/bash
set -e
export subdomain=$1
export domain=$2
export country="${country:-DE}"
export location="${location:-Dusseldorf}"
export organization="${organization:-SOME}"

# Check first arg with subdomain 
if [ -z "$subdomain" ]; then
    echo "Error: set the subdomain as 2nd arg (bash ./create_cert.sh grafana internal)"
    exit 1
fi

# Check second arg with domain
if [ -z "$domain" ]; then
    echo "Error: set the domain as 1st arg (bash ./create_cert.sh grafana internal)"
    exit 1
fi

mkdir -p "$subdomain.$domain"
mkdir -p "$subdomain.$domain"/CA
cd "$subdomain.$domain"

openssl genrsa -out CA/selfsignCA.key 4096

# Create configuration file for CA
cat << EOF > ca.cnf
[req]
default_md = sha256
prompt = no
distinguished_name = req_distinguished_name

[req_distinguished_name]
commonName = SelfSignedCA
countryName = $country
stateOrProvinceName = No state
localityName = $location
organizationName = $organization
EOF

# Create CA-cert using configuration file
openssl req -new -x509 -days 3650 -key CA/selfsignCA.key -out CA/selfsignCA.crt -config ca.cnf

openssl genrsa -out "$subdomain.$domain".key 2048
touch openssl.cnf

cat << EOF > openssl.cnf
[req]
default_md = sha256
prompt = no
req_extensions = req_ext
distinguished_name = req_distinguished_name

[req_distinguished_name]
commonName = $subdomain.$domain
countryName = $country
stateOrProvinceName = No state
localityName = $location
organizationName = $organization

[req_ext]
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = critical,serverAuth,clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = $subdomain.$domain
DNS.2 = *.$subdomain.$domain
EOF

echo -e '\nConfiguration:\n' && cat openssl.cnf && echo -e '\n'

openssl req -new -nodes -key "$subdomain.$domain".key -config openssl.cnf -out "$subdomain.$domain".csr
openssl x509 -req -in "$subdomain.$domain".csr -CA CA/selfsignCA.crt -CAkey CA/selfsignCA.key -CAcreateserial -out "$subdomain.$domain".pem -days 3650 -sha256 -extfile openssl.cnf -extensions req_ext
pass=$(openssl rand -base64 12)
echo -e "\n\np12 password: $pass"
openssl pkcs12 -export -out "$subdomain.$domain".p12 -inkey "$subdomain.$domain".key -in "$subdomain.$domain".pem -name "$subdomain.$domain" -passout pass:"$pass"
chmod 600 CA/selfsignCA.key "$subdomain.$domain".key "$subdomain.$domain".p12

rm -f ca.cnf "$subdomain.$domain".srl "$subdomain.$domain".csr CA/selfsignCA.srl

