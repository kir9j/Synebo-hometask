public with sharing class SendNewPostsQueueable implements Queueable, Database.AllowsCallouts {
    List <Post__c> newPostsList;

    public SendNewPostsQueueable(List <Post__c> newPostsList) {
        this.newPostsList = newPostsList;
    }

    public void execute(QueueableContext context) {
        List<PostWrapper> postWrapperList = new List<PostWrapper>();

        for(Post__c post_i : newPostsList) {
            postWrapperList.add(new PostWrapper(post_i));
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://jsonplaceholder.typicode.com/posts');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(postWrapperList));

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode());
        System.debug(res.getBody());
    }
}
