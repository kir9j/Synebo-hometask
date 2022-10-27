public with sharing class SongAmountBatchScheduler implements Schedulable {
    // Database.schedule('My First Schedule', '0 9 * * *', new SongAmountBatchScheduler());
    public void execute(SchedulableContext sc){
        SongAmountBatch batch = new SongAmountBatch();
        database.executeBatch(batch);
    }
}