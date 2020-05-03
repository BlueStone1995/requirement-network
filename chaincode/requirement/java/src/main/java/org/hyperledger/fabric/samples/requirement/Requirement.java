package org.hyperledger.fabric.samples.requirement;

import com.owlike.genson.Genson;
import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.*;
import org.hyperledger.fabric.shim.ChaincodeException;
import org.hyperledger.fabric.shim.ChaincodeStub;
import org.hyperledger.fabric.shim.ledger.KeyValue;
import org.hyperledger.fabric.shim.ledger.QueryResultsIterator;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Java implementation of the Requirement Contract described in the mather thesis
 */
@Contract(
        name = "Requirement",
        info = @Info(
                title = "Requirement contract",
                description = "The hyperlegendary requirement contract",
                version = "0.0.1-SNAPSHOT",
                license = @License(
                        name = "Apache 2.0 License",
                        url = "http://www.apache.org/licenses/LICENSE-2.0.html"),
                contact = @Contact(
                        email = "pierre.mbape@outlook.com",
                        name = "MBAPE Pierre",
                        url = "")))
@Default
public final class Requirement implements ContractInterface {

    private final Genson genson = new Genson();

    private enum RequirementErrors {
        TRACE_NOT_FOUND,
        TRACE_ALREADY_EXISTS
    }

    /**
     * Retrieves a requirement with the specified key from the ledger.
     *
     * @param ctx the transaction context
     * @param key the key
     * @return the Trace found on the ledger if there was one
     */
    @Transaction()
    public Trace queryTrace(final Context ctx, final String key) {
        ChaincodeStub stub = ctx.getStub();
        String traceState = stub.getStringState(key);

        if (traceState.isEmpty()) {
            String errorMessage = String.format("Trace %s does not exist", key);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, RequirementErrors.TRACE_NOT_FOUND.toString());
        }

        Trace trace = genson.deserialize(traceState, Trace.class);

        return trace;
    }

    /**
     * Creates some initial Trace on the ledger.
     *
     * @param ctx the transaction context
     */
    @Transaction()
    public void initLedger(final Context ctx) {
        ChaincodeStub stub = ctx.getStub();

        // TODO: initialise new private repository on Github with
        String readMe = "{ \"issuer\": \"Standard Company\", \"artefact\": \"README.md\", \"hash\": \"c3253074a4c2601e133932efbe9e03f9bb4418d8\", \"date\": \"2020-01-25T21:34:55\", \"state\": \"ISSUED\", \"message\": \"first commit\" }";

        String key = String.format("TRACE0");

        Trace trace = genson.deserialize(readMe, Trace.class);
        String traceState = genson.serialize(trace);
        stub.putStringState(key, traceState);
    }

    /**
     * Creates a new trace on the ledger.
     *
     * @param ctx      the transaction context
     * @param key      the key for the new trace
     * @param issuer   the issuer of the new trace
     * @param artefact the artefact of the new trace
     * @param hash     the hash of the new trace
     * @param date     the date of the new trace
     * @param state    the state of the new trace
     * @param message  the message of the new trace
     * @return the created Trace
     */
    @Transaction()
    public Trace createTrace(final Context ctx, final String key, final String issuer, final String artefact,
                             final String hash, final LocalDate date, final String state, final String message) {
        ChaincodeStub stub = ctx.getStub();

        String traceState = stub.getStringState(key);
        if (!traceState.isEmpty()) {
            String errorMessage = String.format("Trace %s already exists", key);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, RequirementErrors.TRACE_ALREADY_EXISTS.toString());
        }

        Trace trace = new Trace(issuer, artefact, hash, date, state, message);
        traceState = genson.serialize(trace);
        stub.putStringState(key, traceState);

        return trace;
    }

    /**
     * Retrieves every trace between TRACE0 and TRACE999 from the ledger.
     *
     * @param ctx the transaction context
     * @return array of Traces found on the ledger
     */
    @Transaction()
    public TraceQueryResult[] queryAllTraces(final Context ctx) {
        ChaincodeStub stub = ctx.getStub();

        final String startKey = "TRACE0";
        final String endKey = "TRACE999";
        List<TraceQueryResult> queryResults = new ArrayList<TraceQueryResult>();

        QueryResultsIterator<KeyValue> results = stub.getStateByRange(startKey, endKey);

        for (KeyValue result : results) {
            Trace trace = genson.deserialize(result.getStringValue(), Trace.class);
            queryResults.add(new TraceQueryResult(result.getKey(), trace));
        }

        TraceQueryResult[] response = queryResults.toArray(new TraceQueryResult[queryResults.size()]);

        return response;
    }

    /**
     * Update the trace of an artefact from commit on the ledger.
     *
     * @param ctx      the transaction context
     * @param key      the key
     * @param issuer   the issuer of the new trace
     * @param artefact the artefact of the new trace
     * @param hash     the hash of the new trace
     * @param date     the date of the new trace
     * @param state    the state of the new trace
     * @param message  the message of the new trace
     * @return the updated Artefact
     */
    @Transaction()
    public Trace updateArtefact(final Context ctx, final String key, final String issuer, final String artefact,
                                final String hash, final LocalDate date, final String state, final String message) {
        ChaincodeStub stub = ctx.getStub();

        String traceState = stub.getStringState(key);

        if (traceState.isEmpty()) {
            String errorMessage = String.format("Trace %s does not exist", key);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, RequirementErrors.TRACE_NOT_FOUND.toString());
        }

        Trace trace = genson.deserialize(traceState, Trace.class);

        Trace updatedTrace = new Trace(issuer, artefact, hash, date, state, message);
        String updatedTraceState = genson.serialize(updatedTrace);
        stub.putStringState(key, updatedTraceState);

        return updatedTrace;
    }
}