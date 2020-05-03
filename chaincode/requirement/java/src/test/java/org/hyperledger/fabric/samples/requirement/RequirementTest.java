package org.hyperledger.fabric.samples.requirement;

import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.shim.ChaincodeException;
import org.hyperledger.fabric.shim.ChaincodeStub;
import org.hyperledger.fabric.shim.ledger.KeyValue;
import org.hyperledger.fabric.shim.ledger.QueryResultsIterator;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.InOrder;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.ThrowableAssert.catchThrowable;
import static org.mockito.Mockito.*;
import static org.mockito.Mockito.when;

public final class RequirementTest {

    private final class MockKeyValue implements KeyValue {

        private final String key;
        private final String value;

        MockKeyValue(final String key, final String value) {
            super();
            this.key = key;
            this.value = value;
        }

        @Override
        public String getKey() {
            return this.key;
        }

        @Override
        public String getStringValue() {
            return this.value;
        }

        @Override
        public byte[] getValue() {
            return this.value.getBytes();
        }

    }

    private final class MockTraceResultsIterator implements QueryResultsIterator<KeyValue> {

        private final List<KeyValue> traceList;

        MockTraceResultsIterator() {
            super();

            traceList = new ArrayList<KeyValue>();

            traceList.add(new MockKeyValue("TRACE0",
                    "{ \"issuer\": \"Standard Company\", \"artefact\": \"README.md\", \"hash\": \"c3253074a4c2601e133932efbe9e03f9bb4418d8\", \"date\": \"2020-01-25T21:34:55\", \"state\": \"ISSUED\", \"message\": \"first commit\" }"));
        }

        @Override
        public Iterator<KeyValue> iterator() {
            return traceList.iterator();
        }

        @Override
        public void close() throws Exception {
            // do nothing
        }

    }

    @Test
    public void invokeUnknownTransaction() {
        Requirement contract = new Requirement();
        Context ctx = mock(Context.class);

        Throwable thrown = catchThrowable(() -> {
            contract.unknownTransaction(ctx);
        });

        assertThat(thrown).isInstanceOf(ChaincodeException.class).hasNoCause()
                .hasMessage("Undefined contract method called");
        assertThat(((ChaincodeException) thrown).getPayload()).isEqualTo(null);

        verifyZeroInteractions(ctx);
    }

    @Nested
    class InvokeQueryTraceTransaction {

        @Test
        public void whenCarExists() {
            Requirement contract = new Requirement();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("TRACE0"))
                    .thenReturn("{ \"issuer\": \"Standard Company\", \"artefact\": \"README.md\", \"hash\": \"c3253074a4c2601e133932efbe9e03f9bb4418d8\", \"date\": \"2020-01-25T21:34:55\", \"state\": \"ISSUED\", \"message\": \"first commit\" }");

            Trace trace = contract.queryTrace(ctx, "TRACE0");
            LocalDate date = LocalDate.now();
            assertThat(trace).isEqualTo(new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test"));
        }

        @Test
        public void whenTraceDoesNotExist() {
            Requirement contract = new Requirement();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("TRACE0")).thenReturn("");

            Throwable thrown = catchThrowable(() -> {
                contract.queryTrace(ctx, "TRACE0");
            });

