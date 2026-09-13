public class CreateContacts {
    public class input{
       @InvocableVariable(required=true)
       public string firstName ;
       @InvocableVariable(required=true)
       public string lastName;
    }
    public class output{
        @InvocableVariable
       public string message;
        @InvocableVariable
       public string id ;
    }
    
    @InvocableMethod(label='create contacts')
    public static List<output> createContacts (List<input> request){
        List<output> result = new List<output>();
        
       list<Contact> contactsToInsert = new list<Contact>();
        
      
        for (input req :request){
            Contact con = new Contact();
            con.FirstName= req.firstName;
            con.LastName = req.lastName;
            contactsToInsert.add(con);
        }
        insert contactsToInsert;
        for (Contact cont:contactsToInsert ){
            output res = new output();
            res.id = cont.Id;
            res.message = 'Contact created succesfully';
            result.add(res);
            
        }
        return result ;
    }

}