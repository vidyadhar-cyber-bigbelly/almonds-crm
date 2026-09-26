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
                ALMD_Category_V__c = 'Category 2',
                ALMD_Sub_Category_V__c = 'Sub 2',
                Quantity_On_Hand__c = 20,
                ALMD_Active_V__c = true
            ));

            insert existingRecords;
        }
    }

    @isTest
    static void testSyncInventory_Success_AllScenarios() {
        String jsonBody = '[' +
            '{"product_code":"PROD-001", "product_name":"Updated Product Name", "category":"New Cat", "quantity":10, "active":true},' +
            '{"product_code":"PROD-002", "product_name":"Unchanged Product", "category":"Category 2", "subCategory":"Sub 2", "quantity":20, "active":true},' +
            '{"product_code":"PROD-003", "product_name":"New Product", "category":"Category 3", "quantity":50, "active":true},' +
            '{"product_name":"Missing Code Product"}' +
        ']';

        Test.setMock(HttpCalloutMock.class, new SupabaseHttpMock(200, jsonBody));

        // Wrap execution in runAs to prevent the tmpVar1 cursor bug
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
}