@isTest
public class UpdateORownerTest {
    @isTest
    static void testUpdateORowner() {
        //Users 08-08-2024
           
        
        // Create test opportunities with different divisions
        Opportunity oppSouth = new Opportunity(Name = 'Test South Opp', CloseDate = Date.newInstance(2024, 8, 22), StageName = 'Qualify', OwnerId = '005dN0000016pIdQAI');
        Opportunity oppNorth = new Opportunity(Name = 'Test North Opp', CloseDate = Date.newInstance(2024, 8, 22), StageName = 'Qualify', OwnerId = '005dN0000016pIcQAI');
        Opportunity oppEast = new Opportunity(Name = 'Test East Opp', CloseDate = Date.newInstance(2024, 8, 22), StageName = 'Qualify', OwnerId = '005dN0000016pIbQAI');
        Opportunity oppWest = new Opportunity(Name = 'Test West Opp', CloseDate = Date.newInstance(2024, 8, 22), StageName = 'Qualify', OwnerId = '005dN0000016pIeQAI');
        insert new List<Opportunity>{oppSouth, oppNorth, oppEast, oppWest};

        //10-08-2024: Account
        Account Acc = new Account(Name='Test Account');
        insert Acc;
            
        // Create operation requests with different statuses
        Operation_Request__c oprSalesSouth = new Operation_Request__c(
            Operations_Type__c = 'Sales Operations',
            Opportunity__c = oppSouth.Id
        );
        Operation_Request__c oprSalesNorth = new Operation_Request__c(
            Operations_Type__c = 'Sales Operations',
            Opportunity__c = oppNorth.Id
        );
        Operation_Request__c oprSalesEast = new Operation_Request__c(
            Operations_Type__c = 'Sales Operations',
            Opportunity__c = oppEast.Id
        );
        Operation_Request__c oprSalesWest = new Operation_Request__c(
            Operations_Type__c = 'Sales Operations',
            Opportunity__c = oppWest.Id
        );
        
        Operation_Request__c oprDataSouth = new Operation_Request__c(
            Operations_Type__c = 'Data Operations',
            Opportunity__c = oppSouth.Id
        );
        Operation_Request__c oprDataNorth = new Operation_Request__c(
            Operations_Type__c = 'Data Operations',
            Opportunity__c = oppNorth.Id
        );
        Operation_Request__c oprDataEast = new Operation_Request__c(
            Operations_Type__c = 'Data Operations',
            Opportunity__c = oppEast.Id
        );
        Operation_Request__c oprDataWest = new Operation_Request__c(
            Operations_Type__c = 'Data Operations',
            Opportunity__c = oppWest.Id
        );

        // Insert operation requests to trigger the logic
        insert new List<Operation_Request__c>{oprSalesSouth, oprSalesNorth, oprSalesEast, oprSalesWest, oprDataSouth, oprDataNorth, oprDataEast, oprDataWest};

        // Verify that the owner IDs are set correctly
        List<Operation_Request__c> results = [
            SELECT Id, User_assigned__C, User_Assigned__r.Email,User_Assigned__r.Manager.Email, Status__c, Opportunity__r.OwnerId, Account__r.Name FROM Operation_Request__c WHERE Id IN :new List<Id>{oprSalesSouth.Id, oprSalesNorth.Id, oprSalesEast.Id, oprSalesWest.Id, oprDataSouth.Id, oprDataNorth.Id, oprDataEast.Id, oprDataWest.Id}
        ];

        for (Operation_Request__c result : results) {
            if (result.Status__c == 'Sales Operations') {
                if (result.Opportunity__r.OwnerId == '005dN0000016pIdQAI' || result.Opportunity__r.OwnerId == '005dN0000016pIeQAI') {
                    System.assertEquals('005dN0000016pIiQAI', result.OwnerId, 'Owner ID should be salesopssw for Sales Operations South and West');
                    System.assertEquals(acc.Name, result.Account__r.Name,'Account added');
                } else if (result.Opportunity__r.OwnerId == '005dN0000016pIcQAI' || result.Opportunity__r.OwnerId == '005dN0000016pIbQAI') {
                    System.assertEquals('005dN0000016t4TQAQ', result.OwnerId, 'Owner ID should be salesopsne for Sales Operations North and East');
                    System.assertEquals(acc.Name, result.Account__r.Name,'Account added');
                }
            } 
            else if (result.Status__c == 'Data Operations') {
                if (result.Opportunity__r.OwnerId == '005dN0000016pIdQAI' || result.Opportunity__r.OwnerId == '005dN0000016pIeQAI') {
                    System.assertEquals('005dN0000016t4UQAQ', result.OwnerId, 'Owner ID should be dataopssw for Data Operations South and West');
                    System.assertEquals(acc.Name, result.Account__r.Name,'Account added');
                } else if (result.Opportunity__r.OwnerId == '005dN0000016pIcQAI' || result.Opportunity__r.OwnerId == '005dN0000016pIbQAI') {
                    System.assertEquals('005dN0000016pIjQAI', result.OwnerId, 'Owner ID should be dataopsne for Data Operations North and East');
                    System.assertEquals(acc.Name, result.Account__r.Name,'Account added');
                }
            }
            
            
        }
    }
}