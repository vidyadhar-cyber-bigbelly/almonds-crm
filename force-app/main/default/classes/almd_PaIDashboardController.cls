public without sharing class almd_PaIDashboardController {
    //wrapper class for payload
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
    // wrapper for result to show on Toast message
    public class syncResult {
        public Integer insertedCount = 0;
        public Integer updatedCount = 0;
        public Integer skippedCount = 0;
        public Integer failedCount = 0;
        
        public List<String> errors = new List<String>();
        
        public String getMessage() {
            return 'Inventory sync completed. ' +
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
        return message;
    }
}