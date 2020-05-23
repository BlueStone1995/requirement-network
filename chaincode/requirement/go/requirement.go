package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing/transport/http"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

/**
 * Struct Type
 *
 */

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

/**
 * Chaincode Function
 *
 */

// InitLedger adds a base set of traces to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	timestamp, _ := ctx.GetStub().GetTxTimestamp()
	date := time.Unix(timestamp.Seconds, int64(timestamp.Nanos))

	traces := []Trace{
		{Issuer: "Standard Company", Artefact: "README.md", Hash: "246768bd999c2df2c03a5e33219ae4b3b52d9de6", Date: date, State: "ISSUED", Version: "1.0.0", Message: "Initial commit"},
	}

	CloneRepo()
	GitConfig()

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
func (s *SmartContract) IssueArtefact(ctx contractapi.TransactionContextInterface, traceNumber string,
	idPullRequest string, branchName string, issuer string, artefact string, hash string, message string) error {
	timestamp, _ := ctx.GetStub().GetTxTimestamp()
	date := time.Unix(timestamp.Seconds, int64(timestamp.Nanos))

	trace := Trace{
		Issuer:   issuer,
		Artefact: artefact,
		Hash:     hash,
		Date:     date,
		State:    "ISSUED",
		Version:  "1.0.0",
		Message:  message,
	}

	// Merge Pull Request
	MergeOnPeer(idPullRequest, branchName)

	traceAsBytes, _ := json.Marshal(trace)

	return ctx.GetStub().PutState(traceNumber, traceAsBytes)
}

// UpdateArtefact updates the fields of trace with given id in world state
func (s *SmartContract) UpdateArtefact(ctx contractapi.TransactionContextInterface, traceNumber string,
	idPullRequest string, branchName string, issuer string, hash string, version string, message string) error {
	trace, err := s.QueryTrace(ctx, traceNumber)

	if err != nil {
		return err
	}

	timestamp, _ := ctx.GetStub().GetTxTimestamp()
	date := time.Unix(timestamp.Seconds, int64(timestamp.Nanos))

	trace.Issuer = issuer
	trace.Hash = hash
	trace.State = "UPDATED"
	trace.Version = version
	trace.Message = message
	trace.Date = date

	// Merge Pull Request
	MergeOnPeer(idPullRequest, branchName)

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

/**
 * Git Function
 *
 */
func CloneRepo() {

	Info("git clone https://github.com/StandardCompany/requirement-test.git")

	r, err := git.PlainClone("/home/chaincode/requirement-test", false, &git.CloneOptions{
		URL:      "https://github.com/StandardCompany/requirement-test.git",
		Progress: os.Stdout,
		Auth: &http.BasicAuth{
			Username: "StandardCompany",
			Password: "sc0-password",
		},
	})

	CheckIfError(err)

	// ... retrieving the branch being pointed by HEAD
	ref, err := r.Head()
	CheckIfError(err)

	// ... retrieving the commit object
	commit, err := r.CommitObject(ref.Hash())
	CheckIfError(err)

	fmt.Println(commit)
}

func GitConfig() {
	log.Printf("Running git config --global user.email standard.company.test@gmail.com")
	cmd := exec.Command("git", "config", "--global", "user.email", "standard.company.test@gmail.com")
	cmd.Dir = "/home/chaincode/requirement-test"
	err := cmd.Run()

	CheckIfError(err)

	log.Printf("Running git config --global user.name StandardCompany")
	cmd = exec.Command("git", "config", "--global", "user.name", "StandardCompany")
	cmd.Dir = "/home/chaincode/requirement-test"
	err = cmd.Run()

	CheckIfError(err)
}

func MergeOnPeer(id string, branch string) {
	var pullRef string
	pullRef = "pull/" + id + "/head:" + branch

	log.Printf("Running git fetch origin pull/%s/head:%s", id, branch)
	cmd := exec.Command("git", "fetch", "origin", pullRef)
	cmd.Dir = "/home/chaincode/requirement-test"
	err := cmd.Run()

	CheckIfError(err)

	log.Printf("Running git merge --no-ff --no-edit %s", branch)
	cmd = exec.Command("git", "merge", "--no-ff", "--no-edit", branch)
	cmd.Dir = "/home/chaincode/requirement-test"
	err = cmd.Run()

	CheckIfError(err)

	log.Printf("Running git status")
	cmd = exec.Command("git", "status")
	cmd.Dir = "/home/chaincode/requirement-test"
	err = cmd.Run()

	CheckIfError(err)
}

// CheckArgs should be used to ensure the right command line arguments are
// passed before executing an example.
func CheckArgs(arg ...string) {
	if len(os.Args) < len(arg)+1 {
		Warning("Usage: %s %s", os.Args[0], strings.Join(arg, " "))
		os.Exit(1)
	}
}

// CheckIfError should be used to naively panics if an error is not nil.
func CheckIfError(err error) {
	if err == nil {
		return
	}

	fmt.Printf("\x1b[31;1m%s\x1b[0m\n", fmt.Sprintf("error: %s", err))
	os.Exit(1)
}

// Info should be used to describe the example commands that are about to run.
func Info(format string, args ...interface{}) {
	fmt.Printf("\x1b[34;1m%s\x1b[0m\n", fmt.Sprintf(format, args...))
}

// Warning should be used to display a warning
func Warning(format string, args ...interface{}) {
	fmt.Printf("\x1b[36;1m%s\x1b[0m\n", fmt.Sprintf(format, args...))
}

/**
 * Main Function
 *
 */
func main() {
	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create requirement chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting requirement chaincode: %s", err.Error())
	}
}
