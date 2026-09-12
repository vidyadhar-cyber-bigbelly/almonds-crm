public class DemoSObject {
    public void demoSObjectVariableMethod(){
        //creating Standard object variable and printing
        Account acc=new Account(name = 'Ram', phone = '12345');
        System.debug('acc: '+acc);
     	//creating custom object variable 
     	House__c h = new House__c();
        h.name = 'Krishna';
        h.City__c = 'Dwaraka';
		System.debug(h);
		//creating one generic object variable, assign an instance of object and type casting it into specific sObject 
		sObject obj;
        obj = new Contact(FirstName = 'Hanu', LastName = 'Man');
        Contact c= (Contact)obj;
        System.debug(c);
        
    }
    public void demoCollectionLoop(){
        List<Account> accList = [Select id,name from Account limit 2];
        Set<Id> idSet = new Set<id>();
        
        //iterating the list
        if(!accList.isEmpty()){
            for(Account acc : accList){
            idSet.add(acc.id);
        }
        }
        System.debug(accList);
        System.debug(idSet);
        
        //iterating the map
        Map<Id, Account> accMap = new Map<Id, Account>([Select id,name from Account limit 2]);
		
        System.debug(accMap);
    }
        
}