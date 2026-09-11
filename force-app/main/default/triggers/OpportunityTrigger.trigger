trigger OpportunityTrigger on Opportunity (before insert, after insert,after update) {
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            OpportunityHandler.afterInsert(trigger.new);
            }
    }

}