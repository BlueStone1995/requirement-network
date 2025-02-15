CHANNEL_NAME="$1"
CC_SRC_LANGUAGE="$2"
VERSION="$3"
DELAY="$4"
MAX_RETRY="$5"
VERBOSE="$6"
: ${CHANNEL_NAME:="mychannel"}
: ${CC_SRC_LANGUAGE:="golang"}
: ${VERSION:="1"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}
CC_SRC_LANGUAGE=$(echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:])

FABRIC_CFG_PATH=$PWD/../config/

# import utils
. scripts/envVar.sh

# installChaincode PEER ORG
installChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  set -x
  peer lifecycle chaincode install requirement.tar.gz >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on peer${PEER}.org${ORG} has failed"
  echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
  echo
}

chaincodeQuery() {
  PEER=$1
  ORG=$2
  ARGS=$3
  setGlobals $PEER $ORG
  echo "===================== Querying on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
  local rc=1
  local COUNTER=1
  # continue to poll
  # we either get a successful response, or reach MAX RETRY
  while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
    sleep $DELAY
    echo "Attempting to Query peer${PEER}.org${ORG} ...$(($(date +%s) - starttime)) secs"
    set -x
    peer chaincode query -C $CHANNEL_NAME -n requirement -c "{\"Args\":$ARGS}" >&log.txt
    res=$?
    set +x
    let rc=$res
    COUNTER=$(expr $COUNTER + 1)
  done
  echo
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Query successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
    echo
  else
    echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Query result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

# chaincodeInvoke PEER ORG (PEER ORG) ...
# Accepts as many peer/org pairs as desired and requests endorsement from each
chaincodeInvoke() {
  FUNCTION=$1
  ARGS=$2
  shift
  shift
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  set -x
  peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.requirementnet.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n requirement $PEER_CONN_PARMS -c "{\"function\":$FUNCTION,\"Args\":$ARGS}" >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
}

# Query chaincode on peer0.org1
echo "Querying chaincode on peer0.org1..."
chaincodeQuery 0 1 "[\"queryAllTraces\"]"

# Invoke chaincode on all peer0
echo "Sending invoke issue transaction on all peer0..."
chaincodeInvoke '"issueArtefact"' "[\"TRACE1\",\"3\",\"EquipmentCompany-issued\",\"Equipment Company\",\"R1.txt\",\"e01766d3d78b51f4d7bed8ef596f22019bbefc37\",\"R1 requirement document from EC\"]" 0 1 0 2 0 3 0 4

# Invoke chaincode on all peer0
#echo "Sending invoke update transaction on all peer0..."
#chaincodeInvoke '"updateArtefact"' "[\"TRACE0\",\"4\",\"EquipmentCompany-updated\",\"Equipment Company\",\"3c3116a8d03ed56216505932360e71a053992188\",\"1.1.0\",\"Test update from EC\"]" 0 1 0 2 0 3 0 4

# Query chaincode on peer0.org2
echo "Querying chaincode on peer0.org2..."
chaincodeQuery 0 2 "[\"queryTrace\",\"TRACE0\"]"

## Install chaincode on peer1.org2
echo "Installing chaincode on peer1.org2..."
installChaincode 1 2

# Query on chaincode on peer1.org2, check if the result has been updated
echo "Querying chaincode on peer1.org2..."
chaincodeQuery 1 2 "[\"queryAllTraces\"]"

exit 0
