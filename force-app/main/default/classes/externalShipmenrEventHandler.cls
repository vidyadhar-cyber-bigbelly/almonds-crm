public class  externalShipmenrEventHandler {
    
    public static void externalShipmentStatus(List<External_Shipment__e> listEvent ){
        try{
        set<string> ordernumber = new set<string> ();
        for(External_Shipment__e eve:listEvent){
            if(eve.status__c == '1'){
                ordernumber.add(eve.Order_number__c);
             }
        }
        List<Order> ordersToUpdate = new List<Order> ([select id,OrderNumber,Status from Order where OrderNumber in :ordernumber]);
        List<Task> taskToInsert = new List<Task> ();           
        for ( Order o :ordersToUpdate ){
            o.Status ='Delivered';
            taskToInsert.add(
            new Task(
            	WhatId = o.Id,
                subject = 'Follow up for shipped order ' + o.OrderNumber,
                Priority = 'Normal'
           )
            );
        }
        if(!ordersToUpdate.isEmpty()){
        update ordersToUpdate;
        insert taskToInsert;
        }
            List<Event_Log__c> logs = new List<Event_Log__c>();
         logs.add(new Event_Log__c(
         Pay_load__c = JSON.serialize(listEvent)
            /* Stack_trace__c = ex.getStackTraceString(),
             Error_message__c = ex.getMessage()*/
                   ));
              insert logs ;
       
        }
        catch(exception ex){
             system.debug('*system debug'+ ex.getMessage());
        }
    }
    
}