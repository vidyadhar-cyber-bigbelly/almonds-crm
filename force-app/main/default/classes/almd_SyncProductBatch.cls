public without sharing class almd_SyncProductBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // Use the SyncResult wrapper from your controller
    public almd_PaIDashboardController.SyncResult result = new almd_PaIDashboardController.SyncResult();
    
    // Stateful set to collect Product IDs across all batch chunks
    public Set<Id> productIdsForQueueable = new Set<Id>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Fetching all the inventory records that have an EPM ID
        return Database.getQueryLocator([
            SELECT Id, Name, ALMD_EPM_Id_V__c, ALMD_Product_Name_V__c, ALMD_Category_V__c, 
                   ALMD_Sub_Category_V__c, ALMD_Manufacturer_V__c, Quantity_On_Hand__c, 
                   ALMD_Description_V__c, ALMD_Active_V__c, ALMD_Last_Synced_V__c 
            FROM Inventory__c
            WHERE ALMD_EPM_Id_V__c != null
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Inventory__c> scope) {
        Set<String> invEpmIds = new Set<String>();
        
        for(Inventory__c inv : scope) {
            invEpmIds.add(inv.ALMD_EPM_Id_V__c);
        }
        
        if(invEpmIds.isEmpty()){
            return;
        }
        
        Map<String, Product2> existingProducts = new Map<String, Product2>();
        
        String query = 'SELECT Id, Name, ALMD_EPM_Id_V__c, ALMD_Category_V__c, ' +
                       'ALMD_Sub_Category_V__c, Description, IsActive, ALMD_Inventory__c ' +
                       'FROM Product2 WHERE ALMD_EPM_Id_V__c IN :invEpmIds';
        
        for(Product2 prd : Database.query(query)) {
            existingProducts.put(prd.ALMD_EPM_Id_V__c, prd);
        }
        
        List<Product2> recordsToInsert = new List<Product2>();
        List<Product2> recordsToUpdate = new List<Product2>();
        
        for(Inventory__c inv : scope) {
            String invEpmId = String.valueOf(inv.ALMD_EPM_Id_V__c);
            
            if(!existingProducts.containsKey(invEpmId)) {
                Product2 newProduct = new Product2();
                newProduct.Name = inv.Name;
                newProduct.ALMD_EPM_Id_V__c = inv.ALMD_EPM_Id_V__c;
                newProduct.ALMD_Category_V__c = inv.ALMD_Category_V__c;
                newProduct.ALMD_Sub_Category_V__c = inv.ALMD_Sub_Category_V__c;
                newProduct.Description = inv.ALMD_Description_V__c;
                newProduct.IsActive = inv.ALMD_Active_V__c;
                newProduct.ALMD_Inventory__c = inv.id;
                
                recordsToInsert.add(newProduct);
            } else {
                Product2 existingProduct = existingProducts.get(invEpmId);
                Boolean hasChanged = false;
                            
                // Compare fields exactly as in your synchronous method
                if (existingProduct.Name != inv.Name || 
                    existingProduct.ALMD_Category_V__c != inv.ALMD_Category_V__c || 
                    existingProduct.ALMD_Sub_Category_V__c != inv.ALMD_Sub_Category_V__c || 
                    existingProduct.Description != inv.ALMD_Description_V__c || 
                    existingProduct.IsActive != inv.ALMD_Active_V__c ||
                   	existingProduct.ALMD_Inventory__c != inv.Id) {
                    
                    hasChanged = true;
                }
                
                if (!hasChanged) {
                    result.skippedCount++;
                } else {
                    existingProduct.Name = inv.Name;
                    existingProduct.ALMD_Category_V__c = inv.ALMD_Category_V__c;
                    existingProduct.ALMD_Sub_Category_V__c = inv.ALMD_Sub_Category_V__c;
                    existingProduct.Description = inv.ALMD_Description_V__c;
                    existingProduct.IsActive = inv.ALMD_Active_V__c;
                    existingProduct.ALMD_Inventory__c = inv.id;
                    
                    recordsToUpdate.add(existingProduct);
                }
            }
        }
        
        // Inserting new products
        if (!recordsToInsert.isEmpty()) {
            Database.SaveResult[] insertResults = Database.insert(recordsToInsert, false);
            for (Database.SaveResult sr : insertResults) {
                if (sr.isSuccess()) {
                    productIdsForQueueable.add(sr.getId());
                    result.insertedCount++;
                } else {
                    result.failedCount++;
                    for(Database.Error err : sr.getErrors()) {
                        result.errors.add('Product Insert Error: ' + err.getMessage());
                    }
                }
            }
        }
        
        // Updating existing products
        if (!recordsToUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(recordsToUpdate, false);
            for (Database.SaveResult sr : updateResults) {
                if (sr.isSuccess()) {
                    productIdsForQueueable.add(sr.getId());
                    result.updatedCount++;
                } else {
                    result.failedCount++;
                    for(Database.Error err : sr.getErrors()) {
                        result.errors.add('Product Update Error: ' + err.getMessage());
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // 1. Enqueue the linker job if we successfully processed any products
        if (!productIdsForQueueable.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new almd_productAndInventoryLinkerQueue(productIdsForQueueable));
        }
        
        // 2. Prepare and send the completion email
        String message = result.getMessage();
        
        // Append the top errors to the email body if any occurred
        if (!result.errors.isEmpty()) {
            Integer maxErrorsToLog = Math.min(5, result.errors.size());
            message += '\n\nTop Errors:\n';
            for(Integer i = 0; i < maxErrorsToLog; i++) {
                message += result.errors[i] + '\n';
            }
        }
        
        //almd_PaIDashboardController.sendCompletionEmail(message, 'Product ');
    }
}