@isTest
public class AddressValidationTest {
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
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(3,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
        for(Order ord : lstOrder){
            ord.BillToAddress__c = lstAccount[0].ShippingAddress__c;
            ord.ShipToAddress__c = lstAccount[0].ShippingAddress__c;
        }
        insert lstOrder;
        
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);
        for(OrderItem ordIt : lstOrderItems){
            ordIt.ShipToAddress__c = lstAccount[0].ShippingAddress__c;
            ordIt.OrderStatus__c = 'Draft';
        }
        
        insert lstOrderItems;
    }
    
    @isTest
    public static void testAddressImportOrderInvocable(){
        List<Account> testAcc = [SELECT Id FROM Account];
        List<ILAddress__c> addies = [SELECT Id from ILAddress__c];
            
        List<AddressValidation.Request> requests = new List<AddressValidation.Request>();
        AddressValidation.Request request = new AddressValidation.Request();
        request.street = 'DePijp';
        request.housenumber = '22';
        request.housenumberAddition = '';
        request.postalcode = '1224AM';
        request.country = 'Netherlands';
        request.accountId = testAcc[0].Id;
        requests.add(request);
        
        test.startTest();
        AddressValidation.validateAddress(requests);
        boolean updated = AddressValidation.updateOrdersANDOrderItems(addies[0].Id, true);
        test.stopTest();
    }
    
}