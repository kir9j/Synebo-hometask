public with sharing class GetAllComentQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        getAllComments();  
    }
    
    public void getAllComments(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:jsonplaceholder/comments');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() == 200) {
            List <CommentWrapper> commentWrapperList = (List <CommentWrapper>)JSON.deserialize(res.getBody(), List <CommentWrapper>.class);
            Map<String, List<Comment__c>> externalPostIdToCommentsMap = new Map<String, List<Comment__c>>();

            for(CommentWrapper commentWrapper_i : commentWrapperList) {
                if (commentWrapper_i.postId != Null) {
                    Comment__c newComment = new Comment__c(
                        Body__c = commentWrapper_i.body, Email__c = commentWrapper_i.email,
                        External_Id__c = commentWrapper_i.id, Name__c = commentWrapper_i.name,
                        Post_Id__c = commentWrapper_i.postId
                    );

                    if(externalPostIdToCommentsMap.containsKey(newComment.Post_Id__c)) {
                        externalPostIdToCommentsMap.get(newComment.Post_Id__c).add(newComment);
                    } else {
                        externalPostIdToCommentsMap.put(newComment.Post_Id__c, new List <Comment__c> {newComment});
                    }
                }
            }

            if (!externalPostIdToCommentsMap.isEmpty()) {
                List <Post__c> postFromDbList = [
                    SELECT
                        Id, Post_Id__c
                    FROM
                        Post__c
                    WHERE
                        Post_Id__c IN : externalPostIdToCommentsMap.keySet()
                ];

                if (!postFromDbList.isEmpty()) {
                    List<Comment__c> commentToUpsertList = new List<Comment__c>();

                    for (Post__c post_i : postFromDbList) {

                        if (externalPostIdToCommentsMap.containsKey(post_i.Post_Id__c)) {
                            List<Comment__c> tempList = externalPostIdToCommentsMap.get(post_i.Post_Id__c);

                            for (Comment__c coment_j : tempList) {
                                coment_j.Post__c = post_i.Id;
                                commentToUpsertList.add(coment_j);
                            }
                        }
                    }

                    if(!commentToUpsertList.isEmpty()) {
                        upsert commentToUpsertList External_Id__c;
                    }
                }
            }
        }
    }
    
    public with sharing class CommentWrapper {
        public String postId;
        public String id;
        public String name;
        public String email;
        public String body;  
    }
}
