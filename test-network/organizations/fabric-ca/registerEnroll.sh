

function createOrg1 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org1.requirementnet.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.requirementnet.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:1055 --caname ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-1055-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-1055-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-1055-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-1055-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo
	echo "Register peer1"
  echo
  set -x
	fabric-ca-client register --caname ca-org1 --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org1.requirementnet.com/peers
  mkdir -p organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1055 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/msp --csr.hosts peer0.org1.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:1055 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer0.org1.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/tlsca/tlsca.org1.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/ca/ca.org1.requirementnet.com-cert.pem

echo
  echo "## Generate the peer1 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1055 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/msp --csr.hosts peer1.org1.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:1055 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer1.org1.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/tlsca/tlsca.org1.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer1.org1.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/ca/ca.org1.requirementnet.com-cert.pem

  mkdir -p organizations/peerOrganizations/org1.requirementnet.com/users
  mkdir -p organizations/peerOrganizations/org1.requirementnet.com/users/User1@org1.requirementnet.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:1055 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/users/User1@org1.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org1.requirementnet.com/users/Admin@org1.requirementnet.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:1055 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/users/Admin@org1.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.requirementnet.com/users/Admin@org1.requirementnet.com/msp/config.yaml

}


function createOrg2 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org2.requirementnet.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.requirementnet.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:2055 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-2055-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-2055-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-2055-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-2055-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo
	echo "Register peer1"
  echo
  set -x
	fabric-ca-client register --caname ca-org2 --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org2.requirementnet.com/peers
  mkdir -p organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:2055 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/msp --csr.hosts peer0.org2.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:2055 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer0.org2.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/tlsca/tlsca.org2.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/ca/ca.org2.requirementnet.com-cert.pem

  echo
  echo "## Generate the peer1 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer1:peer1pw@localhost:2055 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/msp --csr.hosts peer1.org2.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:2055 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer1.org2.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/tlsca/tlsca.org2.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer1.org2.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/ca/ca.org2.requirementnet.com-cert.pem

  mkdir -p organizations/peerOrganizations/org2.requirementnet.com/users
  mkdir -p organizations/peerOrganizations/org2.requirementnet.com/users/User1@org2.requirementnet.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:2055 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/users/User1@org2.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org2.requirementnet.com/users/Admin@org2.requirementnet.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:2055 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/users/Admin@org2.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.requirementnet.com/users/Admin@org2.requirementnet.com/msp/config.yaml

}

function createOrg3 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org3.requirementnet.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org3.requirementnet.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:3055 --caname ca-org3 --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-3055-ca-org3.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-3055-ca-org3.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-3055-ca-org3.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-3055-ca-org3.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org3 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

  echo
	echo "Register peer1"
  echo
  set -x
	fabric-ca-client register --caname ca-org3 --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org3 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org3 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org3.requirementnet.com/peers
  mkdir -p organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:3055 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/msp --csr.hosts peer0.org3.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:3055 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer0.org3.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/tlsca/tlsca.org3.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/ca/ca.org3.requirementnet.com-cert.pem

  echo
  echo "## Generate the peer1 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer1:peer1pw@localhost:3055 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/msp --csr.hosts peer1.org3.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:3055 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer1.org3.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/tlsca/tlsca.org3.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer1.org3.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/ca/ca.org3.requirementnet.com-cert.pem

  mkdir -p organizations/peerOrganizations/org3.requirementnet.com/users
  mkdir -p organizations/peerOrganizations/org3.requirementnet.com/users/User1@org3.requirementnet.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:3055 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/users/User1@org3.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org3.requirementnet.com/users/Admin@org3.requirementnet.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:3055 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/users/Admin@org3.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org3.requirementnet.com/users/Admin@org3.requirementnet.com/msp/config.yaml

}

