public with sharing class SongAmountBatch implements Database.Batchable<sObject>, Database.Stateful {
    Map<String, Integer> bandIdToSongAmountMap = new Map<String, Integer>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('SELECT Id, Hit_Song__c, Album__r.Band__r.Id FROM Song__c'); 
    }
    public void execute(Database.BatchableContext bc, List<Song__c> records){
        // process each batch of records
        for(Song__c song_i : records) { 
            if(song_i.Hit_Song__c == True) {
                if(bandIdToSongAmountMap.containsKey(song_i.Album__r.Band__r.Id)) {
                    Integer tempAmount = bandIdToSongAmountMap.get(song_i.Album__r.Band__r.Id);
                    tempAmount  += 1;
                    bandIdToSongAmountMap.put(song_i.Album__r.Band__r.Id, tempAmount);    
                } else {
                    bandIdToSongAmountMap.put(song_i.Album__r.Band__r.Id, 1);
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        List<Band__c> bandToUpdateList = new List<Band__c>();
        for(String key_i : bandIdToSongAmountMap.keySet()) {
            Integer tempAmount = bandIdToSongAmountMap.get(key_i);
            bandToUpdateList.add(new Band__c(id = key_i, Total_Songs_Number__c = tempAmount));
        }

        if(!bandToUpdateList.isEmpty()){
            update bandToUpdateList;
        }
    }


    
}