@isTest
public class almd_PaIDashboardControllerTest {

    // Helper Mock Class to simulate HTTP Callouts
    public class SupabaseHttpMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public SupabaseHttpMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.responseBody);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }

    @testSetup
    static void setupTestData() {
        // 1. CREATE DYNAMIC PERMISSION SET
        PermissionSet ps = new PermissionSet(
            Name = 'Dyn_FLS_Bypass_' + DateTime.now().getTime(), 
            Label = 'Dynamic FLS Bypass PS'
        );
        insert ps;
        
        insert new ObjectPermissions(
            ParentId = ps.Id,
            SobjectType = 'Inventory__c',
            PermissionsRead = true,
            PermissionsCreate = true,
            PermissionsEdit = true,
            PermissionsDelete = true
        );
        
        List<FieldPermissions> fpsToInsert = new List<FieldPermissions>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Inventory__c.fields.getMap();
        
        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
            if (dfr.isCustom() && !dfr.isCalculated() && !dfr.isAutoNumber()) {
                fpsToInsert.add(new FieldPermissions(
                    ParentId = ps.Id,
                    SobjectType = 'Inventory__c',
                    Field = 'Inventory__c.' + dfr.getName(),
                    PermissionsRead = true,
                    PermissionsEdit = true
                ));
            }
        }
        insert fpsToInsert;
        
        // Assign to the deployment user
        insert new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(), 
            PermissionSetId = ps.Id
        );
        
        // 2. INSERT TEST DATA
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Inventory__c> existingRecords = new List<Inventory__c>();
            
            existingRecords.add(new Inventory__c(
                Name = 'Old Product Name',
                ALMD_EPM_Id_V__c = 'PROD-001',
                ALMD_Product_Name_V__c = 'Old Product Name',
                ALMD_Category_V__c = 'Old Cat',
                Quantity_On_Hand__c = 5,
                ALMD_Active_V__c = false
            ));

            existingRecords.add(new Inventory__c(
                Name = 'Unchanged Product',
                ALMD_EPM_Id_V__c = 'PROD-002',
                ALMD_Product_Name_V__c = 'Unchanged Product',
                ALMD_Category_V__c = 'Vehicle',
                ALMD_Sub_Category_V__c = 'Electric Vehicle',
                Quantity_On_Hand__c = 20,
                ALMD_Active_V__c = true
            ));

            insert existingRecords;
        }
    }

    // =======================================================================
    // Existing Tests for syncInventory()
    // =======================================================================

    @isTest
    static void testSyncInventory_Success_AllScenarios() {
        String jsonBody = '[' +
            '{"product_code":"PROD-001", "product_name":"Updated Product Name", "category":"New Cat", "quantity":10, "active":true},' +
            '{"product_code":"PROD-002", "product_name":"Unchanged Product", "category":"Vehicle", "subCategory":"Electric Vehicle", "quantity":20, "active":true},' +
            '{"product_code":"PROD-003", "product_name":"New Product", "category":"Category 3", "quantity":50, "active":true},' +
            '{"product_name":"Missing Code Product"}' +
        ']';

        Test.setMock(HttpCalloutMock.class, new SupabaseHttpMock(200, jsonBody));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            String resultMessage = almd_PaIDashboardController.syncInventory();
            Test.stopTest();

            System.assert(resultMessage.contains('Inserted: 1'), 'Should have inserted 1 record.');
            System.assert(resultMessage.contains('Updated: 1'), 'Should have updated 1 record.');
            System.assert(resultMessage.contains('Skipped: 1'), 'Should have skipped 1 record.');
            System.assert(resultMessage.contains('Failed: 1'), 'Should have failed 1 record.');
        }
    }

    @isTest
    static void testSyncInventory_HttpError() {
        Test.setMock(HttpCalloutMock.class, new SupabaseHttpMock(500, 'Internal Server Error'));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            try {
                almd_PaIDashboardController.syncInventory();
                System.assert(false, 'Expected AuraHandledException to be thrown.');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Script-thrown exception'), 'Expected standard Aura exception message.');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testSyncInventory_EmptyResponse() {
        Test.setMock(HttpCalloutMock.class, new SupabaseHttpMock(200, '[]'));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            String resultMessage = almd_PaIDashboardController.syncInventory();
            Test.stopTest();

            System.assertEquals('No records found in Supabase.', resultMessage, 'Expected empty record message.');
        }
    }

    @isTest
    static void testSyncInventory_NoValidEpmIds() {
        String jsonBody = '[{"product_name":"Test No Code 1"}, {"product_name":"Test No Code 2"}]';
        Test.setMock(HttpCalloutMock.class, new SupabaseHttpMock(200, jsonBody));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            String resultMessage = almd_PaIDashboardController.syncInventory();
            Test.stopTest();

            System.assertEquals('No valid Supabase EPM IDs found.', resultMessage, 'Expected no valid ID message.');
        }
    }

    // =======================================================================
    // New Tests for productSyncFromInventoryMnl()
    // =======================================================================

    @isTest
    static void testProductSyncFromInventoryMnl_MixedOperations() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            // 1. Setup pre-existing Product2 for 'PROD-001' (Will trigger an UPDATE because category is different)
            Product2 p1 = new Product2(
                Name = 'Old Product Name',
                ALMD_EPM_Id_V__c = 'PROD-001',
                ALMD_Category_V__c = 'OEM Parts', // Different from Inventory
                IsActive = false
            );
            
            // 2. Setup pre-existing Product2 for 'PROD-002' (Will trigger a SKIP because data perfectly matches Inventory)
            Product2 p2 = new Product2(
                Name = 'Unchanged Product',
                ALMD_EPM_Id_V__c = 'PROD-002',
                ALMD_Category_V__c = 'Vehicle',
                ALMD_Sub_Category_V__c = 'Electric Vehicle',
                IsActive = true
            );
            insert new List<Product2>{p1, p2};

            // 3. Setup a new Inventory record to trigger an INSERT 
            Inventory__c invNew = new Inventory__c(
                Name = 'Brand New Product',
                ALMD_EPM_Id_V__c = 'PROD-004',
                ALMD_Category_V__c = 'Accessories',
                ALMD_Active_V__c = true
            );

            // 4. Setup an Inventory record without an EPM ID to trigger a FAIL skip inside the iteration
            Inventory__c invFail = new Inventory__c(
                Name = 'Missing EPM ID Product',
                ALMD_EPM_Id_V__c = null
            );
            insert new List<Inventory__c>{invNew, invFail};

            Test.startTest();
            String resultMessage = almd_PaIDashboardController.productSyncFromInventoryMnl();
            System.debug(resultMessage);
            Test.stopTest();

            System.assertNotEquals(null, resultMessage, 'Result message should not be null');
            System.assert(resultMessage.contains('Inserted: 1'), 'Should have inserted 1 Product2 record.');
            System.assert(resultMessage.contains('Updated: 0'), 'Should have updated 0 Product2 record.');
            System.assert(resultMessage.contains('Skipped: 1'), 'Should have skipped 1 Product2 record.');
            System.assert(resultMessage.contains('Failed: 2'), 'Should have failed 2 loop iteration due to missing EPM ID.');
        }
    }

    @isTest
    static void testProductSyncFromInventoryMnl_NoInventory() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Delete all inventory records to hit the first isEmpty() check
            delete [SELECT Id FROM Inventory__c];

            Test.startTest();
            String resultMessage = almd_PaIDashboardController.productSyncFromInventoryMnl();
            Test.stopTest();

            System.assertEquals('No inventory records found in the SF system', resultMessage, 'Expected the early exit message for no inventory.');
        }
    }

    @isTest
    static void testProductSyncFromInventoryMnl_NoEpmIds() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Remove valid EPM IDs from all existing Inventory records
            List<Inventory__c> invList = [SELECT Id, ALMD_EPM_Id_V__c FROM Inventory__c];
            for (Inventory__c inv : invList) {
                inv.ALMD_EPM_Id_V__c = null;
            }
            update invList;

            Test.startTest();
            String resultMessage = almd_PaIDashboardController.productSyncFromInventoryMnl();
            Test.stopTest();

            System.assertEquals('No valid EPM IDs found in Inventory.', resultMessage, 'Expected the early exit message for no valid EPM IDs.');
        }
    }
}