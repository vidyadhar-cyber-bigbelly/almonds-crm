trigger OrderTrigger on Order (before insert ,after update) {
   static boolean isRun = false;
    if(trigger.isAfter){
        if(trigger.isUpdate){
            if(isRun) {return;}
            isRun= true;
          orderHandler.orderStatusPublish(trigger.new);
        }
       
        
        }

}