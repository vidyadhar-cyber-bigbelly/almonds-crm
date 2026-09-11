trigger BUupdateOLI on OpportunityLineItem (before insert,before update) {

    Set<Id> opptyIds = new Set<Id>();
    for (OpportunityLineItem OLIs : Trigger.new){
            opptyIds.add(OLIs.opportunityId);   
    }
    
    Map<Id, Opportunity> oppty = new Map<Id,Opportunity>([Select Id,owner.division,Product_segment__c,Product_Application__c,Market__c from Opportunity 
                                                         where Id IN :opptyIds]);
    
    Map<String,BU_Mapping__c> BUMap = new Map<String,BU_Mapping__c>();
    
    //List<BU_Mapping__c> BUlist = [ SELECT Id, BU_Market__c, BU_Product_Application__c, Bu_Product_Segment__c, Region__c, Product_Family__c FROM BU_Mapping__c WHERE Is_Active__c = TRUE];
    //System.debug('BUlist size: ' + BUlist.size());
    /*for(BU_Mapping__c BU : BUlist ){
        //System.debug('BU record: ' + BU);
        String bukey = BU.BU_Market__c+'|'+BU.BU_Product_Application__c+'|'+BU.Bu_Product_Segment__c+'|'+BU.Region__c+'|'+BU.Product_Family__c;
        BUMap.put(bukey,BU);
        System.debug('BU record: ' + BUMap); 
    }*/
    
    for(OpportunityLineItem oli : Trigger.new){
        Opportunity opp = oppty.get(oli.OpportunityId);
        if(opp != null){
           List<BU_Mapping__c> Bum = [Select Id from BU_Mapping__c where
                              BU_Market__c =: opp.Market__c AND
                              BU_Product_Application__c =: opp.Product_Application__c AND
                              Bu_Product_Segment__c =: opp.Product_segment__c AND
                              Region__c =: opp.owner.Division AND
                              Product_Family__c =: oli.Product_Family__c 
                              AND Is_Active__c = true];
            System.debug('BU:'+Bum);
            if(Bum.size()>0){
               	oli.BU_Mapping__c = Bum[0].id;
            }
            else {
                oli.BU_Mapping__c = null;
            }
        }
        
    }
    
    
    
    
}