public class MDF_Book_Type_Controller {
	 @AuraEnabled
    public static List<Map<String,String>> getBookTypePicklist() {
        
        List<Map<String,String>> options = new List<Map<String,String>>();
        
        // Getting picklist values from Book_type__c field
        // Replace 'Book__c' with your actual Object Name
        Schema.DescribeFieldResult fieldResult = 
            Book__c.Book_Type__c.getDescribe();
            
        List<Schema.PicklistEntry> picklistValues = 
            fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry entry : picklistValues) {
            if(entry.isActive()) {
                Map<String,String> option = new Map<String,String>();
                option.put('label', entry.getLabel());
                option.put('value', entry.getValue());
                options.add(option);
            }
        }
        
        return options;
    }
}