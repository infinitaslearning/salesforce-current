global class SK_createAccounts_Batch implements Database.Batchable<sObject>, Database.Stateful {

    global List<Account> accounts;
    
    global SK_createAccounts_Batch(List<Account> accountList) {
        this.accounts = accountList;
    }

    global List<Account> start(Database.BatchableContext BC) {
        return this.accounts;
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        System.debug('SK_createAccounts_Batch - EXECUTE');
        
        upsert scope;

    }

    global void finish(Database.BatchableContext BC) {
        System.enqueueJob(new SK_activateAccounts());
        System.debug('Skolverket account update finished');
    }
}