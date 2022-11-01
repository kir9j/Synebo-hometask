public with sharing class GetAllPostsQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() == 200) {
            List <PostWrapper> postWrapperList = (List <PostWrapper>)JSON.deserialize(res.getBody(), List <PostWrapper>.class);

            List <Post__c> postToUpsertList = new List <Post__c>();
            for(PostWrapper postWrapper_i : postWrapperList) {
                postToUpsertList.add(new Post__c(Body__c = postWrapper_i.body, Title__c = postWrapper_i.title, Post_Id__c = postWrapper_i.id, User_Id__c = postWrapper_i.userId));
            }

            if(!postToUpsertList.isEmpty()) {
                upsert postToUpsertList Post_Id__c;
            }
        }      
    }       
}
