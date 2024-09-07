@IsTest
public class BL_customBooklistHelper_TEST {
    
    @TestSetup
    static void makeData(){
        
        Account acc = New Account();
        acc.Name = 'Test Account';
        acc.OperatingCompany__c = 'Plantyn';
        acc.NumberofStudents__c = 0;
        acc.Area__c = 'Dutch';
        insert acc;

        Id booklistRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Booklist').getRecordTypeId();

        Asset asset1 = New Asset();
        asset1.Name = 'Base Asset';
        asset1.RecordTypeId = booklistRecordTypeId;
        asset1.Quantity = 1;
        insert asset1;

        List<Asset> assetList = New List<Asset>();
        // CREATE BOOKLISTS
        for (Integer i = 0; i < 7; i++) {
            Asset a = New Asset();
            a.Name = 'Test Booklist ' + (i+1);
            a.SchoolYear__c = (2014 + i) + '-' + (2015 + i);
            a.Booklist__c = asset1.Id;
            a.Subtype__c = 'Lager';
            if (i < 4) {
                a.Year1__c = true;
             } else {
                a.Year1__c = false;
             }
             if (i < 3) {
                 a.Year2__c = false;
             } else {
                 a.Year2__c = true;
             }
             if (i < 3) {
                a.Year3__c = false;
            } else {
                a.Year3__c = true;
            }
            if (i > 5) {
                a.Year4__c = false;
            } else {
                a.Year4__c = true;
            }
            if (i > 4) {
                a.Year5__c = false;
            } else {
                a.Year5__c = true;
            }
            if (i > 2) {
                a.Year6__c = false;
            } else {
                a.Year6__c = true;
            }
            a.RecordTypeId = booklistRecordTypeId;
            a.AccountId = acc.Id;
            a.IsSalesStatistic__c = false;
            a.Quantity = 1;
            assetList.add(a);
        }

        Product2 p = New Product2();
        p.Name = 'Test Product';
        p.Type__c = 'Item Group';
        p.Use__c = 'Sales Item';
        p.StartDate__c = Date.today().addDays(-1);
        insert p;

        // CREATE SALES STATISTICS
        for (Integer i = 0; i < 5; i++) {
            Asset newAsset = New Asset();
            newAsset.Name = 'Test Sates Statistic ' + (i+1);
            newAsset.SchoolYear__c = (2014 + i) + '-' + (2015 + i);
            newAsset.Product2Id = p.Id;
            newAsset.Quantity = 50;
            newAsset.Value__c = 10;
            newAsset.Year__c = 2017 + i;
            newAsset.RecordTypeId = booklistRecordTypeId;
            newAsset.AccountId = acc.Id;
            newAsset.IsSalesStatistic__c = true;
            assetList.add(newAsset);
        }
        insert assetList;
    }

    @IsTest
    static void testGetBookLists(){
        
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
            List<Asset> assetList = BL_customBookListHelper.getBookLists(accountId);
        Test.stopTest();

        System.assertEquals(7, assetList.size());
        
    }

    @IsTest
    static void testGetSalesStatistics(){
        
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
            List<Asset> assetList = BL_customBookListHelper.getSalesStatistics(accountId);
        Test.stopTest();

        System.assertEquals(5, assetList.size());
        
    }
}