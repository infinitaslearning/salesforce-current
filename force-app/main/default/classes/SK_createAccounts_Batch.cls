public class SK_createAccounts_Batch implements Database.Batchable<SK_SkolverketUpdateByAPI.schoolDetails> {
    public List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList;
    public Map<String,Account> liberAccountMap;

    public SK_createAccounts_Batch(List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetails, Map<String,Account> liberAccounts) {
        this.schoolDetailList = schoolDetails;
        this.liberAccountMap = liberAccounts;
    }

    public List<SK_SkolverketUpdateByAPI.schoolDetails> start(Database.BatchableContext BC) {
        return this.schoolDetailList;
    }

    public void execute(Database.BatchableContext BC, List<SK_SkolverketUpdateByAPI.schoolDetails> scope) {
        System.debug('SK_createAccounts_Batch - EXECUTE');

        List<Account> accountsToUpsert = new List<Account>();
        for (SK_SkolverketUpdateByAPI.schoolDetails sd : scope) {
            accountsToUpsert.add(SK_createAccounts.createAccount(sd, this.liberAccountMap));
        }
        
        upsert accountsToUpsert;

    }

    public void finish(Database.BatchableContext BC) {
        System.enqueueJob(new SK_activateAccounts());
        System.debug('Skolverket account update finished');
    }
}