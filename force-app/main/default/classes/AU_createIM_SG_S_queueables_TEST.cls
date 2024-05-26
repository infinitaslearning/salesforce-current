@IsTest
public class AU_createIM_SG_S_queueables_TEST {
    
    @TestSetup
    static void makeData(){

        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

        List<Account> accountList = new List<Account>();
        for (Integer i=0; i < 3; i++) {
            Account Acc = new Account();
            Acc.RecordTypeId = recordTypeId;
            Acc.Name = 'School'+i;
            Acc.OperatingCompany__c = 'Plantyn';
            acc.CustomerCategory__c = 'Educational Institution';
            //Acc.CustomerDiscountGroup__c = acc.CustomerCategory__c;
            Acc.NetsuiteInternalId__c = '1234'+i;
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.BillingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22';
            Acc.invoicingEmail__c = 'test@test.be';
            Acc.Phone = '0123456789';
            Acc.Website = 'http://www.testwebsite.be';
            Acc.Type = 'Customer';
            Acc.ExternalDatabase__c = 'Agodi';
            acc.Area__c = 'Dutch';
            acc.ConverseImport__c = 'Plantyn Converse migration';
            AccountList.Add(Acc);
        }
        accountList[0].ExternalCustomerId__c = '123456';
        accountList[1].ExternalCustomerId__c = '654321';
        accountList[2].ExternalCustomerId__c = '987654';
        insert accountList;

        List<AccountSubsidiary__c> accSubList = new List<AccountSubsidiary__c>();
        for (Account acc : accountList) {
            AccountSubsidiary__c accSub = new AccountSubsidiary__c();
            accSub.Account__c = acc.Id;
            accSub.LegalName__c = 'Plantyn';
            accSub.AgodiUpdateIsRunning__c = true;
            accSubList.add(accSub);
        }
        insert accSubList;


        AgodiUpdate__c au = new AgodiUpdate__c();
        insert au;
    }

    @IsTest
    static void TestInrichtendeMachtenFileHandlingUpdate(){

        List<Id> updatedAccounts = new List<Id>();
        Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :agodiUpdateId];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
        String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
                                'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456798;test@test.be;http://www.testwebsite.be\r\n';
        Test.startTest();
            System.enqueueJob(new AU_createInrichtendemachten_queueable(fakeFileContent, currentPlantynAccounts, agodiUpdateId, contentDocumentIds));
        Test.stopTest();

        Account[] updatedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];

     //   System.assertEquals('TestAccount', updatedAccount.LegalName__c);
        System.assertEquals(null, updatedAccount[0].BillingStreet);
        System.assertEquals(null, updatedAccount[0].BillingPostalCode);
        System.assertEquals(null, updatedAccount[0].BillingCity);
        System.assertEquals('Netherlands', updatedAccount[0].BillingCountry);
        System.assertEquals('0123456789', updatedAccount[0].Phone);
        System.assertEquals('test@test.be', updatedAccount[0].invoicingEmail__c);
        System.assertEquals('http://www.testwebsite.be', updatedAccount[0].Website);
        System.assertEquals('Customer', updatedAccount[0].Type);
        
    }

    @IsTest
    static void TestInrichtendeMachtenFileHandlingInsert(){
        
        List<Id> updatedAccounts = new List<Id>();
        Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :agodiUpdateId];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
        String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
                                'testStraat;1;b;TestAccount;456789;12345;testGemeente;0123456789;0123456798;test@test.be;http://www.testwebsite.be\r\n';
        Test.startTest();
            System.enqueueJob(new AU_createInrichtendemachten_queueable(fakeFileContent, currentPlantynAccounts, agodiUpdateId, contentDocumentIds));
        Test.stopTest();

        Account[] insertedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ExternalCustomerId__c FROM Account WHERE ExternalCustomerId__c = '456789' LIMIT 1];
        Integer numberOfAccounts = [SELECT COUNT() FROM Account];
