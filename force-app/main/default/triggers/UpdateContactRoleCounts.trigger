trigger UpdateContactRoleCounts on OpportunityContactRole (after insert, after delete) {
    // set for oppty ids
    Set<Id> opptyIds = new set<Id>();
	// collecting the opptys ids that are undergone insert/delete of contact roles
    if(Trigger.isInsert){
        for(OpportunityContactRole ocr : Trigger.new){
            opptyIds.add(ocr.opportunityId);
        }
    }
        if(Trigger.isDelete){
        for(OpportunityContactRole ocr : Trigger.old){
            opptyIds.add(ocr.opportunityId);
        }
    }
    //Querying the count of contat roles based on count
    Map<Id,Integer> ContactRoleCnt = new Map<Id,Integer>();
    for(AggregateResult  RC : [Select opportunityId,Count(id) contactrolecount from OpportunityContactRole where opportunityId IN : opptyIds 
                            Group By opportunityId ]){
                                
                                ContactRoleCnt.put((Id)RC.get('opportunityId'),(Integer)RC.get('contactrolecount'));
                                
                            }
    //updating opptys
    List<Opportunity> Opptytoupdate = new List<Opportunity>();
    for(opportunity opp :[select id,contact_role_count__c from opportunity where Id IN :opptyIds]){
        opp.contact_role_count__c = ContactRoleCnt.get(opp.id);
        Opptytoupdate.add(opp);
    }
    if(!Opptytoupdate.isEmpty()){
        update Opptytoupdate;
    }
}