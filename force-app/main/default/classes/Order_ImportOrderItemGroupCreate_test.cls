@istest
public with sharing class Order_ImportOrderItemGroupCreate_test {
   

    public static testmethod void ImportOrderItemGroupCreate1(){

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);

        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(2,true);
        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2023');
        

        List<PricebookEntry> lstPricebookEntryItemGroup = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItemGroup,true);
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        

        lstPricebookEntryItemGroup = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItemGroup,true);
        lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProduct,true);
        

        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,PricebookCustom.id,true);
        
        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProduct,lstProductItemGroup,true);
        
        lstPricebookEntryItemGroup.AddAll(lstPricebookEntry);
        //Fires Process Builder (Invocable method)
        List<Pricing__c> InsertPricing = Order_TestDataFactory.InsertPricing(lstProduct,lstProductComponent,true);
        Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);


        system.debug('***InsertPricing***'+InsertPricing);
        system.debug('***PricebookCustom***'+PricebookCustom);

        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,PricebookCustom.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         

       

        List<Order_ImportOrderItemGroupCreate.Request> lst_request = new  List<Order_ImportOrderItemGroupCreate.Request>();

         
        for(OrderItem item:lstOrderItems){
            Order_ImportOrderItemGroupCreate.Request request = new Order_ImportOrderItemGroupCreate.Request();
            request.SingleOrderItems = item;
            lst_request.add(request);
        }

        Order_ImportOrderItemGroupCreate.OrderItemGroupCreate(lst_request);
        



    }

}