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

<<<<<<< HEAD
** You can avoid data answer using your own openssl.cnf file (/etc/ssl/openssl.cnf)
=======
local-data: "ten.zero.zero.one. A 10.0.0.1"

local-data-ptr: "10.0.0.1 ten.zero.zero.one."

local-data: "ten.zero.zero.two. A 10.0.0.2"

local-data-ptr: "10.0.0.2 ten.zero.zero.two."


docker run -d -P  -e DNSENTRIES="ten.zero.zero.one@10.0.0.1 ten.zero.zero.two@10.0.0.2" frjaraur/docker-simple-unbound


###########

EXAMPLE:

docker run -d -P -e DNSSERVERS="208.67.222.222 208.67.220.220" -e DNSENTRIES="ten.zero.zero.one@10.0.0.1 ten.zero.zero.two@10.0.0.2" frjaraur/docker-simple-unbound


NOTE:
Instead of DNSENTRIES variable, you can create your own "localrecords.conf" file and use it...

docker run -d -p 53:53/udp -v $(pwd)/localrecords.conf:/etc/unbound/localrecords.conf frjaraur/docker-simple-unbound
>>>>>>> f90c90ac26dd024066418f1121e4529e5a2f9e21

frjaraur - https://github.com/frjaraur - DOCKER-SIMPLE-TLSCERTS

