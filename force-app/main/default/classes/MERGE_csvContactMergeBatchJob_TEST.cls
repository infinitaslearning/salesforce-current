@IsTest
public class MERGE_csvContactMergeBatchJob_TEST {
    
    @TestSetup
    static void makeData(){
        Account[] parentAccount = MERGE_TestDataFactory.createAccounts(2, true);
        Contact[] contacts = MERGE_TestDataFactory.createContactsForEmailMatchingOnAccount(2, parentAccount[0], true);
    }

    @IsTest
    static void test1(){
        
            Contact[] contacts = [SELECT Id FROM Contact WHERE FirstName = 'Test2'];
            contacts[1].AccountId = [SELECT Id FROM Account WHERE Name = 'Parent Test Account 1' LIMIT 1].Id;
            update contacts[1];
            //MERGE_TestDataFactory.createAccountContactRelations([SELECT Id FROM Account LIMIT 1], contacts[1], true);
            Map<String,String> masterDuplicateIdMap = new Map<String,String>();
            masterDuplicateIdMap.put(contacts[0].Id, contacts[1].Id);

        Test.startTest();
            Id batchJobId = Database.executeBatch(new MERGE_csvContactMergeBatchJob(masterDuplicateIdMap), 200);
        Test.stopTest();
        
    }
}