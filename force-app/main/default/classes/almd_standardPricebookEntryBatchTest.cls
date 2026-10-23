@isTest
private class almd_standardPricebookEntryBatchTest {

    @testSetup
    static void setupTestData() {
        // 1. Setup Standard Pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        
        // 2. Create Inventory Records
        List<Inventory__c> inventories = new List<Inventory__c>();
        inventories.add(new Inventory__c(Name = 'Inv-1', ALMD_ERP_List_Price__c = 150.00)); // For Insert
        inventories.add(new Inventory__c(Name = 'Inv-2', ALMD_ERP_List_Price__c = 250.00)); // For Update
        inventories.add(new Inventory__c(Name = 'Inv-3', ALMD_ERP_List_Price__c = 350.00)); // For No-Op (Same Price)
        inventories.add(new Inventory__c(Name = 'Inv-4', ALMD_ERP_List_Price__c = null));   // For Null fallback
        insert inventories;

        // 3. Create Products
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Prod 1 (Insert)', IsActive = true, ALMD_EPM_Id_V__c = 'EPM-001', ALMD_Inventory__c = inventories[0].Id));
        products.add(new Product2(Name = 'Prod 2 (Update)', IsActive = true, ALMD_EPM_Id_V__c = 'EPM-002', ALMD_Inventory__c = inventories[1].Id));
        products.add(new Product2(Name = 'Prod 3 (No-Op)', IsActive = true, ALMD_EPM_Id_V__c = 'EPM-003', ALMD_Inventory__c = inventories[2].Id));
        products.add(new Product2(Name = 'Prod 4 (Null)', IsActive = true, ALMD_EPM_Id_V__c = 'EPM-004', ALMD_Inventory__c = inventories[3].Id));
        insert products;

        // 4. Create Existing Pricebook Entries (for Update and No-Op scenarios)
        List<PricebookEntry> existingPbes = new List<PricebookEntry>();
        
        // Exists but price is different (currently 200, should become 250)
        existingPbes.add(new PricebookEntry(
            Pricebook2Id = stdPricebookId,
            Product2Id = products[1].Id,
            UnitPrice = 200.00,
            IsActive = true
        ));

        // Exists and price is already exactly the same (should be skipped by optimization check)
        existingPbes.add(new PricebookEntry(
            Pricebook2Id = stdPricebookId,
            Product2Id = products[2].Id,
            UnitPrice = 350.00,
            IsActive = true
        ));
        
        insert existingPbes;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        // Execute the batch
        almd_standardPricebookEntryBatch batch = new almd_standardPricebookEntryBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest(); // Forces batch to finish synchronously in test context

        // 1. Retrieve the products to get their IDs
        List<Product2> prods = [SELECT Id, Name FROM Product2 ORDER BY Name];
        Id prod1Id = prods[0].Id;
        Id prod2Id = prods[1].Id;
        Id prod3Id = prods[2].Id;
        Id prod4Id = prods[3].Id;

        // 2. Query all Standard Pricebook Entries created/updated
        Id stdPricebookId = Test.getStandardPricebookId();
        Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :stdPricebookId]) {
            pbeMap.put(pbe.Product2Id, pbe);
        }

        // 3. Asserts to verify all 4 scenarios

        // Scenario 1: Insert (Should create a new PBE with list price 150)
        System.assert(pbeMap.containsKey(prod1Id), 'PricebookEntry should have been created for Product 1.');
        System.assertEquals(150.00, pbeMap.get(prod1Id).UnitPrice, 'Product 1 UnitPrice should be 150.00 from Inventory.');

        // Scenario 2: Update (Existing PBE was 200, should now be updated to 250)
        System.assert(pbeMap.containsKey(prod2Id), 'PricebookEntry should exist for Product 2.');
        System.assertEquals(250.00, pbeMap.get(prod2Id).UnitPrice, 'Product 2 UnitPrice should have been updated to 250.00.');

        // Scenario 3: No-Op (Existing PBE was 350, should remain 350)
        System.assert(pbeMap.containsKey(prod3Id), 'PricebookEntry should exist for Product 3.');
        System.assertEquals(350.00, pbeMap.get(prod3Id).UnitPrice, 'Product 3 UnitPrice should remain 350.00.');

        // Scenario 4: Null Fallback (Null ERP price should result in 0.00 UnitPrice)
        System.assert(pbeMap.containsKey(prod4Id), 'PricebookEntry should have been created for Product 4.');
        System.assertEquals(0.00, pbeMap.get(prod4Id).UnitPrice, 'Product 4 UnitPrice should fallback to 0.00.');
    }
}