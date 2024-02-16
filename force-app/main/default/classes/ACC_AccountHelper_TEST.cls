@isTest
public class ACC_AccountHelper_TEST {
   
    @TestSetup
    static void makeData(){

        Id B2BEdicationalRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('B2B Educational').getRecordTypeId();

        Account acc = new Account();
        acc.OperatingCompany__c = 'Plantyn';
        acc.Name = 'Test Account';
        acc.LegalName__c = 'Test Account';
        acc.RecordTypeId = B2BEdicationalRecordTypeId;
        acc.NumberofStudents__c = 1;
        acc.Area__c = 'Dutch';
        acc.TypeOfAccount__c = 'Sales';
        acc.CustomerCategory__c = 'Educational Institution';
        acc.ExternalDatabase__c = 'Agodi';
        acc.ExternalCustomerId__c = '12345';
        acc.AgodiUpdateInProgress__c = false;
        insert acc;
        System.debug('===> AccId in MakeData = ' + acc.Id);
    }

    @IsTest
    static void TestLocationChange(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        System.debug('===> AccId in TestMethod = ' + acc.Id);
        List<Id> accountIds = new List<Id>();

        Test.startTest();
            acc.SchoolType__c = 'Location';
            update acc;
            accountIds.add(acc.Id);
        	ACC_AccountHelper.GetUpdateAccountLocationRecordType(accountIds);
        Test.stopTest();

        System.debug('===> RecordType B2BEducational = ' + Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2BEducational').getRecordTypeId());
        System.debug('===> RecordType B2B_Educational_Location = ' + Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Educational_Location').getRecordTypeId());
        
        System.assertEquals(
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Educational_Location').getRecordTypeId(), 
            [SELECT RecordTypeId FROM Account LIMIT 1].RecordTypeId
            );
    }

    @IsTest
    static void TestLegalNameChangeAfterUpdate(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String longName = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua';

        Test.startTest();
            acc.LegalName__c = longName;
            update acc;
        Test.stopTest();
        
        Account accAfter = [SELECT Id, LegalName__c, LegalName2__c FROM Account LIMIT 1];

        System.assertEquals('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor', accAfter.LegalName__c);
        System.assertEquals('incididunt ut labore et dolore magna aliqua', accAfter.LegalName2__c);

    }

    @IsTest
    static void TestLegalNameChangeAfterInsert(){
        
        Id B2BEdicationalRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('B2B Educational').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'Test Account for Legal Name';
        acc.LegalName__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua';
        acc.RecordTypeId = B2BEdicationalRecordTypeId;
        acc.NumberofStudents__c = 1;
        acc.OperatingCompany__c = 'Plantyn';
        acc.Type = 'Educational Institution';
        acc.Area__c = 'Dutch';
        acc.TypeOfAccount__c = 'Sales';
        acc.ExternalDatabase__c = 'Agodi';
        acc.ExternalCustomerId__c = '123456';

        Test.startTest();
            insert acc;
        Test.stopTest();
        
        Account accAfter = [SELECT Id, LegalName__c, LegalName2__c FROM Account WHERE Name != 'Test Account' LIMIT 1];

        System.assertEquals('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor', accAfter.LegalName__c);
        System.assertEquals('incididunt ut labore et dolore magna aliqua', accAfter.LegalName2__c);

    }

    @isTest
    static void TestValidateAccountBeforeTriggerDelete(){

        Account acc = [SELECT Id FROM Account LIMIT 1];

        AccountSubsidiary__c accSubsidiary = new AccountSubsidiary__c();
        accSubsidiary.Account__c = acc.Id;
        accSubsidiary.Balance__c = 50;
        insert accSubsidiary;

        Test.startTest();
        try{
            delete acc;
        } catch(Exception ex){
            System.assert(ex.getMessage().contains('Cannot delete the Account! an Account Subsidiary related to the Account has an Outstanding Balance!'));
        }
        Test.stopTest();
    }
    
}