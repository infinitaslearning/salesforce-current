@IsTest
public class SK_createAccounts_TEST {
    
    @TestSetup
    static void makeData(){
        List<Account> accountList = SK_TestDataFactory.createAccounts(3, true);
    }

    @IsTest
    static void Test01(){
        
        List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList = SK_TestDataFactory.createSchoolDetails(5);
        List<Account> accountList = [SELECT Id, Name, ExternalCustomerId__c FROM Account];
        Map<String, Account> liberAccountMap = new Map<String, Account>();
        for (Account acc : accountList) {
            liberAccountMap.put(acc.ExternalCustomerId__c, acc);
        }

        Test.startTest();
            System.enqueueJob(new SK_createAccounts(schoolDetailList, liberAccountMap));
        Test.stopTest();
        
    }

    @IsTest
    static void Test02(){
        
        List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList = SK_TestDataFactory.createSchoolDetails(5);
        List<Account> accountList = [SELECT Id, Name, ExternalCustomerId__c FROM Account];
        Map<String, Account> liberAccountMap = new Map<String, Account>();
        for (Account acc : accountList) {
            liberAccountMap.put(acc.ExternalCustomerId__c, acc);
        }
        List<Account> createdAccountlist = new List<Account>();

        Test.startTest();
            System.enqueueJob(new SK_createAccounts(schoolDetailList, createdAccountlist, liberAccountMap));
        Test.stopTest();
        
    }
}