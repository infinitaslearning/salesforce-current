@istest
public with sharing class Order_UpdateOrderListPriceDisAll_test {

    //Order_UpdateOrderListPriceDiscountAll_test full name shortened in the class

    public static testmethod void UpdateOrderListPriceDiscountAll1_test() {
          
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

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

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
        
            List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
            List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);


            TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,true);

            List<String> OrderId = new List<String>();

            for(Order ord:lstOrder ){
                OrderId.add(ord.id);
            }

            processListPriceDiscount(OrderId);
           // Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);
        
    }
    

    

    public static testmethod void UpdateOrderListPriceDiscountAll2_test() {
          
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

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
        List<Product2> lstProductItem = TestDataFactory.insertProducts(3,false);

        Integer x=0;
        for(Product2 prod:lstProductItem){
            if(x==0){
                prod.Renewal__c = 'Manual';
            }
            else{
                prod.Renewal__c = null;
            }
            x++;
        }
        insert lstProductItem;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();


        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);      
        List<PricebookEntry> lstPricebookEntryItemGroup = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItemGroup,true);
        List<PricebookEntry> lstPricebookEntryItem = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);
        lstPricebookEntryItemGroup.AddAll(lstPricebookEntryItem);
        
        //Fires Process Builder (Invocable method)
        Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);
        
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntryItemGroup,true);
        
        TestDataFactory.insertAsset(standardPricebook.id,lstProductItem,lstAccount, lstAccount,true);

        List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);
        Order_TestDataFactory.insertListPriceDiscount(1,'Inspection Copy','Workbooks',true);  
  
   
        Map<String,String> Map_itemGroup = new Map<String,String>();

        List<String> lstOrderId = new List<String>();

        for(Order ord:lstOrder ){
            lstOrderId.add(ord.id);
        }
        


        
       // lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,lstOrderId);

        lstOrderItems = Order_SoqlFactory.returnQueryOrderItems(null,lstOrderId, null, null);

        system.debug('**Order_SoqlFactory.Order_UpdateOrderListPriceDisAll_test1.lstOrderItems :Size**'+lstOrderItems.size());

        Product2[] lstProd = [Select OrderLineType__c from Product2]; 

        
        x=0;
        for(OrderItem item:lstOrderItems){

          
            
            Map_itemGroup.put(item.Product2Id ,item.id );

            //Add list price discounts
            for(ListPriceDiscount__c lpd:ListPriceDiscount){
                item.ListPriceDiscount__c = lpd.id;
            }
            item.ShipToAccount__c=lstAccount[0].id;
            //item.OrderLineItemType__c ='Regular';
            item.OrderLineType__c ='Regular';
            item.ComponentListPrice__c = item.UnitPrice;

            if(x==0){
                item.ManualDiscount__c = 'Recurring Percentage';
                item.ManualDiscountPercent__c = 5;
            }
            else if(x==1){
                item.ManualDiscount__c = 'Recurring Amount';
                item.ManualDiscountValue__c = 5;
            }
            else{

            }
            
            x++;
        }    
        
        

        
        for(OrderItem item:lstOrderItems){            
            for(ProductComponent__c prod:lstProductComponent){
                 if(item.Product2Id == prod.Product__c && prod.MainProduct__c != null){
                    item.ItemGroup__c = Map_itemGroup.get(prod.MainProduct__c);
                    item.ProductComponent__c = prod.id;
                    item.quantity = 100;
                 }
                 else if(item.Product2Id == prod.MainProduct__c){

                    item.ListPriceItemGroup__c = 100;
                 }           
            } 
        }

        update lstOrderItems;


       // lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,lstOrderId);

        lstOrderItems = Order_SoqlFactory.returnQueryOrderItems(null,lstOrderId, null, null);
        system.debug('**Order_SoqlFactory.Order_UpdateOrderListPriceDisAll_test2.lstOrderItems :Size**'+lstOrderItems.size());


        Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(null,lstOrderId , standardPricebook.id,lstOrderItems, ListPriceDiscount);


    }
    public static testmethod void UpdateOrderListPriceDiscountAll1b_test() {
          
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

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

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        
            List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
            List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);

        for(OrderItem item:lstOrderItems){
            item.OrderLineType__c = 'Free';
        }

        insert lstOrderItems;


            TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,true);

            List<String> OrderId = new List<String>();

            for(Order ord:lstOrder ){
                OrderId.add(ord.id);
            }

           // Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);
            processListPriceDiscount(OrderId);
    }
    public static testmethod void UpdateOrderListPriceDiscountAll1c_test() {
          
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

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

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

        for(Order ord:lstOrder){
            ord.Type ='RenewalOrder';
        }
        Insert lstOrder;

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
        
            List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
            List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);

        


            TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,true);

            List<String> OrderId = new List<String>();

            for(Order ord:lstOrder ){
                OrderId.add(ord.id);
            }

           // Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);

            processListPriceDiscount(OrderId);
        
    }

    public static testmethod void UpdateOrderListPriceDiscountAll3_test() {
          

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

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

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='ProductDiscountGroupUsageBased';
        }
        insert lstOrder;

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
    
        for(OrderItem item:lstOrderItems){
            item.ManualDiscount__c='One-Off Amount';
            item.ManualDiscountValue__c = 1;
        }
        insert lstOrderItems;

        List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
        List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);

        TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,true);

        List<String> OrderId = new List<String>();

        for(Order ord:lstOrder ){
            OrderId.add(ord.id);
        }
