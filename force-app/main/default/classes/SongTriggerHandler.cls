public with sharing class SongTriggerHandler {
    @future
    public static void calculateSongsFuture(Map<String,Integer> bandIdToSongAmountNewMap, Map<String,Integer> bandIdToSongAmountOldMap, String triggerContext) {
        if(!bandIdToSongAmountNewMap.isEmpty()) {
            List<Band__c> bandToUpdateList = new List<Band__c>();

            for(String key_i : bandIdToSongAmountNewMap.keySet()) {
                Integer newSongAmount = bandIdToSongAmountNewMap.get(key_i);
                Integer oldSongAmount = bandIdToSongAmountOldMap.get(key_i);

                if(triggerContext == 'Insert') {
                    if(oldSongAmount == Null) {
                        bandToUpdateList.add(new Band__c(Id = key_i, Total_Songs_Number__c = newSongAmount));
                    }else {
                        bandToUpdateList.add(new Band__c(Id = key_i, Total_Songs_Number__c = newSongAmount + oldSongAmount));
                    }
                } else if(triggerContext == 'Delete') {
                    bandToUpdateList.add(new Band__c(Id = key_i, Total_Songs_Number__c = oldSongAmount - newSongAmount)); 
                } else if(triggerContext == 'Update') {
                    if(newSongAmount != 0) {
                        bandToUpdateList.add(new Band__c(Id = key_i, Total_Songs_Number__c = oldSongAmount + newSongAmount));
                    }
                }
            }

            if(!bandToUpdateList.isEmpty()) {
                update bandToUpdateList;
            }
        }
    }

    public void calculateSongs(List<Song__c> songList, Map<Id,Song__c> oldMap, String triggerContext) {
        Map<String, Integer> albumIdToSongAmountMap;

        if(triggerContext == 'Insert' || triggerContext == 'Delete'){
            albumIdToSongAmountMap = createAlbumIdToSongAmountMap(songList);
        } else if(triggerContext == 'Update'){
            albumIdToSongAmountMap = createAlbumIdToSongAmountMap(songList,oldMap);
        }

        if(!albumIdToSongAmountMap.isEmpty()) {
            List<Album__c> albumFromDbList = getAlbumFromDb(albumIdToSongAmountMap.keySet());
            if(!albumFromDbList.isEmpty()) {

                Map<String,Integer> bandIdToSongAmountNewMap = createBandIdToSongAmountMap(albumFromDbList,albumIdToSongAmountMap);
                Map<String,Integer> bandIdToSongAmountOldMap = createBandIdToSongAmountMap(albumFromDbList);

                if(!bandIdToSongAmountNewMap.isEmpty()) {
                    calculateSongsFuture(bandIdToSongAmountNewMap, bandIdToSongAmountOldMap, triggerContext);
                }
            }
        }      
    }

    public static Map<String, Integer> createAlbumIdToSongAmountMap(List<Song__c> songList){
        Map<String, Integer> albumIdToSongAmountMap = new Map<String, Integer>();
        for(Song__c song_i : songList) { 
            if(song_i.Hit_Song__c == True) {
                if(albumIdToSongAmountMap.containsKey(song_i.Album__c)) {
                    Integer tempAmount = albumIdToSongAmountMap.get(song_i.Album__c);
                    tempAmount  += 1;
                    albumIdToSongAmountMap.put(song_i.Album__c, tempAmount);    
                } else {
                    albumIdToSongAmountMap.put(song_i.Album__c, 1);
                }
            }
        }

        return albumIdToSongAmountMap;
    }

    public static Map<String, Integer> createAlbumIdToSongAmountMap(List<Song__c> songList, Map<Id,Song__c> oldMap){
        Map<String, Integer> albumIdToSongAmountMap = new Map<String, Integer>();
        for(Song__c song_i : songList) { 
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

        return albumIdToSongAmountMap;
    }

    private static List<Album__c> getAlbumFromDb(Set<String> albumIdSet) {
        return [
            SELECT
                Id, Band__c, Band__r.Total_Songs_Number__c
            FROM 
                Album__c
            WHERE
                Id IN : albumIdSet
        ];
    }

    private static Map<String, Integer> createBandIdToSongAmountMap(List<Album__c> albumList, Map<String, Integer> albumIdToSongAmountMap) {
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

    private static Map<String, Integer> createBandIdToSongAmountMap(List<Album__c> albumList) {
        Map<String, Integer> bandIdToSongAmountMap = new Map<String, Integer>();

        for(Album__c album_i : albumList) {
            
            if(bandIdToSongAmountMap.containsKey(album_i.Band__c)) {           
                if(album_i.Band__r.Total_Songs_Number__c != Null) {              
                    Integer tempAmount = bandIdToSongAmountMap.get(album_i.Band__c);
                    tempAmount += Integer.valueOf(album_i.Band__r.Total_Songs_Number__c);
                    bandIdToSongAmountMap.put(album_i.Band__c, tempAmount);  
                } else {
                     bandIdToSongAmountMap.put(album_i.Band__c, Null);
                }  
            } else {
                if(album_i.Band__r.Total_Songs_Number__c != Null){
                    bandIdToSongAmountMap.put(album_i.Band__c, Integer.valueOf(album_i.Band__r.Total_Songs_Number__c));
                } else {
                    bandIdToSongAmountMap.put(album_i.Band__c, Null);
                }
            }
        }

        return bandIdToSongAmountMap;
    }
}   