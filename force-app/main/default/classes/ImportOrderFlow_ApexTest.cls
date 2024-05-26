@isTest
public class ImportOrderFlow_ApexTest {

	static final Integer NumberOfRecords = 2;
    static final String StatusIndividualWaitingNetsuite = 'Waiting Account NetsuiteId';
    static final String StatusCompleted = 'Completed';
    
	@TestSetup
    static void makeFlowData(){
        
        Account acc = new Account();
        acc.BillingCity = 'Utrecht';
        acc.BillingCountry = 'Netherlands';
        acc.BillingPostalCode = '3511SW';
        acc.BillingStreet = 'Daalsingel 1';
        acc.ShippingCity = 'Utrecht';
        acc.ShippingCountry = 'Netherlands';
        acc.ShippingPostalCode = '3511SW';
        acc.ShippingStreet = 'Daalsingel 1';
        acc.Email__c = 'test2@example.invalid';
        acc.BillingReminderEmail__c = 'test2@example.invalid';
        acc.DigitalActivationEmail__c = 'test2@example.invalid';
        acc.InvoicingEmail__c = 'test2@example.invalid';
        acc.OrderNotificationEmail__c = 'test2@example.invalid';
        acc.CommunicationLanguage__c = 'nl_NL';
        acc.CustomerCategory__c = 'Private Individual';
        acc.CustomerDiscountGroup__c = 'Private Individual';
        acc.authorFirstName__c = 'Test';
        acc.authorLastName__c = 'Test2';
        acc.Name = acc.authorFirstName__c + ' ' + acc.authorLastName__c;
        acc.OperatingCompany__c = 'Plantyn';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Private_Individuals').getRecordTypeId();
        acc.NetsuiteInternalId__c = '12345';
        acc.NetsuiteCustomerNumber__c = 'C00012345';
        insert acc;
        
        List<ImportOrder__c> ioList = new List<ImportOrder__c>();
        ImportOrder__c io;
        for(Integer i=0; i<=NumberOfRecords; i++){
            String recordEmail = 'test' + i + '@example.invalid';
            
            io = new ImportOrder__c();
            io.ExternalOrderId__c = 'Test1';
            io.customerNo__c = '0';
            io.orderDate__c = '22/09/2022';
            io.LineCount__c = 1;
            io.TotalLineCountQuantities__c = 1;
            io.Source__c = 'eCommerce B2C';
            io.deliveryIdLocation__c = '0';
            io.Shiptoemail__c = recordEmail;
            io.addressLine1__c = 'Daalsingel 1';
            io.City__c = 'Utrecht';
            io.Country__c = 'Netherlands';
            io.Postalcode__c = '3511SW';
            io.invoiceIdLocation__c = '0';
            io.InvoiceEmail__c = recordEmail;
            io.BillingStreet__c = 'Daalsingel 1';
            io.BillingCity__c = 'Utrecht';
            io.BillingCountry__c = 'Netherlands';
            io.BillingPostalCode__c = '3511SW';
            io.AmountExclVAT__c = 15.09;
            io.ShippingCost__c = 3.07;
            io.Paid__c = true;
            io.ShippingCostMethodNsId__c = '193';
            io.OperatingCompany__c = 'Plantyn';
            io.FirstName__c = 'Test';
            io.LastName__c = 'Test' + i;
            io.UserEmail__c = recordEmail;
            io.customerOrderType__c = 'private';
            io.CommunicationLanguage__c = 'nl-NL';
            
            ioList.add(io);
        }
        insert ioList;
        
    }
    
    public static testmethod void testNewPrivateIndividualImportOrder(){
        List<ImportOrder__c> ioList = [SELECT Status__c FROM ImportOrder__c WHERE UserEmail__c = 'test1@example.invalid'];
        Test.startTest();
        System.assertEquals(StatusIndividualWaitingNetsuite, ioList[0].Status__c, 'The Import Order Status should be: ' + StatusIndividualWaitingNetsuite);
        Test.stopTest();
    }
    
    public static testmethod void testExistingPrivateIndividualImportOrder(){
        List<ImportOrder__c> ioList = [SELECT Status__c FROM ImportOrder__c WHERE UserEmail__c = 'test2@example.invalid'];
        Test.startTest();
        System.assertEquals(StatusCompleted, ioList[0].Status__c, 'The Import Order Status should be: ' + StatusCompleted);
        Test.stopTest();
    }
}