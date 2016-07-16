# docker-simple-tlscerts

Use following environment variables for passing data to key generation scripts:
 + CASERVERNAME -> Name of the CA server, defaults to docker-tls
 + SERVERIPS -> IPs to add to server certificate (defaults to 127.0.0.1 to allow at least local connections)
 + CLIENTNAME -> Server name for the client certificate, defaults to docker-tls

 Actions available:
 - generate_CA -- Generate a Certificate Authority (Public and Private keys for siging server and client certificates)
 - generate_serverkey -- Generate CA signed server certificates (public and private)
 - generate_clientkey -- Generate CA signed client certificates (public and private)
 - list -- List files in /certs directory
 - clean -- Remove previously created certificates and configurations

** You can avoid data answer using your own openssl.cnf file (/etc/ssl/openssl.cnf)

frjaraur - https://github.com/frjaraur - DOCKER-SIMPLE-TLSCERTS

