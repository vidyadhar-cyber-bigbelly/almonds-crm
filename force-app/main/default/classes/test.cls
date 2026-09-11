/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : test
 * Author          : <YourName>
 * Created Date    : Aug 31, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Aug 31, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Aug 31, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class test {

	@AuraEnabled(cacheable=true)
	public static List<opportunity> getdata() {
    return [SELECT Id,Name from opportunity LIMIT 5];
	
	}
	@AuraEnabled(cacheable=true)
	public static List<Regional_Delivery_Est__mdt> getAllDeliveryConfig(){
    return [SELECT DeveloperName,Country__c,Courier__c,Estimated_days__c from Regional_Delivery_Est__mdt];
	}

}