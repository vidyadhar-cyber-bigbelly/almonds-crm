/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : account_data
 * Author          : <YourName>
 * Created Date    : Jul 9, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Jul 9, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jul 9, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class account_data {

	@AuraEnabled(cacheable=true)
	public static List <Account> getAccountrecords(){
		return [SELECT Id,Name,Industry,Phone,AccountNumber,ALMD_Compliance__c from Account LIMIT 10];

		}
	

}