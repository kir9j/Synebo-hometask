trigger SongTrigger on Song__c (after insert, after delete, after update) {
    SongTriggerHandler  handler = new SongTriggerHandler();

    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
           handler.calculateSongsAfterInsert(Trigger.new);
        }
    }
    if (Trigger.isDelete) {
        if (Trigger.isAfter) {
            handler.calculateSongsAfterDelete(Trigger.old);
        }
    }
    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            handler.calculateSongsAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
    