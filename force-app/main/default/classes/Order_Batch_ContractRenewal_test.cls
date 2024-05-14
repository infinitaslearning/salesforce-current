@istest
public with sharing class Order_Batch_ContractRenewal_test {
  
    
    public static testmethod void Order_B2BOrderInvoice1(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);
        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        Pricebook2 ProfPricebook = TestDataFactory.insertPricebookCustom2('Zorg','Noordhoff Zorg');
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,ProfPricebook.id,false);

        for(Contract con:lstContract){
            con.StartDate = system.today()-364;
            con.ContractTerm = 12;
            con.OperatingCompany__c ='Noordhoff Zorg';
        }
        insert lstContract;
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
        for(Asset ass:lst_Asset){
            ass.RenewalDate__c = system.today()+1;
            ass.RenewalRunDate__c = system.today()+1;
            ass.AutomatedRenewProcess__c = true;
            ass.Contract__c = lstContract[0].id ;
        }
        Insert lst_Asset;

        lstContract = [SELECT Id,ContractTerm,EndDate  FROM Contract];
        
        system.debug('**End Date**'+lstContract[0].EndDate);
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_Batch_ContractRenewal  ContractRenewal = new Order_Batch_ContractRenewal();
        database.executebatch(ContractRenewal ,100);

        test.stoptest();

    }

    public static testmethod void Order_B2BOrderInvoice2(){


        test.startTest();
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);
        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        Pricebook2 ProfPricebook = TestDataFactory.insertPricebookCustom2('Zorg','Noordhoff Zorg');
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,ProfPricebook.id,false);
        

        for(Contract con:lstContract){
            con.StartDate = system.today()-364;
            con.ContractTerm = 12;
            con.OperatingCompany__c ='Noordhoff Zorg';
        }
        insert lstContract;
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
        for(Asset ass:lst_Asset){
            ass.RenewalDate__c = system.today()+1;
            ass.RenewalRunDate__c = system.today()+1;
            ass.AutomatedRenewProcess__c = true;
            ass.Contract__c = lstContract[0].id ;
        }
        Insert lst_Asset;

        lstContract = [SELECT Id,ContractTerm,EndDate  FROM Contract];
        
        system.debug('**End Date**'+lstContract[0].EndDate);
        
        Order_Batch_ContractRenewal  ContractRenewal = new Order_Batch_ContractRenewal();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, ContractRenewal);  


         test.stoptest();
    }

    public static testmethod void Order_B2BOrderInvoice3(){
        test.startTest();

        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);
        Set<String> Set_AccId = new Set<String>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }
        
        List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        Pricebook2 ProfPricebook = TestDataFactory.insertPricebookCustom2('Zorg','Noordhoff Zorg');
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,ProfPricebook.id,false);

        for(Contract con:lstContract){
            con.StartDate = system.today()-364;
            con.ContractTerm = 12;
            con.OperatingCompany__c ='Noordhoff Zorg';
        }
        insert lstContract;
        List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
        for(Asset ass:lst_Asset){
            ass.RenewalDate__c = system.today()+1;
            ass.RenewalRunDate__c = system.today()+1;
            ass.AutomatedRenewProcess__c = true;
            ass.Contract__c = lstContract[0].id ;
        }
        
        
        Insert lst_Asset;

        lstContract = [SELECT Id,ContractTerm,EndDate  FROM Contract];
        
        system.debug('**End Date**'+lstContract[0].EndDate);
        
        UTIL_TestClassExceptions.TESTCLASSEXCEPTION=True;
        Order_Batch_ContractRenewal.ContractRenewal();

        test.stoptest();

    }
}