global class inventoryProductSyncBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Sync statistics
    global Integer totalProcessed = 0;
    global Integer totalInserted = 0;
    global Integer totalUpdated = 0;
    global Integer totalFailed = 0;

    global List<String> errors = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id,name,ALMD_Active_V__c,ALMD_Category_V__c,ALMD_Sub_Category_V__c,ALMD_Manufacturer_V__c,ALMD_EPM_Id_V__c,ALMD_Product_Name_V__c,ALMD_Description_V__c
        FROM Inventory__c WHERE ALMD_EPM_Id_V__c != NULL limit 1]);
    }

    global void execute(Database.BatchableContext bc, List<Inventory__c> inventoryRecords) {

        List<Product2> productsToUpsert = new List<Product2>();

        for (Inventory__c inventory : inventoryRecords) {
            Product2 product = new Product2();
            // EPMID used for matching
            product.ALMD_EPM_Id_V__c = inventory.ALMD_EPM_Id_V__c;
            // Product fields
            product.Name = inventory.Name;
            product.Description = inventory.ALMD_Description_V__c;
            product.IsActive = inventory.ALMD_Active_V__c;
            productsToUpsert.add(product);

        }

        if (productsToUpsert.isEmpty()) {
            return;
        }

        Database.UpsertResult[] results = Database.upsert(productsToUpsert, false);

        for (Integer i = 0;i < results.size();i++) {

            totalProcessed++;

            Database.UpsertResult result = results[i];

            if (result.isSuccess()) {
                if (result.isCreated()) {
                    totalInserted++;
                }
                else {
                    totalUpdated++;
                }
            }
            else {
                totalFailed++;

                for (Database.Error error : result.getErrors()) {
                    errors.add(
                    'Inventory Product Code: ' +
                    productsToUpsert[i].ALMD_EPM_Id_V__c +
                    ' | Error: ' +
                    error.getStatusCode() +
                    ' - ' +
                    error.getMessage()
                    );
                }
            }
        }
    }

    /*
    * Finish
    */
    global void finish(Database.BatchableContext bc) {

        System.debug('========== INVENTORY PRODUCT SYNC ==========');
        System.debug('Total Processed: ' + totalProcessed);
        System.debug('Total Inserted: ' + totalInserted);
        System.debug('Total Updated: ' + totalUpdated);
        System.debug('Total Failed: ' + totalFailed);

        if (!errors.isEmpty()) {
            System.debug('========== ERRORS ==========');

            for (String error : errors) {
                System.debug(error);
            }
        }
    }
}