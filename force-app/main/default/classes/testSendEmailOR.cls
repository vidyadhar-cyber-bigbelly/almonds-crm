@isTest
public class testSendEmailOR {
    
    @isTest
    static void testemailsendor(){
        User manager = new User(
            Alias = 'testmgr',
            Lastname = 'daffa',
            Email = 'managerbabai@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'managerbabaienter@test.com'
        );
        
        insert manager;
        
        User us = new user(Alias = 'testumgr',
            Lastname = 'daffai',
            Email = 'managerbabai1@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'managerbabaientert@test.com');
        
        insert us;
       
        
        Operation_Request__c oprSalesSouth = new Operation_Request__c(
            Operations_Type__c = 'Sales Operations', 
            User_Assigned__c = us.id	
        );
    
        Test.startTest();
        insert oprSalesSouth;
        Test.stopTest();
        
       Operation_Request__c results = [
            SELECT Id, User_assigned__C, User_Assigned__r.Email,User_Assigned__r.Manager.Email, Status__c, Opportunity__r.OwnerId FROM Operation_Request__c WHERE Id =: oprSalesSouth.id
        ];
        
        System.assertEquals(us.Id, results.User_Assigned__c, 'Owner ID should be dataopssw for Data Operations South and West');
    
    }

}