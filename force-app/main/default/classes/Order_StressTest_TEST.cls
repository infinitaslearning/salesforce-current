@isTest
public class Order_StressTest_TEST {
    @testSetup
    public static void makeData(){
        
		List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All Products 2021');
        lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Plantyn',false, false);
        lstAccount[0].BillingReminderEmail2__c = 'connor@cloudmuscle.nl';
        lstAccount[0].InvoiceEmail2__c = 'connor@cloudmuscle.nl';
        lstAccount[0].VATNumberRequired__c = 'No';
        lstAccount[0].VATStatus__c = 'Correct';
        insert lstAccount[0];
        
        OrderStressTest__c config1 = new OrderStressTest__c();
        config1.OperatingCompany__c = 'Plantyn';
        config1.IntervalMinutes__c = '5';
        config1.NumberOfOrdersToCreate__c = 1;
        config1.IncludeItemGroups__c = true;
        config1.NumberOfProductsPerOrder__c = 5;
        config1.RunAutomationUntil__c = DateTime.now().addminutes(10);
        insert config1;
        
        OrderStressTest__c config2 = new OrderStressTest__c();
        config2.OperatingCompany__c = 'Plantyn';
        config2.IntervalMinutes__c = '5';
        config2.NumberOfOrdersToCreate__c = 1;
        config2.IncludeItemGroups__c = true;
        config2.NumberOfProductsPerOrder__c = 5;
        insert config2;
    }
    
    public static testMethod void testStressOrders(){
        test.startTest();
        Order_StressTestInvocable.createStressTests();
        test.stopTest();
    }
    
    public static testMethod void testStressOrders1(){
        List<ImportOrder__c> ioLs = new List<ImportOrder__c>();
        
        ImportOrder__c io = new ImportOrder__c();
        ioLs.add(io);
        
        test.startTest();
        Order_StressTest_REST_Queueable restQueue = new Order_StressTest_REST_Queueable(ioLs);
        restQueue.execute(null);
        test.stopTest();
    }
}