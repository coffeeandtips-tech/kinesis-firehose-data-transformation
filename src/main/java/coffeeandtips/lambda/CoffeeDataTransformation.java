package coffeeandtips.lambda;

import coffeeandtips.model.Record;
import coffeeandtips.model.Records;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.KinesisFirehoseEvent;
import lombok.SneakyThrows;

import java.util.ArrayList;
import java.util.List;

public class CoffeeDataTransformation implements RequestHandler<KinesisFirehoseEvent, Records> {

    @SneakyThrows
    @Override
    public Records handleRequest(KinesisFirehoseEvent input, Context context) {

        List<Record> listRecord = new ArrayList<>();
        Records records = new Records();

            input.getRecords().stream().forEach(
                    item ->
                            listRecord.add(new Record(item.getRecordId(),
                                    "Ok", item.getData()))
            );

        records.setRecords(listRecord);
        return records;
    }
}



