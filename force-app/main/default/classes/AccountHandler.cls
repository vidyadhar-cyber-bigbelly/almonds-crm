/**
 * @description This class contains the code that handles DMLs on account object
 * @author      Vishal Goud
 * @date        2026-07-27
 * Note			Do not change API version to 67.
 */
public class AccountHandler {
    
    public static void validation(list<Account> acc){
        
        if(!acc.isEmpty()){
            for(Account a :acc){
                
                if(string.isBlank(a.AccountNumber)){
                    a.AccountNumber.addError('Account Number iyara erri flower');
                }
                
            }
            
        }
        
    }
 
}