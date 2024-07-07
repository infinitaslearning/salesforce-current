global class MERGE_StoreDeletedRecords implements dupcheck.dc3Plugin.InterfaceMerge {

   public static Boolean deleteHandler;

   public static void HandletriggerDelete(List<sObject> sObjectList){
      System.debug('MERGE_StoreDeletedRecords - HandletriggerDelete');

      List<Id> contactIds = new List<Id>();
      List<Id> accountIds = new List<Id>();
      
      for (sObject sObj : sObjectList) {
         String objectName = findObjectNameFromPrefix(String.valueOf(sObj.Id).left(3));
         System.debug('objectName ==> ' + objectName);

         if (objectName == 'Contact') {
            contactIds.add(sObj.Id);
         } else if (objectName == 'Account') {
            accountIds.add(sObj.Id);
         }
      }

      if (contactIds.size() > 0) {
         HandleContactDelete(contactIds);
      }
      if (accountIds.size() > 0) {
         HandleAccountDelete(accountIds);
      }

   }


   global void beforeMerge(String objectPrefix, Sobject masterRecord, List < sobject > mergedRecordList) {
        
      if (findObjectNameFromPrefix(objectPrefix) == 'Contact') {
         handleMergedContact(masterRecord, mergedRecordList);
      } else if (findObjectNameFromPrefix(objectPrefix) == 'Account') {
         handleMergedAccount(masterRecord, mergedRecordList);
      }

      system.debug('**Before Merge***');
      system.debug('**Before Merge: objectPrefix***'+objectPrefix);
      system.debug('**Before Merge: masterRecord***'+masterRecord);
      
   }
 
   global void mergeFailed(String objectPrefix, Sobject masterRecord, Set < id > mergedRecordsIds, dupcheck.dc3Exception.MergeException exceptionData) {
      // YOUR CUSTOM CODE
      system.debug('**Merge Fail***');
      return;
   }
 
   global void afterMerge(String objectPrefix, Sobject masterRecord, Set < id > mergedRecordIds) {
       // YOUR CUSTOM CODE
       
       if (findObjectNameFromPrefix(objectPrefix) == 'Contact') {
           //DO NOTHING
       } else if (findObjectNameFromPrefix(objectPrefix) == 'Account') {
           //clear the MergeToRecordId__c field value on Account
           postMergeAccountUpdates(masterRecord);
           //delete Account Subsidiary records creatred by merging Accounts
           handleAfterAccountSubsidiaryMerge(masterRecord);
       }
       
       system.debug('**After Merge***');
       system.debug('**After Merge objectPrefix*** ' + objectPrefix);
       system.debug('**After Merge masterRecord*** ' + masterRecord);
       system.debug('**After Merge mergedRecordIds*** ' + mergedRecordIds);
       return;
   }


// ############################## CONTACT METHODS ##############################

   // ON DELETE
   public static void HandleContactDelete(List<Id> contactIds){

      List<Contact> contacts = [SELECT Id, MasterRecordId, OperatingCompany__c FROM Contact WHERE Id IN :contactIds ALL ROWS];

      List<DeletedContact__c> lstDeletedContact = new List<DeletedContact__c>();

      system.debug('**Before Merge: Handletrigger***');
      System.debug('contacts.size() ==> ' + contacts.size());

      for (Contact con : contacts) {

         // Check if the delete is from a merge
         System.debug('con.MasterRecordId ==> ' + con.MasterRecordId);
         if (con.MasterRecordId == null) {
            DeletedContact__c  del = new DeletedContact__c();
            del.DeletedContactId__c = con.id;
            //del.MergedContactId__c = con.MasterRecordId;
            del.OperatingCompany__c = con.OperatingCompany__c;
            del.Type__c = 'Deleted';
            lstDeletedContact.add(del);
         }
      }

      System.debug('lstDeletedContact.size() ==> ' + lstDeletedContact.size());

      if(lstDeletedContact.size() > 0) { 
         try{
            insert lstDeletedContact;
         }  
         catch(exception e){
            System.debug('ERROR: ' + e.getMessage());
            HandleCustomException.LogException(e);
         }
      }
   }

   // ON MERGE
   public static void handleMergedContact(sObject masterRecord, List<SObject> contacts) {
      List<DeletedContact__c> lstDeletedContact = new List<DeletedContact__c>();

      Set<String> Set_ConId = new Set<String>();
      for(sobject obj:contacts){
         Set_ConId.Add(obj.id);
         system.debug('**Before Merge: masterRecord***'+obj.id);
      } 

      Contact[] lstContact = [Select OperatingCompany__c,MasterRecordId from Contact where id in: Set_ConId ]; 
      for(Contact con:lstContact){

         DeletedContact__c  del = new DeletedContact__c();
         del.DeletedContactId__c = con.id;
         del.MergedContactId__c = masterRecord.Id;
         if(con.OperatingCompany__c == null){
            del.OperatingCompany__c = 'Plantyn';
            del.Notes__c = 'Opco missing: Value for save = Plantyn';
         }
         else{
            del.OperatingCompany__c = con.OperatingCompany__c;
         }
         
         del.Type__c = 'Merged';
         lstDeletedContact.add(del);
      }
   
      try{
         insert lstDeletedContact;
      }
      catch(exception e){
         system.debug('**ERROR***'+e.getmessage());
         HandleCustomException.LogException(e);
      }   
      /*
      for(sobject obj:mergedRecordList){
         system.debug('**Before Merge: masterRecord***'+obj.id);
      }
      */
      return;
   }

// ############################## ACCOUNT METHODS ##############################

   // ON DELETE
   public static void HandleAccountDelete(List<Id> accountIds){
   
      List<Account> accounts = [SELECT Id, MasterRecordId, OperatingCompany__c FROM Account WHERE Id IN :accountIds ALL ROWS];

      List<DeletedAccount__c> deletedAccountLst = new List<DeletedAccount__c>();

      system.debug('**Before Merge: Handletrigger***');

      for (Account acc : accounts) {

         // Check if the delete is from a merge
         if (acc.MasterRecordId == null) {
            DeletedAccount__c  del = new DeletedAccount__c();
            del.DeletedAccountId__c = acc.id;
            del.OperatingCompany__c = acc.OperatingCompany__c;
            del.Type__c = 'Deleted';
            deletedAccountLst.add(del);
         }
      }

      if(deletedAccountLst.size() > 0){ 
         try{
            insert deletedAccountLst;
         } 
         catch(exception e){
            system.debug('**ERROR***' + e.getmessage());
            HandleCustomException.LogException(e);
         }
      }
   }

   // ON MERGE
   public static void handleMergedAccount(sObject masterRecord, List<SObject> accounts) {
      deleteHandler = true;

      List<DeletedAccount__c> deletedAccountLst = new List<DeletedAccount__c>();

      Set<String> Set_AccId = new Set<String>();
      for (sobject obj : accounts) {
         Set_AccId.Add(obj.id);
         system.debug('**Before Merge: masterRecord***' + obj.id);
      } 

      List<Account> lstAccount = [SELECT OperatingCompany__c,MasterRecordId FROM Account WHERE id IN :Set_AccId]; 
      
      for (Account acc : lstAccount) {

         DeletedAccount__c del = new DeletedAccount__c();
         del.DeletedAccountId__c = acc.id;
         del.MergedAccountId__c = masterRecord.Id;
         
         if (acc.OperatingCompany__c == null) {
            del.OperatingCompany__c = 'Plantyn';
            del.Notes__c = 'Opco missing: Value for save = Plantyn';
         }
         else {
            del.OperatingCompany__c = acc.OperatingCompany__c;
         }
         
         del.Type__c = 'Merged';
         deletedAccountLst.add(del);
      }
   
      try{
         insert deletedAccountLst;
      }
      catch (exception e) {
         HandleCustomException.LogException(e);
         system.debug('**ERROR***' + e.getmessage());
      }   

      return;
   }


   // GET OBJECTNAME FROM PREFIX
   public static String findObjectNameFromPrefix(String objectPrefix){
      String objectName = '';
      try{
          //Get schema information
          Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
           
          //Loop through all the sObject types returned by Schema
          for(Schema.SObjectType stype : gd.values()){

              Schema.DescribeSObjectResult r = stype.getDescribe();
              String prefix = r.getKeyPrefix();
               
              //Check if the prefix matches with requested prefix
              if(prefix!=null && prefix.equals(objectPrefix)){
                  objectName = r.getName();
                  System.debug('Object Name is ' + objectName);
                  break;
              }
          }
      }catch(Exception e){
          System.debug(e);
      }
      return objectName;
  }
    
   //POST ACCOUNT MERGE UPDATES ON MASTER ACCOUNT
    public static void postMergeAccountUpdates(Sobject masterRecord){
        Account masterAccount = [SELECT Id, MergeToRecordId__c  FROM Account WHERE Id =: masterRecord.Id];
        if(String.isNotBlank(masterAccount.MergeToRecordId__c)){
            masterAccount.MergeToRecordId__c = '';
            try{
                update masterAccount;
                System.debug('postMergeAccountUpdates masterAccount Id: ' + masterAccount.Id);
            }  
            catch(exception e){
                System.debug('ERROR: ' + e.getMessage());
                HandleCustomException.LogException(e);
            }
        }
    }

    //DELETE DUPLICATED AccountSubsidiary__c RECORDS AFTYER MERGE IS COMPLETED
    public static void handleAfterAccountSubsidiaryMerge(sObject masterRecord){
      Account masterAccount = [SELECT Id, Account_Subsidiary__c  FROM Account WHERE Id =: masterRecord.Id];
      System.debug('##handleAfterAccountSubsidiaryMerge Master Account: ' + masterAccount.Id + '. ' +  masterAccount.Account_Subsidiary__c);

      List<AccountSubsidiary__c> masterAccountSubsidiaryDeleteList = [SELECT Id, Name, IsInactive__c FROM AccountSubsidiary__c WHERE Account__c =: masterAccount.Id AND Id !=: masterAccount.Account_Subsidiary__c];
      System.debug('##handleAfterAccountSubsidiaryMerge masterAccountSubsidiaryDeleteList: ' + masterAccountSubsidiaryDeleteList.size());
      
      for(AccountSubsidiary__c subsidiary : masterAccountSubsidiaryDeleteList){
         System.debug('##handleAfterAccountSubsidiaryMerge  subsidiary to be set as Pending Inactive: ' + subsidiary.Name);
         subsidiary.IsInactive__c = true;
     }
      try{
         update masterAccountSubsidiaryDeleteList;
         Set<String> Set_Accid = new Set<String>();
         Set_Accid.add(masterRecord.Id);

         Order_BatchUpdateOrdersOnMerge  OrdersOnMerge = new Order_BatchUpdateOrdersOnMerge(Set_Accid);
         database.executebatch(OrdersOnMerge ,1);
      }  
      catch(Exception e){
         System.debug('##ERROR: ' + e.getMessage());
         HandleCustomException.LogException(e);
      }
    }

}