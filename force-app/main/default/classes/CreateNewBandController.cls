public with sharing class CreateNewBandController {
    @AuraEnabled
    public static string createNewBand(String name, String country, String yearOfFoundation, String bandClosingYear) {
        try {
            insert new Band__c(Name__c = name, Country__c = country, Year_Of_Foundation__c = Date.valueOf(yearOfFoundation), Band_Closing_Year__c = Date.valueOf(bandClosingYear));
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