/*
       System.assertEquals('TestAccount', insertedAccount.LegalName__c);
        System.assertEquals('456789', insertedAccount[0].ExternalCustomerId__c);
        System.assertEquals('testStraat 1 b', insertedAccount[0].BillingStreet);
        System.assertEquals('12345', insertedAccount[0].BillingPostalCode);
        System.assertEquals('testGemeente', insertedAccount[0].BillingCity);
        System.assertEquals('Belgium', insertedAccount[0].BillingCountry);
        System.assertEquals('0123456789', insertedAccount[0].Phone);
        System.assertEquals('test@test.be', insertedAccount[0].invoicingEmail__c);
        System.assertEquals('http://www.testwebsite.be', insertedAccount[0].Website);
        System.assertEquals('Customer', insertedAccount[0].Type);
        System.assertEquals(4, numberOfAccounts);
  */

    }

    @IsTest
    static void TestScholengemeenschappenFileHandlingUpdate(){
        
        List<Id> updatedAccounts = new List<Id>();
        List<Id> createdAccounts = new List<Id>();
        Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :agodiUpdateId];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
        String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postnummer;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
                                'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456798;test@test.be;www.testwebsite.be\r\n';
        Test.startTest();
            System.enqueueJob(new AU_createScholenGemeenschappen_queueable(fakeFileContent, currentPlantynAccounts, agodiUpdateId, contentDocumentIds, createdAccounts, updatedAccounts));
        Test.stopTest();

        Account[] updatedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];

        /*
        System.assertEquals('TestAccount', updatedAccount.LegalName__c);
        System.assertEquals(null, updatedAccount[0].BillingStreet);
        System.assertEquals(null, updatedAccount[0].BillingPostalCode);
        System.assertEquals(null, updatedAccount[0].BillingCity);
        System.assertEquals('Netherlands', updatedAccount[0].BillingCountry);
        System.assertEquals('0123456789', updatedAccount[0].Phone);
        System.assertEquals('test@test.be', updatedAccount[0].invoicingEmail__c);
        System.assertEquals('http://www.testwebsite.be', updatedAccount[0].Website);
        System.assertEquals('Customer', updatedAccount[0].Type);
        */

    }

    @IsTest
    static void TestScholengemeenschappenFileHandlingInsert(){
        
        List<Id> updatedAccounts = new List<Id>();
        List<Id> createdAccounts = new List<Id>();
        Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :agodiUpdateId];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
        String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postnummer;fusiegemeente;telefoon;telefax;e_mail;website\r\n'+
                                'testStraat;1;b;TestAccount;456789;12345;testGemeente;0123456789;0123456798;test@test.be;www.testwebsite.be\r\n';
        Test.startTest();
            System.enqueueJob(new AU_createScholenGemeenschappen_queueable(fakeFileContent, currentPlantynAccounts, agodiUpdateId, contentDocumentIds, createdAccounts, updatedAccounts));
        Test.stopTest();

        Account[] insertedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ExternalCustomerId__c FROM Account WHERE ExternalCustomerId__c = '456789' LIMIT 1];
        Integer numberOfAccounts = [SELECT COUNT() FROM Account];
        
        /*
        System.assertEquals('TestAccount', insertedAccount[0].LegalName__c);
        System.assertEquals('456789', insertedAccount[0].ExternalCustomerId__c);
        System.assertEquals('testStraat 1 b', insertedAccount[0].BillingStreet);
        System.assertEquals('12345', insertedAccount[0].BillingPostalCode);
        System.assertEquals('testGemeente', insertedAccount[0].BillingCity);
        System.assertEquals('Belgium', insertedAccount[0].BillingCountry);
        System.assertEquals('0123456789', insertedAccount[0].Phone);
        System.assertEquals('test@test.be', insertedAccount[0].invoicingEmail__c);
        System.assertEquals('http://www.testwebsite.be', insertedAccount[0].Website);
        System.assertEquals('Customer', insertedAccount[0].Type);
        System.assertEquals(4, numberOfAccounts);
        */

    }

    @IsTest
    static void TestScholenFileHandlingUpdate(){

        List<Id> createdAccounts = new List<Id>();
        List<Id> updatedAccounts = new List<Id>();
        Set<String> handledAgodiNumbers = new Set<String>();
        
        Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :agodiUpdateId];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
        String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website;scholengemeenschap;IM_nummer\r\n'+
                                'testStraat;1;b;TestAccount;123456;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
                                'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
                                'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
                                'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
                                'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
                                'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
                                'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n'+
                                'testStraat;1;b;TestAccount;456799;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n';
        Test.startTest();
            System.enqueueJob(new AU_createScholen_queueable(fakeFileContent, currentPlantynAccounts, agodiUpdateId, 1, handledAgodiNumbers, contentDocumentIds, createdAccounts, updatedAccounts));
            // AU_createAccountsFromAgodiData.scholen(fakeFileContent, currentPlantynAccounts, AgodiUpdateId, 1, handledAgodiNumbers);
        Test.stopTest();

        Account[] updatedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ParentId, PurchasingGroup__c FROM Account WHERE ExternalCustomerId__c = '123456' LIMIT 1];
        Id ParentId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '654321' LIMIT 1].Id;
        Id PurchasingGroupId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '987654' LIMIT 1].Id;

        /*
        System.assertEquals('TestAccount', updatedAccount.LegalName__c);
        System.assertEquals(null, updatedAccount[0].BillingStreet);
        System.assertEquals(null, updatedAccount[0].BillingPostalCode);
        System.assertEquals(null, updatedAccount[0].BillingCity);
        System.assertEquals('Netherlands', updatedAccount[0].BillingCountry);
        System.assertEquals('0123456789', updatedAccount[0].Phone);
        System.assertEquals('test@test.be', updatedAccount[0].invoicingEmail__c);
        System.assertEquals('http://www.testwebsite.be', updatedAccount[0].Website);
        System.assertEquals('Customer', updatedAccount[0].Type);
        System.assertEquals(ParentId, updatedAccount[0].ParentId);
        System.assertEquals(PurchasingGroupId, updatedAccount[0].PurchasingGroup__c);
        */
    }

    @IsTest
    static void TestScholenFileHandlingInsert(){

        List<Id> createdAccounts = new List<Id>();
        List<Id> updatedAccounts = new List<Id>();
        Set<String> handledAgodiNumbers = new Set<String>();
        
        Id AgodiUpdateId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :agodiUpdateId];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
        String fakeFileContent = 'crab_straat;huisnr;huisnr_ext;lange_naam_instelling;nummer;postcode;fusiegemeente;telefoon;telefax;e_mail;website;scholengemeenschap;IM_nummer\r\n'+
                                'testStraat;1;b;TestAccount;456789;12345;testGemeente;0123456789;0123456789;test@test.be;www.testwebsite.be;654321;987654\r\n';
        Test.startTest();
            System.enqueueJob(new AU_createScholen_queueable(fakeFileContent, currentPlantynAccounts, agodiUpdateId, 1, handledAgodiNumbers, contentDocumentIds, createdAccounts, updatedAccounts));
            //AU_createAccountsFromAgodiData.scholen(fakeFileContent, currentPlantynAccounts, AgodiUpdateId, 1, handledAgodiNumbers);
        Test.stopTest();

        Account[] insertedAccount = [SELECT Name, LegalName__c, BillingStreet, BillingPostalCode, BillingCity, Phone, invoicingEmail__c, Website, Type, BillingCountry, ParentId, PurchasingGroup__c, ExternalCustomerId__c FROM Account WHERE ExternalCustomerId__c = '456789' LIMIT 1];
        Id ParentId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '654321' LIMIT 1].Id;
        Id PurchasingGroupId = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '987654' LIMIT 1].Id;
        Integer numberOfAccounts = [SELECT COUNT() FROM Account];

        /*
        System.assertEquals('TestAccount', insertedAccount[0].LegalName__c);
        System.assertEquals('testStraat 1 b', insertedAccount[0].BillingStreet);
        System.assertEquals('456789', insertedAccount[0].ExternalCustomerId__c);
        System.assertEquals('12345', insertedAccount[0].BillingPostalCode);
        System.assertEquals('testGemeente', insertedAccount[0].BillingCity);
        System.assertEquals('Belgium', insertedAccount[0].BillingCountry);
        System.assertEquals('0123456789', insertedAccount[0].Phone);
        System.assertEquals('test@test.be', insertedAccount[0].invoicingEmail__c);
        System.assertEquals('http://www.testwebsite.be', insertedAccount[0].Website);
        System.assertEquals('Customer', insertedAccount[0].Type);
        System.assertEquals(ParentId, insertedAccount[0].ParentId);
        System.assertEquals(PurchasingGroupId, insertedAccount[0].PurchasingGroup__c);
        System.assertEquals(4, numberOfAccounts);
        */
        
    }

    @IsTest
    static void TestCreateAccSubs(){
        
        List<Account> testAccounts = [SELECT Id FROM Account];
        List<Id> createdAccountIds = new List<Id>();
        List<Id> updatedAccountIds = new List<Id>();

        createdAccountIds.add(testAccounts[0].Id);
        createdAccountIds.add(testAccounts[1].Id);
        updatedAccountIds.add(testAccounts[2].Id);

        Test.startTest();
            System.enqueueJob(new AU_createAccSubsidiaries_queueable(createdAccountIds, updatedAccountIds));
        Test.stopTest();
    }

    @IsTest
    static void TestActivateAccSubs(){

        Test.startTest();
            System.enqueueJob(new AU_activateAccSubsidiaries_queueable());
        Test.stopTest();
    }

}