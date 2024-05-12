public class SK_activateAccounts implements Queueable {
    
    public Integer batchSize = 200;

    public void execute(QueueableContext context) {

        String query = 'SELECT Id FROM Account WHERE OperatingCompany__c = \'Liber\' AND AgodiUpdateInProgress__c = true LIMIT ' + this.batchSize;
        List<Account> accounts = Database.query(query);

        for(Account acc : accounts) {
            acc.AgodiUpdateInProgress__c = false;
        }

        update accounts;
        if (accounts.size() == batchSize) {
            System.enqueueJob(new SK_activateAccounts());
        } else {
            System.debug('Skolverket update is Finished!');
        }
    }

}