@RestResource(urlMapping = '/api/v1/opportunities/')
global without sharing class RestApi_Opportunitymgmt {
	@HttpPost
    global static String doPost(List<Opportunity> opp){
        Set<id> accids = new Set<id>();
        for(Opportunity oppty : opp){
            accids.add(oppty.AccountId);
        }
        List<Account> acc = [Select id from Account where id =:accids];
        if(!acc.isEmpty()){
            try{
                Database.insert(opp);
                return 'Opportunity Successfully Inserted';
            }catch(Exception e){
                return e.getMessage();
            }
        }
        else
        {
            return 'Invalid Account';
        }
    }
    @HttpGet
    global static List<opportunity> doGet(){
        Map<String,String> paramsMap = RestContext.Request.params;
        String oppid = paramsMap.get('oppId');
        List<Opportunity> opp = [Select id,name,StageName,CloseDate,Account.Name from Opportunity order by createddate desc limit 5 ];
        return opp;
    }
}