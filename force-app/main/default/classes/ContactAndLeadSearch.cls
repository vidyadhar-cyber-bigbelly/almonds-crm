public class ContactAndLeadSearch {
	public static List<List<sObject>> searchContactsAndLeads(String lName){
        List<List<sObject>> searchVal= [Find :lName in all fields returning Contact(FirstName, LastName), Lead(FirstName,LastName)];
        return searchVal;
}
}