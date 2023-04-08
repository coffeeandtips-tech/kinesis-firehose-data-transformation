package coffee.tips.lambda;

import coffee.tips.model.Record;
import coffee.tips.model.Records;
import coffee.tips.status.Status;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.KinesisFirehoseEvent;
import lombok.SneakyThrows;
import org.json.JSONObject;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

public class Handler implements RequestHandler<KinesisFirehoseEvent, Records> {

    private List<Record> listRecords;
    private Records records;


    @SneakyThrows
    @Override
    public Records handleRequest(KinesisFirehoseEvent input, Context context) {

        listRecords = new ArrayList<>();
        records = new Records();

        AtomicReference<Record> record =
                new AtomicReference<>(new Record());

            input.getRecords().stream().forEach(
                    item ->
                            {

                                String data = decode(item.getData());
                                JSONObject jsonObject = new JSONObject(data);

                                if (Double.parseDouble(jsonObject.get("CHANGE").toString()) < 0L) {

                                    record.set(new Record(item.getRecordId(),
                                            Status.Dropped.name(), item.getData()));


                                } else if(jsonObject.get("SECTOR").equals("TECHNOLOGY")) {

                                    jsonObject.put("TICKER_SYMBOL", "TECH");

                                    record.set(new Record(item.getRecordId(),
                                            Status.Ok.name(), encode(jsonObject.toString())));

                                } else {

                                    record.set(new Record(item.getRecordId(),
                                            Status.Ok.name(), item.getData()));

                                }

                                listRecords.add(record.get());

                        }
            );

        records.setRecords(listRecords);
        return records;
    }

    private String decode(ByteBuffer data) {
        return new String(data.array(), Charset.defaultCharset());
    }

    private ByteBuffer encode(String content) {
        return ByteBuffer.wrap(content.getBytes());
    }

}
