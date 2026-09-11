public class orderHandler {

    public static void orderStatusPublish(List<Order>triggeredOrder){
        List<External_Shipment__e> orderEvent = new List<External_Shipment__e>();
            for(Order ord : triggeredOrder){
                if(ord.Status.equalsIgnoreCase('Shipped')){
                    orderEvent.add(
                    new External_Shipment__e(
                    	Order_number__c= ord.OrderNumber,
                        status__c=ord.Status
                    )
                    );
                }
            }

             if(!orderEvent.isEmpty()){
            List<Database.SaveResult>eventPubResultList =EventBus.publish(orderEvent);
            for(Database.SaveResult pubResult : eventPubResultList)
            {
                if(pubResult.isSuccess()){
                    system.debug('***Events publish sucessfully'+pubResult);
                }
                else{
                    for(Database.Error pubError :pubResult.getErrors()){
                        system.debug('***Events publish failed'+pubError.getMessage());
                    }
                }
            }
            }
    }
}