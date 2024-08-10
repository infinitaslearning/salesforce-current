@isTest
public class ReportEmailerSchedulerTest {
    public static testMethod void ReportEmailerSchedulerTest() {
        /*Report rep = [SELECT Id FROM Report LIMIT 1]; // NEED A REPORT TO TEST
@isTest(SeeAllData = true)
        Report_Emailer_Setting__mdt customMetaData = new Report_Emailer_Setting__mdt();
        customMetaData.Report_Export_File_Name__c = 'TestExport';
        customMetaData.Report_Id__c = rep.Id;
        customMetaData.Report_Name__c = 'Test Export';
        customMetaData.Recipient_Email__c = 'connor@cloudmuscle.nl';
        insert customMetaData;*/
        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);

    List<Id> Set_AccId = new List<Id>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        Order_AccountSubsidiary.AccountSubsidiary(Set_AccId);

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);


        List<Id> RecordIds = new List<Id>();
        Set<Id> Set_RecordIds = new Set<Id>();
        for(Order ord:lstOrder){
            system.debug('**Map_AccSub**'+Map_AccSub.get(ord.AccountId));
            ord.AccountSubsidiary__c = Map_AccSub.get(ord.AccountId); 
            ord.NetSuiteIdAccountSubsidiary__c = '12345';
          //  RecordIds.add(ord.id);
           // Set_RecordIds.add(ord.id);
        }
        Insert lstOrder;

        for(OrderItem item:lstOrderItems){
            system.debug('**Map_AccSub**'+Map_AccSub.get(item.ShipToAccount__c));
            item.AccountSubsidiary__c = Map_AccSub.get(item.ShipToAccount__c); 
            item.OrderId = lstOrder[0].id;
        }

        insert lstOrderItems;

        
        ReportEmailerScheduler s = new ReportEmailerScheduler();
        s.execute(null);
        test.stopTest();
    }
}