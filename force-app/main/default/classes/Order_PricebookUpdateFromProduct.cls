public with sharing class Order_PricebookUpdateFromProduct {
    @invocablemethod
    public static void PricebookUpdateFromProduct(List<Id> ProductId){  
        
        Pricing__c[] lstPricing;
        try {

            /* 	 
            lstPricing = [Select id,EndDate__c,StartDate__c,IsActive__c From Pricing__c where 
                (Product__c in:ProductId OR ProductComponent__r.Product__c in: ProductId)
                AND StartDate__c <=: system.today()
                AND EndDate__c >=: system.today()
                AND IsActive__c =: true
            ];
            */
            lstPricing = Order_SoqlFactory.returnPricing('UpdatePricingfromProduct',null,ProductId,null,null);
            system.debug('**Order_SoqlFactory.Order_PricebookUpdateFrom.lstPrice :size**'+lstPricing.size());

            
            
            List<Id> PriceId = new List<Id>();

            system.debug('**PricebookUpdateFromProduct**');

            for(Pricing__c price: lstPricing){
                PriceId.add(price.id);
            }

            Order_PricebookEntryCreate.ProcessPricebookEntryCreate(PriceId);

            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
            }

        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e,lstPricing[0].id);
        }
        finally {
            // Something executed whether there was an error or not
        }

    }    
}