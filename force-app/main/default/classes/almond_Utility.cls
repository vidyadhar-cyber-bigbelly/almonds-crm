public  without sharing class almond_Utility {
    @AuraEnabled(cacheable=true)
    public static List<PermSetDTO> getOwnerPermissionSets(Id recordId) {
  
        Id ownerId = [ SELECT OwnerId FROM User_Information__c WHERE Id = :recordId LIMIT 1].OwnerId;
        
        List<PermissionSetAssignment> psaList = [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment
            WHERE AssigneeId = :ownerId AND PermissionSet.Profile.name = '' limit 100];
        
        List<PermSetDTO> result = new List<PermSetDTO>();
        
        for (PermissionSetAssignment psa : psaList) {
            result.add(
                new PermSetDTO(
                    psa.PermissionSet.Name,
                    psa.PermissionSet.Label,
                    psaList.size()
                )
            );
        }
        return result;
    }
    
    public class PermSetDTO {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public integer pscount;
        
        public PermSetDTO(String name, String label, integer pscount) {
            this.name = name;
            this.label = label;
            this.pscount = pscount;
        }
    }
}