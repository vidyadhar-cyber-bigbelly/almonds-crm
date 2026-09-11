trigger userTrigger on User (before insert,before update,after insert,after update) {

    Map<String,Almond_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Almond_Trigger_Executions__c.getAll();
    
    if(!mapFunctionalityNameTriggerExecution.isEmpty()){
        
        //Set<Id> userIds = Trigger.newMap.keySet();
  
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                Set<Id> userIds = Trigger.newMap.keySet();
                if(mapFunctionalityNameTriggerExecution.containsKey('UserAfterInsert') && mapFunctionalityNameTriggerExecution.get('UserAfterInsert').Almond_Active__c){
                    almondUserHandler.userInformationInsert(userIds);
                }
            }
            if(Trigger.isUpdate){
                if(mapFunctionalityNameTriggerExecution.containsKey('UserAfterUpdate') && mapFunctionalityNameTriggerExecution.get('UserAfterUpdate').Almond_Active__c){
                    almondUserHandler.userInformationUpdate(Trigger.oldMap,Trigger.new);
                }
            }
        }
    }
}