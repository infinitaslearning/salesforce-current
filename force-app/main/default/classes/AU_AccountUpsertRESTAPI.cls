@RestResource(urlMapping='/Account/*')
global with sharing class AU_AccountUpsertRESTAPI {
    
    @HttpPost
    global static Map<String,String> doPost(List<Account> accounts) {
        System.debug('AU_AccountUpsertRESTAPI - doPost - START');
        
        Map<String,String> returnMap = new Map<String,String>();
        
        Integer updatedAccounts = 0;
        Integer insertedAccounts = 0;
        Integer errorAccounts = 0;
        String resultString = '';
        String errormessages = '';
        
        // upsert Accounts and return upsert result feedback
        Database.UpsertResult[] results = Database.upsert(accounts, false);

        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                if (results[i].isCreated()) {
                    resultString += 'Inrichtende Machten,' + accounts[i].Id + ',' + accounts[i].ExternalCustomerId__c + ',' + accounts[i].Phone + ',inserted,\n';
                    insertedAccounts ++;
                } else {
                    resultString += 'Inrichtende Machten,' + accounts[i].Id + ',' + accounts[i].ExternalCustomerId__c + ',' + accounts[i].Phone + ',updated,\n';
                    updatedAccounts ++;
                }
            } else {
                String tmpErr = '';
                for (Database.Error err : results[i].getErrors()) {
                    tmpErr += '==> ' + err.getStatusCode() + ' : ' + err.getMessage();
                    // System.debug('==========> ERROR: ' + err.getMessage());
                    errorAccounts ++;
                }
                resultString += 'Inrichtende Machten,' + accounts[i].Id + ',' + accounts[i].ExternalCustomerId__c + ',' + accounts[i].Phone + ',error,' + tmpErr + '\n';
                errormessages += tmpErr + '\n';
            }
        }

        returnMap.put('updatedAccounts', String.valueOf(updatedAccounts));
        returnMap.put('insertedAccounts', String.valueOf(insertedAccounts));
        returnMap.put('errorAccounts', String.valueOf(errorAccounts));
        returnMap.put('resultString', resultString);
        returnMap.put('errormessages', errormessages);

        return returnMap;
    }

}