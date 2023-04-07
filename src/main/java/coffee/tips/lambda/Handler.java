package coffee.tips.lambda;

import coffee.tips.model.Record;
import coffee.tips.model.Records;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.KinesisFirehoseEvent;
import lombok.SneakyThrows;

import java.util.ArrayList;
import java.util.List;

public class Handler implements RequestHandler<KinesisFirehoseEvent, Records> {

    @SneakyThrows
    @Override
    public Records handleRequest(KinesisFirehoseEvent input, Context context) {

        List<Record> listRecords = new ArrayList<>();
        Records records = new Records();

            input.getRecords().stream().forEach(
                    item ->
                            listRecords.add(new Record(item.getRecordId(),
                                    "Ok", item.getData()))
            );

        records.setRecords(listRecords);
        return records;
    }
}


