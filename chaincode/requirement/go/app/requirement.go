/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package app

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"requirementnet.com/chaincode/requirement/go/gogit"
)

// SmartContract provides functions for managing a trace
type SmartContract struct {
	contractapi.Contract
}

// Trace describes basic details of what makes up a trace
type Trace struct {
	Issuer   string    `json:"issuer"`
	Artefact string    `json:"artefact"`
	Hash     string    `json:"hash"`
	Date     time.Time `json:"date"`
	State    string    `json:"state"`
	Version  string    `json:"version"`
	Message  string    `json:"message"`
}

// QueryResult structure used for handling result of query
type QueryResult struct {
	Key    string `json:"Key"`
	Record *Trace
}

// InitLedger adds a base set of traces to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	traces := []Trace{
		{Issuer: "Standard Company", Artefact: "README.md", Hash: "c3253074a4c2601e133932efbe9e03f9bb4418d8", Date: time.Now(), State: "ISSUED", Version: "1.0.0", Message: "first commit"},
		{Issuer: "System Company", Artefact: "Documentation.pdf", Hash: "c3253074a4c2601e133932efbe9e03f9bb4418d9", Date: time.Now(), State: "ISSUED", Version: "1.0.0", Message: "first commit"},
	}

	// Init GitHub repository
	// Clone the given repository to the given directory
	fmt.Printf("git clone https://github.com/BlueStone1995/requirement-test.git")

	_, err := git.PlainClone("/tmp/requirement-test", false, &git.CloneOptions{
		URL:      "https://github.com/BlueStone1995/requirement-test.git",
		Progress: os.Stdout,
	})

	gogit.CheckIfError(err)

	for i, trace := range traces {
		traceAsBytes, _ := json.Marshal(trace)
		err := ctx.GetStub().PutState("TRACE"+strconv.Itoa(i), traceAsBytes)

		if err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// CreateTrace adds a new trace to the world state with given details
func (s *SmartContract) CreateTrace(ctx contractapi.TransactionContextInterface, traceNumber string, issuer string, artefact string, hash string, date time.Time, state string, version string, message string) error {
	trace := Trace{
		Issuer:   issuer,
		Artefact: artefact,
		Hash:     hash,
		Date:     date,
		State:    state,
		Version:  version,
		Message:  message,
	}

	traceAsBytes, _ := json.Marshal(trace)

	return ctx.GetStub().PutState(traceNumber, traceAsBytes)
}

// UpdateArtefact updates the fields of trace with given id in world state
func (s *SmartContract) UpdateArtefact(ctx contractapi.TransactionContextInterface, traceNumber string, issuer string, artefact string,
	hash string, date time.Time, state string, version string, message string) error {
	trace, err := s.QueryTrace(ctx, traceNumber)

	if err != nil {
		return err
	}

	trace.Issuer = issuer
	trace.Artefact = artefact
	trace.Hash = hash
	trace.Date = date
	trace.State = state
	trace.Version = version
	trace.Message = message

	traceAsBytes, _ := json.Marshal(trace)

	return ctx.GetStub().PutState(traceNumber, traceAsBytes)
}

// QueryTrace returns the trace stored in the world state with given id
func (s *SmartContract) QueryTrace(ctx contractapi.TransactionContextInterface, traceNumber string) (*Trace, error) {
	traceAsBytes, err := ctx.GetStub().GetState(traceNumber)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if traceAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", traceNumber)
	}

	trace := new(Trace)
	_ = json.Unmarshal(traceAsBytes, trace)

	gogit.CommitToRequirement()

	return trace, nil
}

// QueryAllTraces returns all traces found in world state
func (s *SmartContract) QueryAllTraces(ctx contractapi.TransactionContextInterface) ([]QueryResult, error) {
	startKey := "TRACE0"
	endKey := "TRACE99"

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)

	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []QueryResult{}

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()

		if err != nil {
			return nil, err
		}

		trace := new(Trace)
		_ = json.Unmarshal(queryResponse.Value, trace)

		queryResult := QueryResult{Key: queryResponse.Key, Record: trace}
		results = append(results, queryResult)
	}

	return results, nil
}
