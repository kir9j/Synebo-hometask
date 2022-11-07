public with sharing class SongAmountBatch implements Database.Batchable<sObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('SELECT Id FROM Band__c'); 
    }
    public void execute(Database.BatchableContext bc, List<Band__c> records) {
        // process each batch of records
        Map<String, Band__c> bandIdToBandMap = new Map<String, Band__c>(records);
        Map<String, Integer> bandIdToSongAmountMap = new Map<String, Integer>();

        List<AggregateResult> resultList = [
            SELECT
                Album__r.Band__r.Id bandId,COUNT(Id) songAmount  
            FROM 
                Song__c
            WHERE 
                Album__r.Band__c IN : bandIdToBandMap.keySet() AND Album__c != Null AND Album__r.Band__c != Null AND Hit_Song__c = True
            GROUP BY  Album__r.Band__r.Id 
        ];

        if(!resultList.isEmpty()){
            List<Band__c> bandToUpdateList = new List<Band__c>();
            
            for (AggregateResult result_i : resultList) {
                Band__c tempBand = bandIdToBandMap.get((String) result_i.get('bandId'));
                tempBand.Total_Songs_Number__c = (Decimal) result_i.get('songAmount');
                bandToUpdateList.add(tempBand);
            }

            if(!bandToUpdateList.isEmpty()) {
                update bandToUpdateList;
            }
        }
    }  

    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }

    // Database.schedule('My First Schedule', '0 9 * * *', new SongAmountBatchScheduler());
    public void execute(SchedulableContext sc){
        SongAmountBatch batch = new SongAmountBatch();
        database.executeBatch(batch);
    }  
}