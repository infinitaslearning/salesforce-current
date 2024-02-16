@istest
public with sharing class Order_OrderLineCountManager_test {

    public static testmethod void OrderLineCountManage(){

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

        OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];

        Integer count = integer.valueof(OrderLineItemMaxCount[0].Count__c)+3;

        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
        
        for(Order ord:lstOrder){
            ord.source__c = 'eCommerce B2B';
        }
        Insert lstOrder;

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(count,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         

        List<Id> OrderId = new List<Id>();


        for(Order ord:lstOrder){
            OrderId.add(ord.id);
        }

            UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;

            //Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(OrderId, null);

            Order[] lst_Order = Order_SoqlFactory.returnQueryOrder(OrderId,null,null);
            system.debug('**Order_SoqlFactory.Order_OrderLineCountManager_test1.lst_Order :Size**'+lst_Order.size());
            
            system.debug('**LineCount**'+lst_Order[0].LineCount__c);

            if(lst_Order[0].LineCount__c>3){
           
                    System.enqueueJob(new Order_OrderLineCountManager(lst_Order,'Start'));
                   
            }
    }

    /*
        public static testmethod void OrderLineCountManage2(){

            List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);

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

        OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];

        Integer count = integer.valueof(OrderLineItemMaxCount[0].Count__c)+3;

        List<Product2> lstProductItemGroup = TestDataFactory.insertProducts(count+3,true);
        List<Product2> lstProductItem = TestDataFactory.insertProducts(count,false);

        Integer ISBN = lstProductItemGroup.size()+1;
        
        i = 0;
        
        for(Product2 prod:lstProductItem){
            prod.ISBN__c = prod.ISBN__c + i;
            i++;
        }

        insert lstProductItem;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
      //  List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProductItem,true);

        Pricebook2 PricebookCustom = TestDataFactory.insertPricebookCustom('Plantyn - All 2021');
       // lstPricebookEntry = TestDataFactory.insertPricebookEntry(PricebookCustom.id ,lstProductItem,true);

        List<ProductComponent__c> lstProductComponent = Order_TestDataFactory.InsertGroupComponent(lstProductItem,lstProductItemGroup,true);

        
        Order_TestDataFactory.InsertPricing(lstProductItemGroup,null,true);
        Pricing__c[] lstPricing = Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);

        Pricing__c[] lstPricingComponent = Order_TestDataFactory.InsertPricingProductComponent(lstProductComponent,true);
     
        String OrderExternalId = 'Ext123';


        Pricing__c[] lstPricingCheck = [Select ProductComponent__r.Product__c from Pricing__c where ProductComponent__r.Product__c !=: null];

        system.debug('**Price check: lstPricingCheck**'+lstPricingCheck.size());


       PricebookEntry[] lstPricebookEntry = [Select id, Pricebook2.Name,Product2.ISBN__c from PricebookEntry];



       system.debug('**Before Import Order**');
        lstAccount = [Select NetsuiteInternalId__c from Account];
       List<ImportOrder__c> lstinsertImportOrder = Order_TestDataFactory.insertImportOrderOrder(lstAccount,true,OrderExternalId);
       List<ImportOrder__c> lstinsertImportOrderItem = Order_TestDataFactory.insertImportOrderItem(lstProductItem,false,OrderExternalId,null);
       List<ImportOrder__c> lstinsertImportOrderItemGroup = Order_TestDataFactory.insertImportOrderItem(lstProductItemGroup,false,OrderExternalId,lstProductItem[0].ISBN__c);


       
       lstinsertImportOrderItem.addAll(lstinsertImportOrderItemGroup);
       insert lstinsertImportOrderItem;
*/
/*
            List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,PricebookCustom.id,true);
            List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,PricebookCustom.id,true);
             List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(count,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         */
/*
        List<Id> OrderId = new List<Id>();
        Order[] lstOrder = [Select id,Pricebook2.Name from Order];
        system.debug('**lstOrder.size**'+lstOrder.size());

        for(Order ord:lstOrder){
            OrderId.add(ord.id);
        }

            UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;

            Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(OrderId, null);
            
            system.debug('**LineCount**'+lst_Order[0].LineCount__c);

            if(lst_Order[0].LineCount__c>3){
           
                    System.enqueueJob(new Order_OrderLineCountManager(lst_Order,'Next'));
                   
            }
    
    }
    */
    public static testmethod void OrderLineCountManage2(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
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
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

        for(Order ord:lstOrder){
            ord.source__c = 'eCommerce B2B';
        }
        Insert lstOrder;

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
        
        Map<String,String> Map_itemGroup = new Map<String,String>();
        
        x=0;
        for(OrderItem item:lstOrderItems){
            Map_itemGroup.put(item.Product2Id ,item.id );

            //Add list price discounts
            item.ShipToAccount__c=lstAccount[0].id;
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
                    system.debug('**ITEM GROUP LINK 3**'+Map_itemGroup.get(prod.MainProduct__c));
                    item.ItemGroup__c = Map_itemGroup.get(prod.MainProduct__c);
                 } 
                 else{
                   item.ProductType__c  = 'Item Group';
                 }
                       
            } 
        }

        update lstOrderItems;


        List<Id> OrderId = new List<Id>();

        for(Order ord:lstOrder){
            OrderId.add(ord.id);
        }

            UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;

           // Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(OrderId, null);

            Order[] lst_Order = Order_SoqlFactory.returnQueryOrder(OrderId,null,null);
            system.debug('**Order_SoqlFactory.Order_OrderLineCountManager_test2.lst_Order :Size**'+lst_Order.size());
            
            system.debug('**LineCount**'+lst_Order[0].LineCount__c);

            if(lst_Order[0].LineCount__c>3){
           
                    System.enqueueJob(new Order_OrderLineCountManager(lst_Order,'Next'));
                   
            }

           test.stopTest();
    }

    public static testmethod void OrderLineCountManage3(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);
        
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
        lstPricebookEntryItem.AddAll(lstPricebookEntryItemGroup);

        
        //Fires Process Builder (Invocable method)
        Order_TestDataFactory.InsertPricing(lstProductItem,lstProductComponent,true);
        
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

        for(Order ord:lstOrder){
            ord.source__c = 'eCommerce B2B';
        }
        Insert lstOrder;

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

        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntryItem,true);
        
        Map<String,String> Map_itemGroup = new Map<String,String>();
        
        x=0;
        for(OrderItem item:lstOrderItems){
            Map_itemGroup.put(item.Product2Id ,item.id );

            //Add list price discounts
            item.ShipToAccount__c=lstAccount[0].id;
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
                    system.debug('**ITEM GROUP LINK 3**'+Map_itemGroup.get(prod.MainProduct__c));
                    item.ItemGroup__c = Map_itemGroup.get(prod.MainProduct__c);
                 } 
                 else{
                   item.ProductType__c  = 'Item Group';
                 }
                       
            } 
        }

        update lstOrderItems;


        List<Id> OrderId = new List<Id>();

        for(Order ord:lstOrder){
            OrderId.add(ord.id);
        }

            UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;

            //Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(OrderId, null);

            Order[] lst_Order = Order_SoqlFactory.returnQueryOrder(OrderId,null,null);
            system.debug('**Order_SoqlFactory.Order_OrderLineCountManager_test3.lst_Order :Size**'+lst_Order.size());
            
            system.debug('**LineCount**'+lst_Order[0].LineCount__c);

            if(lst_Order[0].LineCount__c>3){
           
                    System.enqueueJob(new Order_OrderLineCountManager(lst_Order,'Next'));
                   
            }

           test.stopTest();
    }


}