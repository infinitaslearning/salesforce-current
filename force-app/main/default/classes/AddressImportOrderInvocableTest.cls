@isTest
public without sharing class AddressImportOrderInvocableTest {

    @testSetup static void createTestData(){
        //create Account
        List<Account> testAcc = TestDataFactory.insertAccounts(1, 'Plantyn', false);
        insert testAcc;
        //create ILAddress__c
        ILAddress__c accountShippinAddress = new ILAddress__c();
        accountShippinAddress.Account__c = testAcc[0].Id;
        accountShippinAddress.Street__c = 'Daalsesingel';
        accountShippinAddress.HouseNumber__c = '51';
        accountShippinAddress.HouseNumberAddition__c = '';
        accountShippinAddress.PostalCode__c = '3511SW';
        accountShippinAddress.City__c = 'Utrecht';
        accountShippinAddress.Country__c = 'Netherlands';
        insert accountShippinAddress;
    }
    
    @isTest
    public static void testAddressImportOrderInvocable(){
        List<Account> testAcc = [SELECT Id FROM Account];
            
        List<AddressValidation.Request> requests = new List<AddressValidation.Request>();
        AddressValidation.Request request = new AddressValidation.Request();
        request.street = 'Daalsesingel';
        request.housenumber = '51';
        request.housenumberAddition = '';
        request.postalcode = '3511SW';
        request.country = 'Netherlands';
        request.accountId = testAcc[0].Id;
        requests.add(request);
        
        test.startTest();
        AddressImportOrderInvocable.validateImportOrderAddress(requests);
        test.stopTest();
    }
    
}