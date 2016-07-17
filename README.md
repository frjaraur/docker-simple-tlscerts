# docker-simple-tlscerts

Use following environment variables for passing data to key generation scripts:
 + SERVERNAME -> Name of the CA server, defaults to localhost.
 + SERVERIPS -> IPs to add to server certificate (defaults to 127.0.0.1 to allow at least local connections)
 + CLIENTNAME -> Server name for the client certificate, defaults to localhost.
 + PASSPRHASE -> Avoid asking passphrase during certifcates generation.

 Actions available:
 - generate_CA -- Generate a Certificate Authority (Public and Private keys for siging server and client certificates)
 - generate_serverkeys -- Generate CA signed server certificates (public and private)
 - generate_clientkeys -- Generate CA signed client certificates (public and private)
 - list -- List files in /certs directory
 - clean -- Remove previously created certificates and configurations
 - read_privatekey -- Read private key data
 - read_publickey -- Read public key data

** You can avoid data answer using your own openssl.cnf file (/etc/ssl/openssl.cnf)

frjaraur - https://github.com/frjaraur - DOCKER-SIMPLE-TLSCERTS

OBTAINING HELP
 docker run -ti --rm --net=none -v certs:/certs docker-tlscerts
 
STEPS FOR GENERATING TLS CERTS FOR DOCKER:

1) docker run -ti --rm --net=none -v certs:/certs docker-tlscerts generate_CA

2) docker run -ti --rm --net=none -v certs:/certs docker-tlscerts generate_serverkeys

3) docker run -ti --rm --net=none -v certs:/certs docker-tlscerts generate_clientkeys
