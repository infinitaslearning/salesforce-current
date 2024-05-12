@istest
public with sharing class Order_OrderUtilityQueueable_test {


    Public static testmethod void OrderUtilityQueueable1(){
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
           List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);

           for(Order ord:lstOrder){
                ord.DateUpdateBlock__c = true;
           }
           insert lstOrder;


           List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
   
           List<Id> OrderId = new List<Id>();
           
           for(Order ord:lstOrder){
                OrderId.add(ord.id);
           }
   
   
           System.enqueueJob(new Order_OrderUtilityQueueable('resetDates',OrderId));
   
           Test.stopTest();
           
       }

       Public static testmethod void OrderUtilityQueueable2(){
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

        OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];

        Integer count = integer.valueof(OrderLineItemMaxCount[0].Count__c)+3;

        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(2,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(count,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        MaxOrderLine__c MaxOrderLine = new MaxOrderLine__c();

        lstOrder = [Select LineCount__c,TotalAmount,MaxOrderLine__c From Order ];

        MaxOrderLine.LineCount__c = lstOrder[1].LineCount__c + lstOrder[0].LineCount__c;
        MaxOrderLine.OrderTotal__c = lstOrder[1].TotalAmount + lstOrder[0].TotalAmount;
        MaxOrderLine.ExpectedActivationCount__c = lstOrder.size(); 
        MaxOrderLine.ActivationReadyCount__c = lstOrder.size();

        insert MaxOrderLine;

        lstOrder[1].MasterOrder__c = lstOrder[0].id;
        lstOrder[1].MaxOrderLine__c = MaxOrderLine.id;
        lstOrder[0].MaxOrderLine__c = MaxOrderLine.id;

       
        update lstOrder;


           List<Id> OrderId = new List<Id>();
           
           for(Order ord:lstOrder){
                OrderId.add(ord.id);
           }
   
   
           System.enqueueJob(new Order_OrderUtilityQueueable('resetDates',OrderId));
   
           Test.stopTest();
           
       }

       Public static testmethod void OrderUtilityQueueable3(){
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

        OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];

        Integer count = integer.valueof(OrderLineItemMaxCount[0].Count__c)+3;

        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(2,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(count,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,true);
         

        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        MaxOrderLine__c MaxOrderLine = new MaxOrderLine__c();

        lstOrder = [Select LineCount__c,TotalAmount,MaxOrderLine__c,ShipbyDate__c From Order ];

        MaxOrderLine.LineCount__c = lstOrder[1].LineCount__c + lstOrder[0].LineCount__c;
        MaxOrderLine.OrderTotal__c = lstOrder[1].TotalAmount + lstOrder[0].TotalAmount;
        MaxOrderLine.ExpectedActivationCount__c = lstOrder.size(); 
        MaxOrderLine.ActivationReadyCount__c = lstOrder.size();

        insert MaxOrderLine;

        lstOrder[1].MasterOrder__c = lstOrder[0].id;
        lstOrder[1].MaxOrderLine__c = MaxOrderLine.id;
        lstOrder[0].MaxOrderLine__c = MaxOrderLine.id;
        lstOrder[0].ShipByDate__c = lstOrder[0].ShipByDate__c+1;
       
        update lstOrder;


           List<Id> OrderId = new List<Id>();
           
           for(Order ord:lstOrder){
                OrderId.add(ord.id);
           }
   
   
           System.enqueueJob(new Order_OrderUtilityQueueable('maxlineDates',OrderId));
   
           Test.stopTest();
           
       }
}