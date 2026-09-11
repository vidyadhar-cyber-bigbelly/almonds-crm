trigger externalShipmentEventTrigger on External_Shipment__e (after insert) {
    
    externalShipmenrEventHandler.externalShipmentStatus(trigger.new);
    
    

}