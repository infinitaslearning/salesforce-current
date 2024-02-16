@IsTest
public class SK_getLiberAccountsQueueable_TEST {
    
    @TestSetup
    static void makeData(){
        List<Account> accounts = SK_TestDataFactory.createAccounts(5, true);
    }

    @IsTest
    static void test01(){
        
        List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList = new List<SK_SkolverketUpdateByAPI.schoolDetails>();
        
        Test.startTest();
            System.enqueueJob(new SK_getLiberAccountsQueueable(schoolDetailList));
        Test.stopTest();
    }

    @IsTest
    static void test02(){
        
        List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList = new List<SK_SkolverketUpdateByAPI.schoolDetails>();
        List<Account> queriedAccounts = new List<Account>();
        Id lastId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
            System.enqueueJob(new SK_getLiberAccountsQueueable(schoolDetailList, queriedAccounts, lastId));
        Test.stopTest();
    }
}