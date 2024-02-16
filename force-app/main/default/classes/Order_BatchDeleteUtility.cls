global with sharing class Order_BatchDeleteUtility implements Database.Batchable<sObject>,Schedulable {
    global Order_BatchDeleteUtility() {

    }
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
    // return Database.getQueryLocator([SELECT Id,IntegrationFactorySend__c  FROM Contact ]  ); // WHERE ACCOUNT HAS ACTIVE ASSET
   
        return Database.getQueryLocator([SELECT Id  FROM SummaryofObjectsCleaned__c where ObjectAPIName__c= 'ErrorLog__c']  ); // WHERE ACCOUNT HAS ACTIVE ASSET where createddate <: system.today()-15
    }
    
    global void execute(Database.BatchableContext BC, List<SummaryofObjectsCleaned__c> scope){
       

        delete scope;
                    
    }
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext sc)
    {
        Order_BatchDeleteUtility  DeleteUtility = new Order_BatchDeleteUtility();
        database.executebatch(DeleteUtility ,500);
    }

}