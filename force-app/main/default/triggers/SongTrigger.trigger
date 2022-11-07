trigger SongTrigger on Song__c (after insert, after delete, after update) {
    SongTriggerHandler  handler = new SongTriggerHandler();

    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
           handler.calculateSongs(Trigger.new, Null, Trigger.operationType);
        }
    }
    if (Trigger.isDelete) {
        if (Trigger.isAfter) {
            handler.calculateSongs(Trigger.old, Null, Trigger.operationType);
        }
    }
    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            handler.calculateSongs(Trigger.new, Trigger.oldMap, Trigger.operationType);
        }
    }
}
    