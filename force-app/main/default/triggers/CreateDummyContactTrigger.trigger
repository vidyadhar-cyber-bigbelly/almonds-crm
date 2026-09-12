trigger CreateDummyContactTrigger on Account (after insert) {
    List<Contact> contactList=new List<Contact>();
    for(Account acc:Trigger.new){
        Contact con=new Contact();
        con.LastName = acc.name;
        con.FirstName = 'Dummy';
        con.AccountId = acc.Id;
        con.MailingState = acc.BillingState;
        con.MailingCity = acc.BillingCity;
        contactList.add(con);      
    }
    insert contactList;
}