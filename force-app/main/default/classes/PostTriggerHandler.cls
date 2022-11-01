public with sharing class PostTriggerHandler {
    public void afterUpdate(List <Post__c> newList, Map<Id,Post__c> oldMap) {
        Boolean isUpdateField = False;
        for(Post__c post_i : newList) {
            Post__c oldPost = oldMap.get(post_i.Id);
            if(post_i.Is_Active__c != oldPost.Is_Active__c) {
                isUpdateField = True;
                break;
            }
        }

        if(isUpdateField != False) {
            getAllPosts();
        }
    }

    public void afterInsert(List <Post__c> newList) {
        createNewPosts(newList);
    }

    public void getAllPosts() {
        System.enqueueJob(new GetAllPostsQueueable());
    }

    public void createNewPosts(List <Post__c> newList) {
        System.enqueueJob(new SendNewPostsQueueable(newList));
    }
}
