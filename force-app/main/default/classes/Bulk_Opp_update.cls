/**
* @File Name : Bulk_Opp_update.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : December 17, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 17, 2025 |   | Initial Version
**/

public class Bulk_Opp_update {
	@AuraEnabled
	public static List<Opportunity> getOpportunities(){
		List<Opportunity> Opp =[SELECT Id,Name,CloseDate,Amount,Risk__c FROM Opportunity where CloseDate < TODAY ];
		System.debug( +Opp);
		return Opp;

	}
}