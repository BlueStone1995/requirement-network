package org.hyperledger.fabric.samples.requirement;

import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

public final class TraceTest {

    @Nested
    class Equality {

        @Test
        public void isReflexive() {
            LocalDate date = LocalDate.now();
            Trace trace = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");

            assertThat(trace).isEqualTo(trace);
        }

        @Test
        public void isSymmetric() {
            LocalDate date = LocalDate.now();
            Trace traceA = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");
            Trace traceB = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");

            assertThat(traceA).isEqualTo(traceB);
            assertThat(traceB).isEqualTo(traceA);
        }

        @Test
        public void isTransitive() {
            LocalDate date = LocalDate.now();
            Trace traceA = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");
            Trace traceB = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");
            Trace traceC = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");

            assertThat(traceA).isEqualTo(traceB);
            assertThat(traceB).isEqualTo(traceC);
            assertThat(traceA).isEqualTo(traceC);
        }

        @Test
        public void handlesInequality() {
            LocalDate date = LocalDate.now();
            Trace traceA = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");
            Trace traceB = new Trace("Standard Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");

            assertThat(traceA).isNotEqualTo(traceB);
        }

        @Test
        public void handlesOtherObjects() {
            LocalDate date = LocalDate.now();
            Trace traceA = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");
            String traceB = "not a trace";

            assertThat(traceA).isNotEqualTo(traceB);
        }

        @Test
        public void handlesNull() {
            LocalDate date = LocalDate.now();
            Trace trace = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");

            assertThat(trace).isNotEqualTo(null);
        }
    }

    @Test
    public void toStringIdentifiesCar() {
        LocalDate date = LocalDate.parse("2020-01-25T21:34:55");
        Trace trace = new Trace("Equipment Company", "README.md", "ab037cb6d11130d091375514545970c935e6cbbd", date, "UPDATE", "test");

        assertThat(trace.toString()).isEqualTo("Trace@61a77e4f [issuer=Equipment Company, artefact=README.md, hash=ab037cb6d11130d091375514545970c935e6cbbd, date=2020-01-25T21:34:55, state=UPDATE, message=test]");
    }
}