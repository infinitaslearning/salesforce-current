public class MERGE_recoverMergedAccounts_Batch {

    
    public static Integer unMergeAccounts(List<Account> mergedAccounts) {
    System.debug('MERGE_recoverMergedAccounts_Batch - unMergeAccounts()');

    //List<Account> mergedAccounts = [SELECT Id, MasterRecordId, BillingCity, ParentId FROM Account WHERE MasterRecordId != null AND LastModifiedDate > 2021-02-18T00:00:00.000z ALL ROWS];

    Set<Id> masterAccountIds = new Set<Id>();
    for (Account acc : mergedAccounts) {
        masterAccountIds.add(acc.MasterRecordId);
    }

    List<Account> masterAccounts = [SELECT Id, BillingCity, ParentId FROM Account WHERE Id IN :masterAccountIds];

    List<AccountHistory> accHistLst = [SELECT AccountId, Field, CreatedDate, NewValue, OldValue FROM AccountHistory WHERE AccountId IN :masterAccountIds AND CreatedDate > 2021-02-18T00:00:00.000z AND Field = 'Parent' ORDER BY AccountId];

    List<Account> undeleteAccounts = new List<Account>();
    List<Account> updateAccounts = new List<Account>();
    integer successes = 0;
    for (Account masterAccount : masterAccounts) {
        
        for (Account mergedAccount : mergedAccounts) {
            
            if (mergedAccount.MasterRecordId == masterAccount.Id) {
            
                if (mergedAccount.BillingCity != masterAccount.BillingCity) {

                    for (AccountHistory accHist : accHistLst) {

                        if (masterAccount.Id == accHist.AccountId) {
                            if (accHist.OldValue == null) {
                                masterAccount.ParentId = null;
                                updateAccounts.add(masterAccount);
                            } else if (String.ValueOf(accHist.OldValue).subString(0,1) == '00') {
                                masterAccount.ParentId = String.ValueOf(accHist.OldValue);
                                updateAccounts.add(masterAccount);
                            }
                        }
                    }
                    undeleteAccounts.add(mergedAccount);
                }
            
            }
            
        }
    }

    if (undeleteAccounts.size() > 0) {
        successes = undeleteAccounts.size();
        undelete undeleteAccounts;
        for (Account acc : undeleteAccounts) {
            acc.TEMP_undeleted__c = true;
        }
        update undeleteAccounts;
    }
    

    if (updateAccounts.size() > 0) {
        update updateAccounts;
    }

    System.debug('Nr of Accounts to Undelete: ' + undeleteAccounts.size());
    System.debug('Nr of Accounts to update: ' + updateAccounts.size());
    
    return successes;

    }

}