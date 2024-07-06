public class ACC_AccountHelper {
    
    @InvocableMethod(label='Update Account with Location RecordType' description='Updates Accounts with the Location RecordType' category='Account')
    public static void GetUpdateAccountLocationRecordType(List<Id> accountIds) {
        System.debug('ACC_AccountHelper - GetLocationRecordType');

        Id locationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Educational_Location').getRecordTypeId();
        System.debug('locationRecordTypeId = ' + locationRecordTypeId);
        List<Account> acclst = new List<Account>();
        for (Id accId : accountIds) {
            Account acc = new Account();
            acc.Id = accId;
            acc.RecordTypeId = locationRecordTypeId;
            acclst.add(acc);
        }
        update acclst;
    }

    public static void ValidateAccountBeforeTriggerDelete(List<Account> accounts){
        System.debug('### MERGE_StoreDeletedRecords - ValidateBeforeTriggerDelete');
        
        List<Id> accountIds = new List<Id>();
        Map<Id, Boolean> accountToAllowToDeleteMap = new Map<Id, Boolean>();
        
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        System.debug('### ValidateBeforeTriggerDelete accountIds: ' + accountIds);
        
        if (accountIds.size() > 0) {
            List<AccountSubsidiary__c> accountSubsidiariesDeleteList = [SELECT Id, Name, OutstandingBalance__c, Account__c FROM AccountSubsidiary__c WHERE Account__c IN : accountIds];
            System.debug('### ValidateBeforeTriggerDelete accountSubsidiariesDeleteList: ' + accountSubsidiariesDeleteList.size());
            
            for(AccountSubsidiary__c accSub : accountSubsidiariesDeleteList){
                if(accSub.OutstandingBalance__c > 0){
                    accountToAllowToDeleteMap.put(accSub.Account__c, false);
                }
            }
            System.debug('### ValidateBeforeTriggerDelete accountToAllowToDeleteMap: ' + accountToAllowToDeleteMap);
            
            for (Account acc : accounts) {
                
                if(accountToAllowToDeleteMap.containsKey(acc.Id) && accountToAllowToDeleteMap.get(acc.Id) == false){
                    acc.addError('Cannot delete the Account! an Account Subsidiary related to the Account has an Outstanding Balance!');
                }
            }
        }
    }

    public static void updatePackingSlipNameOnInsert(List<Account> accountList) {

        for (Account acc : accountList) {
            if (acc.Name.length() > 83) {
                acc.addError('The account name can not be longer that 83 characters');
            } else if (acc.OperatingCompany__c != 'Liber') {
                acc.PackingSlipName__c = acc.Name.length() <= 45 ? acc.Name : returnShortAccountName(acc.Name, 45);
            } else {
                acc.PackingSlipName__c = acc.Name;
            }
        }

    }

    public static void updatePackingSlipNameOnUpdate(List<Account> accountList, Map<Id,Account> oldAccountMap) {

        for (Account acc : accountList) {
            if (acc.Name != oldAccountMap.get(acc.Id).Name) {
                if (acc.Name.length() > 83) {
                    acc.addError('The account name can not be longer that 83 characters');
                } else if (acc.OperatingCompany__c == 'Liber') {
                    acc.PackingSlipName__c = acc.Name;
                }
            }
        }

    }

    public static String returnShortAccountName(String name, Integer characters) {

        String shortName = '';
        if (name.substring(characters, characters + 1) == ' ') {
            shortName = name.left(characters);
        } else {
            shortName = name.left(name.left(characters).lastIndexOf(' '));
        }

        return shortName;

    }
}