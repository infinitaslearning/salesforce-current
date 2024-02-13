@Istest
public with sharing class Order_ProductCalculationDates_test {
    

    Public static testmethod void ProductCalculationDates1(){
        Test.startTest();
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
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
           
           
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

        //   lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
        lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test1.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }

       //5
       Public static testmethod void ProductCalculationDates2_1(){
        Test.startTest();
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
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 9, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),7, 1);
           Date BreakDate = date.newinstance(system.today().year(), 5, 1);

           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
                prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }

           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = BreakDate-10;
                ord.ShipByDate__c = ord.EffectiveDate;
           }
           insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);

           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test2.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       //5
       Public static testmethod void ProductCalculationDates2_2(){
        Test.startTest();
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
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 9, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),7, 1);
           Date BreakDate = date.newinstance(system.today().year(), 5, 1);

           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
              
                prod.LicenseBreakDate__c = BreakDate;
           }

           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = BreakDate-10;
                ord.ShipByDate__c = ord.EffectiveDate;
           }
           insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);

           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test3.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       //1
       Public static testmethod void ProductCalculationDates3_1(){
        Test.startTest();
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
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 9, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),7, 1);
           Date BreakDate = date.newinstance(system.today().year(), 5, 1);
                
           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
                prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = BreakDate+10;
                ord.ShipByDate__c = ord.EffectiveDate;
           }
           insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test4.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       //1
       Public static testmethod void ProductCalculationDates3_2(){
        Test.startTest();
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
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 9, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),7, 1);
           Date BreakDate = date.newinstance(system.today().year(), 5, 1);
                
           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
                prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = FreeFromDate+10;
                ord.ShipByDate__c = ord.EffectiveDate;
           }
           insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);

           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test5.lstOrderItems :Size**'+lstOrderItems.size());


           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       //1
       Public static testmethod void ProductCalculationDates4_1(){
        Test.startTest();
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

           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 9, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),7, 1);
           Date BreakDate = date.newinstance(system.today().year(), 5, 1);
                
           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
                prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = Fixedstart+10;
                ord.ShipByDate__c = ord.EffectiveDate;
            }
            insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test6.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       //1
       Public static testmethod void ProductCalculationDates4_2(){
        Test.startTest();
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

           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 2, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),12, 1);
           Date BreakDate = date.newinstance(system.today().year(), 11, 1);
                
           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
                //prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = Fixedstart+10;
                ord.ShipByDate__c = ord.EffectiveDate;
            }
            insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test7.lstOrderItems :Size**'+lstOrderItems.size());


           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       //6
       Public static testmethod void ProductCalculationDates5(){
        Test.startTest();
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

           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 2, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),12, 1);
           Date BreakDate = date.newinstance(system.today().year(), 11, 1);
                
           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
                prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = BreakDate+10;
                ord.ShipByDate__c = ord.EffectiveDate;
            }
            insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

          // lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test8.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       //6
       Public static testmethod void ProductCalculationDates6_1(){
        Test.startTest();
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

           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 2, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),12, 1);
           Date BreakDate = date.newinstance(system.today().year(), 11, 1);
                
           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
               // prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = BreakDate+10;
                ord.ShipByDate__c = ord.EffectiveDate;
            }
            insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test9.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       //6
       Public static testmethod void ProductCalculationDates6_2(){
        Test.startTest();
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

           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 2, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),12, 1);
           Date BreakDate = date.newinstance(system.today().year(), 11, 1);
                
           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
                prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = FreeFromDate+2;
                ord.ShipByDate__c = ord.EffectiveDate;
            }
            insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test10.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       Public static testmethod void ProductCalculationDates6_3(){
        Test.startTest();
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

           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           Date Fixedstart = date.newinstance(system.today().year(), 2, 1);
           Date FreeFromDate = date.newinstance(system.today().year(),12, 1);
           Date BreakDate = date.newinstance(system.today().year(), 11, 1);
                
           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = Fixedstart;
                prod.FreeFromDate__c = FreeFromDate;
                prod.LicenseBreakDate__c = BreakDate;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.EffectiveDate = FreeFromDate-2;
                ord.ShipByDate__c = ord.EffectiveDate;
            }
            insert lstOrder;

           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

          // lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test11.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }
       Public static testmethod void ProductCalculationDatesNoFixeddate(){
        Test.startTest();
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
   
           List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);

           

           for(Product2 prod:lstProduct){
                prod.FixedStartDate__c = null;
           }
           update lstProduct;

           Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
           List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
           List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();

           for(Order item:lstOrder){
                OrderId.add(item.id);
           }
        

           //lstOrderItems = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
           lstOrderItems =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
           system.debug('**Order_SoqlFactory.Order_ProductCalculationDates_test12.lstOrderItems :Size**'+lstOrderItems.size());

           Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItems, lstOrder);
   
         
           Test.stopTest();
           
       }



}