#!/bin/sh
#
#VERSION
VERSION=1.0

ACTION=$1

OPTION=$2

SERVERNAME="${SERVERNAME:=localhost}"

SERVERIPS="${SERVERIPS}"

CLIENTNAME="${CLIENTNAME:=localhost}"

CANAME="${CANAME:=swarm}"

DAYS="${DAYS:=365}"


# COLORS
RED='\033[0;31m' # Red
BLUE='\033[0;34m' # Blue
GREEN='\033[0;32m' # Green
CYAN='\033[0;36m' # Cyan
NC='\033[0m' # No Color


if [ -n "${SERVERIPS}" ]
then
	SERVERIPS="IP:$(echo "${SERVERIPS}"|sed -e "s/\,/\,IP:/g")"
	[ $(echo ${SERVERIPS}|grep -c "IP:127.0.0.1") -eq 0 ] && SERVERIPS="${SERVERIPS},IP:127.0.0.1"
else
	SERVERIPS="IP:127.0.0.1"

fi

FixPermissions(){
	chmod -v 0400 ca-key.pem client-key.pem server-key.pem >/dev/null 2>&1
	chmod -v 0444 ca.pem server-cert.pem client-cert.pem >/dev/null 2>&1
	rm -f server.csr extfile.cnf ca.srl 2>/dev/null
}

PrintError(){
	printf "${RED}ERROR: $* ${NC}\n"
	exit 1
}

