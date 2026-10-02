public without sharing class almd_productAndInventoryLinkerQueue implements Queueable {
    
    private Set<Id> productIds;
    
    public almd_productAndInventoryLinkerQueue(Set<Id> productIds){
        this.productIds = productIds;
    }
    
    public void execute(QueueableContext context){
        System.debug(productIds);
        List<Product2> products = [select id,ALMD_EPM_Id_V__c from Product2 where Id IN:productIds];
        
        Map<String, Id> epmToProdIdMap = new Map<String, Id>();
        
        for(Product2 prod : products){
            if(prod.ALMD_EPM_Id_V__c !=null){
                epmToProdIdMap.put(prod.ALMD_EPM_Id_V__c, prod.id);
            }
        }
		System.debug(epmToProdIdMap);        
        List<Inventory__c> unlinkedInvs = [select id,ALMD_EPM_Id_V__c from Inventory__c where Product__c =null and ALMD_EPM_Id_V__c 
                                           in:epmToProdIdMap.keySet()];
        
        List<Inventory__c> invToUpdate = new List<Inventory__c>();
        
        for(Inventory__c inv : unlinkedInvs){
            Id matchingProdID = epmToProdIdMap.get(inv.ALMD_EPM_Id_V__c);
            if(matchingProdID!=null){
                inv.Product__C = matchingProdID;
                invToUpdate.add(inv);
            }
        }
        
        if(!invToUpdate.isEmpty()){
            System.debug('Entered update inventories');
            update invToUpdate;
        }    
    }
}