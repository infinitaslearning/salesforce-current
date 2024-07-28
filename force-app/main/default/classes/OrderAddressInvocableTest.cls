@isTest
public class OrderAddressInvocableTest {
    @testSetup static void createTestData(){
        //create Account
        List<Account> lstAccount = TestDataFactory.insertAccounts(1, 'Plantyn', false);
        insert lstAccount;
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
        
        //create ILAddress__c
        ILAddress__c accountShippinAddress = new ILAddress__c();
        accountShippinAddress.Account__c = lstAccount[0].Id;
        accountShippinAddress.Street__c = 'Daalsesingel';
        accountShippinAddress.HouseNumber__c = '51';
        accountShippinAddress.HouseNumberAddition__c = '';
        accountShippinAddress.PostalCode__c = '3511SW';
        accountShippinAddress.City__c = 'Utrecht';
        accountShippinAddress.Country__c = 'Netherlands';
        insert accountShippinAddress;
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
        for(Order ord : lstOrder){
            ord.BillToAddress__c = accountShippinAddress.Id;
            ord.ShipToAddress__c = accountShippinAddress.Id;
        }
        insert lstOrder;
        
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        for(OrderItem ordIt : lstOrderItems){
            ordIt.ShipToAddress__c = accountShippinAddress.Id;
            ordIt.OrderStatus__c = 'Draft';
        }
        
        insert lstOrderItems;
    }
    
    @isTest
    public static void testAddressImportOrderInvocable(){
        List<Account> testAcc = [SELECT Id FROM Account];
        List<ILAddress__c> addies = [SELECT Id from ILAddress__c];
        List<Order> ordLs = [SELECT Id from Order];
        
        List<OrderAddressInvocable.Request> requests = new List<OrderAddressInvocable.Request>();
        OrderAddressInvocable.Request request = new OrderAddressInvocable.Request();
        request.street = 'Daalsesingel';
        request.housenumber = '51';
        request.housenumberAddition = '';
        request.postalcode = '3511SW';
        request.country = 'Netherlands';
        request.shipToAccountId = testAcc[0].Id;
        request.OrderId = ordLs[0].Id;
        requests.add(request);
        
        test.startTest();
        OrderAddressInvocable.updateOrderItems(requests);
        
        test.stopTest();
    }
}