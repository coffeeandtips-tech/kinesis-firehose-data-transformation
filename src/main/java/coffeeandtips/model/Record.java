package coffeeandtips.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.nio.ByteBuffer;

@Data
@AllArgsConstructor
public class Record {

    private String recordId;
    private String result;
    private ByteBuffer data;
}
