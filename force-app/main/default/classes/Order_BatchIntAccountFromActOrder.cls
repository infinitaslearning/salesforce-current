global with sharing class Order_BatchIntAccountFromActOrder Implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts{
    
    //USED for Sending account and account subsidiary to integration factory after Order 
    //Possible delete

    Private String OrderId;

    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        //Simpler to start with Orders than Assets renewed today to ensure that there is no split due to batch size
        Date CurrrentDay = system.today()-1;

        system.debug('**Order Created: 1');

       return Database.getQueryLocator([SELECT Id,Account__c,IntegrationFactorySend__c  FROM AccountSubsidiary__c]  );
      
      // return Database.getQueryLocator([SELECT Id,Billto__c  FROM Order where ActivateforBatchProcessing__c =:true AND createddate >: CurrrentDay and Status =: 'Activated' and ValidationErrorsOrder__c =:0 and ValidationErrorsOrderProducts__c =:0 limit 1]  );
    
    }

    global void execute(Database.BatchableContext BC, List<AccountSubsidiary__c> scope) {

        Set<String> Set_AccId = new Set<String>();     
        for(AccountSubsidiary__c acc:scope){
            acc.IntegrationFactorySend__c = true;
           // Set_AccId.add(acc.Account__c);
        }
        
        update scope;
    
    /*
        Account[] lst_Account = [Select IntegrationFactorySend__c From Account where id in: Set_AccId];
        
        for(Account acc:lst_Account){
            acc.IntegrationFactorySend__c = true;
        }

        update lst_Account;
        */
        
        /*
        String OrderId;     
        for(Order ord:scope){
            OrderId = ord.id;
        }

        Order_OrderActivateRESTAPI.IntegrateAccounts(OrderId);
        */
    }    

    global void finish(Database.BatchableContext BC){

        
    }

    global void execute(SchedulableContext sc)
    {
        Order_BatchIntAccountFromActOrder  orderActivate = new Order_BatchIntAccountFromActOrder();
        database.executebatch(orderActivate ,5);
    }

}