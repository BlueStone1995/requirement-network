#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${P1PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

ORG=1
P0PORT=1050
P1PORT=1051
CAPORT=1055
PEERPEM=organizations/peerOrganizations/org1.requirementnet.com/tlsca/tlsca.org1.requirementnet.com-cert.pem
CAPEM=organizations/peerOrganizations/org1.requirementnet.com/ca/ca.org1.requirementnet.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org1.requirementnet.com/connection-org1.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org1.requirementnet.com/connection-org1.yaml

ORG=2
P0PORT=2050
P1PORT=2051
CAPORT=2055
PEERPEM=organizations/peerOrganizations/org2.requirementnet.com/tlsca/tlsca.org2.requirementnet.com-cert.pem
CAPEM=organizations/peerOrganizations/org2.requirementnet.com/ca/ca.org2.requirementnet.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org2.requirementnet.com/connection-org2.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org2.requirementnet.com/connection-org2.yaml

ORG=3
P0PORT=3050
P1PORT=3051
CAPORT=3055
PEERPEM=organizations/peerOrganizations/org3.requirementnet.com/tlsca/tlsca.org3.requirementnet.com-cert.pem
CAPEM=organizations/peerOrganizations/org3.requirementnet.com/ca/ca.org3.requirementnet.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org3.requirementnet.com/connection-org3.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org3.requirementnet.com/connection-org3.yaml

ORG=4
P0PORT=4050
P1PORT=4051
CAPORT=4055
PEERPEM=organizations/peerOrganizations/org4.requirementnet.com/tlsca/tlsca.org4.requirementnet.com-cert.pem
CAPEM=organizations/peerOrganizations/org4.requirementnet.com/ca/ca.org4.requirementnet.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org4.requirementnet.com/connection-org4.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org4.requirementnet.com/connection-org4.yaml

ORG=5
P0PORT=5050
P1PORT=5051
CAPORT=5055
PEERPEM=organizations/peerOrganizations/org5.requirementnet.com/tlsca/tlsca.org5.requirementnet.com-cert.pem
CAPEM=organizations/peerOrganizations/org5.requirementnet.com/ca/ca.org5.requirementnet.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org5.requirementnet.com/connection-org5.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/org5.requirementnet.com/connection-org5.yaml