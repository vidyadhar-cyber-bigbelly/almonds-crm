/**
 * @description This class contains the apex logics used for UI renders/data on components.
 * @author      Jaswanth Varma
 * @date        2026-07-13
 * Note			Do not change API version to 67.
 */
public with sharing class AccountController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){
        return[SELECT Name, Industry, Phone from Account LIMIT 10];
    }
    
    /**
     * @description		This method is used for showing the account mananger PS related warning on account flexipage.
     * @author			Vidyadhar	
     */
    @AuraEnabled(cacheable=true)
    public static Boolean accountManagerCheck(Id accountId){
        if (accountId == null) {
            return false;
        }
        
        Account acc = [select ownerId from account	where id= :accountId limit 1];
        
        list<PermissionSetAssignment> psaList = [select id from PermissionSetAssignment where AssigneeId = :acc.OwnerId
            AND PermissionSet.Name = 'ALMD_Account_Manager'];
        
        return !psaList.isEmpty();
    }
}