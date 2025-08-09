## Usage

For *.example.lan:
```
./fastSelfcert.sh example lan
```

An even quicker way:
```
bash <(curl -s https://raw.githubusercontent.com/reduxvzr/fastSelfcert/refs/heads/main/fastSelfcert.sh) example lan
```

With other country, location or organization:
```
country=US location=Boston \
bash <(curl -s https://raw.githubusercontent.com/reduxvzr/fastSelfcert/refs/heads/main/fastSelfcert.sh) example lan
```
 
## Example 

```
❯ bash <(curl -s https://raw.githubusercontent.com/reduxvzr/fastSelfcert/refs/heads/main/fastSelfcert.sh) example lan


Configuration:

[req]
default_md = sha256
prompt = no
req_extensions = req_ext
distinguished_name = req_distinguished_name

[req_distinguished_name]
commonName = example.lan
countryName = DE
stateOrProvinceName = No state
localityName = Dusseldorf
organizationName = SOME

[req_ext]
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = critical,serverAuth,clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = example.lan
DNS.2 = *.example.lan


Certificate request self-signature ok
subject=CN=example.lan, C=DE, ST=No state, L=Dusseldorf, O=SOME


p12 password: randompasswith16symbols

❯ tree example.lan
example.lan
├── CA
│   ├── selfsignCA.crt
│   └── selfsignCA.key
├── example.lan.key
├── example.lan.p12
├── example.lan.pem
└── openssl.cnf
```
