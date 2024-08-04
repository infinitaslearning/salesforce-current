@IsTest
public class SK_createAccounts_TEST {
    
    @TestSetup
    static void makeData(){
        List<Account> accountList = SK_TestDataFactory.createAccounts(3, true);
    }

    @IsTest
    static void TestUpdate(){
        
        SK_SkolverketUpdateByAPI.schoolDetails schoolDetail = SK_TestDataFactory.createSchoolDetail();
        List<Account> accountList = [SELECT Id, Name, ExternalCustomerId__c FROM Account];
        Map<String, Account> liberAccountMap = new Map<String, Account>();
        for (Account acc : accountList) {
            liberAccountMap.put(acc.ExternalCustomerId__c, acc);
        }

        Test.startTest();
            Account acc = SK_createAccounts.createAccount(schoolDetail, liberAccountMap);
        Test.stopTest();
        
    }

    @IsTest
    static void TestInsert(){
        
        SK_SkolverketUpdateByAPI.schoolDetails schoolDetail = SK_TestDataFactory.createSchoolDetail();
        List<Account> accountList = [SELECT Id, Name, ExternalCustomerId__c FROM Account];
        Map<String, Account> liberAccountMap = new Map<String, Account>();

        Test.startTest();
            Account acc = SK_createAccounts.createAccount(schoolDetail, liberAccountMap);
        Test.stopTest();
        
    }

}