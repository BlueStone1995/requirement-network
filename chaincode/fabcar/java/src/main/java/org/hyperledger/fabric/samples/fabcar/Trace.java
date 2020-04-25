package org.hyperledger.fabric.samples.fabcar;

import com.owlike.genson.annotation.JsonProperty;
import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import java.time.LocalDate;
import java.util.Objects;

@DataType()
public final class Trace {

    @Property()
    private final String issuer;

    @Property()
    private final String artefact;

    @Property()
    private final String hash;

    @Property()
    private final LocalDate date;

    @Property()
    private final String state;

    @Property()
    private final String message;

    public String getIssuer() {
        return issuer;
    }

    public String getArtefact() {
        return artefact;
    }

    public String getHash() {
        return hash;
    }

    public LocalDate getDate() {
        return date;
    }

    public String getState() {
        return state;
    }

    public String getMessage() {
        return message;
    }

    public Trace(@JsonProperty("issuer") final String issuer, @JsonProperty("artefact") final String artefact,
                 @JsonProperty("hash") final String hash, @JsonProperty("date") final LocalDate date, @JsonProperty("state") final String state, @JsonProperty("message") final String message) {
        this.issuer = issuer;
        this.artefact = artefact;
        this.hash = hash;
        this.date = date;
        this.state = state;
        this.message = message;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }

        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }

        Trace other = (Trace) obj;

        return Objects.deepEquals(new String[]{getIssuer(), getArtefact(), getHash(), getDate().toString(), getState(), getMessage()},
                new String[]{other.getIssuer(), other.getArtefact(), other.getHash(), other.getDate().toString(), other.getState(), other.getMessage()});
    }

    @Override
    public int hashCode() {
        return Objects.hash(getIssuer(), getArtefact(), getHash(), getDate(), getState(), getMessage());
    }

    @Override
    public String toString() {
        return this.getClass().getSimpleName() + "@" + Integer.toHexString(hashCode()) + " [issuer=" + issuer + ", artefact=" + artefact + ", hash="
                + hash + ", date=" + date + ", state=" + state + ", message=" + message + "]";
    }
}