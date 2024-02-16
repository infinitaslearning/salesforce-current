Global class  Batch_update implements Database.Batchable<sObject>,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        // Date DateStart = Date.newInstance(2021,9,5);

        return Database.getQueryLocator([Select id, IntegrationFactorySend__c from Account]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
           
        for(Account acc:scope){
               acc.IntegrationFactorySend__c=true;
        }
        update scope;
        
        
        //  delete scope;
       
    }
    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext sc)
    {
        Batch_update  dailyupdate = new Batch_update();
        database.executebatch(dailyupdate ,1);
    }
    
}