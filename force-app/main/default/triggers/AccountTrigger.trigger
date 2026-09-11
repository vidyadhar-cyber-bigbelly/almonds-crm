trigger AccountTrigger on Account (before insert) {
    if (trigger.isBefore){
        if(trigger.isInsert){
            AccountHandler.validation(trigger.new);
            
        }
    }

}