function createOrg4 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org4.requirementnet.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org4.requirementnet.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:4055 --caname ca-org4 --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-4055-ca-org4.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-4055-ca-org4.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-4055-ca-org4.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-4055-ca-org4.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org4 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

  echo
	echo "Register peer1"
  echo
  set -x
	fabric-ca-client register --caname ca-org4 --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org4 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org4 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org4.requirementnet.com/peers
  mkdir -p organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:4055 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/msp --csr.hosts peer0.org4.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:4055 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer0.org4.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/tlsca/tlsca.org4.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/ca/ca.org4.requirementnet.com-cert.pem

  echo
  echo "## Generate the peer1 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer1:peer1pw@localhost:4055 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/msp --csr.hosts peer1.org4.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:4055 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer1.org4.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/tlsca/tlsca.org4.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer1.org4.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/ca/ca.org4.requirementnet.com-cert.pem

  mkdir -p organizations/peerOrganizations/org4.requirementnet.com/users
  mkdir -p organizations/peerOrganizations/org4.requirementnet.com/users/User1@org4.requirementnet.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:4055 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/users/User1@org4.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org4.requirementnet.com/users/Admin@org4.requirementnet.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:4055 --caname ca-org4 -M ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/users/Admin@org4.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org4/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org4.requirementnet.com/users/Admin@org4.requirementnet.com/msp/config.yaml

}

function createOrg5 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/org5.requirementnet.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org5.requirementnet.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:5055 --caname ca-org5 --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-5055-ca-org5.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-5055-ca-org5.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-5055-ca-org5.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-5055-ca-org5.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org5 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

  echo
	echo "Register peer1"
  echo
  set -x
	fabric-ca-client register --caname ca-org5 --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org5 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org5 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/org5.requirementnet.com/peers
  mkdir -p organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:5055 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/msp --csr.hosts peer0.org5.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:5055 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer0.org5.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/tlsca/tlsca.org5.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/ca/ca.org5.requirementnet.com-cert.pem

  echo
  echo "## Generate the peer1 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer1:peer1pw@localhost:5055 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/msp --csr.hosts peer1.org5.requirementnet.com --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:5055 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls --enrollment.profile tls --csr.hosts peer1.org5.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/tlsca/tlsca.org5.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/ca
  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer1.org5.requirementnet.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/ca/ca.org5.requirementnet.com-cert.pem

  mkdir -p organizations/peerOrganizations/org5.requirementnet.com/users
  mkdir -p organizations/peerOrganizations/org5.requirementnet.com/users/User1@org5.requirementnet.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:5055 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/users/User1@org5.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/org5.requirementnet.com/users/Admin@org5.requirementnet.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:5055 --caname ca-org5 -M ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/users/Admin@org5.requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org5/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org5.requirementnet.com/users/Admin@org5.requirementnet.com/msp/config.yaml

}

function createOrderer {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/ordererOrganizations/requirementnet.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/requirementnet.com
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7055 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7055-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/requirementnet.com/msp/config.yaml


  echo
	echo "Register orderer"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  echo
  echo "Register the orderer admin"
  echo
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

	mkdir -p organizations/ordererOrganizations/requirementnet.com/orderers
  mkdir -p organizations/ordererOrganizations/requirementnet.com/orderers/requirementnet.com

  mkdir -p organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7055 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/msp --csr.hosts orderer.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/requirementnet.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7055 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls --enrollment.profile tls --csr.hosts orderer.requirementnet.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/msp/tlscacerts/tlsca.requirementnet.com-cert.pem

  mkdir ${PWD}/organizations/ordererOrganizations/requirementnet.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/requirementnet.com/msp/tlscacerts/tlsca.requirementnet.com-cert.pem

  mkdir -p organizations/ordererOrganizations/requirementnet.com/users
  mkdir -p organizations/ordererOrganizations/requirementnet.com/users/Admin@requirementnet.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:7055 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/requirementnet.com/users/Admin@requirementnet.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/requirementnet.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/requirementnet.com/users/Admin@requirementnet.com/msp/config.yaml


}
