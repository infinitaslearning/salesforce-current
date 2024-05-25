global class Order_StressTest_BATCH implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    private OrderStressTest__c stressTestSetting;
    private List<Account> accountList;
    private List<ImportOrder__c> importOrderItemsRESTAPI;
    private List<StressTestDTO> stressTestCfgWrappers;
    
    public Order_StressTest_BATCH(OrderStressTest__c record){
        stressTestSetting = record;
        accountList = new List<Account>();
        importOrderItemsRESTAPI = new List<ImportOrder__c>();
        
        stressTestCfgWrappers = new List<StressTestDTO>();
    }
    
    public class StressTestDTO {
        public Account randomAccount {get; set;}
        public List<sObject> recordLs {get; set;}
        public OrderStressTest__c stressTestCfg {get; set;}
        public String externalOrderId {get; set;}
    }
    
    public Account getRandomAccount(List<Account> startingList){
        Integer indexSizeOfList = startingList.size()-1;
        Integer randomIndex = Integer.valueOf(indexSizeOfList*Math.random());//index starts at 0 size needs to be decreased then get the random number
        return startingList[randomIndex];
    }
    
    global Iterable<sObject> start(Database.BatchableContext bc) {
        Integer numRecordsToProcess = Integer.valueOf(stressTestSetting.NumberofOrderstoCreate__c);
        Integer numProductsToUse = Integer.valueOf(stressTestSetting.NumberofProductsPerOrder__c);
        Integer totalAccs = 0;
        
        if(!Test.isRunningTest()){
            totalAccs = [SELECT COUNT() FROM Account WHERE OperatingCompany__c = :stressTestSetting.OperatingCompany__c AND NetsuiteCustomerNumber__c != NULL AND ValidateIntegrationerrors__c = FALSE AND ValidateErrors__c = FALSE];
            //Integer rand = Math.floor(Math.random() * totalAccs).intValue();
            
            // get synced accounts for opco (NEW ACCOUNT FOR EACH ORDER)
            accountList = [SELECT Id, NetsuiteCustomerNumber__c, CurrencyIsoCode 
                           FROM Account 
                           WHERE OperatingCompany__c = :stressTestSetting.OperatingCompany__c AND NetsuiteCustomerNumber__c != NULL AND ValidateIntegrationerrors__c = FALSE AND status__c = 'Active'
                           AND ValidateErrors__c = FALSE
                           LIMIT :totalAccs];
        } else {
            totalAccs = [SELECT COUNT() FROM Account WHERE OperatingCompany__c = :stressTestSetting.OperatingCompany__c];
            //Integer rand = Math.floor(Math.random() * totalAccs).intValue();
            
            // get synced accounts for opco (NEW ACCOUNT FOR EACH ORDER)
            accountList = [SELECT Id, NetsuiteCustomerNumber__c, CurrencyIsoCode 
                           FROM Account 
                           WHERE OperatingCompany__c = :stressTestSetting.OperatingCompany__c AND status__c = 'Active'
                           LIMIT :totalAccs];
        }
        
        
        system.debug('accountList: ' + accountList);
        
        // get active pricebook for OpCo. EXCLUDE INFORMAT
        Pricebook2 pricebookRecord = [SELECT Id FROM Pricebook2 
                                      WHERE IsActive = true AND Subsidiary__c = :stressTestSetting.OperatingCompany__c AND EndDate__c >= TODAY 
                                      AND (NOT Name LIKE '%Informat%') LIMIT 1];
        
        // get pricebook entries (including product info)
        List<PricebookEntry> pricebookEntriesWithProductInfo = new List<PricebookEntry>();
        
        // get useable products for opco
        if(stressTestSetting.IncludeItemGroups__c){
            // INCLUDE ITEM GROUPS
            // make sure half of the products are item group products, and the rest are non item group products
            Integer itemGroupsToGet = Integer.valueOf(Decimal.valueOf((numProductsToUse/2)).round(System.RoundingMode.CEILING));
            
            List<PricebookEntry> itemGroupPBEs = [SELECT Price__c,Product2.Stocknumber__c,Product2.maxQuantity__c,Product2.DeliveryStatus__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id 
                                                  FROM PricebookEntry
                                                  WHERE Pricebook2Id =:pricebookRecord.Id 
                                                  AND IsActive = TRUE
                                                  AND (Product2.DeliveryStatus__c = 'Published' OR Product2.DeliveryStatus__c = 'Production')
                                                  AND Product2.HasBlock__c = FALSE
                                                  AND Product2.itemGroupManualBlock__c = FALSE
                                                  AND Product2.Type__c = 'Item Group'
                                                  LIMIT :itemGroupsToGet];
            
            // make sure remaining products are non item-group products
            Integer nonIGsToGet = numProductsToUse - itemGroupPBEs.size();
            
            List<PricebookEntry> nonItemGroupPBEs = [SELECT Price__c,Product2.Stocknumber__c,Product2.maxQuantity__c,Product2.DeliveryStatus__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id 
                                                  FROM PricebookEntry
                                                  WHERE Pricebook2Id =:pricebookRecord.Id 
                                                  AND IsActive = TRUE
                                                  AND (Product2.DeliveryStatus__c = 'Published' OR Product2.DeliveryStatus__c = 'Production')
                                                  AND Product2.HasBlock__c = FALSE
                                                  AND Product2.itemGroupManualBlock__c = FALSE
                                                  AND Product2.Type__c != 'Item Group'   
                                                  LIMIT :nonIGsToGet];
            
            // add the two different sets of products to one list
            pricebookEntriesWithProductInfo.addAll(itemGroupPBEs);
            pricebookEntriesWithProductInfo.addAll(nonItemGroupPBEs);
        } else {
            // EXCLUDE ITEM GROUPS
            pricebookEntriesWithProductInfo = [SELECT Price__c,Product2.Stocknumber__c,Product2.maxQuantity__c,Product2.DeliveryStatus__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id 
                                               FROM PricebookEntry
                                               WHERE Pricebook2Id =:pricebookRecord.Id 
                                               AND IsActive = true
                                               AND (Product2.DeliveryStatus__c = 'Published' OR Product2.DeliveryStatus__c = 'Production')
                                               AND Product2.HasBlock__c = FALSE
                                               AND Product2.itemGroupManualBlock__c = FALSE
                                               AND Product2.Type__c != 'Item Group'
                                               LIMIT :numProductsToUse];
        }
        
        system.debug('pricebookEntriesWithProductInfo: ' + pricebookEntriesWithProductInfo);
        return pricebookEntriesWithProductInfo;
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> records){
        List<ImportOrder__c> importOrderHeaders = new List<ImportOrder__c>();
        List<ImportOrder__c> importOrderItems = new List<ImportOrder__c>();
        
        system.debug('stressTestSetting.NumberofOrderstoCreate__c: ' + stressTestSetting.NumberofOrderstoCreate__c);
        system.debug('accountList.size(): ' + accountList.size());
        
        if(records.size() > 0){
            for(integer i = 0; i < stressTestSetting.NumberofOrderstoCreate__c; i++){
                Date dateVal = Date.valueOf(System.now());
                
                Account randAcc = getRandomAccount(accountList);
                
                ImportOrder__c ioHeader = new ImportOrder__c();
                ioHeader.customerNo__c = randAcc.NetsuiteCustomerNumber__c;
                ioHeader.orderDate__c = String.valueOf(dateVal.format());
                ioHeader.Source__c = 'Trade';
                ioHeader.OperatingCompany__c = stressTestSetting.OperatingCompany__c;
                ioHeader.ExternalOrderId__c = stressTestSetting.Name + '-' + randAcc.NetsuiteCustomerNumber__c + '-' + String.valueOf(dateVal) + '-' + Integer.valueof((Math.random() * 100));
                ioHeader.LineCount__c = records.size();
                ioHeader.orderType__c = 'Regular';
                ioHeader.CurrencyIsoCode = randAcc.CurrencyIsoCode;
                ioHeader.orderRef__c = 'stressTest';
                
                insert ioHeader;
                
                StressTestDTO stressTestWrapper = new StressTestDTO();
                stressTestWrapper.randomAccount = randAcc;
                stressTestWrapper.recordLs = records;
				stressTestWrapper.stressTestCfg = stressTestSetting;
                stressTestWrapper.externalOrderId = ioHeader.ExternalOrderId__c;
                
                stressTestCfgWrappers.add(stressTestWrapper);
                
                //System.enqueueJob(new Order_StressTest_Queueable(randAcc, records, stressTestSetting, i));
                
                /*for(integer j = 0; j < records.size(); j++){
                    ImportOrder__c ioProduct = new ImportOrder__c();
                    ioProduct.customerNo__c = randAcc.NetsuiteCustomerNumber__c;
                    ioProduct.deliveryIdLocation__c = randAcc.NetsuiteCustomerNumber__c;
                    ioProduct.invoiceIdLocation__c = randAcc.NetsuiteCustomerNumber__c;
                    ioProduct.ProductId__c = String.valueOf(records[j].getSObject('Product2').get('ISBNArticleNumber__c'));
                    ioProduct.quantity__c = 1;
                    ioProduct.orderRef__c = 'stressTest';
                    ioProduct.orderItemRef__c = 'sT-' + j;
                    ioProduct.orderDate__c = String.valueOf(dateVal.format());
                    ioProduct.ExternalOrderId__c = stressTestSetting.Name + '-' + randAcc.NetsuiteCustomerNumber__c + '-' + String.valueOf(dateVal)  + '-' + i;
                    ioProduct.Source__c = 'B2B Salesforce';
                    ioProduct.LineItemType__c = 'Regular';
                    ioProduct.OperatingCompany__c = stressTestSetting.OperatingCompany__c;
                    ioProduct.TriggerBusinessLogic__c = false;
                    ioProduct.DigitalActivationEmail__c = 'connor@cloudmuscle.nl';
                    ioProduct.CurrencyIsoCode = randAcc.CurrencyIsoCode;
                    
                    if(j == records.size()-1){
                        ioProduct.TriggerBusinessLogic__c = true;
                        ioProduct.orderItemRef__c = 'last-item';
                        
                        // insert the last order item via REST (because of trigger business logic), to not interfere with other batch job
                        importOrderItemsRESTAPI.add(ioProduct);

                    } else {
                        importOrderItems.add(ioProduct);
                    }
                }*/
            }
        }
        
        // Insert order items
        /*try {
            System.debug('=== importOrderItems.size(): ' + importOrderItems.size());
            insert importOrderItems;
            

        } catch (Exception e) {
            System.debug('Exception when inserting order items: ' + e.getMessage());
            HandleCustomException.LogException(e);
        }*/
    } 
    
    global void finish(Database.BatchableContext bc){
        // insert the last order item via REST (because of trigger business logic), to not interfere with other batch job
        //String restResourceRetVal  = Order_StressTest_RESTAPI.insertLastItem(importOrderItemsRESTAPI);
        //system.debug('=== restResourceRetVal REST CALLOUT: ' + restResourceRetVal);
        
        System.enqueueJob(new Order_StressTest_Queueable(stressTestCfgWrappers));
        
        stressTestSetting.LastRun__c = System.now();
        update stressTestSetting;
        
        // abort current job so new ones can be added
        Boolean cancelJob = Order_StressTestScheduleable.abortScheduledJob();
        
        //parse to a cron expression
        String nextFireTime = Order_StressTestScheduleable.getCronExpression(1);
        
        if(cancelJob){
            // call job 1 minute after last run, so that it's always running
            Order_StressTestScheduleable stressTest = new Order_StressTestScheduleable();
            System.schedule('Order_StressTestScheduleable-' + System.now(), nextFireTime, stressTest);
        }
    }
}