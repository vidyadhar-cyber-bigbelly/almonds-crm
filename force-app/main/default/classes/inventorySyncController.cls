public without sharing class inventorySyncController {
    
    @AuraEnabled
    public static String syncInventory() {
        
        if (!FeatureManagement.checkPermission('Inventory_Sync')){ 
            throw new AuraHandledException('You do not have permission to sync Inventory.');
        }

        try {
            return inventorySyncServiceHandler.syncInventory();// calls the service handler method
        } 
        catch (Exception e) {
            throw new AuraHandledException('Inventory sync failed: ' + e.getMessage());
        }
    }

}