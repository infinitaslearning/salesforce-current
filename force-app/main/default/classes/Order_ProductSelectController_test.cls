@Istest
public with sharing class Order_ProductSelectController_test {

    public static testmethod void Order_StructurediscountCalculation1(){

        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(2,true);

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

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);
        Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);

        List<String> ShiptoId = new List<String>(); 
        for(OrderShipto__c ord:lst_OrderShipto){
            ShiptoId.add(ord.ShiptoAccount__c); 
        }

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[1].id);

        Decimal NoStudents = lstAccount[0].NumberofStudents__c;
        String ContractId = lstContract[0].id; 
        String ExistingContract = 'yes';   
        String ContractRenewal = 'no';
        String PricingMethod = 'ProductUsageBased';
        String OrderId = lstOrder[0].id;
        String Pricebook2Id = standardPricebook.id;

 
       Order_ProductSelectController.loadListPriceDiscountType(OrderId);   

        List<Order_ProductSelectController.OrderLineItem> OrderItems = new List<Order_ProductSelectController.OrderLineItem>();
        OrderItems = Order_ProductSelectController.loadOrderItems(OrderId,NoStudents,PricingMethod);
             
        for(Order_ProductSelectController.OrderLineItem OItem: OrderItems){
            OItem.IsEdited=true;
            OItem.ComponentQuantityFinal = OItem.Quantity;
        }
        Order_ProductSelectController.InsertOrderItems(OrderItems,lstContract[0].id,OrderId,233,lstAccount);
      test.stopTest();
    }    

   


    public static testmethod void Order_StructurediscountCalculation2(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Plantyn',true,true);        
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

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
        Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);
     
        
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);


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

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntryItemGroup,true);
        
        List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);

        TestDataFactory.insertAsset(standardPricebook.id,lstProductItem,lstAccount, lstAccount,true);

        List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);
        ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(1,'Inspection Copy','Workbooks',false);  
  
        for(ListPriceDiscount__c lpd:ListPriceDiscount){
            lpd.DiscountType__c = 'Market Segment';
        }    
        Insert ListPriceDiscount;

        List<String> ShiptoId = new List<String>(); 
        for(OrderShipto__c ord:lst_OrderShipto){
            ShiptoId.add(ord.Id); 
        }

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[0].id);

        Decimal NoStudents = lstAccount[0].NumberofStudents__c;
        String ContractId = lstContract[0].id; 
        String ExistingContract = 'yes';   
        String ContractRenewal = 'no';
        String PricingMethod = 'AccountStudents';
        String OrderId = lstOrder[0].id;
        String Pricebook2Id = standardPricebook.id;

        
        Map<String,String> Map_itemGroup = new Map<String,String>();
        
        x=0;
        for(OrderItem item:lstOrderItems){
            Map_itemGroup.put(item.Product2Id ,item.id );

            //Add list price discounts
            for(ListPriceDiscount__c lpd:ListPriceDiscount){
                item.ListPriceDiscount__c = lpd.id;

            }
            item.ShipToAccount__c=lstAccount[0].id;
            item.OrderLineType__c ='Inspection Copy';
            

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
          //  system.debug('**Ord_Prod_ItemGroup: 2**');          
            for(ProductComponent__c prod:lstProductComponent){
               // system.debug('**Ord_Prod_ItemGroup: 3**');
                 if(item.Product2Id == prod.Product__c && prod.MainProduct__c != null){
                    item.ItemGroup__c = Map_itemGroup.get(prod.MainProduct__c);
                    
                 } 
                 else{
                        item.DiscountedPriceItemGroup__c = item.quantity * 100;
                        item.ListPriceItemGroup__c = item.quantity * 123;
                        item.NetSalesPriceItemGroup__c =   item.quantity * 100;
                 }          
            } 
        }

        update lstOrderItems;


        Order_ProductSelectController.returnOrder(OrderId);
        List<Order_ProductSelectController.OrderLineItem> OrderItems = new List<Order_ProductSelectController.OrderLineItem>();
        OrderItems = Order_ProductSelectController.loadOrderItems(OrderId,NoStudents,PricingMethod);
        Order_ProductSelectController.loadAssetsforRate (OrderId,lst_AccountId, 'ProductUsageBased');
        
        for(Order_ProductSelectController.OrderLineItem OItem: OrderItems){
            OItem.IsEdited=true;
            OItem.ComponentQuantityFinal = OItem.Quantity;
        }
        Order_ProductSelectController.InsertOrderItems(OrderItems,lstContract[0].id,OrderId,233,lstAccount);

     test.stopTest();
    }    


    public static testmethod void Order_StructurediscountCalculation3(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);
        
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

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
        Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);

        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);


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

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntryItemGroup,true);        
        List<OrderShipto__c> lst_OrderShipto = Order_TestDataFactory.insertOrderShipto(1,lstOrder, lstAccount,true);

        TestDataFactory.insertAsset(standardPricebook.id,lstProductItem,lstAccount, lstAccount,true);

        List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);
        Order_TestDataFactory.insertListPriceDiscount(1,'Inspection Copy','Workbooks',true);  
  

        List<String> ShiptoId = new List<String>(); 
        for(OrderShipto__c ord:lst_OrderShipto){
            ShiptoId.add(ord.Id); 
        }

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[0].id);

        List<String> lst_ShipTo = new List<String>();
        for(Account acc:lstAccount){
            lst_ShipTo.add(acc.id);
        }
        

        Decimal NoStudents = lstAccount[0].NumberofStudents__c;
        String ContractId = lstContract[0].id; 
        String ExistingContract = 'yes';   
        String ContractRenewal = 'no';
        String PricingMethod = 'OrderTotalRate';
        String OrderId = lstOrder[0].id;
        String Pricebook2Id = standardPricebook.id;

        
        Map<String,String> Map_itemGroup = new Map<String,String>();
        
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
                 }
                 else{
                    item.DiscountedPriceItemGroup__c = item.quantity * 100;
                    item.ListPriceItemGroup__c = item.quantity * 123;
                    item.NetSalesPriceItemGroup__c =   item.quantity * 100;
                }         
            } 
        }

        update lstOrderItems;

        Order_ProductSelectController.loadOrderItems(OrderId,NoStudents,PricingMethod);
        Order_ProductSelectController.loadAccountbyBillto(lstOrder[0].id);
        Order_ProductSelectController.loadAccountbyShipto(lstOrder[0].id, lst_ShipTo);

           test.stopTest();
    }    




    public static testmethod void Order_StructurediscountCalculation4(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);
        
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);

        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

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
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
         
        List<PricebookEntry> lstPricebookEntryItemGroup = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItemGroup,true);
        List<PricebookEntry> lstPricebookEntryItem = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);
        lstPricebookEntryItemGroup.AddAll(lstPricebookEntryItem);
        
        lstProductItem.addAll(lstProductItemGroup);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);
        Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);

        Map<String,String> Map_Price = new Map<String,String>();

         for(Pricing__c price:lstPricing){
            Map_Price.put(price.Product__c,price.id);
         }

        for(PricebookEntry pbe:lstPricebookEntryItem){
            pbe.Price__c = Map_Price.get(pbe.Product2Id);
        }
        
        update lstPricebookEntryItem;
        
        Decimal NoStudents = lstAccount[0].NumberofStudents__c;
        String ExistingContract = 'yes';   
        String ContractRenewal = 'no';
        String PricingMethod = 'OrderTotalRate';
        String ContractId = lstContract[0].id;
        String OrderId = lstOrder[0].id;
 

        system.debug('** ContractId**'+ ContractId);
        Order_ProductSelectController.loadProductsbyPriceBookContract(null,ContractId,NoStudents,null,ExistingContract,ContractRenewal,PricingMethod);   	
        Order_ProductSelectController.loadProductsbyPriceBookOrder(null,OrderId ,NoStudents,null,ExistingContract,ContractRenewal,PricingMethod);
        Order_ProductSelectController.loadProductsbySearch(null,null,OrderId,'Prod');
      test.stopTest();
    }    
   
    public static testmethod void Order_StructurediscountCalculation5(){
        test.startTest();
        try
        {
            Order_ProductSelectController.returnOrder(null);
        }
        catch(Exception e) 
        {
        
        }    
        try
        {
            Order_ProductSelectController.loadProductsbyPriceBookContract(null,null,null,null,null,null,null);  
        }
        catch(Exception e) 
        {
        
        }  
        try
        {
            Order_ProductSelectController.loadProductsbyPriceBookOrder(null,null ,null,null,null,null,null); 
        }
        catch(Exception e) 
        {
        
        }
        try
        {
            Order_ProductSelectController.loadProductsbySearch(null,null,null,null); 
        }
        catch(Exception e) 
        {
        
        }  
        try
        {
            Order_ProductSelectController.loadOrderItems(null,null,null);
        }
        catch(Exception e) 
        {
        
        } 
        try
        {
            Order_ProductSelectController.InsertOrderItems(null,null,null,null,null);
        }
        catch(Exception e) 
        {
        
        } 
        try
        {
            Order_ProductSelectController.loadListPriceDiscountType(null);
        }
        catch(Exception e) 
        {
        
        } 
        try
        {
            Order_ProductSelectController.loadAssetsforRate (null,null, null);
        }
        catch(Exception e) 
        {
        
        }
        try
        {
            Order_ProductSelectController.loadAccountbyBillto(null);
        }
        catch(Exception e) 
        {
        
        }
        try
        {
            Order_ProductSelectController.loadAccountbyShipto(null, null);
        }
        catch(Exception e) 
        {
        
        }
        try
        {
            Order_ProductSelectController.returnPricebook(null);
        }
        catch(Exception e) 
        {
        
        }
              
        
        
        

        test.stopTest();
    }    


    public static testmethod void Order_ProductSelectorOpportunity1(){

        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(2,true);

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

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Opportunity> lstOpportunity =  TestDataFactory.insertOpportunityHeader(1,lstAccount,standardPricebook.id,true);
        List<OpportunityLineItem> lstOpportunityItems = TestDataFactory.insertOpportunityItems(2,lstAccount,lstOpportunity, lstPricebookEntry,true);


        Decimal NoStudents = lstAccount[0].NumberofStudents__c;
        String ContractId = lstContract[0].id; 
        String ExistingContract = 'yes';   
        String ContractRenewal = 'no';
        String PricingMethod = 'ProductUsageBased';
        String OrderId = lstOpportunity[0].id;
        String Pricebook2Id = standardPricebook.id;

      
        List<Order_ProductSelectController.OrderLineItem> OrderItems = new List<Order_ProductSelectController.OrderLineItem>();
        OrderItems = Order_ProductSelectController.loadOrderItems(lstOpportunity[0].id, 100, 'ProductUsageBased');

        for(Order_ProductSelectController.OrderLineItem OItem: OrderItems){
            OItem.IsEdited=true;
            OItem.ComponentQuantityFinal = OItem.Quantity;
        }
       

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[1].id);

        Order_ProductSelectController.returnOrder(OrderId);
        Order_ProductSelectController.InsertOrderItems(OrderItems,lstContract[0].id,OrderId,233,lstAccount);	
        Order_ProductSelectController.loadAssetsforRate (OrderId,lst_AccountId, 'ProductUsageBased');
        test.stopTest();
    }    

    public static testmethod void Order_ProductSelectorOpportunity2(){

        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(2,true);

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

        

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Opportunity> lstOpportunity =  TestDataFactory.insertOpportunityHeader(1,lstAccount,standardPricebook.id,true);
        List<OpportunityLineItem> lstOpportunityItems = TestDataFactory.insertOpportunityItems(2,lstAccount,lstOpportunity, lstPricebookEntry,true);
        
        Order_ProductSelectController.loadOrderItems(lstOpportunity[0].id, 100, 'ProductUsageBased');
        Order_ProductSelectController.loadListPriceDiscountType(lstOpportunity[0].id);
        

      test.stopTest();
    }
    public static testmethod void Order_ProductSelectorOpportunity3(){

        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(2,true);

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

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Opportunity> lstOpportunity =  TestDataFactory.insertOpportunityHeader(1,lstAccount,standardPricebook.id,false);
        
        for(Opportunity opp:lstOpportunity){
            opp.PricingMethod__c = 'OrderTotalAmount';
        }

        insert lstOpportunity;


        List<OpportunityLineItem> lstOpportunityItems = TestDataFactory.insertOpportunityItems(2,lstAccount,lstOpportunity, lstPricebookEntry,true);
        

        Order_ProductSelectController.loadOrderItems(lstOpportunity[0].id, 100, 'OrderTotalAmount');
        Order_ProductSelectController.loadListPriceDiscountType(lstOpportunity[0].id);
      test.stopTest();
    }

    public static testmethod void Order_ProductSelectorOpportunity4(){

        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(2,true);

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

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Opportunity> lstOpportunity =  TestDataFactory.insertOpportunityHeader(1,lstAccount,standardPricebook.id,true);
        List<OpportunityLineItem> lstOpportunityItems = TestDataFactory.insertOpportunityItems(2,lstAccount,lstOpportunity, lstPricebookEntry,true);
   

        Decimal NoStudents = lstAccount[0].NumberofStudents__c;
        String ExistingContract = 'yes';   
        String ContractRenewal = 'no';
        String PricingMethod = 'OrderTotalRate';
        String ContractId = lstContract[0].id;
        String OrderId = lstOpportunity[0].id;

        Order_ProductSelectController.loadProductsbyPriceBookOrder(null,OrderId ,NoStudents,null,ExistingContract,ContractRenewal,PricingMethod);
        Order_ProductSelectController.loadProductsbySearch(null,null,OrderId,'Prod');
        Order_ProductSelectController.loadAccountbyBillto(OrderId);
    }   
    
    
    public static testmethod void Order_ProductSelectorOpportunity5(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);
        
        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(1,false);

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
        Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);
     
        
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Opportunity> lstOpportunity =  TestDataFactory.insertOpportunityHeader(1,lstAccount,standardPricebook.id,true);
        List<OpportunityLineItem> lstOpportunityItems = TestDataFactory.insertOpportunityItems(2,lstAccount,lstOpportunity, lstPricebookEntryItemGroup,true);
        
        List<ListPriceDiscount__c> ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(5,'Regular','Workbooks',true);
        ListPriceDiscount = Order_TestDataFactory.insertListPriceDiscount(1,'Inspection Copy','Workbooks',false);  
  
        for(ListPriceDiscount__c lpd:ListPriceDiscount){
            lpd.DiscountType__c = 'Market Segment';
        }    
        Insert ListPriceDiscount;

        List<Id> lst_AccountId = new List<Id>();
        lst_AccountId.add(lstAccount[0].id);

        Decimal NoStudents = lstAccount[0].NumberofStudents__c;
        String ContractId = lstContract[0].id; 
        String ExistingContract = 'yes';   
        String ContractRenewal = 'no';
        String PricingMethod = 'AccountStudents';
        String OrderId = lstOpportunity[0].id;
        String Pricebook2Id = standardPricebook.id;

        
        Map<String,String> Map_itemGroup = new Map<String,String>();
        
        x=0;
        for(OpportunityLineItem item:lstOpportunityItems){
            Map_itemGroup.put(item.Product2Id ,item.id );

            //Add list price discounts
            for(ListPriceDiscount__c lpd:ListPriceDiscount){
                item.ListPriceDiscount__c = lpd.id;

            }
            item.Shipto__c=lstAccount[0].id;
            item.OrderLineType__c ='Inspection Copy';
            

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
        
        
        for(OpportunityLineItem item:lstOpportunityItems){  
          //  system.debug('**Ord_Prod_ItemGroup: 2**');          
            for(ProductComponent__c prod:lstProductComponent){
               // system.debug('**Ord_Prod_ItemGroup: 3**');
                 if(item.Product2Id == prod.Product__c && prod.MainProduct__c != null){
                    item.ItemGroup__c = Map_itemGroup.get(prod.MainProduct__c);
                    
                 } 
                 else{
                        item.DiscountedPriceItemGroup__c = item.quantity * 100;
                        item.ListPriceItemGroup__c = item.quantity * 123;
                        item.NetSalesPriceItemGroup__c =   item.quantity * 100;
                 }          
            } 
        }

        update lstOpportunityItems;
        

        List<Order_ProductSelectController.OrderLineItem> OrderItems = new List<Order_ProductSelectController.OrderLineItem>(); 
        Order_ProductSelectController.returnOrder(OrderId);	
        Order_ProductSelectController.loadAssetsforRate (OrderId,lst_AccountId, 'ProductUsageBased');

        OrderItems = Order_ProductSelectController.loadOrderItems(OrderId,NoStudents,PricingMethod);

        for(Order_ProductSelectController.OrderLineItem OItem: OrderItems){
            OItem.IsEdited=true;
            OItem.ComponentQuantityFinal = OItem.Quantity;
        }


        Order_ProductSelectController.InsertOrderItems(OrderItems,lstContract[0].id,OrderId,233,lstAccount);
        


     test.stopTest();
    }    
            
    public static testmethod void Order_ProductSelectorPricebook1(){

        test.startTest();
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();     
        Order_ProductSelectController.returnPricebook(standardPricebook.id);	
        test.stopTest();
    }    
    public static testmethod void Order_ProductSelectorPricebook2(){
        test.startTest();
        
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        Pricebook2 ProfPricebook = TestDataFactory.insertPricebookCustom2('Zorg','Noordhoff Zorg');
        Order_ProductSelectController.returnPricebook(ProfPricebook.id);
        Order_ProductSelectController.returnPricebook(null);
        Order_ProductSelectController.returnOrderLineItemMaxCount();
      	
      test.stopTest();
    }    

}