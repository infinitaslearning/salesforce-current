global with sharing class Order_BATCHTESTASSETRENEWAL implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts{



    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        //Simpler to start with Orders than Assets renewed today to ensure that there is no split due to batch size
        Date CurrrentDay = system.today()-1;

        system.debug('**Order Created: 1');
       return Database.getQueryLocator([SELECT id from Account limit 1]  );
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){  
        
       
        Asset[] lst_AssetResets = [Select id,RenewalDate__c,LastRenewalUpdate__c,AutomatedRenewProcess__c from Asset where PricingMethod__c !=: null AND Product2Id !=: null  Order by Id ASC limit 2000];
		Date RenewalDay = system.today();
		for(Asset ass:lst_AssetResets){
	 		ass.RenewalDate__c  = RenewalDay;
        	 	ass.LastRenewalUpdate__c = null; 
			ass.CancellationDate__c = null;
        		ass.AutomatedRenewProcess__c = true; 
		}
		update lst_AssetResets;
        system.debug('**Order Created: 2');
		System.enqueueJob(new Order_TESTBULKINSERT(lst_AssetResets));
        


    }  

    global void finish(Database.BatchableContext BC){

      Datetime NextStart =  Datetime.now().addMinutes(25);
        String hour = String.valueOf(NextStart.hour());
        String min = String.valueOf(NextStart.minute()); 
        String ss = String.valueOf(00);

        String dayT = String.valueOf(NextStart.day());
     String monthT = String.valueOf(NextStart.Month()); 

        //parse to cron expression
        //String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + dayT +' '+  monthT+ ' ?';

       // MyScheduledJob s = new MyScheduledJob(); 
       Order_Batch_AccountswithRenwalAssets  orderActivate = new  Order_Batch_AccountswithRenwalAssets();
       System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, orderActivate);
    }

    global void execute(SchedulableContext sc)
    {
        Order_BATCHTESTASSETRENEWAL  B2BOrders = new Order_BATCHTESTASSETRENEWAL();
        database.executebatch(B2BOrders ,1);
    }

}