global with sharing class Order_Batch_ContractRenewal implements Database.Batchable<sObject>,Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        Date CurrentDay = system.today()+1;
        Date RenewalDay = system.today()+1;

        String Querystr = Order_SoqlFactory.returnasset('Contractrenewal',null,null);
        system.debug('**Order_SoqlFactory.Order_Batch_ContractRenewal.Querystr**'+Querystr);
        return Database.getQueryLocator(Querystr);
        /*
         
        return Database.getQueryLocator([SELECT BillToAccount__c,Contract__c  from asset     where
            BillToAccount__r.RenewalAssetToday__c =: false
            AND 
            (Product2Id !=: null AND BillToAccount__c !=: null AND PricingMethod__c !=: null )
            AND((
            ( CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)   
            AND ( 
                ((RenewalDate__c  =: RenewalDay AND RenewalRunDate__c =: null) OR RenewalRunDate__c =: CurrrentDay) 
                /*
                AND 
                (
                    (QuantityUpdateCheckYearly__c =: false)
                    OR(QuantityUpdateCheckYearly__c =: True AND RenewalDate__c  <=: RenewalDay AND QuantityStartDate__c <=:CurrrentDay AND QuantityEndDate__c >=:CurrrentDay  )
                )
                *
                /
            )
            AND LastRenewalUpdate__c !=: CurrrentDay              
            AND AutomatedRenewProcess__c =: true  
            AND Contract__c !=:null
            AND Product2.Type__c != 'Item Group'
            )
            OR(
                AssetRenewalTrigger__c =: true
                AND Product2.Type__c != 'Item Group'
            ))

            ]  );
            */ 
       // return Database.getQueryLocator([SELECT Id,ContractTerm  FROM Contract where EndDate =: system.today() AND OperatingCompany__c ='Noordhoff']  ); 
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> scope){

            Set<String> Set_ContractId = new Set<String>();
    
            for(Asset var:scope){
                Set_ContractId.add(var.Contract__c);
            }

            Contract[] lstContract = [SELECT Id,ContractTerm    FROM Contract where id in: Set_ContractId AND ContractTerm !=: null];
            for(Contract var: lstContract){
                var.ContractTerm += 12;
            }

            try{
                update lstContract;

                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
              }
            }
            catch(exception e){
                HandleCustomException.LogException(e,scope[0].id);
            }

    }
    global void finish(Database.BatchableContext BC){


    }

    global void execute(SchedulableContext sc)
    {
        Order_Batch_ContractRenewal  ContractRenewal = new Order_Batch_ContractRenewal();
        database.executebatch(ContractRenewal ,1000);
    }


    @invocablemethod
    Public static void ContractRenewal(){
        Order_Batch_ContractRenewal  ContractRenewal = new Order_Batch_ContractRenewal();
        database.executebatch(ContractRenewal ,1000);
    }    
}