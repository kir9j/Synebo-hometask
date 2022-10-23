public with sharing class SongTriggerHandler {

    public void afterInsert(List<Song__c> songList) {
        
        Map<String, Integer> albumToSongAmountMap = new Map<String, Integer>();
        for(Song__c song_i : songList) { 

            if(albumToSongAmountMap.containsKey(song_i.Album__c)) {
                Integer tempAmount = albumToSongAmountMap.get(song_i.Album__c);
                tempAmount  += 1;
                albumToSongAmountMap.put(song_i.Album__c, tempAmount);    
            } else {
                albumToSongAmountMap.put(song_i.Album__c, 1);
            }
        }
        
        List<Album__c> albumFromDbList = [
            SELECT
                Id, Band__c
            FROM 
                Album__c
            WHERE
                Id IN : albumToSongAmountMap.keySet()
        ];
        
        Map<String,Integer> bandIdToSongAmountMap = new Map<String,Integer>();
        for(Album__c album_i : albumFromDbList) {
            bandIdToSongAmountMap.put(album_i.Band__c,albumToSongAmountMap.get(album_i.Id));
        }
        
        List<Band__c> bandFromDbList = [
            SELECT
                Id, Total_Songs_Number__c
            FROM 
                Band__c
            WHERE
                Id IN : bandIdToSongAmountMap.keySet()
        ];
        
        for(Band__c band_i : bandFromDbList) {
            if(band_i.Total_Songs_Number__c == Null) {
                band_i.Total_Songs_Number__c = bandIdToSongAmountMap.get(band_i.Id);
            } else {
                band_i.Total_Songs_Number__c += bandIdToSongAmountMap.get(band_i.Id);
            }
        }

        update bandFromDbList;
    }
}