public class OpportunityControllerClass {

	// FETCH : DB -> (SOQL) -> Apex -> (Wire/Imperative) -> JS -> HTML -> UI
	// @AuraEnabled: to make apex class method accessible to JS -> MUST 
	// Apex -> JS => return 
	// JS -> Apex => parameter
	// we are passing list of opportunity records to JS

	// Wire Service -> MUST Required -> cacheable=true -> to catch the data
	// ******* FETCH ALL OPPORTUNITITES -> WIRE/IMPERATIVE ***************
	@AuraEnabled(cacheable=true)
	public static List<Opportunity> fetchAllOpp() {
		// Integer res = 1/0;   // to show the error part
		return [SELECT Name, StageName, CloseDate, Amount FROM Opportunity];
	}

	// ******* FETCH 'CLOSED WON' OPPORTUNITITES -> IMPERATIVE ***************
	@AuraEnabled()
	public static List<Opportunity> fetchWonOpp() {
		return [SELECT Name, StageName, CloseDate, Amount FROM Opportunity WHERE StageName='Closed Won'];
	}

	// ******* FETCH 'CLOSED LOST' OPPORTUNITITES -> IMPERATIVE ***************
	@AuraEnabled()
	public static List<Opportunity> fetchLostOpp() {
		return [SELECT Name, StageName, CloseDate, Amount FROM Opportunity WHERE StageName='Closed Lost'];
	}

	// Delete Operation(DML): user select record to delete in the UI -> JS will fetch the record Id of the selected record -> pass Id to Apex via parameter -> fetch the user selected record from DB, checks the condition and perform deletion.
	
	// ******* DELETE OPPORTUNITY -> IMPERATIVE ***************
	// oppId: received from JS, stores the record Id of the selected row's record.
	// WHERE Id = value  
	// WHERE Id = :variable -> 'oppId' is a variable (WHERE Id = :oppId) -> must use bind operator(':')
	@AuraEnabled()
	public static void deleteOpp(Id oppId) {
		Opportunity oppRec = [SELECT Name, StageName, CloseDate, Amount FROM Opportunity WHERE Id = :oppId];
		if(oppRec.StageName!='Closed Won'){
			delete oppRec;
		}
		else{
			throw new AuraHandledException('Closed Won Opportunitites cannot be deleted!');
		}
	}

}