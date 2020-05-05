package main

import (
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"requirementnet.com/chaincode/requirement/go/app"
)

func main() {
	chaincode, err := contractapi.NewChaincode(new(app.SmartContract))

	if err != nil {
		fmt.Printf("Error create requirement chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting requirement chaincode: %s", err.Error())
	}
}
