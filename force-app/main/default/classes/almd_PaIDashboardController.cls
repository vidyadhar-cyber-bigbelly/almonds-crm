public without sharing class almd_PaIDashboardController {
    //wrapper class
    public class SupabaseInventory {
        public String product_code;
        public String product_name;
        public String category;
        public String subCategory;
        public String manufacturer;
        public Integer quantity;
        public String description;
        public boolean active;	
    }
    // wrapper for result to show on Toast
    public class syncResult {
        public Integer insertedCount = 0;
        public Integer updatedCount = 0;
        public Integer skippedCount = 0;
        public Integer failedCount = 0;
        
        public List<String> errors = new List<String>();
        
        public String getMessage() {
            return 'Sync completed. ' +
                'Inserted: ' + insertedCount +
                ', Updated: ' + updatedCount +
                ', Skipped: ' + skippedCount +
                ', Failed: ' + failedCount;
        }
    }
    @AuraEnabled
    public static String syncInventory() {
        //making a http request to supabase database
        String currentOrgId = UserInfo.getOrganizationId().subString(0,15);
        almd_Supabase_table_org_config__mdt supaBaseConfig = [SELECT almd_Table_Name__c 
                                                              FROM almd_Supabase_table_org_config__mdt
                                                              where almd_Org_Id__c  = :currentOrgId
                                                              limit 1];
        //String endPoint = 'callout:Supabase/rest/v1'+ System.Label.almd_Supabase_table_name;
        String endPoint = 'callout:Supabase/rest/v1/' + supaBaseConfig.almd_Table_Name__c;
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endPoint); //taking the endpoint for external creds
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json'); //requesting a json format response
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        //validating response
        if (res.getStatusCode() != 200 ) {
            throw new AuraHandledException(
                'Supabase returned HTTP ' +
                res.getStatusCode() +
                ': ' +
                res.getBody()
            );
        }
        
        List<SupabaseInventory> supabaseRecords = (List<SupabaseInventory>) JSON.deserialize(res.getBody(),List<SupabaseInventory>.class);
        
        if (supabaseRecords.isEmpty()) {
            return 'No records found in Supabase.';
        }
        
        Set<String> sbEpmIds = new Set<String>();
        
        for (SupabaseInventory item : supabaseRecords) {
            
            if (item.product_code != null) {
                sbEpmIds.add(String.valueOf(item.product_code));
            }
        }
        
        
        if (sbEpmIds.isEmpty()) {
            return 'No valid Supabase EPM IDs found.';
        }
        
        Map<String, Inventory__c> existingInventory = new Map<String, Inventory__c>();
        
        for (Inventory__c inv : [select id,ALMD_EPM_Id_V__c,ALMD_Product_Name_V__c,ALMD_Category_V__c,ALMD_Sub_Category_V__c,ALMD_Manufacturer_V__c,Quantity_On_Hand__c,ALMD_Description_V__c,ALMD_Active_V__c from Inventory__c 
                                 WHERE ALMD_EPM_Id_V__c IN :sbEpmIds]) {
                                     
                                     existingInventory.put(inv.ALMD_EPM_Id_V__c,inv);
                                 }
        
        
        List<Inventory__c> recordsToInsert = new List<Inventory__c>();
        List<Inventory__c> recordsToUpdate = new List<Inventory__c>();
        
        SyncResult result = new SyncResult();
        
        //comparing sf records with supabase
        for (SupabaseInventory item : supabaseRecords) {
            
            if (item.product_code == null) {
                result.failedCount++;
                result.errors.add('Supabase record has no EPM ID.');
                continue;
            }
            
            String supabaseEpmId = String.valueOf(item.product_code);
            
            //if records does not exist in sf, we insert them
            
            if (!existingInventory.containsKey(supabaseEpmId) || existingInventory.isEmpty()) {
                
                Inventory__c newInventory = new Inventory__c();
                newInventory.Name = item.product_Name; //mandatory field
                newInventory.ALMD_EPM_Id_V__c = supabaseEpmId;
                newInventory.ALMD_Product_Name_V__c = item.product_Name;
                newInventory.ALMD_Category_V__c = item.category;
                newInventory.ALMD_Sub_Category_V__c = item.subCategory;
                newInventory.ALMD_Manufacturer_V__c = item.manufacturer;
                newInventory.Quantity_On_Hand__c = item.quantity;
                newInventory.ALMD_Description_V__c = item.description;
                newInventory.ALMD_Active_V__c = item.active;
                newInventory.ALMD_Last_Synced_V__c = system.now();
                recordsToInsert.add(newInventory);
                continue;
            }
            
            //records exists in sf, we get it from pam
            Inventory__c existingRecord = existingInventory.get(supabaseEpmId);
            
            //comparing key fields
            Boolean hasChanged = false;
            
            if (existingRecord.ALMD_Product_Name_V__c!= item.product_Name || existingRecord.Quantity_On_Hand__c != item.quantity || existingRecord.ALMD_Active_V__c != item.active ||
                existingRecord.ALMD_Category_V__c != item.category || existingRecord.ALMD_Sub_Category_V__c != item.subCategory ) {
                    
                    hasChanged = true;
                }
            
            //skipping for unchanged records
            if (!hasChanged) {
                result.skippedCount++;
                continue;
            }
            
            //updates the exisitng records if different
            existingRecord.ALMD_Product_Name_V__c = item.product_Name;
            existingRecord.ALMD_Category_V__c = item.category;
            existingRecord.ALMD_Sub_Category_V__c = item.subCategory;
            existingRecord.Quantity_On_Hand__c = item.quantity;
            existingRecord.ALMD_Active_V__c = item.active;
            existingRecord.ALMD_Last_Synced_V__c = system.now();
            
            recordsToUpdate.add(existingRecord);
        }
        
        //inserting new records
        if (!recordsToInsert.isEmpty()) {
            
            Database.SaveResult[] insertResults = Database.insert(recordsToInsert,false);
            
            for (Database.SaveResult sr :insertResults) {
                if (sr.isSuccess()) {
                    result.insertedCount++;
                } 
                else {
                    result.failedCount++;
                }
            }
        }
        
        //updating existing records
        if (!recordsToUpdate.isEmpty()) {
            
            Database.SaveResult[] updateResults = Database.update(recordsToUpdate,false);
            
            for (Database.SaveResult sr :updateResults) {
                if (sr.isSuccess()) {
                    result.updatedCount++;
                } 
                else {
                    result.failedCount++;
                }
            }
        }
        
        String message = result.getMessage();
        sendCompletionEmail(message,'Inventory ');
        return message;
    }
    
    @AuraEnabled
    public static string productSyncFromInventoryMnl(){
        try {
            //fetching all the inventory records
            List<Inventory__c> inventoryList = [SELECT Id, Name, ALMD_EPM_Id_V__c, ALMD_Product_Name_V__c, ALMD_Category_V__c, ALMD_Sub_Category_V__c, ALMD_Manufacturer_V__c, Quantity_On_Hand__c, ALMD_Description_V__c,
                                                ALMD_Active_V__c, ALMD_Last_Synced_V__c FROM Inventory__c];
            
            if(inventoryList.isEmpty()){
                return 'No inventory records found in the SF system';
            }
            
            Set<String> invEpmIds = new Set<String>();
            
            for(Inventory__c inv :inventoryList){
                if(inv.ALMD_EPM_Id_V__c != null){
                    invEpmIds.add(inv.ALMD_EPM_Id_V__c);
                }
            }
            
            if(invEpmIds.isEmpty()){
                return 'No valid EPM IDs found in Inventory.';
            }
            
            Map<String,Product2> existingProducts = new Map<String,Product2>();
            
            for(Product2 prd : [select id,Name,ALMD_EPM_Id_V__c,ALMD_Category_V__c,ALMD_Sub_Category_V__c,Description,IsActive from product2
                                where ALMD_EPM_Id_V__c IN :invEpmIds ]){
                                    existingProducts.put(prd.ALMD_EPM_Id_V__c, prd);
                                }
            
            List<Product2> recordsToInsert = new List<Product2>();
            List<Product2> recordsToUpdate = new List<Product2>();
            Set<Id> productIds = new Set<Id>();
            
            SyncResult result = new SyncResult();
            
            for(Inventory__c inv : inventoryList){
                
                if(inv.ALMD_EPM_Id_V__c == null){
                    result.failedCount++;
                    result.errors.add('Inventory record has no EPM ID.');
                    continue;
                }
                
                String invEpmId = String.valueOf(inv.ALMD_EPM_Id_V__c);
                
                if(!existingProducts.containsKey(invEpmId) || existingProducts.isEmpty()){
                    
                    Product2 newProduct = new Product2();
                    newProduct.Name = inv.Name;
                    newProduct.ALMD_EPM_Id_V__c = inv.ALMD_EPM_Id_V__c;
                    newProduct.ALMD_Category_V__c = inv.ALMD_Category_V__c;
                    newProduct.ALMD_Sub_Category_V__c = inv.ALMD_Sub_Category_V__c;
                    newProduct.Description = inv.ALMD_Description_V__c;
                    newProduct.IsActive = inv.ALMD_Active_V__c;
                    
                    recordsToInsert.add(newProduct);
                    continue;
                }
                
                Product2 existingProduct = existingProducts.get(invEpmId);
                Boolean hasChanged = false;
                
                if (existingProduct.Name != inv.Name || existingProduct.ALMD_Category_V__c != inv.ALMD_Category_V__c || existingProduct.ALMD_Sub_Category_V__c != inv.ALMD_Sub_Category_V__c || existingProduct.Description != inv.ALMD_Description_V__c || existingProduct.IsActive != inv.ALMD_Active_V__c) {
                    hasChanged = true;
                }
                
                if (!hasChanged) {
                    result.skippedCount++;
                    continue;
                }
                
                existingProduct.Name = inv.Name;
                existingProduct.ALMD_Category_V__c = inv.ALMD_Category_V__c;
                existingProduct.ALMD_Sub_Category_V__c = inv.ALMD_Sub_Category_V__c;
                existingProduct.Description = inv.ALMD_Description_V__c;
                existingProduct.IsActive = inv.ALMD_Active_V__c;
                
                recordsToUpdate.add(existingProduct);
            }
            
            //inserting new records
            if (!recordsToInsert.isEmpty()) {
                
                Database.SaveResult[] insertResults = Database.insert(recordsToInsert,false);
                
                for (Database.SaveResult sr :insertResults) {
                    if (sr.isSuccess()) {
                        productIds.add(sr.getId());
                        result.insertedCount++;
                    } 
                    else {
                        result.failedCount++;
                    }
                }
            }
            
            //updating existing records
            if (!recordsToUpdate.isEmpty()) {
                
                Database.SaveResult[] updateResults = Database.update(recordsToUpdate,false);
                
                for (Database.SaveResult sr :updateResults) {
                    if (sr.isSuccess()) {
                        productIds.add(sr.getId());
                        result.updatedCount++;
                    } 
                    else {
                        result.failedCount++;
                    }
                }
            }
            
            Id jobId = System.enqueueJob(new almd_productAndInventoryLinkerQueue(productIds));
            String message = result.getMessage();
            sendCompletionEmail(message,'Product ');
            return message;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @future 
    public static void sendCompletionEmail(String message,String typeOfSync) {
        // 1. Fetch the Org-Level Custom Setting data
        almd_Org_Owner_Emails__c config = almd_Org_Owner_Emails__c.getOrgDefaults();
        
        if (config == null || String.isBlank(config.almd_Current_Org_Owner__c)) {
            return; 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // 2. Query and set the Org-Wide Email Address
        if (String.isNotBlank(config.almd_Org_wide_Email__c)) {
            List<OrgWideEmailAddress> owea = [
                SELECT Id 
                FROM OrgWideEmailAddress 
                WHERE Address = :config.almd_Org_wide_Email__c 
                LIMIT 1
            ];
            if (!owea.isEmpty()) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
        }
        
        // 3. Set the TO address
        String currentOrgOwner = config.almd_Current_Org_Owner__c.trim();
        mail.setToAddresses(new String[] { currentOrgOwner });
        
        // 4. Build and set the CC list
        List<String> ccAddresses = new List<String>();
        
        if (String.isNotBlank(config.almd_All_Org_Owners__c)) {
            String[] allOwners = config.almd_All_Org_Owners__c.split(',');
            
            for (String email : allOwners) {
                String cleanEmail = email.trim();
                
                if (cleanEmail.equalsIgnoreCase(currentOrgOwner) == false) {
                    ccAddresses.add(cleanEmail);
                }
            }
        }
        
        if (!ccAddresses.isEmpty()) {
            mail.setCcAddresses(ccAddresses);
        }
        String mailSubject = typeOfSync + 'sync completed';
        String mailBody = mailSubject +' with ' + message;
        // 5. Send the email
        mail.setSubject(mailSubject);
        mail.setPlainTextBody(mailBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}