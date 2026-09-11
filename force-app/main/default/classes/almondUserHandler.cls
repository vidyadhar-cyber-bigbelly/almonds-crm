public without sharing class almondUserHandler {

    @AuraEnabled(cacheable=true)
    public static Map<String, List<User>> getUsersByProfile() {
        Map<String, List<User>> usersToShow = new Map<String, List<User>>();
        
		List<profile>profilId = [select Id,UserLicenseId from Profile where UserLicenseId  in (select Id from UserLicense where name ='Salesforce')];
        List<User> users = [select Id, Name, Profile.Name, IsActive,Type_V__c,Department,Region_V__c from User where Type_V__c ='Almond User' and profileId in :profilId];
   		

        List<User> admins = new List<User>();
        List<User> activeUsers = new List<User>();
        List<User> inactiveUsers = new List<User>();
        

        for (User userr : users) {
            if (userr.Profile.Name == 'System Administrator' || userr.Profile.Name == 'Super Admin' ) {
                admins.add(userr);
            } else if (userr.IsActive) {
                activeUsers.add(userr);
            } else {
                inactiveUsers.add(userr);
            }
        }

        usersToShow.put('Admins', admins);
        usersToShow.put('Active', activeUsers);
        usersToShow.put('Inactive', inactiveUsers);
        system.debug(usersToShow.get('Admins'));
        return usersToShow;
    }

    @AuraEnabled
    public static void updateUserActivation(List<Id> userIds, Boolean setActive) {
        if (userIds == null || userIds.isEmpty()) return;

        List<User> usersToUpdate = [select Id, IsActive from User where Id IN :userIds];

        for (User userrr : usersToUpdate) {
            userrr.IsActive = setActive;
        }
        try{
            update usersToUpdate;
        }
        catch(DmlException e){
            throw new AuraHandledException('Type: ' + e.getDmlType(0) + ' | Message: ' + e.getMessage());
        }    
    }
    
    @future
    public static void userInformationInsert( Set<Id> userIds ){
        
        List<User_Information__c> userInformationToUpdate = new List<User_Information__c>();
        List<User_Information__c> userInformationToInsert = new List<User_Information__c>();
        List<User_Information__c> userInformationEdit = new List<User_Information__c>();
        Map<String,Id> userIdNameMap = new Map<String,Id> ();
        set<Id> insertedUiIds = new set<Id>();

        List<String> userNames = new List<String>();
        Set<Id> userId = new Set<Id> ();
        //system.debug(newList);
        
        List<User> newList = [SELECT Id, Name,username FROM User WHERE Id IN :userIds];
        List<Id> userIdList = new List<Id>(userIds);
        
        for(User userr: newList){
            userNames.add(userr.Name);
            userId.add(userr.Id);
            
            User_information__c uinf = new User_information__C ();
            uinf.Name = userr.name;
            userInformationToInsert.add(uinf);
            
        }
        
        try{
            insert userInformationToInsert;
        }
        catch(DmlException e){
            
        }
        //insert userInformationToInsert;
        for(User_Information__c userInfoRecords :userInformationToInsert){
            insertedUiIds.add(userInfoRecords.Id);
        }
        
        userInformationEdit = [select id,Name,User_Name_J__c from User_Information__c where id=:insertedUiIds];
 
        for (Integer i = 0;i < userInformationEdit.size(); i++){
            system.debug(userInformationEdit[i]);
            system.debug(UserInformationEdit.size()+' '+userIdList.size());
            if(userInformationEdit.size() == userIdList.size()){
                system.debug('96');
                userInformationEdit[i].OwnerId = userIdList[i];
                userInformationToUpdate.add(userInformationEdit[i]);
            }
        }
        try{
            update userInformationToUpdate;
        }
        catch(DmlException e){
            
        }
        
    }
 
    public static void userInformationUpdate(Map<Id,User>oldMap , List<User> newList){
        set<Id> userIds = new Set<Id> ();
        set<Id> userIdForDelete = new Set<Id> ();
        set<Id> userIdForInsert = new Set<Id> ();
        
        set<Id> userInfoIdForDelete = new Set<Id> ();
      
        List<User> correctUsers = new List<User> ();
        List<User> ownerUiDelete = new List<User> ();
        List<User> ownerUiInsert = new List<User> ();
        
        List<User_information__C> userInfoToDelete = new List<User_information__C>();
        List<User_information__C> userInfoToInsert = new List<User_information__C>();
        
        
        for(User userr : newList){
            User oldUser = oldMap.get(userr.Id);
            if(userr.IsActive != oldUser.IsActive){
                userIds.add(userr.Id);
                correctUsers.add(userr);
                
                if(userr.IsActive == false){
                    ownerUiDelete.add(userr);
                    userIdForDelete.add(userr.Id);
                }
                if(userr.IsActive == true){
                    ownerUiInsert.add(userr);
                    userIdForInsert.add(userr.Id);
                }
            }
        }
        if(userIdForDelete.size() > 0){
           userInfoToDelete = [select id from User_information__C where ownerId =:userIdForDelete];
        }
        if(userIdForInsert.size() > 0){
            userInfoToInsert = [select id from User_information__C where ownerId =:userIdForInsert];
        }
        //List<User_information__C> userInfoToDelete = [select id,name from User_information__C where ownerId =:userIdForDelete];
        //List<User_information__C> userInfoToInsert = [select id,name from User_information__C where ownerId =:userIdForInsert];
        
        system.debug('userInfoToInsert --- '+userInfoToInsert.size()+' '+userInfoToInsert+' '+userInfoToInsert == null);
        system.debug('userInfoToDelete --- '+userInfoToDelete.size()+' '+userInfoToDelete+' '+userInfoToDelete != null);
        if(userInfoToDelete.size() > 0){
            system.debug('entered 156');
            for(user_information__c userInfo :userInfoToDelete){
                userInfoIdForDelete.add(userInfo.id);
            }
            userInformationDelete(userInfoIdForDelete);
            /*try{
                delete userInfoToDelete;
            }
            catch(DmlException e){
                
            }*/
        }
        if(userInfoToInsert.size() == 0){
            system.debug('entered 168');
                userInformationInsert(userIdForInsert);
        }
        
    }
    
    @future
    public static void userInformationDelete(Set<Id> userInfoDeleteIds ){
        List<User_information__C> userInfoToDelete = [select id,name from User_information__C where Id =:userInfoDeleteIds];
        if(userInfoToDelete != null && userInfoToDelete.size() > 0){
            try{
                delete userInfoToDelete;
            }
            catch(DmlException e){
                
            }
        }
        
    }
}