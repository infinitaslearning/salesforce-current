global with sharing class Order_BATCHASSETSETP implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts{



    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        //Simpler to start with Orders than Assets renewed today to ensure that there is no split due to batch size
        Date CurrrentDay = system.today()-1;

        system.debug('**Order Created: 1');
        
        
        return Database.getQueryLocator([Select id,RenewalAssetToday__c from Account where RenewalAssetToday__c =: true]  );
      // return Database.getQueryLocator([Select id,RenewalDate__c,LastRenewalUpdate__c,AutomatedRenewProcess__c,PricingMethod__c,PriceBook__c from Asset where PricingMethod__c =: null]  );
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){  
       
       
       for(Account acc:scope){
           acc.RenewalAssetToday__c = false;
       }
       update scope;
       
       
        /*
           integer i=1;
           integer x=5;
         for(Asset ass:scope){
                 ass.PriceBook__c  = '01s0E0000022EzoQAE';
                 if(x-i==1){
                     ass.PricingMethod__c = 'AccountStudents'; 
                 }
                 if(x-i==2){
                     ass.PricingMethod__c = 'ProductUsageBased'; 
                 }
                 if(x-i==3){
                     ass.PricingMethod__c = 'OrderProductQuantity'; 
                 }
                 if(x-i==4){
                     ass.PricingMethod__c = 'ProductDiscountGroupUsageBased'; 
                 }
                 
                 i++;
                 x++;
          }
        update scope;
        */
        
    }  

    global void finish(Database.BatchableContext BC){
    }

    global void execute(SchedulableContext sc)
    {
        Order_BATCHASSETSETP  B2BOrders = new Order_BATCHASSETSETP();
        database.executebatch(B2BOrders ,500);
    }

}