case ${ACTION} in
	generate_CA)
		echo "You will be asked for a passphrase for securing your CA key (can use PASSPHRASE environment variable)."
		echo "Remember this password for next steps."
		echo "Generating Certificate Authority Private key"
		PASSPOPTS=""
		[ -n "${PASSPHRASE}" ]  && PASSPOPTS="-passout pass:${PASSPHRASE} "
		openssl genrsa -aes256 ${PASSPOPTS} -out ca-key.pem 2048
		[ $? -ne 0 ] && PrintError "An error ocurred during CA private key generation..."
		echo "Generating Certificate Authority Public key"
		echo "You will be asked for CA key passphrase (can use PASSPHRASE environment variable)."
		echo "You will be asked for information to complete public key data, can be left blank for testing purposes"
		[ -n "${PASSPHRASE}" ]  && PASSPOPTS="-passin pass:${PASSPHRASE} "
		openssl req -new -x509 -days ${DAYS} -key ca-key.pem -sha256 -subj "/CN=${CANAME}" ${PASSPOPTS} -out ca.pem
		[ $? -ne 0 ] && PrintError "An error ocurred during CA public key generation..."

		echo "Certificate Authority created..."
		printf "Files ${BLUE}ca-key.pem${NC} and ${BLUE}ca.pem${NC} were created on ${RED}/certs${NC} directory.\n"

		FixPermissions
		exit 0
	;;
	generate_serverkeys)
		echo "You will be asked for CA key passphrase (can use PASSPHRASE environment variable)."
		echo "Creating private server key"
		openssl genrsa -out server-key.pem 2048
		[ $? -ne 0 ] && PrintError "An error ocurred during server public key generation..."
		echo "Creating a certificate sigining request for server ${SERVERNAME} (default localhost)."
		openssl req -subj "/CN=${SERVERNAME}" -new -key server-key.pem -out server.csr
		[ $? -ne 0 ] && PrintError "An error ocurred during server signing request generation..."
		echo "SERVER IPs: ${SERVERIPS}"
		echo "subjectAltName = ${SERVERIPS}" > extfile.cnf
	 	[ -n "${PASSPHRASE}" ] && PASSPHRASE="-passin pass:${PASSPHRASE} "
		openssl x509 -req -days ${DAYS} -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial ${PASSPHRASE}-out server-cert.pem -extfile extfile.cnf
		[ $? -ne 0 ] && PrintError "An error ocurred during server key signing ..."
		rm -f server.csr extfile.cnf ca.srl 2>/dev/null
		echo "Server certificates created..."
		printf "Files ${BLUE}server-key.pem${NC} and ${BLUE}server-cert.pem${NC} were created on ${RED}/certs${NC} directory.\n"
		FixPermissions
		exit 0

	;;

	generate_clientkeys)
		echo "You will be asked for CA key passphrase (can use PASSPHRASE environment variable)."
		echo "Creating private client key"
		openssl genrsa -out client-key.pem 2048
		[ $? -ne 0 ] && PrintError "An error ocurred during public key generation..."
		echo "Creating a certificate sigining request for client ${CLIENTNAME} (default localhost)."
		openssl req -subj "/CN=${CLIENTNAME}" -new -key client-key.pem -out client.csr
		[ $? -ne 0 ] && PrintError "An error ocurred during server signing request generation..."
		echo "SERVER IPs: ${SERVERIPS}"
		echo "extendedKeyUsage = clientAuth" > extfile.cnf
		[ -n "${PASSPHRASE}" ] && PASSPHRASE="-passin pass:${PASSPHRASE} "
		openssl x509 -req -days ${DAYS} -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial ${PASSPHRASE}-out client-cert.pem -extfile extfile.cnf
		[ $? -ne 0 ] && PrintError "An error ocurred during server key signing ..."
		rm -f client.csr extfile.cnf ca.srl 2>/dev/null
		echo "Client certificates created..."
		printf "Files ${BLUE}client-key.pem${NC} and ${BLUE}client-cert.pem${NC} were created on ${RED}/certs${NC} directory.\n"
		FixPermissions
		exit 0

	;;

	list)
		FixPermissions
		ls -l /certs
		exit 0
	;;

	clean)
		rm -f /certs/*
		exit 0
	;;

	read_publickey)
		[ -n "${PASSPHRASE}" ] && PASSPHRASE="-passin pass:${PASSPHRASE} "
		FILE="$(echo ${OPTION}|cut -d "." -f1)"
		[ ! -f /certs/${FILE} ] && PrintError "File ${RED}${FILE}.pem${NC} doesn't exists" && exit 0
		openssl x509  ${PASSPHRASE}-in /certs/${FILE}.pem -noout -text
		exit 0
	;;

	read_privatekey)
		[ -n "${PASSPHRASE}" ] && PASSPHRASE="-passin pass:${PASSPHRASE} "
		FILE="$(echo ${OPTION}|cut -d "." -f1)"
		[ ! -f /certs/${FILE} ] && PrintError "File ${RED}${FILE}.pem${NC} doesn't exists" && exit 0
		openssl rsa ${PASSPHRASE}-in /certs/${FILE}.pem -noout -text
		exit 0
	;;
	help)
		printf "\n\nUse following environment variables for passing data to key generation scripts:\n"
		printf " + ${RED}SERVERNAME${NC} -> Name of the server, defaults to localhost.\n"
		printf " + ${RED}SERVERIPS${NC} -> IPs to add to server certificate (defaults to 127.0.0.1 to allow at least local connections).\n"
		printf " + ${RED}CLIENTNAME${NC} -> Server name for the client certificate, defaults to localhost.\n"
		printf " + ${RED}PASSPHRASE${NC} -> Avoid asking for passphrase during certs generation.\n"
		printf " + ${RED}DAYS${NC} -> Valid days for certificate (defaults to 365).\n"


		printf "\n\nActions available:\n"
		printf " - ${CYAN}generate_CA${NC} -- Generate a Certificate Authority (Public and Private keys for siging server and client certificates)\n"
		printf " - ${CYAN}generate_serverkeys${NC} -- Generate CA signed server certificates (public and private)\n"
		printf " - ${CYAN}generate_clientkeys${NC} -- Generate CA signed client certificates (public and private)\n"
		printf " - ${CYAN}list${NC} -- List files in /certs directory\n"
		printf " - ${CYAN}clean${NC} -- Remove previously created certificates and configurations\n"
		printf " - ${CYAN}read_privatekey${NC} -- Read private key data\n"
		printf " - ${CYAN}read_publickey${NC} -- Read public key data\n\n\n"
		printf "\n ${RED}/certs${NC} is created as VOLUME for easy access to keys created\n\n"
		printf "** You can avoid data answer using your own openssl.cnf file (/etc/ssl/openssl.cnf) and using PASSPHRASE environment variable\n"
		printf "** Remember to use -ti when running containers if you to be asked for data ;)\n"
		printf "${GREEN}frjaraur - https://github.com/frjaraur - DOCKER-SIMPLE-TLSCERTS${RED}${VERSION}${NC}\n\n"

		FixPermissions
		exit 0
	;;

esac

exec $@