            assertThat(thrown).isInstanceOf(ChaincodeException.class).hasNoCause()
                    .hasMessage("Trace TRACE0 does not exist");
            assertThat(((ChaincodeException) thrown).getPayload()).isEqualTo("TRACE_NOT_FOUND".getBytes());
        }
    }

    @Test
    void invokeInitLedgerTransaction() {
        Requirement contract = new Requirement();
        Context ctx = mock(Context.class);
        ChaincodeStub stub = mock(ChaincodeStub.class);
        when(ctx.getStub()).thenReturn(stub);

        contract.initLedger(ctx);

        InOrder inOrder = inOrder(stub);
        inOrder.verify(stub).putStringState("TRACE0",
                "{ \"issuer\": \"Standard Company\", \"artefact\": \"README.md\", \"hash\": \"c3253074a4c2601e133932efbe9e03f9bb4418d8\", \"date\": \"2020-01-25T21:34:55\", \"state\": \"ISSUED\", \"message\": \"first commit\" }");
    }

    @Nested
    class InvokeCreateTraceTransaction {

        @Test
        public void whenTraceExists() {
            Requirement contract = new Requirement();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("TRACE0"))
                    .thenReturn("{ \"issuer\": \"Standard Company\", \"artefact\": \"README.md\", \"hash\": \"c3253074a4c2601e133932efbe9e03f9bb4418d8\", \"date\": \"2020-01-25T21:34:55\", \"state\": \"ISSUED\", \"message\": \"first commit\" }");

            Throwable thrown = catchThrowable(() -> {
                LocalDate date = LocalDate.now();
                contract.createTrace(ctx, "TRACE0", "Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");
            });

            assertThat(thrown).isInstanceOf(ChaincodeException.class).hasNoCause()
                    .hasMessage("Trace TRACE0 already exists");
            assertThat(((ChaincodeException) thrown).getPayload()).isEqualTo("TRACE_ALREADY_EXISTS".getBytes());
        }

        @Test
        public void whenTraceDoesNotExist() {
            Requirement contract = new Requirement();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("TRACE0")).thenReturn("");

            LocalDate date = LocalDate.now();
            Trace trace = contract.createTrace(ctx, "TRACE0", "Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");
            assertThat(trace).isEqualTo(new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test"));
        }
    }

    @Test
    void invokeQueryAllTracesTransaction() {
        Requirement contract = new Requirement();
        Context ctx = mock(Context.class);
        ChaincodeStub stub = mock(ChaincodeStub.class);
        when(ctx.getStub()).thenReturn(stub);
        when(stub.getStateByRange("TRACE0", "TRACE999")).thenReturn(new MockTraceResultsIterator());

        TraceQueryResult[] traces = contract.queryAllTraces(ctx);

        final List<TraceQueryResult> expectedTraces = new ArrayList<TraceQueryResult>();
        LocalDate date = LocalDate.now();
        expectedTraces.add(new TraceQueryResult("TRACE0", new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test")));

        assertThat(traces).containsExactlyElementsOf(expectedTraces);
    }

    @Nested
    class UpdateTraceTransaction {

        @Test
        public void whenTraceExists() {
            Requirement contract = new Requirement();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("TRACE0"))
                    .thenReturn("{ \"issuer\": \"Standard Company\", \"artefact\": \"README.md\", \"hash\": \"c3253074a4c2601e133932efbe9e03f9bb4418d8\", \"date\": \"2020-01-25T21:34:55\", \"state\": \"ISSUED\", \"message\": \"first commit\" }");
            LocalDate date = LocalDate.parse("2020-01-25T21:34:55");
            Trace trace = contract.updateArtefact(ctx, "TRACE0", "Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");

            assertThat(trace).isEqualTo(new TraceQueryResult("CAR0", new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test")))
            ;
        }

        @Test
        public void whenTraceDoesNotExist() {
            Requirement contract = new Requirement();
            Context ctx = mock(Context.class);
            ChaincodeStub stub = mock(ChaincodeStub.class);
            when(ctx.getStub()).thenReturn(stub);
            when(stub.getStringState("TRACE0")).thenReturn("");

            Throwable thrown = catchThrowable(() -> {
                LocalDate date = LocalDate.now();
                contract.updateArtefact(ctx, "TRACE0", "Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");
            });

            assertThat(thrown).isInstanceOf(ChaincodeException.class).hasNoCause()
                    .hasMessage("Trace TRACE0 does not exist");
            assertThat(((ChaincodeException) thrown).getPayload()).isEqualTo("TRACE_NOT_FOUND".getBytes());
        }
    }
}