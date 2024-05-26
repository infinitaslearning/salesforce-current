Global class  Batch_DeleteUtility implements Database.Batchable<sObject>,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
         Date DateStart = Date.newInstance(2022,3,8);
//  
//return Database.getQueryLocator([SELECT Id,Billto__c  FROM Order where ActivateforBatchProcessing__c =:true AND Status !=: 'Activated']);
        return Database.getQueryLocator([SELECT Id,lastmodifieddate from    ImportOrder__c where createddate <: DateStart]);
    }
    
    global void execute(Database.BatchableContext BC, List< ImportOrder__c> scope){
       delete scope;
      
     /*  
      Set<String> Set_Acc = new Set<String>(); 
      
      for(Order ord: Scope){
       ord.ActivateforBatchProcessing__c =false;  
      }
      */ 
   //   update Scope;
      
    //  Contact[] lstCOntact = [Select id from Contact where AccountId in: Set_Acc]; 
       
       
   //   delete lstCOntact;
       
  //    AccountContactRelation[] lstAccountContact = [Select id from AccountContactRelation where AccountId in: Set_Acc];
       
     //  update scope;
     //  delete lstAccountContact;
   //    */
       
       
       
    }
    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext sc)
    {
        Batch_DeleteUtility  DailyDelete = new Batch_DeleteUtility();
        database.executebatch(DailyDelete ,100);
    }
    
}