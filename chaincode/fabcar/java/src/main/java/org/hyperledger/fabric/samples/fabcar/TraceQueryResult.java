package org.hyperledger.fabric.samples.fabcar;

import com.owlike.genson.annotation.JsonProperty;
import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import java.util.Objects;

/**
 * CarQueryResult structure used for handling result of query
 */
@DataType()
public final class TraceQueryResult {
    @Property()
    private final String key;

    @Property()
    private final Trace record;

    public TraceQueryResult(@JsonProperty("Key") final String key, @JsonProperty("Record") final Trace record) {
        this.key = key;
        this.record = record;
    }

    public String getKey() {
        return key;
    }

    public Trace getRecord() {
        return record;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }

        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }

        TraceQueryResult other = (TraceQueryResult) obj;

        Boolean recordsAreEquals = this.getRecord().equals(other.getRecord());
        Boolean keysAreEquals = this.getKey().equals(other.getKey());

        return recordsAreEquals && keysAreEquals;
    }

    @Override
    public int hashCode() {
        return Objects.hash(this.getKey(), this.getRecord());
    }

    @Override
    public String toString() {
        return "{\"Key\":\"" + key + "\"" + "\"Record\":{\"" + record + "}\"}";
    }

}