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



}