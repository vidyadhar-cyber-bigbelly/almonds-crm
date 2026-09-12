@RestResource(urlMapping = '/accountmgmt/')
global class RestApi_Accountmgmt{
    //method will get the Account records which are created with name as Post and based on Industry
    @HttpGet
    global static AccountWrapper getPostAccounts(){
        Map<String,String> paramsMap =  RestContext.request.params;
        String accIndustry = paramsMap.get('Industry');
        Set<Id> accid = new Set<Id>();
        List<Account> acclst= [Select id,name,Industry from Account where Created_from_Postman__c = true and Industry =: accIndustry];
        for(Account acc : acclst){
            accid.Add(acc.id);
		}
        List<Contact> conList = [Select id,firstname,lastname from Contact where accountid =:accid];
        List<Case> caseList = [select id,CaseNumber,ClosedDate from Case where AccountId =: accid];
        List<Opportunity> oppList = [select id,Name,Owner.Name,StageName,CloseDate from Opportunity where AccountId =: accid];
        AccountWrapper accWrapper = new AccountWrapper();
        accWrapper.accList = acclst;
        accWrapper.conList = conList;
        accWrapper.caseList = caseList;
        accWrapper.oppList = oppList;
        return accWrapper;
    }
    
    //this method will create the Account records from postman
    @HttpPost
    /*global static String createAcc(String accName, String accIndustry, String accRating){
        Account acc = new Account();
        acc.Name = accName;
        acc.Industry = accIndustry;
        acc.Rating = accRating;
        acc.Created_from_Postman__c = true;
        try{
            Database.Insert(acc);
            return 'Account created succssfully';
        }catch(Exception e){
            return e.getMessage();
        }
    }*/
    global static String createAccount(AccountInformationWrapper accInformation){
        Account accRecord = accInformation.accRecord;
        accRecord.Created_from_Postman__c = true;
        Contact conRecord = accInformation.conRecord;
        Opportunity oppRecord = accInformation.oppRecord;
        try{
            Database.insert(accRecord);
            conRecord.accountId = accRecord.id;
            Database.insert(conRecord);
            oppRecord.accountId = accRecord.id;
            Database.insert(oppRecord);
            return 'Successfully Inserted';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    //this method will delete the account records based on the id given by the user
    @HttpDelete
    global static string deleteAccount(){
        Map<String, String> paramsMap = RestContext.request.params;
        String accountId = paramsMap.get('accId');
        List<Account> accids = [Select id from Account where id =:accountId];
        if(!accids.isEmpty()){
            try{
                Database.delete(accids);
                return 'Account Deleted Successfully';
            }catch(Exception e){
                return e.getMessage();
            }
        }else{
            return 'No Account found.';
        }
    }
        
    global class AccountInformationWrapper{
    	global Account accRecord {get;set;}
        global Contact conRecord {get;set;}
        global Opportunity oppRecord {get;set;}
    }
        
    global class AccountWrapper{
        global List<Account> accList;
        global List<Contact> conList;
        global List<Case> caseList;
        global List<Opportunity> oppList;
    }
}