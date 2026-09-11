trigger UpdateORowner on Operation_Request__c (before insert) {
    // Defining owner IDs
    Id salesopssw = '005dN0000016pIiQAI';
    Id salesopsne = '005dN0000016t4TQAQ';
    Id dataopssw  = '005dN0000016t4UQAQ';
    Id dataopsne  = '005dN0000016pIjQAI';
    
    // Collect Opportunity IDs from Operation Requests
    Set<Id> opportunityIds = new Set<Id>();
    for (Operation_Request__c opr : Trigger.new) {
        if (opr.Opportunity__c != null) {
            opportunityIds.add(opr.Opportunity__c); 
        }
    }
    //collecting ids of OR owners
    Set<Id> ownerIds = new Set<Id>();
    for (Operation_Request__C oppr : Trigger.new){
        ownerIds.add(oppr.OwnerId);
    }
    //07-08-2024: creating an email format
     List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    // Query related Opportunities and store in a map
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
        [SELECT Id, Owner.Division,AccountId FROM Opportunity WHERE Id IN :opportunityIds]
    );
    /*//07-08-2024
    Map<Id, User> users = new Map<Id, User>(
          [SELECT Id,Name,Email,ManagerId from User where Id IN :ownerIds]
      );
    //07-08-2024 
    Map<Id, String> ownerEmails = new Map<Id, String>();
    Map<Id, String> managerEmails = new Map<Id, String>();/*/
    
    // Update the OwnerId based on the criteria
    for (Operation_Request__c opr : Trigger.new) {
        if (opr.Opportunity__c != null && opportunityMap.containsKey(opr.Opportunity__c)) {
            Opportunity opp = opportunityMap.get(opr.Opportunity__c);
           // System.debug('Opportunity Map: ' + opportunityMap);

            if (opr.Operations_Type__c == 'Sales Operations') {
                if (opp.Owner.Division == 'South' || opp.Owner.Division == 'West') {
                    opr.OwnerId = salesopssw;
                    opr.User_Assigned__c = salesopssw;
                    opr.Account__c = opp.AccountId;
                } else if (opp.Owner.Division == 'North' || opp.Owner.Division == 'East') {
                    opr.OwnerId = salesopsne;
                    opr.User_Assigned__c = salesopsne;
                    opr.Account__c = opp.AccountId;
                }
            } else if (opr.Operations_Type__c == 'Data Operations') {
                if (opp.Owner.Division == 'South' || opp.Owner.Division == 'West') {
                    opr.OwnerId = dataopssw;
                    opr.User_Assigned__c = dataopssw;
                    opr.Account__c = opp.AccountId;
                } else if (opp.Owner.Division == 'North' || opp.Owner.Division == 'East') {
                    opr.OwnerId = dataopsne;
                    opr.User_Assigned__c = dataopsne;
                    opr.Account__c = opp.AccountId;
                }
            }
            /*//07-08-2024 : collecting emails for Owner and manager
            if(users.containsKey(opr.User_Assigned__c)){
                User owner = users.get(opr.User_Assigned__c);
                if(owner.Email != null){
                    ownerEmails.put(opr.id,owner.Email);
                    
                    if(owner.ManagerId != null && users.containsKey(owner.ManagerId)){
                        User manager = users.get(owner.ManagerId);
                        if(manager.Email != null){
                            managerEmails.put(opr.id,manager.Email);
                        }
                    }
                    
                }
                //07-08-2024
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            	email.setSubject('New Operations Request has been created : '+ opr.Name);
            	email.setPlainTextBody('Hi '+ owner.Name + '\n' + 'A new Operations record has been created and auto-assigned to you ' +'\n'
                                     + 'Operations Name : '+ opr.name + '\n'
                                     + 'Operations Type : '+opr.Operations_Type__c+'\n'
                                     + 'Request type : '+opr.Type_of_Request__c+'\n'
                                     + 'Requested by : ' +opr.Requestor__c + '\n\n'
                                     + 'Opportunity ID : ' +opr.Opportunity__c+'\n'
                                     + 'Account Id : '+opr.Account__c);
            
               	email.setToAddresses(new List<String>{ownerEmails.get(opr.Id)});
               

            
            if (managerEmails.containsKey(opr.Id)) {
                email.setCcAddresses(new List<String>{managerEmails.get(opr.Id)});
                
            }
            
            emails.add(email);
            }*/
             
           
        }
    }
    /*if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }*/
    
    
    

}