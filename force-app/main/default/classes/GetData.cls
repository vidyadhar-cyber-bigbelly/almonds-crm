/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : GetData
 * Author          : <YourName>
 * Created Date    : May 24, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 24, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 24, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 **/

public class GetData {

	@AuraEnabled(cacheable=true)
	public static List <Contact> getContacts() {
		return [SELECT Id,Name,Email,Phone,Account.Name,Title,AccountId   FROM Contact ORDER BY Name LIMIT 5 ];
		
	}

	@AuraEnabled(cacheable=true)
	public static List <Account> getAccounts(string searchTerm) {
		string query ='%'+ searchTerm +'%';
		return [SELECT Id,Name  FROM Account where Name LIKE :query ORDER BY Name LIMIT 5 ];
		
	}
  
  @AuraEnabled()
  public static void updateContacts(list<contact> contacts){
	try{
	System.debug(contacts + 'contacts');
	update contacts;
	}
	catch(DmlException e){
		throw new AuraHandledException(e.getMessage());
	}
  }
}