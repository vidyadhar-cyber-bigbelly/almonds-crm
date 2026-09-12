public class ContactSearch {
    public static Contact[] searchForContacts(String lastName, String mailingPostalCode){
        List<Contact> con=[SELECT Id, Name FROM Contact WHERE LastName=:lastName AND MailingPostalCode=:mailingPostalCode];
       	
        return con;
    }
}