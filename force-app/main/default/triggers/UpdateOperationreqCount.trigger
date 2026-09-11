trigger UpdateOperationreqCount on Operation_Request__c (after insert, after delete) {
    
    Set<Id> opptyIds = new set<Id>();
    
    if(Trigger.isInsert){
        for(Operation_Request__c opr:Trigger.new){
            opptyIds.add(opr.Opportunity__c);
        }
    }
    if(Trigger.isDelete){
        for(Operation_Request__c opr:Trigger.old){
            opptyIds.add(opr.Opportunity__c);
        }
    }
    
    Map<Id,Integer> OperationReqCnt = new Map<Id,Integer>();
    for(AggregateResult ar : [SELECT opportunity__c,Count(Id) OPRcount from Operation_Request__c where opportunity__c IN :opptyIds
                             Group by opportunity__c]){
                                 OperationReqCnt.put((Id)ar.get('opportunity__c'),(Integer)ar.get('OPRcount'));
    }
    
    List<Opportunity> Opptytoupdate = new List<Opportunity>();
    for(Opportunity opp : [Select Id,Operation_Request_Count__c from Opportunity WHERE Id IN : opptyIds]){
        opp.Operation_Request_Count__c = OperationReqCnt.get(opp.id);
        Opptytoupdate.add(opp);
    }
    if(!Opptytoupdate.isEmpty()){
        update Opptytoupdate;
    }
}