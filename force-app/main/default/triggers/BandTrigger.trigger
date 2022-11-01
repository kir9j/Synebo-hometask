trigger BandTrigger on Band__c (before insert) {
    BandTriggerHandler  handler = new BandTriggerHandler();
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            handler.dataValidationBypass(Trigger.new);
        }
    }
}