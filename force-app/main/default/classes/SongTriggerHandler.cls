public with sharing class SongTriggerHandler {

    public void calculateSongsAfterInsert(List<Song__c> songList) {
        
        Map<String,Integer> bandIdToSongAmountMap = createBandIdToSongAmountMap(songList);      
        List<Band__c> bandFromDbList = getBandFromDb(bandIdToSongAmountMap.keySet());

        for(Band__c band_i : bandFromDbList) {
            if(band_i.Total_Songs_Number__c == Null) {

                band_i.Total_Songs_Number__c = bandIdToSongAmountMap.get(band_i.Id);
            } else {
                band_i.Total_Songs_Number__c += bandIdToSongAmountMap.get(band_i.Id);               
            }
        }

        update bandFromDbList;
    }
    
    public void calculateSongsAfterDelete(List<Song__c> songList) {
        Map<String,Integer> bandIdToSongAmountMap = createBandIdToSongAmountMap(songList);
        List<Band__c> bandFromDbList = getBandFromDb(bandIdToSongAmountMap.keySet());

        for(Band__c band_i : bandFromDbList) {
            band_i.Total_Songs_Number__c -= bandIdToSongAmountMap.get(band_i.Id);               
            
        }

        update bandFromDbList;
    }
    
    private Map<String, Integer> createBandIdToSongAmountMap(List<Song__c> songList) {
        Map<String, Integer> albumToSongAmountMap = new Map<String, Integer>();

        for(Song__c song_i : songList) { 
            if(song_i.Hit_Song__c == True) {
                if(albumToSongAmountMap.containsKey(song_i.Album__c)) {
                    Integer tempAmount = albumToSongAmountMap.get(song_i.Album__c);
                    tempAmount  += 1;
                    albumToSongAmountMap.put(song_i.Album__c, tempAmount);    
                } else {
                    albumToSongAmountMap.put(song_i.Album__c, 1);
                }
            }
        }

        List<Album__c> albumFromDbList = getAlbumFromDb(albumToSongAmountMap.keySet());
     
        Map<String,Integer> bandIdToSongAmountMap = getBandIdToSongAmountMap(albumFromDbList, albumToSongAmountMap);

        return  bandIdToSongAmountMap;
    } 

    public void calculateSongsAfterUpdate(List<Song__c> newList, Map<Id,Song__c> oldMap) {
        Map<String,Integer> albumIdToSongAmountMap = new Map<String,Integer>();
        for(Song__c song_i : newList) { 
            Song__c oldSong = oldMap.get(song_i.id);

            if(song_i.Hit_Song__c != oldSong.Hit_Song__c) {
                if(song_i.Hit_Song__c == True) {
                    if(albumIdToSongAmountMap.containsKey(song_i.Album__c)) {
                        Integer tempAmount = albumIdToSongAmountMap.get(song_i.Album__c);
                        tempAmount  += 1;
                        albumIdToSongAmountMap.put(song_i.Album__c, tempAmount);    
                    } else {
                        albumIdToSongAmountMap.put(song_i.Album__c, 1);
                    }   
                }   else if(song_i.Hit_Song__c == False) {
                    if(albumIdToSongAmountMap.containsKey(song_i.Album__c)) {
                        Integer tempAmount = albumIdToSongAmountMap.get(song_i.Album__c);
                        tempAmount  -= 1;
                        albumIdToSongAmountMap.put(song_i.Album__c, tempAmount);    
                    } else {
                        albumIdToSongAmountMap.put(song_i.Album__c, -1);
                    }
                }
                
            }
        }
        List<Album__c> albumFromDbList = getAlbumFromDb(albumIdToSongAmountMap.keySet());

        Map<String,Integer> bandIdToSongAmountMap = getBandIdToSongAmountMap(albumFromDbList, albumIdToSongAmountMap);

        List<Band__c> bandFromDbList = getBandFromDb(bandIdToSongAmountMap.keySet());
        List<Band__c> bandToUpdateList = new List<Band__c>();
        for(Band__c band_i : bandFromDbList) {
            Integer tempAmount = bandIdToSongAmountMap.get(band_i.Id);
            if(tempAmount != 0) {
                band_i.Total_Songs_Number__c += bandIdToSongAmountMap.get(band_i.Id);
                bandToUpdateList.add(band_i);
            }
        }
        if(!bandToUpdateList.isEmpty()) {
            update bandToUpdateList;
        }
    }

    private List<Band__c> getBandFromDb(Set<String> bandIdSet) {
        return [
            SELECT
                Id, Total_Songs_Number__c
            FROM 
                Band__c
            WHERE
                Id IN : bandIdSet
        ]; 
    }

    private List<Album__c> getAlbumFromDb(Set<String> albumIdSet) {
        return [
            SELECT
                Id, Band__c
            FROM 
                Album__c
            WHERE
                Id IN : albumIdSet
        ];
    }

    private Map<String, Integer> getBandIdToSongAmountMap(List<Album__c> albumList, Map<String, Integer> albumIdToSongAmountMap) {
        Map<String, Integer> bandIdToSongAmountMap = new Map<String, Integer>();

        for(Album__c album_i : albumList) {
            if(bandIdToSongAmountMap.containsKey(album_i.Band__c)) {
                Integer tempAmount = bandIdToSongAmountMap.get(album_i.Band__c);
                tempAmount  += albumIdToSongAmountMap.get(album_i.Id);
                bandIdToSongAmountMap.put(album_i.Band__c, tempAmount);    
            } else {
                bandIdToSongAmountMap.put(album_i.Band__c,albumIdToSongAmountMap.get(album_i.Id));
            }    
        }

        return bandIdToSongAmountMap;
    }
}   