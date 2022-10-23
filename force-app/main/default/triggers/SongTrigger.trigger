trigger SongTrigger on Song__c (after insert) {
    
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            SongTriggerHandler  handler = new SongTriggerHandler();
            handler.afterInsert(Trigger.new);
        }
    }
}