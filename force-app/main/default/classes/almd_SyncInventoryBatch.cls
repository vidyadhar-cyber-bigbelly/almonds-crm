public without sharing class almd_SyncInventoryBatch implements Database.Batchable<Integer>, Database.AllowsCallouts, Database.Stateful {
    
    public almd_PaIDashboardController.SyncResult result = new almd_PaIDashboardController.SyncResult();
    private Integer pageSize = 1000; // Supabase default max rows per request
    
    public Iterable<Integer> start(Database.BatchableContext bc) {
        String currentOrgId = UserInfo.getOrganizationId().subString(0,15);
        almd_Supabase_table_org_config__mdt supaBaseConfig = [SELECT almd_Table_Name__c 
                                                              FROM almd_Supabase_table_org_config__mdt 
                                                              WHERE almd_Org_Id__c = :currentOrgId LIMIT 1];
        
        String endPoint = 'callout:Supabase/rest/v1/' + supaBaseConfig.almd_Table_Name__c;
        
        // 1. Make a lightweight callout to get the TOTAL count of records
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Prefer', 'count=exact');
        req.setHeader('Range-Unit', 'items');
        req.setHeader('Range', '0-0'); // Request only 1 record just to get the total count header
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        List<Integer> offsets = new List<Integer>();
        
        if (res.getStatusCode() == 200 || res.getStatusCode() == 206) {
            // Supabase returns 'Content-Range' like: 0-0/4500 (where 4500 is total records)
            String contentRange = res.getHeader('Content-Range');
            if (contentRange != null && contentRange.contains('/')) {
                Integer totalRecords = Integer.valueOf(contentRange.substringAfter('/'));
                
                // 2. Generate list of offsets: [0, 1000, 2000, 3000, 4000]
                for (Integer i = 0; i < totalRecords; i += pageSize) {
                    offsets.add(i);
                }
            }
        }
        
        // If the callout failed to return a count, fallback to offset 0 just in case
        if (offsets.isEmpty()) {
            offsets.add(0);
        }
        
        return offsets; // Passes these offsets to the execute method
    }
    
    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        // Because we run this with a batch size of 1, 'scope' contains exactly 1 offset
        Integer offset = scope[0]; 
        Integer rangeEnd = offset + pageSize - 1;
        
        String currentOrgId = UserInfo.getOrganizationId().subString(0,15);
        almd_Supabase_table_org_config__mdt supaBaseConfig = [SELECT almd_Table_Name__c 
                                                              FROM almd_Supabase_table_org_config__mdt 
                                                              WHERE almd_Org_Id__c = :currentOrgId LIMIT 1];
        
        String endPoint = 'callout:Supabase/rest/v1/' + supaBaseConfig.almd_Table_Name__c;
        
        // 3. Make the actual paginated callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Range-Unit', 'items');
        req.setHeader('Range', offset + '-' + rangeEnd); // e.g., '1000-1999'
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() != 200 && res.getStatusCode() != 206) {
            // Log error and skip this chunk
            result.errors.add('Failed on offset ' + offset + '. HTTP ' + res.getStatusCode() + ': ' + res.getBody());
            return;
        }
        
        List<almd_PaIDashboardController.SupabaseInventory> supabaseRecords = 
            (List<almd_PaIDashboardController.SupabaseInventory>) JSON.deserialize(res.getBody(), List<almd_PaIDashboardController.SupabaseInventory>.class);
        
        if (supabaseRecords == null || supabaseRecords.isEmpty()) {
            return;
        }
        
        // 4. Run the SFDC DML logic
        processRecords(supabaseRecords); 
    }
    
    private void processRecords(List<almd_PaIDashboardController.SupabaseInventory> supabaseRecords) {
        Set<String> sbEpmIds = new Set<String>();
        for (almd_PaIDashboardController.SupabaseInventory item : supabaseRecords) {
            if (item.product_code != null) {
                sbEpmIds.add(String.valueOf(item.product_code));
            } else {
                result.failedCount++;
                result.errors.add('Supabase record has no EPM ID.');
            }
        }
        
        if (sbEpmIds.isEmpty()) return;
        
        Map<String, Inventory__c> existingInventory = new Map<String, Inventory__c>();
        for (Inventory__c inv : [SELECT Id, ALMD_EPM_Id_V__c, ALMD_Product_Name_V__c, ALMD_Category_V__c, 
                                        ALMD_Sub_Category_V__c, ALMD_Manufacturer_V__c, Quantity_On_Hand__c, 
                                        ALMD_Description_V__c, ALMD_Active_V__c,ALMD_ERP_List_Price__c 
                                 FROM Inventory__c 
                                 WHERE ALMD_EPM_Id_V__c IN :sbEpmIds]) {
            existingInventory.put(inv.ALMD_EPM_Id_V__c, inv);
        }
        
        List<Inventory__c> recordsToInsert = new List<Inventory__c>();
        List<Inventory__c> recordsToUpdate = new List<Inventory__c>();
        
        for (almd_PaIDashboardController.SupabaseInventory item : supabaseRecords) {
            if (item.product_code == null) continue;
            
            String supabaseEpmId = String.valueOf(item.product_code);
            
            if (!existingInventory.containsKey(supabaseEpmId)) {
                // Record does not exist, map for Insert
                Inventory__c newInventory = new Inventory__c();
                newInventory.Name = item.product_Name;
                newInventory.ALMD_EPM_Id_V__c = supabaseEpmId;
                newInventory.ALMD_Product_Name_V__c = item.product_Name;
                newInventory.ALMD_Category_V__c = item.category;
                newInventory.ALMD_Sub_Category_V__c = item.subCategory;
                newInventory.ALMD_Manufacturer_V__c = item.manufacturer;
                newInventory.Quantity_On_Hand__c = item.quantity;
                newInventory.ALMD_Description_V__c = item.description;
                newInventory.ALMD_Active_V__c = item.active;
                newInventory.ALMD_Last_Synced_V__c = System.now();
                newInventory.ALMD_ERP_List_Price__c = item.unit_price;
                recordsToInsert.add(newInventory);
            } else {
                // Record exists, compare fields for Update
                Inventory__c existingRecord = existingInventory.get(supabaseEpmId);
                Boolean hasChanged = (existingRecord.ALMD_Product_Name_V__c != item.product_Name || 
                                      existingRecord.Quantity_On_Hand__c != item.quantity || 
                                      existingRecord.ALMD_Active_V__c != item.active ||
                                      existingRecord.ALMD_Category_V__c != item.category || 
                                      existingRecord.ALMD_Sub_Category_V__c != item.subCategory || 
                                      existingRecord.ALMD_ERP_List_Price__c != item.unit_price);
                
                if (!hasChanged) {
                    result.skippedCount++;
                } else {
                    existingRecord.ALMD_Product_Name_V__c = item.product_Name;
                    existingRecord.ALMD_Category_V__c = item.category;
                    existingRecord.ALMD_Sub_Category_V__c = item.subCategory;
                    existingRecord.Quantity_On_Hand__c = item.quantity;
                    existingRecord.ALMD_Active_V__c = item.active;
                    existingRecord.ALMD_Last_Synced_V__c = System.now();
                    existingRecord.ALMD_ERP_List_Price__c = item.unit_price;
                    recordsToUpdate.add(existingRecord);
                }
            }
        }
        
        // Execute DML Insert
        if (!recordsToInsert.isEmpty()) {
            Database.SaveResult[] insertResults = Database.insert(recordsToInsert, false);
            for (Database.SaveResult sr : insertResults) {
                if (sr.isSuccess()) {
                    result.insertedCount++;
                } else {
                    result.failedCount++;
                    for(Database.Error err : sr.getErrors()) {
                        result.errors.add('Insert Error: ' + err.getMessage());
                    }
                }
            }
        }
        
        // Execute DML Update
        if (!recordsToUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(recordsToUpdate, false);
            for (Database.SaveResult sr : updateResults) {
                if (sr.isSuccess()) {
                    result.updatedCount++;
                } else {
                    result.failedCount++;
                    for(Database.Error err : sr.getErrors()) {
                        result.errors.add('Update Error: ' + err.getMessage());
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Send Summary Email
        String message = result.getMessage();
        if (!result.errors.isEmpty()) {
            // Append first few errors to message if any exist
            Integer maxErrorsToLog = Math.min(5, result.errors.size());
            message += '\n\nTop Errors:\n';
            for(Integer i=0; i<maxErrorsToLog; i++) {
                message += result.errors[i] + '\n';
            }
        }
        
        //almd_PaIDashboardController.sendCompletionEmail(message, 'Inventory ');
        
        // Chain the Product Sync
        //Database.executeBatch(new almd_SyncProductBatch(), 200);
        if (!Test.isRunningTest()) {
            Database.executeBatch(new almd_SyncProductBatch(), 200);
        }
    }
}