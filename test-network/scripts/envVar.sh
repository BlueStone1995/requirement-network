#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/msp/tlscacerts/tlsca.requirementnet.com-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.requirementnet.com/peers/peer0.org1.requirementnet.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.requirementnet.com/peers/peer0.org2.requirementnet.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.requirementnet.com/peers/peer0.org3.requirementnet.com/tls/ca.crt
export PEER0_ORG4_CA=${PWD}/organizations/peerOrganizations/org4.requirementnet.com/peers/peer0.org4.requirementnet.com/tls/ca.crt
export PEER0_ORG5_CA=${PWD}/organizations/peerOrganizations/org5.requirementnet.com/peers/peer0.org5.requirementnet.com/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/ordererOrganizations/requirementnet.com/orderers/orderer.requirementnet.com/msp/tlscacerts/tlsca.requirementnet.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/ordererOrganizations/requirementnet.com/users/Admin@requirementnet.com/msp
}

# Set environment variables for the peer org
setGlobals() {
  local USING_PEER=""
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_PEER=$1
    USING_ORG=$2
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  echo "Using organization ${USING_ORG} and peer ${USING_PEER}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.requirementnet.com/users/Admin@org1.requirementnet.com/msp

    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:1050
    elif [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:1051
    else
      echo "================== ERROR !!! PEER Unknown =================="
    fi

  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.requirementnet.com/users/Admin@org2.requirementnet.com/msp

    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:2050
    elif [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:2051
    else
      echo "================== ERROR !!! PEER Unknown =================="
    fi

  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.requirementnet.com/users/Admin@org3.requirementnet.com/msp

    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:3050
    elif [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:3051
    else
      echo "================== ERROR !!! PEER Unknown =================="
    fi

  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_LOCALMSPID="Org4MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG4_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org4.requirementnet.com/users/Admin@org4.requirementnet.com/msp

    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:4050
    elif [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:4051
    else
      echo "================== ERROR !!! PEER Unknown =================="
    fi

  elif [ $USING_ORG -eq 5 ]; then
    export CORE_PEER_LOCALMSPID="Org5MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG5_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org5.requirementnet.com/users/Admin@org5.requirementnet.com/msp

    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:5050
    elif [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:5051
    else
      echo "================== ERROR !!! PEER Unknown =================="
    fi

  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1 $2
    PEER="peer$1.org$2"
    ## Set peer adresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER$1_ORG$2_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by two to get the next pair of peer/org parameters
    shift
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}
