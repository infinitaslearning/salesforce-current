public with sharing class Order_AccountSubsidiary {
    

    @invocablemethod
    public static void AccountSubsidiary(List<Id> Accid){

        try {
                List<AccountSubsidiary__c> lst_AccountSubsidiary = new List<AccountSubsidiary__c>();
                Account[] lstAccount = [Select id,OperatingCompany__c,AccountSubsidiaryCount__c,isVocationalEducation__c,isHigherEducation__c from Account where id in: Accid];

                AccountSubsidiary__c[] ExistingAccountSubsidiary = [Select Account__c,LegalName__c From AccountSubsidiary__c where Account__c in:Accid];

                Set<String> Set_LegalName = new Set<String>();

                for(AccountSubsidiary__c acc:ExistingAccountSubsidiary){
                    Set_LegalName.add(acc.LegalName__c);
                }

                system.debug('**AccountSubsid**'+lstAccount);
                for(Account acc:lstAccount){
                    AccountSubsidiary__c AccountSubsidiary;
                    system.debug('**AccountSubsid**');
                if(acc.OperatingCompany__c == 'Noordhoff'){
                        
                        
                        system.debug('**NH1**');

                        if(!Set_LegalName.Contains('NoordhoffDigitaalBedrijf') && (acc.isVocationalEducation__c == true || acc.isHigherEducation__c ==true )){
                            AccountSubsidiary = new AccountSubsidiary__c(Account__c = acc.id,LegalName__c='NoordhoffDigitaalBedrijf');
                            lst_AccountSubsidiary.add(AccountSubsidiary);
                        }
                        if(!Set_LegalName.Contains('Noordhoff')){
                            AccountSubsidiary = new AccountSubsidiary__c(Account__c = acc.id,LegalName__c='Noordhoff');
                            lst_AccountSubsidiary.add(AccountSubsidiary);
                        }

                        
                }
                
                }

            if(lst_AccountSubsidiary.size()>0){
                
                    insert lst_AccountSubsidiary;
            }

            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True)
			{

                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
			}
              
        }
        catch(exception e){
            HandleCustomException.LogException(e,Accid[0]);
        }  


    }   

    public static void AccountSubsidiaryValidation(Map<Id, sObject> allProductsMap) {
        System.debug('DEBUG AccountSubsidiaryValidation: ' + allProductsMap.size());
        System.debug('DEBUG AccountSubsidiaryValidation: ' + allProductsMap.keySet());
        System.debug('DEBUG AccountSubsidiaryValidation: ' + allProductsMap.values());
        List<AccountSubsidiary__c> accountSubsidiaryToDeleteList = new List<AccountSubsidiary__c>();
        Set<Id> accValidationMatchSet = new Set<Id>();

        List<AccountSubsidiary__c> lstAccountSubsidiary = [SELECT Id, Name, IsInactive__c, Account__c FROM AccountSubsidiary__c WHERE Id IN :allProductsMap.keySet()];
        System.debug('DEBUG AccountSubsidiaryValidation lstAccountSubsidiary: ' + lstAccountSubsidiary.size());
        Set<Id> accountIdSet = new Set<Id>();
        for(AccountSubsidiary__c subsidiary : lstAccountSubsidiary){
            System.debug('DEBUG AccountSubsidiaryValidation subsidiary.Account__c: ' + subsidiary.Account__c);
            accountIdSet.add(subsidiary.Account__c);
        }
        System.debug('DEBUG AccountSubsidiaryValidation accountIdSet: ' + accountIdSet.size());
        List<Account> accountList = [SELECT Id, Name, OperatingCompany__c, AccountSubsidiaryCount__c FROM Account WHERE Id IN : accountIdSet];
        System.debug('DEBUG AccountSubsidiaryValidation accountList: ' + accountList.size());
        for(Account acc : accountList){
            System.debug('DEBUG AccountSubsidiaryValidation Account Id: ' + acc.Id);
            System.debug('DEBUG AccountSubsidiaryValidation Account OperatingCompany__c: ' + acc.OperatingCompany__c);
            System.debug('DEBUG AccountSubsidiaryValidation Account AccountSubsidiaryCount__c: ' + acc.AccountSubsidiaryCount__c);
            if(acc.OperatingCompany__c == 'Plantyn' && acc.AccountSubsidiaryCount__c == 1){
                    System.debug('DEBUG AccountSubsidiaryValidation INSIDE IF');
                    accValidationMatchSet.add(acc.Id);
                }
        }
        System.debug('DEBUG AccountSubsidiaryValidation accValidationMatchSet: ' + accValidationMatchSet.size());
        for(AccountSubsidiary__c accSub : lstAccountSubsidiary){
            if(accValidationMatchSet.contains(accSub.Id)){
                accountSubsidiaryToDeleteList.add(accSub);
            }
        }
        System.debug('DEBUG AccountSubsidiaryValidation accountSubsidiaryToDeleteList: ' + accountSubsidiaryToDeleteList.size());

        /*Map<Id,Account> accountIdMap = new Map<Id,Account>([SELECT Id, Name, OperatingCompany__c, AccountSubsidiaryCount__c FROM Account WHERE Id IN : accountIdSet AND 
                                                            ((OperatingCompany__c = 'Plantyn' AND AccountSubsidiaryCount__c =: 1 ) OR 
                                                            (OperatingCompany__c = 'Liber' AND AccountSubsidiaryCount__c =: 1 ) OR 
                                                            (OperatingCompany__c = 'Noordhoff' AND AccountSubsidiaryCount__c =: 2 ))]);

        System.debug('DEBUG AccountSubsidiaryValidation accountIdMap: ' + accountIdMap.size());
        List<AccountSubsidiary__c> accountSubsidiaryToDeleteList = new List<AccountSubsidiary__c>();
        for(AccountSubsidiary__c accSub : lstAccountSubsidiary){
            if(accountIdMap.keySet().contains(accSub.Account__c)){
                accountSubsidiaryToDeleteList.add(accSub);
            }
        }*/

        if(accountSubsidiaryToDeleteList.size() > 0){
            System.debug('DEBUG AccountSubsidiaryValidation DELETE');
            //delete accountSubsidiaryToDeleteList;
        }

        /*
        	OR(AND(AccountSubsidiaryCount__c > 1,Text(OperatingCompany__c) ='Plantyn' ),
            AND(AccountSubsidiaryCount__c > 1,Text(OperatingCompany__c) ='Liber' ),
            AND(AccountSubsidiaryCount__c > 2,Text(OperatingCompany__c) ='Noordhoff' ))
        */

    }

}