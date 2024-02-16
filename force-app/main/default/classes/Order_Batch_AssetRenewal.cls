global with sharing class Order_Batch_AssetRenewal implements Database.Batchable<sObject>,Schedulable {
     
    

    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        
        return Database.getQueryLocator([SELECT Id  FROM Account where RenewalAssetToday__c =: true]  ); // WHERE ACCOUNT HAS ACTIVE ASSET
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
       
        Set<String> Set_BillTo = new Set<String>();
        for (Account acc : scope) {
            Set_BillTo.add(acc.id);
        }
        Date CurrentDay = system.today();
        Date RenewalDay = system.today();

        asset[] lstAssets =  Database.query(Order_SoqlFactory.returnasset('renewal',Set_BillTo,null));
        system.debug('**Order_SoqlFactory.Order_Batch_AssetRenewal.lstAssets**'+lstAssets.size());
        system.debug('**Order_Batch_AssetRenewal : Set_BillTo**'+Set_BillTo);

        /*
        asset[] lstAssets = [Select id,PriceBook__c,AssetRenewalTrigger__c,CurrencyIsoCode,LastRenewalUpdate__c,RenewalRunDate__c,Reference__c,PriceBook__r.FollowUpPriceBook__c,OrderLineType__c,
                                    Product2.LicenseDuration__c,Product2.OrderLineType__c,RenewalDate__c,Account.DigitalActivationEmail__c ,DigitalActivationEMail__c,
                                    IndexationPercentage__c,ApplyIndexationPercentage__c,Product2.CustomPricingAllowed__c,Product2.ProductDiscountGroup__c,ListPrice__c,Contract__r.Indexation__c,Product2.ProductRateGroup__c,RenewalTerm__c,DiscountedPrice__c,ManualDiscount__c,
                                    IsUpForRenewal__c,AccountId,PricingMethod__c,BillToAccount__r.ShippingCostMethod__c,ManualDiscountPercent__c,ManualDiscountValue__c,
                                    BillToAccount__r.PaymentMethod__c,BillToAccount__r.CustomerDiscountGroup__c,BillToAccount__r.OperatingCompany__c,
                                    Account.CustomerDiscountGroup__c,Price,Quantity, BillToAccount__c,Product2Id,BillToAccount__r.NetsuiteInternalId__c,Account.NetsuiteInternalId__c, Account.NumberofStudents__c,
                                    BillToAccount__r.ShippingStreet,BillToAccount__r.ShippingPostalCode,BillToAccount__r.ShippingCountry,BillToAccount__r.ShippingCity,ShipToAttentionOf__c,
                                    BillToAccount__r.BillingStreet,BillToAccount__r.BillingPostalCode,BillToAccount__r.BillingCountry,BillToAccount__r.BillingCity,
                                    Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.SuccessorItem__r.CustomPricingAllowed__c,Product2.SuccessorItem__r.Type__c,Product2.SuccessorItem__r.LicenseDuration__c,
                                    Product2.Type__c,RenewalMessage__c,CancellationDate__c
                                    from asset 
                                    where 
                                    //AND IsUpForRenewal__c =:true 
                                    (Product2Id !=: null AND BillToAccount__c in: Set_BillTo AND PricingMethod__c !=: null )
                                    AND((
                                    (CancellationDate__c >: CurrentDay OR CancellationDate__c =:null)    
                                    AND (
                                        ((RenewalDate__c  =: RenewalDay AND RenewalRunDate__c =: null) 
                                        OR RenewalRunDate__c =: CurrentDay 
                                        OR (RenewalDate__c  <: CurrentDay AND QuantityUpdateCheckYearly__c =: True)) 
                                        
                                        AND 
                                        (
                                        QuantityUpdateCheckYearly__c =: false 
                                        OR(QuantityUpdateCheckYearly__c =: True  AND QuantityStartDate__c <=:CurrentDay AND QuantityEndDate__c >=:CurrentDay  )
                                        )
                                    
                                    )
                                    AND LastRenewalUpdate__c !=: CurrentDay 
                                    AND AutomatedRenewProcess__c =: true
                                  //  AND Contract__c =:null
                                    AND Product2.Type__c != 'Item Group'
                                    )
                                    OR(
                                        AssetRenewalTrigger__c =: true
                                        AND Product2.Type__c != 'Item Group'
                                    ))
                                    ];
        */
                                    
        system.debug('**Order_Batch : lstAssets**'+lstAssets );
        system.debug('**Order_Batch : Size**'+lstAssets.size());
        system.debug('**Order_Batch : Set_BillTo**'+Set_BillTo);

        if(lstAssets.size()>0){
        

            try{
              
               Order_AssetRenewal.Initiate_Order_AssetRenewal(lstAssets,CurrentDay,RenewalDay);

               if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
              }

            }
            catch(exception e){
                HandleCustomException.LogException(e,lstAssets[0].id);
            }
                
        }
       
    }
    global void finish(Database.BatchableContext BC){

    

     Datetime NextStart =  Datetime.now().addMinutes(25);
     String hour = String.valueOf(NextStart.hour());
     String min = String.valueOf(NextStart.minute()); 
     String ss = String.valueOf(00);

     

     String dayT = String.valueOf(NextStart.day());
     String monthT = String.valueOf(NextStart.Month()); 

     String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + dayT +' '+  monthT+ ' ?';

        system.debug('***nextFireTime***'+nextFireTime);

    
      
      Order_BatchOrderActivateAssetRenewal  orderActivate = new Order_BatchOrderActivateAssetRenewal();
      System.schedule('ActivateAssetRenewal: Started At ' + String.valueOf(Datetime.now()), nextFireTime, orderActivate);

    }
    
    global void execute(SchedulableContext sc)
    {
        Order_Batch_AssetRenewal  AssetRenewal = new Order_Batch_AssetRenewal();
        database.executebatch(AssetRenewal ,1);
    }



}