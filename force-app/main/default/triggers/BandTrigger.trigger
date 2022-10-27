trigger BandTrigger on Band__c (before insert) {

    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            BandTriggerHandler  handler = new BandTriggerHandler();
            handler.dataValidationBypass(Trigger.new);
        }
    }
}