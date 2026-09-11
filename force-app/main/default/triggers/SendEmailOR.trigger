trigger SendEmailOR on Operation_Request__c (after insert) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for(Operation_Request__c opr : Trigger.new){
        if(opr.User_Assigned__c != null){
            User ua = [SELECT Id,Name,email,managerid from user where Id =:opr.User_Assigned__c limit 1];
            if(ua != null && ua.ManagerId != null){
                User mgr = [select id,email from user where id=:ua.ManagerId limit 1];
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new string[] {ua.Email});
                if(mgr != null && mgr.Email != null){
                    email.setCcAddresses(new String[] {mgr.Email});
                }
                email.setSubject('New Operations Request has been created : '+ opr.Name);
                
                String link = 'https://babaienterpricedevorg-dev-ed.develop.lightning.force.com/lightning/r/Operation_Request__c/'+opr.Id;
                //String body = '<a herf="'+link+'">'+link+'</a>';
                //email.setHtmlBody(body);
                
            	email.setPlainTextBody('Hi '+ ua.Name +','+ '\n\n' + 'A new Operations record has been created and assigned to you ' +'\n'
                                     + 'Operations Name : '+ opr.name + '\n'
                                     + 'Operations Type : '+opr.Operations_Type__c+'\n'
                                     + 'Request type : '+opr.Type_of_Request__c+'\n'
                                     + 'Requested by : ' +opr.Requestor__c + '\n\n'
                                     + 'Opportunity ID : ' +opr.Opportunity__c+'\n'
                                     + 'Account : '+opr.Account__C+'\n\n'
                                     + 'Access the Request from here:' + link+ '\n\n\n'
                                     + 'Best Regards, \n'+'Administration Department');
                
                emails.add(email);
                
                
            }
        }
    }
    if(!emails.isEmpty()){ 
        Messaging.sendEmail(emails);
    }
}