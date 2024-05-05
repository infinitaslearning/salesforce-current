public class Order_StressTest_Queueable implements Queueable, Database.AllowsCallouts{
    private Account acc;
    private List<sObject> batchRecords;
    private OrderStressTest__c stressTestSetting;
    private List<ImportOrder__c> importOrderItemsRESTAPI;
    private Integer incr;
    private List<Order_StressTest_BATCH.StressTestDTO> stressTestWrappers;
    
    public Order_StressTest_Queueable(List<Order_StressTest_BATCH.StressTestDTO> stressTestRecs){
        this.stressTestWrappers = stressTestRecs;
        this.importOrderItemsRESTAPI = new List<ImportOrder__c>();
    }
    public void execute(QueueableContext context){
        List<ImportOrder__c> importOrderItems = new List<ImportOrder__c>();
        
        Date dateVal = Date.valueOf(System.now());
        
        for(integer i = 0; i < this.stressTestWrappers.size(); i++){
            if(this.stressTestWrappers[i].recordLs.size() > 0){
                for(integer j = 0; j < this.stressTestWrappers[i].recordLs.size(); j++){
                    ImportOrder__c ioProduct = new ImportOrder__c();
                    ioProduct.customerNo__c = this.stressTestWrappers[i].randomAccount.NetsuiteCustomerNumber__c;
                    ioProduct.deliveryIdLocation__c = this.stressTestWrappers[i].randomAccount.NetsuiteCustomerNumber__c;
                    ioProduct.invoiceIdLocation__c = this.stressTestWrappers[i].randomAccount.NetsuiteCustomerNumber__c;
                    ioProduct.ProductId__c = String.valueOf(this.stressTestWrappers[i].recordLs[j].getSObject('Product2').get('ISBNArticleNumber__c'));
                    ioProduct.quantity__c = 1;
                    ioProduct.orderRef__c = 'stressTest';
                    ioProduct.orderItemRef__c = 'sT-' + j;
                    ioProduct.orderDate__c = String.valueOf(dateVal.format());
                    ioProduct.ExternalOrderId__c = this.stressTestWrappers[i].externalOrderId;
                    ioProduct.Source__c = 'B2B Salesforce';
                    ioProduct.LineItemType__c = 'Regular';
                    ioProduct.OperatingCompany__c = this.stressTestWrappers[i].stressTestCfg.OperatingCompany__c;
                    ioProduct.TriggerBusinessLogic__c = false;
                    ioProduct.DigitalActivationEmail__c = 'connor@cloudmuscle.nl';
                    ioProduct.CurrencyIsoCode = this.stressTestWrappers[i].randomAccount.CurrencyIsoCode;
                    
                    if(j == this.stressTestWrappers[i].recordLs.size()-1){
                        ioProduct.TriggerBusinessLogic__c = true;
                        ioProduct.orderItemRef__c = 'last-item';
                        
                        // insert the last order item via REST (because of trigger business logic), to not interfere with other batch job
                        importOrderItemsRESTAPI.add(ioProduct);
                        
                    } else {
                        importOrderItems.add(ioProduct);
                    }
                }
            }
        }
        
        // Insert order items
        try {
            System.debug('=== importOrderItems.size(): ' + importOrderItems.size());
            
            if(importOrderItems.size() > 0){
                insert importOrderItems;
            }

        } catch (Exception e) {
            System.debug('Exception when inserting order items: ' + e.getMessage());
            HandleCustomException.LogException(e);
        }
        
        
        // Chain this job to next job by submitting the next job
        if(!Test.isRunningTest()){
			System.enqueueJob(new Order_StressTest_REST_Queueable(importOrderItemsRESTAPI));
        }
    }
}