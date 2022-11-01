public with sharing class PostWrapper {
    public String userId;
    public String id;
    public String title;
    public String body;

    public PostWrapper() {}

    public PostWrapper(Post__c post) {
        this.userId = post.User_Id__c;
        this.title = post.Title__c;
        this.body = post.Body__c;
    }
}