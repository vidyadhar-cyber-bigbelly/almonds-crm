public class OpportunityHandler {

    public static void afterInsert(List<Opportunity> newOpps){
        set<Id> accountIds = new set<Id>();
        for(Opportunity opp :newOpps  ){
            if(opp.AccountId != null){
                accountIds.add(opp.AccountId);
                system.debug('accountIds'+accountIds);
            }
            
        }
    
         Map<Id, Decimal> accountTotals = new Map<Id, Decimal>();
        for(AggregateResult a:[Select AccountId, SUM(Amount)totalAmount from Opportunity 
                               where StageName ='Qualify' AND AccountId IN :accountIds GROUP BY AccountId ]){
                                  
          accountTotals.put(
              (Id)a.get('AccountId'),
         (Decimal)a.get('totalAmount'));
    System.debug('AccountId = ' + a.get('AccountId'));
    System.debug('Total = ' + a.get('totalAmount'));
            
     
    }
        system.debug('accountTotals'+accountTotals);
    List<Account>accsToUpdate = new List<Account>();
    for(Account acc :[Select Id,Status__c,Total_Closed_Won_Amount__c from Account WHERE Id in :accountIds ]){
        Decimal Total = accountTotals.containsKey(acc.Id)?accountTotals.get(acc.Id): 0 ;
        string status =statusCheck(Total);
        if(acc.Status__c !=status || acc.Total_Closed_Won_Amount__c != Total ){
            acc.Status__c = status;
            acc.Total_Closed_Won_Amount__c = Total;
            accsToUpdate.add(acc);
            
        }
        
    }
        system.debug('accsToUpdate'+accsToUpdate);
        if(!accsToUpdate.isEmpty()){
            update accsToUpdate;
        }
       
    }
     private static string statusCheck(Decimal amount){
         string status ;
         if(amount < 1000){
             status = 'Bronze';
         }
         if(amount > 1000){
             status = 'Gold';
         }
            return status;
        } 
}