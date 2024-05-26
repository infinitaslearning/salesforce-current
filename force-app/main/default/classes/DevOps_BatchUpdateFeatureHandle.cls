global with sharing class DevOps_BatchUpdateFeatureHandle implements Database.Batchable<sObject>,Schedulable {
    global DevOps_BatchUpdateFeatureHandle() {
    }
    global Database.QueryLocator start(Database.BatchableContext BC){         
        return Database.getQueryLocator([SELECT Id  FROM Account limit 1]  );       
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        DevOps_FeatureHandler.maintainlists();  
    }
    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext sc)
    {
        DevOps_BatchUpdateFeatureHandle  DevOpsFeatureHandle = new DevOps_BatchUpdateFeatureHandle();
        database.executebatch(DevOpsFeatureHandle ,1);
    }

}