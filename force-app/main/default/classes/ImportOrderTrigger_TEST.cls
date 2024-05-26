@isTest
public class ImportOrderTrigger_TEST {
    public static testMethod void testImportOrderTrigger(){
        ImportOrder__c ioRec = new ImportOrder__c();
        ioRec.Status__c = 'Pending';
        ioRec.LineCount__c = 2;
        ioRec.OperatingCompany__c = 'Plantyn';
        ioRec.Source__c = 'eCommerce B2C';
        ioRec.quantity__c = 0;
        ioRec.FirstName__c = 'con';
        ioRec.LastName__c = 'con';
        ioRec.email__c = 'test@test.com';
        ioRec.customerOrderType__c = 'private';
        
        
        test.startTest();
        	insert ioRec;
        test.stopTest();
    }
}