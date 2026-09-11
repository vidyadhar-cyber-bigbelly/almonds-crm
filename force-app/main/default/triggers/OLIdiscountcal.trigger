trigger OLIdiscountcal on OpportunityLineItem (after insert,after update) {
    for(OpportunityLineItem Oli : Trigger.new){
        if(Oli.Status__c == 'Pending'){
            oli.UnitPrice = oli.ListPrice - ((oli.Discount)/100)-oli.ListPrice;
        }
    }
}