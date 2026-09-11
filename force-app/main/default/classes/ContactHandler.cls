public class ContactHandler {
    public static void Contactdescrption(List<Contact> con, Map<Id,Contact> oldMap){
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact c : con){
            if(!string.isBlank(c.Title) && c.Title != oldMap.get(c.Id).Title){
                c.Description = 'Title changed to ' + c.Title + ' on ' + Date.today().format();
                 contactsToUpdate.add(c);
                
            }
            if(string.isBlank(c.Title) && c.Title != oldMap.get(c.Id).Title){
                c.Title.addError('Title cannot be blank');
            }
           
        }
       system.debug('contactsToUpdate'+contactsToUpdate);
    }

}