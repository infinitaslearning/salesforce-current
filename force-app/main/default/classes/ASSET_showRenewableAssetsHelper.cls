public with sharing class ASSET_showRenewableAssetsHelper {

    @AuraEnabled(cacheable = true)
    public static List<Asset> getAssetListForShipTo(String recordId){
        System.debug('ASSET_showRenewableAssetsHelper - getAssetListForShipTo');
        System.debug('RecordId: ' + recordId);

        Id AssetRecordType = getAssetRecordType();

        List<Asset> assetList = [SELECT Id, Name, Product2Id, Product2.Type__c, Product2.EAN__c, SubscriptionId__c, IsActive__c, AccountId, Account.Name, Account.ExternalCustomerId__c, BillToAccount__c, BillToAccount__r.Name, ActivationDate__c, UsageEndDate,EndDate__c, RenewalDate__c, CancellationDate__c, Quantity FROM Asset WHERE Product2.Renewable__c = true AND RecordTypeId = :AssetRecordType AND AccountId = :recordId];
        System.debug('ASSET_showRenewableAssetsHelper - AssetListForShipTo size = ' + assetList.size());

        return assetList;
    }

    @AuraEnabled(cacheable = true)
    public static List<Asset> getSortedAssetListForShipTo(String recordId, String sorting, String sortField, String selectedDate){
        System.debug('ASSET_showRenewableAssetsHelper - getSortedAssetListForShipTo');

        System.debug('ASSET_showRenewableAssetsHelper - RecordId: ' + recordId);
        System.debug('ASSET_showRenewableAssetsHelper - sorting: ' + sorting);
        System.debug('ASSET_showRenewableAssetsHelper - sortField: ' + sortField);
        System.debug('ASSET_showRenewableAssetsHelper - selectedDate: ' + selectedDate);

        String startSearchDate = selectedDate + 'T00:00:00.000z';
        String stopSearchDate = selectedDate + 'T23:59:59.999z';

        System.debug('ASSET_showRenewableAssetsHelper - startSearchDate: ' + startSearchDate);
        System.debug('ASSET_showRenewableAssetsHelper - stopSearchDate: ' + stopSearchDate);

        Id AssetRecordType = getAssetRecordType();

        String query = 'SELECT Id, Name, Product2Id, Product2.Type__c, Product2.EAN__c, SubscriptionId__c, IsActive__c, AccountId, Account.Name, BillToAccount__c, BillToAccount__r.Name, ActivationDate__c, UsageEndDate,EndDate__c, RenewalDate__c, CancellationDate__c, Quantity FROM Asset WHERE Product2.Renewable__c = true AND RecordTypeId = \'' + AssetRecordType + '\' AND AccountId = \'' + recordId + '\'';
        if (sorting == 'customDate') {
            query += ' AND ' + sortField + ' = ' + selectedDate;
        } else if (sorting != 'ALL_TIMES') {
            query += ' AND ' + sortField + ' = ' + sorting;
        }
        System.debug('ASSET_showRenewableAssetsHelper - query: ' + query);
        List<Asset> assetList = Database.query(query);
       
        System.debug('ASSET_showRenewableAssetsHelper - AssetListForShipTo size = ' + assetList.size());

        return assetList;
    }

    @AuraEnabled(cacheable = true)
    public static List<Asset> getNonRenewableAssetListForShipTo(String recordId){
        System.debug('ASSET_showRenewableAssetsHelper - getNonRenewableAssetListForShipTo');
        System.debug('RecordId: ' + recordId);

        Id AssetRecordType = getAssetRecordType();

        List<Asset> assetList = [SELECT Id, Name, Product2Id, Product2.Type__c, Product2.EAN__c, IsActive__c, AccountId, Account.Name, Account.ExternalCustomerId__c, BillToAccount__c, BillToAccount__r.Name, ActivationDate__c, UsageEndDate, EndDate__c,RenewalDate__c, CancellationDate__c, Quantity FROM Asset WHERE Product2.Renewable__c = false AND RecordTypeId = :AssetRecordType AND AccountId = :recordId];
        System.debug('ASSET_showRenewableAssetsHelper - AssetListForShipTo size = ' + assetList.size());

        return assetList;
    }

    @AuraEnabled(cacheable = true)
    public static List<Asset> getNonRenewableSortedAssetListForShipTo(String recordId, String sorting, String sortField, String selectedDate){
        System.debug('ASSET_showRenewableAssetsHelper - getNonRenewableSortedAssetListForShipTo');

        System.debug('ASSET_showRenewableAssetsHelper - RecordId: ' + recordId);
        System.debug('ASSET_showRenewableAssetsHelper - sorting: ' + sorting);
        System.debug('ASSET_showRenewableAssetsHelper - sortField: ' + sortField);
        System.debug('ASSET_showRenewableAssetsHelper - selectedDate: ' + selectedDate);

        String startSearchDate = selectedDate + 'T00:00:00.000z';
        String stopSearchDate = selectedDate + 'T23:59:59.999z';

        System.debug('ASSET_showRenewableAssetsHelper - startSearchDate: ' + startSearchDate);
        System.debug('ASSET_showRenewableAssetsHelper - stopSearchDate: ' + stopSearchDate);

        Id AssetRecordType = getAssetRecordType();

        String query = 'SELECT Id, Name, Product2Id, Product2.Type__c, Product2.EAN__c, IsActive__c, AccountId, Account.Name, BillToAccount__c, BillToAccount__r.Name, ActivationDate__c, UsageEndDate,EndDate__c, RenewalDate__c, CancellationDate__c, Quantity FROM Asset WHERE Product2.Renewable__c = false AND RecordTypeId = \'' + AssetRecordType + '\' AND AccountId = \'' + recordId + '\'';
        if (sorting == 'customDate') {
            query += ' AND ' + sortField + ' = ' + selectedDate;
        } else if (sorting != 'ALL_TIMES') {
            query += ' AND ' + sortField + ' = ' + sorting;
        }
        System.debug('ASSET_showRenewableAssetsHelper - query: ' + query);
        List<Asset> assetList = Database.query(query);
       
        System.debug('ASSET_showRenewableAssetsHelper - AssetListForShipTo size = ' + assetList.size());

        return assetList;
    }

    @AuraEnabled(cacheable = true)
    public static List<Asset> getAssetListForBillTo(String recordId){
        System.debug('ASSET_showRenewableAssetsHelper - getAssetListForBillTo');
        System.debug('RecordId: ' + recordId);

        Id AssetRecordType = getAssetRecordType();

        List<Asset> assetList = [SELECT Id, Name, Product2Id, Product2.Type__c, Product2.EAN__c, SubscriptionId__c, IsActive__c, AccountId, Account.Name, Account.ExternalCustomerId__c, BillToAccount__c, BillToAccount__r.Name, ActivationDate__c, UsageEndDate,EndDate__c ,RenewalDate__c, CancellationDate__c, Quantity FROM Asset WHERE Product2.Renewable__c = true AND RecordTypeId = :AssetRecordType AND BillToAccount__c = :recordId];
        System.debug('ASSET_showRenewableAssetsHelper - AssetListForBillTo size = ' + assetList.size());

        return assetList;
    }

    @AuraEnabled(cacheable = true)
    public static List<Asset> getSortedAssetListForBillTo(String recordId, String sorting, String sortField, String selectedDate){
        System.debug('ASSET_showRenewableAssetsHelper - getSortedAssetListForBillTo');

        System.debug('ASSET_showRenewableAssetsHelper - RecordId: ' + recordId);
        System.debug('ASSET_showRenewableAssetsHelper - sorting: ' + sorting);
        System.debug('ASSET_showRenewableAssetsHelper - sortField: ' + sortField);
        System.debug('ASSET_showRenewableAssetsHelper - selectedDate: ' + selectedDate);

        String startSearchDate = selectedDate + 'T00:00:00.000z';
        String stopSearchDate = selectedDate + 'T23:59:59.999z';

        System.debug('ASSET_showRenewableAssetsHelper - startSearchDate: ' + startSearchDate);
        System.debug('ASSET_showRenewableAssetsHelper - stopSearchDate: ' + stopSearchDate);

        Id AssetRecordType = getAssetRecordType();

        String query = 'SELECT Id, Name, Product2Id, Product2.Type__c, Product2.EAN__c, SubscriptionId__c, IsActive__c, AccountId, Account.Name, BillToAccount__c, BillToAccount__r.Name, ActivationDate__c, UsageEndDate,EndDate__c ,RenewalDate__c, CancellationDate__c, Quantity FROM Asset WHERE Product2.Renewable__c = true AND RecordTypeId = \'' + AssetRecordType + '\' AND BillToAccount__c = \'' + recordId + '\'';
        if (sorting == 'customDate') {
            query += ' AND ' + sortField + ' = ' + selectedDate;
        } else if (sorting != 'ALL_TIMES') {
            query += ' AND ' + sortField + ' = ' + sorting;
        }
        System.debug('ASSET_showRenewableAssetsHelper - query: ' + query);
        List<Asset> assetList = Database.query(query);
       
        System.debug('ASSET_showRenewableAssetsHelper - AssetListForShipTo size = ' + assetList.size());

        return assetList;
    }

    @AuraEnabled(cacheable = true)
    public static List<Asset> getNonRenewableAssetListForBillTo(String recordId){
        System.debug('ASSET_showRenewableAssetsHelper - getNonRenewableAssetListForBillTo');
        System.debug('RecordId: ' + recordId);

        Id AssetRecordType = getAssetRecordType();

        List<Asset> assetList = [SELECT Id, Name, Product2Id, Product2.Type__c, Product2.EAN__c, IsActive__c, AccountId, Account.Name,Account.ExternalCustomerId__c, BillToAccount__c, BillToAccount__r.Name, ActivationDate__c, UsageEndDate,EndDate__c ,RenewalDate__c, CancellationDate__c, Quantity FROM Asset WHERE Product2.Renewable__c = false AND RecordTypeId = :AssetRecordType AND BillToAccount__c = :recordId];
        System.debug('ASSET_showRenewableAssetsHelper - AssetListForBillTo size = ' + assetList.size());

        return assetList;
    }

    @AuraEnabled(cacheable = true)
    public static List<Asset> getNonRenewableSortedAssetListForBillTo(String recordId, String sorting, String sortField, String selectedDate){
        System.debug('ASSET_showRenewableAssetsHelper - getNonRenewableSortedAssetListForBillTo');

        System.debug('ASSET_showRenewableAssetsHelper - RecordId: ' + recordId);
        System.debug('ASSET_showRenewableAssetsHelper - sorting: ' + sorting);
        System.debug('ASSET_showRenewableAssetsHelper - sortField: ' + sortField);
        System.debug('ASSET_showRenewableAssetsHelper - selectedDate: ' + selectedDate);

        String startSearchDate = selectedDate + 'T00:00:00.000z';
        String stopSearchDate = selectedDate + 'T23:59:59.999z';

        System.debug('ASSET_showRenewableAssetsHelper - startSearchDate: ' + startSearchDate);
        System.debug('ASSET_showRenewableAssetsHelper - stopSearchDate: ' + stopSearchDate);

        Id AssetRecordType = getAssetRecordType();

        String query = 'SELECT Id, Name, Product2Id, Product2.Type__c, Product2.EAN__c, IsActive__c, AccountId, Account.Name, BillToAccount__c, BillToAccount__r.Name, ActivationDate__c, UsageEndDate,EndDate__c ,RenewalDate__c, CancellationDate__c, Quantity FROM Asset WHERE product2.Renewable__c = false AND RecordTypeId = \'' + AssetRecordType + '\' AND BillToAccount__c = \'' + recordId + '\'';
        if (sorting == 'customDate') {
            query += ' AND ' + sortField + ' = ' + selectedDate;
        } else if (sorting != 'ALL_TIMES') {
            query += ' AND ' + sortField + ' = ' + sorting;
        }
        System.debug('ASSET_showRenewableAssetsHelper - query: ' + query);
        List<Asset> assetList = Database.query(query);
       
        System.debug('ASSET_showRenewableAssetsHelper - AssetListForShipTo size = ' + assetList.size());

        return assetList;
    }

    public static Id getAssetRecordType() {
        return Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
    }

}