Global class  Batch_DeleteUtility2 implements Database.Batchable<sObject>,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        // Date DateStart = Date.newInstance(2021,9,5);

        return Database.getQueryLocator([Select id from Account ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        /*    
        for(Order ord:scope){
            ord.Status ='Draft';
        }
        update scope;
        */
        
          delete scope;
       
    }
    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext sc)
    {
        Batch_DeleteUtility2  DailyDelete = new Batch_DeleteUtility2();
        database.executebatch(DailyDelete ,200);
    }
    
}