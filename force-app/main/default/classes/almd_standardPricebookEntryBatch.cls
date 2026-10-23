public without sharing class almd_standardPricebookEntryBatch implements Database.Batchable<sObject> {
    private Id standardPricebookId;
    
    public almd_standardPricebookEntryBatch() {
        if (Test.isRunningTest()) {
            standardPricebookId = Test.getStandardPricebookId();
        } else {
            List<Pricebook2> stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            if (!stdPb.isEmpty()) {
                standardPricebookId = stdPb[0].Id;
            }
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, ALMD_Inventory__c, ALMD_Inventory__r.ALMD_ERP_List_Price__c 
            FROM Product2 
            WHERE ALMD_EPM_Id_V__c != null
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Product2> scope) {
        if (standardPricebookId == null) {
            System.debug('Standard Pricebook not found. Skipping batch chunk.');
            return; 
        }
        
        // 1. Collect all Product IDs from the current batch chunk
        Set<Id> productIds = new Set<Id>();
        for (Product2 prod : scope) {
            productIds.add(prod.Id);
        }
        
        // 2. Query existing Standard Pricebook Entries into a Map
        Map<Id, PricebookEntry> existingPbeByProductId = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry 
                                   WHERE Pricebook2Id = :standardPricebookId 
                                   AND Product2Id IN :productIds
                                  ]) {
                                      existingPbeByProductId.put(pbe.Product2Id, pbe);
                                  }
        
        // 3. Create missing or Update existing Pricebook Entries
        List<PricebookEntry> pbesToUpsert = new List<PricebookEntry>();
        for (Product2 prod : scope) {
            
            Decimal listPrice = 0.00;
            if (prod.ALMD_Inventory__c != null && prod.ALMD_Inventory__r.ALMD_ERP_List_Price__c != null) {
                listPrice = prod.ALMD_Inventory__r.ALMD_ERP_List_Price__c;
            }
            
            if (existingPbeByProductId.containsKey(prod.Id)) {
                // UPDATE Logic
                PricebookEntry existingPbe = existingPbeByProductId.get(prod.Id);
                if (existingPbe.UnitPrice != listPrice) {
                    existingPbe.UnitPrice = listPrice;
                    pbesToUpsert.add(existingPbe);
                }
            } else {
                // CREATE Logic
                pbesToUpsert.add(new PricebookEntry(
                    Pricebook2Id = standardPricebookId,
                    Product2Id = prod.Id,
                    UnitPrice = listPrice,
                    IsActive = true 
                ));
            }
        }
        
        // 4. Upsert the entries
        if (!pbesToUpsert.isEmpty()) {
            
            Database.UpsertResult[] results = Database.upsert(pbesToUpsert, false);
            
            for (Database.UpsertResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error upserting PricebookEntry: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}