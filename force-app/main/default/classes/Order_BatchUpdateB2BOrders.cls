global with sharing class Order_BatchUpdateB2BOrders implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {
   

    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        //Simpler to start with Orders than Assets renewed today to ensure that there is no split due to batch size
        Date CurrrentDay = system.today()-3;

        
      // return Database.getQueryLocator([SELECT Id,Billto__c,B2BJobRun__c,ActivateforBatchProcessing__c,Source__c  FROM Order where 	LineCount__c >:0 AND (((Source__c =:'B2B Invoice' OR Source__c =:'B2B Trade' OR Source__c =:'B2B Shop' OR Source__c =:'B2B DirectPayment') AND createddate >: CurrrentDay and Status !=: 'Activated') OR (Source__c =:'B2B Shop'  AND Status !=: 'Activated' AND (ValidationErrorsOrder__c >:0 OR ValidationErrorsOrderProducts__c >:0))) ]  );
      OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount;

      if(test.isrunningtest()){
          OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];
      }
      else{
          OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='LiveCount'];
      }

      Decimal FIXEDLINECOUNT;
      FIXEDLINECOUNT =  OrderLineItemMaxCount[0].Count__c;


      TriggerBusinessRules__mdt[] TriggerBusinessRules = [Select AutoRun__c,OrderRetries__c from TriggerBusinessRules__mdt];
      
      
      if (TriggerBusinessRules[0].AutoRun__c == true){
        System.debug('**Order_BatchUpdateB2BOrders:AutoRun:1**'+TriggerBusinessRules[0].AutoRun__c);
        System.debug('**Order_BatchUpdateB2BOrders:Retries:2**'+TriggerBusinessRules[0].OrderRetries__c);
        return Database.getQueryLocator([SELECT Id,Billto__c,TriggerBusinessRules__c,ActivateforBatchProcessing__c,Source__c  FROM Order where TriggerBusinessRulesRetries__c < : TriggerBusinessRules[0].OrderRetries__c AND 	LineCount__c >:0 AND Type != 'RenewalOrder' AND lastmodifieddate >=: CurrrentDay and Status !=: 'Activated' AND status != 'Cancelled' AND (TriggerBusinessRules__c =:true OR (ValidationErrorsOrder__c >:0 OR ValidationErrorsOrderProducts__c >:0) OR LineCount__c >: FIXEDLINECOUNT) ]  );
      }
      else{
        date fail = system.today() - 10000;
        return Database.getQueryLocator([SELECT Id from Order where createddate <: fail ]  );
      }

    
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope){  
        
        List<Id> OrderId = new List<Id>();
        for(Order ord:Scope){
          //  ord.B2BJobRun__c = true;
         //   if(ord.Source__c !='B2B Shop'){
          //      ord.ActivateforBatchProcessing__c=true;
                
          //  }
            OrderId.add(ord.Id);
        }

        system.debug('**Order Created: 2'+OrderId.size());
        if(OrderId.size()>0){
            Order_B2BOrderInvocable.UpdateOrderItemsfuture (OrderId);
        }
        //update scope;
        

    }  

    global void finish(Database.BatchableContext BC){

      //OrderActivationRules__mdt OrderActivationRules

        Datetime NextStart =  Datetime.now().addMinutes(5);
        String hour = String.valueOf(NextStart.hour());
        String min = String.valueOf(NextStart.minute()); 
        String ss = String.valueOf(00);
   
        
   
        String dayT = String.valueOf(NextStart.day());
        String monthT = String.valueOf(NextStart.Month()); 
   
        
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + dayT +' '+  monthT+ ' ?';
        CronJobDetail[] cronJob = [SELECT Id,JobType,Name FROM CronJobDetail where name like: '%Started At%' ];

           system.debug('***nextFireTime***'+nextFireTime);
       if(!Test.isRunningTest() && cronJob.size()==0){     
          Order_BatchOrderActivateAssetRenewal  orderActivate = new Order_BatchOrderActivateAssetRenewal();
          System.schedule('B2BActivateOrders: Started At ' + String.valueOf(Datetime.now()), nextFireTime, orderActivate);
        }
        
      //  Order_BatchOrderActivateAssetRenewal  orderActivate = new Order_BatchOrderActivateAssetRenewal();
      //  database.executebatch(orderActivate ,1);
    }
    global void execute(SchedulableContext sc)
    {
        Order_BatchUpdateB2BOrders  B2BOrders = new Order_BatchUpdateB2BOrders();
        database.executebatch(B2BOrders ,1);
    }




}