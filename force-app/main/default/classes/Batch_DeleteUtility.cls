Global class  Batch_DeleteUtility implements Database.Batchable<sObject>,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        // Date DateStart = Date.newInstance(2021,9,5);

        return Database.getQueryLocator([SELECT Id,Billto__c  FROM Order where ActivateforBatchProcessing__c =:true AND  Status !=: 'Activated']);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope){
        
            
        for(Order ord:scope){
            ord.ActivateforBatchProcessing__c = false;
        }
        update scope;
        
        
        //  delete scope;
       
    }
    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext sc)
    {
        Batch_DeleteUtility  DailyDelete = new Batch_DeleteUtility();
        database.executebatch(DailyDelete ,10);
    }
    
}