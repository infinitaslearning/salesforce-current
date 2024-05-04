@IsTest
public class SU_StudentUserNumbersTriggerHandler_TEST {
    
    @TestSetup
    static void makeData(){
        
        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            Account Acc = new Account();
            Acc.RecordTypeId = recordTypeId;
            Acc.Name = 'Test School ' + (i + 1);
            Acc.OperatingCompany__c = 'Plantyn';
            acc.CustomerCategory__c = 'Educational Institution';
            Acc.NetsuiteInternalId__c = '1234' + (i+1);
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.BillingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22';
            Acc.invoicingEmail__c = 'test' + (i + 1) + '@test.be';
            Acc.Phone = '+123456789';
            Acc.Website = 'http://www.testwebsite.be';
            Acc.Type = 'Customer';
            accounts.add(Acc);
        }
        
        insert accounts;
        
        List<StudentAndUsernumbers__c> suList = new List<StudentAndUsernumbers__c>();
        for (Account Acc : accounts) {
            StudentAndUsernumbers__c su = new StudentAndUsernumbers__c();
            su.StartDate__c = Date.today().addMonths(-2);
            su.EndDate__c = Date.today().addMonths(10);
            su.Type__c = 'Student Numbers';
            su.Account__c = Acc.Id;
            su.TotalNumber__c = 15;
            su.KindergartenNumber__c = 1;
            su.PrimaryEducationNumber__c = 2;
            su.SecondaryEducationNumber__c = 3;
            su.HigherEducationNumber__c = 4;
            su.VocationalEducationNumber__c = 5;
            suList.add(su);
        }
        
        insert suList;
    }

    @IsTest
    static void testInsert(){
        
        Id accountId = [SELECT Id FROM Account WHERE Name = 'Test School 1'].Id;

        StudentAndUsernumbers__c su = new StudentAndUsernumbers__c();
        su.StartDate__c = Date.today().addMonths(-2);
        su.EndDate__c = Date.today().addMonths(10);
        su.Type__c = 'Student Numbers';
        su.Account__c = accountId;
        su.TotalNumber__c = 150;
        su.KindergartenNumber__c = 10;
        su.PrimaryEducationNumber__c = 20;
        su.SecondaryEducationNumber__c = 30;
        su.HigherEducationNumber__c = 40;
        su.VocationalEducationNumber__c = 50;
        
        Test.startTest();
            insert su;
        Test.stopTest();
        
        Account accountAfterInsert = [SELECT Id, NumberofStudents__c, KGStudents__c, PEStudents__c, SEStudents__c, HEStudents__c, VEStudents__c FROM Account WHERE Name = 'Test School 1'];

        System.assertEquals(165, accountAfterInsert.NumberofStudents__c);
        System.assertEquals(11, accountAfterInsert.KGStudents__c);
        System.assertEquals(22, accountAfterInsert.PEStudents__c);
        System.assertEquals(33, accountAfterInsert.SEStudents__c);
        System.assertEquals(44, accountAfterInsert.HEStudents__c);
        System.assertEquals(55, accountAfterInsert.VEStudents__c);
    }

    @IsTest
    static void testUpdate(){
        
        List<Account> accounts = [SELECT Id FROM Account];

        List<StudentAndUsernumbers__c> suList = new List<StudentAndUsernumbers__c>();
        for (Account Acc : accounts) {
            StudentAndUsernumbers__c su = [SELECT Id FROM StudentAndUsernumbers__c WHERE Account__c = :Acc.Id];
            su.StartDate__c = Date.today().addMonths(-2);
            su.EndDate__c = Date.today().addMonths(10);
            su.Type__c = 'Student Numbers';
            su.Account__c = Acc.Id;
            su.TotalNumber__c = 150;
            su.KindergartenNumber__c = 10;
            su.PrimaryEducationNumber__c = 20;
            su.SecondaryEducationNumber__c = 30;
            su.HigherEducationNumber__c = 40;
            su.VocationalEducationNumber__c = 50;
            suList.add(su);
        }
        
        Test.startTest();
            update suList;
        Test.stopTest();
        
        Account accountAfterInsert = [SELECT Id, NumberofStudents__c, KGStudents__c, PEStudents__c, SEStudents__c, HEStudents__c, VEStudents__c FROM Account WHERE Name = 'Test School 1'];

        System.assertEquals(150, accountAfterInsert.NumberofStudents__c);
        System.assertEquals(10, accountAfterInsert.KGStudents__c);
        System.assertEquals(20, accountAfterInsert.PEStudents__c);
        System.assertEquals(30, accountAfterInsert.SEStudents__c);
        System.assertEquals(40, accountAfterInsert.HEStudents__c);
        System.assertEquals(50, accountAfterInsert.VEStudents__c);
    }

    @IsTest
    static void testDelete(){
        
        Id accountId = [SELECT Id FROM Account WHERE Name = 'Test School 1'].Id;

        StudentAndUsernumbers__c su = [SELECT Id, TotalNumber__c FROM StudentAndUsernumbers__c WHERE Account__c = :accountId];
        System.debug('TestDebug ==> SU TotalNumber = ' + su.TotalNumber__c);
        
        Test.startTest();
            delete su;
        Test.stopTest();
        
        Account accountAfterInsert = [SELECT Id, NumberofStudents__c, KGStudents__c, PEStudents__c, SEStudents__c, HEStudents__c, VEStudents__c FROM Account WHERE Name = 'Test School 1'];

        System.debug('TestDebug ==> Number of students = ' + accountAfterInsert.NumberofStudents__c);
        System.assert(accountAfterInsert.NumberofStudents__c == null, 'Number of Students is not empty');
        System.assert(accountAfterInsert.KGStudents__c == null, 'field: KGStudents__c is not empty');
        System.assert(accountAfterInsert.PEStudents__c == null, 'field: PEStudents__c is not empty');
        System.assert(accountAfterInsert.SEStudents__c == null, 'field: SEStudents__c is not empty');
        System.assert(accountAfterInsert.HEStudents__c == null, 'field: HEStudents__c is not empty');
        System.assert(accountAfterInsert.VEStudents__c == null, 'field: VEStudents__c is not empty');
    }
}