public with sharing class BandTriggerHandler {

    public void beforeInsert(List<Band__c> bandList) {
        for (Band__c band_i : bandList) {
            if(band_i.Band_Closing_Year__c == band_i.Year_Of_Foundation__c) {
                
                if(band_i.IsGroupExistOneDay__c) { 
                    band_i.Closing_Date_On_Opening_Day__c = band_i.Band_Closing_Year__c;
                    band_i.Band_Closing_Year__c = Null;
                }
            }
        }
    } 
}