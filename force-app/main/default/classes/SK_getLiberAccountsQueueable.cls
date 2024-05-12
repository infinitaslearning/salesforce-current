public class SK_getLiberAccountsQueueable implements Queueable{

    public String lastId = '';
    public List<Account> liberAccounts;
    public List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetails;

    public SK_getLiberAccountsQueueable(List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList) {
        this.liberAccounts = new List<Account>();
        this.schoolDetails = schoolDetailList;
    }

    public SK_getLiberAccountsQueueable(List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList, List<Account> queriedAccounts, String idFromLastQuery) {
        this.liberAccounts = queriedAccounts;
        this.lastId = idFromLastQuery;
        this.schoolDetails = schoolDetailList;
    }

    public void execute(QueueableContext context) {

        List<Account> newAccounts = getCurrentLiberAccounts(this.lastId);
        this.liberAccounts.addAll(newAccounts);

        if (newAccounts.size() < 50000 && newAccounts.size() > 0 && !Test.isRunningTest()) {
            System.enqueueJob(new SK_getLiberAccountsQueueable(this.schoolDetails, this.liberAccounts, newAccounts[newAccounts.size()-1].Id));
        } else {
            System.debug('DONE getting Accounts, we found ' + this.liberAccounts.size() + ' Accounts, creating Map now');
            Map<String, Account> liberExtCustIdAccountMap = new Map<String, Account>();
            for (Account acc : this.liberAccounts) {
                liberExtCustIdAccountMap.put(acc.ExternalCustomerId__c, acc);
            }
            if (!Test.isRunningTest()) {
                System.enqueueJob(new SK_createAccounts(this.schoolDetails, liberExtCustIdAccountMap));
            }
        }
    }

    public List<Account> getCurrentLiberAccounts(String lastId) {

        List<Account> returnList;

        try {
            
            if (lastId == '') {
                returnList = [SELECT
                Id,
                Name,
                ExternalCustomerId__c
                FROM Account
                WHERE OperatingCompany__c = 'Liber'
                AND ExternalDatabase__c = 'Skolverket'
                AND ExternalCustomerId__c != '' 
                LIMIT 50000];
            } else {
                returnList = [SELECT
                Id,
                Name,
                ExternalCustomerId__c
                FROM Account
                WHERE OperatingCompany__c = 'Liber'
                AND ExternalDatabase__c = 'Skolverket'
                AND ExternalCustomerId__c != '' 
                AND Id > : lastId
                LIMIT 50000];
            }

        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
            HandleCustomException.LogException(e);
        } 

        return returnList;
    }

}