//1     
    //    Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);        
        processListPriceDiscount(OrderId);
    
        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='ProductUsageBased';
        }
        update lstOrder;
//2
    // Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);
        processListPriceDiscount(OrderId);
        
        for(OrderItem item:lstOrderItems){
            item.ManualDiscount__c='One-Off Percentage';
            item.ManualDiscountPercent__c = 10;
        }
        update lstOrderItems;
        
         
        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='OrderProductQuantity';
        }
//3
        update lstOrder;
       // Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);
       processListPriceDiscount(OrderId);

        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='AccountStudents';
        }
//4
        update lstOrder;
      //  Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);
        processListPriceDiscount(OrderId);

        for(Order ord:lstOrder ){
            ord.PricingMethod__c ='OrderTotalAmount';
        }
//5
        update lstOrder;
        //        Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null);
        processListPriceDiscount(OrderId);

    //6
    UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;       
   // Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(null,lstOrderId ,null); 
    
    processListPriceDiscount(OrderId);
}

public static void processListPriceDiscount(List<String> OrderId){

    OrderItem[]   lst_OrdItem =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
    system.debug('**UpdateOrderListPriceDiscountAll1_test.lst_OrdItem :Size**'+lst_OrdItem.size());
    Order[] lst_Order = Order_SoqlFactory.returnQueryOrder(OrderId,null,null);
    system.debug('**UpdateOrderListPriceDiscountAll1_test.lst_Order :Size**'+lst_Order.size());

    Set<String> Set_CusDiscountGroup = new Set<String>();
    Set<String> Set_OperatingCo = new Set<String>();
    Set<String> Set_ProdDiscountGroup = new Set<String>();
    Set<String> Set_OrderLineItemType = new Set<String>();
    Set<String> Set_MarketSegment = new Set<String>();


    for(OrderItem item:lst_OrdItem){ 
        Set_CusDiscountGroup.add(item.Order.Billto__r.CustomerDiscountGroup__c); 
        Set_OperatingCo.add(item.Order.Billto__r.OperatingCompany__c);
        Set_ProdDiscountGroup.add(item.Product2.ProductDiscountGroup__c);
        Set_OrderLineItemType.add(item.OrderLineType__c);
    }

    ListPriceDiscount__c[] lst_ListPriceDiscountRegular = Order_SoqlFactory.returnListPriceDiscount('AllDiscount','OrderProductQuantity', Set_CusDiscountGroup, Set_OperatingCo, Set_ProdDiscountGroup, Set_OrderLineItemType, Set_MarketSegment);
    system.debug('**UpdateOrderListPriceDiscountAll1_test:LPD 1**'+lst_ListPriceDiscountRegular);

    Date CurDate = system.today();
    lst_ListPriceDiscountRegular = [Select Id,DiscountType__c,ProductDiscountGroup__c,StartAmount__c,Subsidiary__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c  
                                                                                        where  EndDate__c >=:CurDate 
                                                                                        AND StartDate__c  <=:CurDate  
                                                                                        ORDER BY StartQuantity__c DESC];

    Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(50,OrderId, lst_Order[0].Pricebook2Id,lst_OrdItem, lst_ListPriceDiscountRegular);

}
}