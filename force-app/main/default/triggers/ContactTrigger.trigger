trigger ContactTrigger on Contact (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isUpdate){
            ContactHandler.Contactdescrption(trigger.new,trigger.oldMap);
            system.debug('OChindi');
        }
        
    }

}