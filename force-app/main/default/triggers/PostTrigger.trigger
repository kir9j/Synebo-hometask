trigger PostTrigger on Post__c (after update, after insert) {
    PostTriggerHandler handler = new PostTriggerHandler();
    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            handler.afterInsert(Trigger.new);
        }
    }
}