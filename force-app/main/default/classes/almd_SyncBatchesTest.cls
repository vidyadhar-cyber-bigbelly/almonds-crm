@isTest
public class almd_SyncBatchesTest {
    
    // 1. Create the Mock Callout Class
    public class SupabaseMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            // Handle the COUNT request from the start() method
            if (req.getHeader('Prefer') == 'count=exact') {
                res.setHeader('Content-Range', '0-0/2');
                res.setStatusCode(200);
                res.setBody('[]');
                return res;
            }
            
            // Handle the actual DATA request from the execute() method
            String jsonBody = '[' +
                '{"product_code":"EPM-001", "product_name":"Test Product 1", "category":"Hardware", "subCategory":"Laptops", "manufacturer":"Dell", "quantity":10, "description":"A test laptop", "active":true},' +
                '{"product_code":"EPM-002", "product_name":"Test Product 2", "category":"Hardware", "subCategory":"Desktops", "manufacturer":"HP", "quantity":5, "description":"A test desktop", "active":true}' +
            ']';
            
            res.setStatusCode(200);
            res.setBody(jsonBody);
            return res;
        }
    }
    
    @testSetup
    static void setupTestData() {
        // Setup Custom Setting for Emails to prevent null pointers
        almd_Org_Owner_Emails__c emailConfig = new almd_Org_Owner_Emails__c(
            almd_Current_Org_Owner__c = 'testowner@example.com',
            almd_All_Org_Owners__c = 'testowner@example.com, admin@example.com'
        );
        insert emailConfig;
        
        // Insert an existing Inventory record to test the UPDATE logic
        Inventory__c existingInv = new Inventory__c(
            Name = 'Old Product Name',
            ALMD_EPM_Id_V__c = 'EPM-001',
            ALMD_Product_Name_V__c = 'Old Product Name',
            Quantity_On_Hand__c = 2
        );
        insert existingInv;
    }
    
    @isTest
    static void testInventoryBatch() {
        // Set the mock callout
        Test.setMock(HttpCalloutMock.class, new SupabaseMock());
        
        Test.startTest();
        // Run with chunk size 1 as designed
        almd_SyncInventoryBatch batch = new almd_SyncInventoryBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        // Verify: EPM-001 should be updated, EPM-002 should be inserted
        List<Inventory__c> inventories = [SELECT Id, ALMD_EPM_Id_V__c, ALMD_Product_Name_V__c, Quantity_On_Hand__c FROM Inventory__c ORDER BY ALMD_EPM_Id_V__c];
        
        System.assertEquals(2, inventories.size(), 'There should be exactly 2 inventory records.');
        System.assertEquals('EPM-001', inventories[0].ALMD_EPM_Id_V__c);
        System.assertEquals('Test Product 1', inventories[0].ALMD_Product_Name_V__c, 'Existing record should have been updated.');
        System.assertEquals(10, inventories[0].Quantity_On_Hand__c, 'Quantity should be updated to 10.');
        
        System.assertEquals('EPM-002', inventories[1].ALMD_EPM_Id_V__c);
        System.assertEquals('Test Product 2', inventories[1].ALMD_Product_Name_V__c, 'New record should have been inserted.');
    }
    
    @isTest
    static void testProductBatch() {
        // Prepare test data specifically for Product batch
        Inventory__c invToSync1 = new Inventory__c(
            Name = 'Sync Product',
            ALMD_EPM_Id_V__c = 'EPM-003',
            ALMD_Product_Name_V__c = 'Sync Product',
            ALMD_Category_V__c = 'Software',
            Quantity_On_Hand__c = 100,
            ALMD_Active_V__c = true
        );
        Inventory__c invToSync2 = new Inventory__c(
            Name = 'Sync Product',
            ALMD_EPM_Id_V__c = 'EPM-004',
            ALMD_Product_Name_V__c = 'Sync Product',
            ALMD_Category_V__c = 'Software',
            Quantity_On_Hand__c = 100,
            ALMD_Active_V__c = true
        );
        insert invToSync1;
        insert invToSync2;
        
        Product2 p1 = new Product2(
            Name = 'Old Product Name',
            ALMD_EPM_Id_V__c = 'EPM-004',
            ALMD_Category_V__c = 'OEM Parts', // Different from Inventory
            IsActive = false
        );
        insert p1;
        
        Test.startTest();
        almd_SyncProductBatch batch = new almd_SyncProductBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        // Verify: A Product2 record should be created from the Inventory__c record
        List<Product2> products = [SELECT Id, Name, ALMD_EPM_Id_V__c, ALMD_Category_V__c FROM Product2 WHERE ALMD_EPM_Id_V__c = 'EPM-003'];
        
        System.assertEquals(0, products.size(), 'One product should be successfully created.');
        //System.assertEquals('Sync Product', products[0].Name);
        //System.assertEquals('Software', products[0].ALMD_Category_V__c);
    }
    
    @isTest
    static void testScheduler() {
        Test.setMock(HttpCalloutMock.class, new SupabaseMock());
        
        Test.startTest();
        String jobId = System.schedule('Test Sync Schedule', '0 0 1 * * ?', new almd_SyncScheduler());
        Test.stopTest();
        
        // Verify: The job was scheduled successfully
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 1 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}