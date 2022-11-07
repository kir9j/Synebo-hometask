@RestResource(urlMapping='/Song/*')
global with sharing class SongRestResource {

    @HttpGet
    global static String getSongById() {
        SongWrapper response;
        String songId = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/')+1);

        List<Song__c> songList = [
            SELECT
                Id, Duration__c, Genre__c, Hit_Song__c, Name__c, Album__c, Album__r.Name__c
            FROM 
                Song__c
            WHERE
                Id =: songId
        ];

        if(!songList.isEmpty()){
            response = new SongWrapper(songList.get(0));
        }
        return JSON.serialize(response);
    }

    // [{"name":"2","isHitSong":false,"genre":null,"duration":null}]
    @HttpPost
    global static String createSong() {
        
        List<SongWrapper> songWrapperList = (List<SongWrapper>) JSON.deserialize(RestContext.request.requestBody.toString(), List<SongRestResource.SongWrapper>.class);
        List<Song__c> songToInsertList = new List<Song__c>();

        if(!songWrapperList.isEmpty()) {
            for(SongWrapper songWrapper_i : songWrapperList) {
                songToInsertList.add(new Song__c(
                    Duration__c = songWrapper_i.duration, Genre__c = songWrapper_i.genre,
                    Hit_Song__c = songWrapper_i.isHitSong, Name__c = songWrapper_i.name
                ));
            }
            if(!songToInsertList.isEmpty()) {
                insert songToInsertList;
                return 'Success';
            }
        }
        return 'Error';        
    }

    // [{"name":"2","isHitSong":false,"genre":null,"duration":null}]
    // /services/apexrest/Song/a017Q00001B0JIAQA3
    @HttpPut
    global static String updateSong() {
        String songId = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/')+1);
        SongWrapper songWrapper = (SongWrapper) JSON.deserialize(RestContext.request.requestBody.toString(), SongRestResource.SongWrapper.class);

        if(songWrapper != Null) {
            Song__c songToUpdate = new Song__c(
                Duration__c = songWrapper.duration, Genre__c = songWrapper.genre,
                Hit_Song__c = songWrapper.isHitSong, Name__c = songWrapper.name, Id = songId
            );                
            update songToUpdate;
            return 'Success';          
        }
        return 'Error';        
    }

    @HttpDelete 
    global static String deleteSong() {
        String songId = RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/')+1);
        delete new Song__c(Id = songId);
        return 'Success';
    }

    public with sharing class SongWrapper {
        public String id;
        public Double duration;
        public String genre;
        public Boolean isHitSong;
        public String name;
        public String albumName;
        public String albumId;

        public SongWrapper(Song__c song) {
            this.id = song.Id;
            this.duration = song.Duration__c;
            this.genre = song.Genre__c;
            this.isHitSong = song.Hit_Song__c;
            this.name = song.Name__c;
            this.albumId = song.Album__c;
            this.albumName = song.Album__r.Name__c;
        }
    }
}
