@isTest
public without sharing class AddressImportOrderInvocableTest {

    @testSetup static void createTestData(){
        //create Account
        List<Account> testAcc = TestDataFactory.insertAccounts(1, 'Plantyn', false);
        insert testAcc;
        //create ILAddress__c
        ILAddress__c accountShippinAddress = new ILAddress__c();
        accountShippinAddress.Account__c = testAcc[0].Id;
        accountShippinAddress.Street__c = 'DePijp';
        accountShippinAddress.HouseNumber__c = '22';
        accountShippinAddress.HouseNumberAddition__c = '';
        accountShippinAddress.PostalCode__c = '1224AM';
        accountShippinAddress.City__c = 'Amsterdam';
        accountShippinAddress.Country__c = 'Netherlands';
        insert accountShippinAddress;
    }
    
    @isTest
    public static void testAddressImportOrderInvocable(){
        List<Account> testAcc = [SELECT Id FROM Account];
            
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
        AddressImportOrderInvocable.validateImportOrderAddress(requests);
        test.stopTest();
    }
    
}