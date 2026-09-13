public class AccountControllerClass {
	
	// user enters the value at child html -> child JS create custom event to pass the value -> parent html will receive the event -> parent JS will receive the user entered value -> pass this value to apex parameter -> apex will write SOQL query to fetch the records, whose name contains the searched string, from DB -> pass it to parent JS wire property -> parent JS will pass data to parent HTML to display the records in the table.
	// cacheable=true: in parent JS we are using 'wire property' to fetch the data.
	// JS -> user enterd string -> Apex -> Parameter type String
	// Apex -> JS -> return List of accounts
	// String res = '%' + SearchVal + '%'; => If SearchVal='oil' -> res='%oil%' 
	// Name LIKE 'value'
	// Name LIKE :variable  -> res is a variable, so use it with bind(:) operator.

	@AuraEnabled(cacheable=true)
	public static List<Account> fetchSearchedAccounts(String SearchVal) {
		String res = '%' + SearchVal + '%';
		return [SELECT Name, Type FROM Account WHERE Name LIKE :res];
	}

	// Pattern matching: 'LIKE' Clause
	// '%a' -> string ends with 'a'
	// 'a%' -> string starts with 'a'
	// '%a%' -> string contains 'a'
}