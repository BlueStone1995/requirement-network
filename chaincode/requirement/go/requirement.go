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
		{Issuer: "Standard Company", Artefact: "README.md", Hash: "00e3539a4cb62e11acce8f980476f524417b56a3", Date: date, State: "ISSUED", Version: "1.0.0", Message: "first commit"},
		{Issuer: "System Company", Artefact: "artefact-test.txt", Hash: "13e55a9d82078c4afc3e3cda2ca81319ec942e2b", Date: date, State: "ISSUED", Version: "1.0.0", Message: "first commit"},
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
func (s *SmartContract) IssueArtefact(ctx contractapi.TransactionContextInterface, traceNumber string, issuer string, artefact string, message string) error {
	timestamp, _ := ctx.GetStub().GetTxTimestamp()
	date := time.Unix(timestamp.Seconds, int64(timestamp.Nanos))

	trace := Trace{
		Issuer:   issuer,
		Artefact: artefact,
		Hash:     "",
		Date:     date,
		State:    "ISSUED",
		Version:  "1.0.0",
		Message:  message,
	}

	// Commit and push new artefact
	/**
	obj, err := CommitToRepo(true, trace, date)

	if err != nil {
		return err
	}
	PushToRepo()

	trace.Hash = obj.Hash.String()
	*/
	traceAsBytes, _ := json.Marshal(trace)

	return ctx.GetStub().PutState(traceNumber, traceAsBytes)
}

// UpdateArtefact updates the fields of trace with given id in world state
func (s *SmartContract) UpdateArtefact(ctx contractapi.TransactionContextInterface, traceNumber string, issuer string,
	version string, message string) error {
	trace, err := s.QueryTrace(ctx, traceNumber)

	if err != nil {
		return err
	}

	timestamp, _ := ctx.GetStub().GetTxTimestamp()
	date := time.Unix(timestamp.Seconds, int64(timestamp.Nanos))

	trace.Issuer = issuer
	trace.State = "UPDATED"
	trace.Version = version
	trace.Message = message
	trace.Date = date

	// Commit and push new artefact
	/**
	obj, errCommit := CommitToRepo(false, trace, date)

	if errCommit != nil {
		return errCommit
	}
	PushToRepo()

	trace.Hash = obj.Hash.String()
	*/

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

func CommitToRepo(add bool, trace *Trace, date time.Time) (*object.Commit, error) {

	// Opens an already existing repository.
	r, err := git.PlainOpen("/tmp/requirement-test")
	CheckIfError(err)

	w, err := r.Worktree()
	CheckIfError(err)

	// worktree of the project using the go standard library.
	Info("echo \"Commit operation on artefact\" > " + trace.Artefact)
	filename := filepath.Join("/tmp/requirement-test", trace.Artefact)
	err = ioutil.WriteFile(filename, []byte(trace.Message), 0644)
	CheckIfError(err)

	if add {
		// Adds the new file to the staging area.
		Info("git add " + trace.Artefact)
		_, err = w.Add(trace.Artefact)
		CheckIfError(err)
	}

	// We can verify the current status of the worktree using the method Status.
	Info("git status --porcelain")
	status, err := w.Status()
	CheckIfError(err)

	fmt.Println(status)

	// Commits the current staging area to the repository, with the new file
	// just created. We should provide the object.Signature of Author of the
	// commit.
	Info("git commit -m " + trace.Artefact)
	commit, err := w.Commit(trace.Artefact+" go-git commit", &git.CommitOptions{
		All: true,
		Author: &object.Signature{
			Name:  "Wilfried Mbape",
			Email: "wilfried.mbape@gmail.com",
			When:  date,
		},
	})

	CheckIfError(err)

	// Prints the current HEAD to verify that all worked well.
	Info("git show -s")
	obj, err := r.CommitObject(commit)
	CheckIfError(err)

	fmt.Println(obj)

	return obj, err
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
