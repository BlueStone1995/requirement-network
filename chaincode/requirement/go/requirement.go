package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing/object"
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
		{Issuer: "Standard Company", Artefact: "README.md", Hash: "c3253074a4c2601e133932efbe9e03f9bb4418d8", Date: date, State: "ISSUED", Version: "1.0.0", Message: "first commit"},
		{Issuer: "System Company", Artefact: "Documentation.pdf", Hash: "c3253074a4c2601e133932efbe9e03f9bb4418d9", Date: date, State: "ISSUED", Version: "1.0.0", Message: "first commit"},
	}

	CloneRepo()

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
func (s *SmartContract) IssueArtefact(ctx contractapi.TransactionContextInterface, traceNumber string, issuer string, artefact string, hash string, date time.Time, state string, version string, message string) error {
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

	// Interact with git repository
	CommitToRepo()
	PushToRepo()

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
 * Go-Git Function
 *
 */
func CloneRepo() {

	fmt.Printf("git clone https://github.com/BlueStone1995/requirement-test.git")

	r, err := git.PlainClone("/tmp/requirement-test", false, &git.CloneOptions{
		URL:      "https://github.com/BlueStone1995/requirement-test.git",
		Progress: os.Stdout,
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

func CommitToRepo() {

	// Opens an already existing repository.
	r, err := git.PlainOpen("/tmp/requirement-test")
	CheckIfError(err)

	w, err := r.Worktree()
	CheckIfError(err)

	// ... we need a file to commit so let's create a new file inside of the
	// worktree of the project using the go standard library.
	Info("echo \"hello world from Interface Company!\" > example-test-file")
	filename := filepath.Join("/tmp/requirement-test", "example-test-file")
	err = ioutil.WriteFile(filename, []byte("hello world!"), 0644)
	CheckIfError(err)

	// Adds the new file to the staging area.
	Info("git add example-test-file")
	_, err = w.Add("example-test-file")
	CheckIfError(err)

	// We can verify the current status of the worktree using the method Status.
	Info("git status --porcelain")
	status, err := w.Status()
	CheckIfError(err)

	fmt.Println(status)

	// Commits the current staging area to the repository, with the new file
	// just created. We should provide the object.Signature of Author of the
	// commit.
	Info("git commit -m \"example go-git commit\"")
	commit, err := w.Commit("example go-git commit", &git.CommitOptions{
		Author: &object.Signature{
			Name:  "Wilfried Mbape",
			Email: "wilfried.mbape@gmail.com",
			When:  time.Now(),
		},
	})

	CheckIfError(err)

	// Prints the current HEAD to verify that all worked well.
	Info("git show -s")
	obj, err := r.CommitObject(commit)
	CheckIfError(err)

	fmt.Println(obj)
}

// Example of how to open a repository in a specific path, and push to
// its default remote (origin).
func PushToRepo() {

	r, err := git.PlainOpen("/tmp/requirement-test")
	CheckIfError(err)

	Info("git push")
	// push using default options
	err = r.Push(&git.PushOptions{
		Auth: &http.BasicAuth{
			Username: "wmbape",
			Password: "papmUb-qochok-5quxra",
		},
	})
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
