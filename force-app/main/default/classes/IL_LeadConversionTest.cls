@isTest
public class IL_LeadConversionTest {
    
    @testSetup 
    static void createTestData() {
        
        //Create Test Data  
        Lead ld = new lead ();
        ld.ReadytoConvert__c = true;
        ld.LastName ='test';
        ld.Company = 'Company';
        ld.OperatingCompany__c = 'Plantyn';
        insert ld;
        
        Account acc = new account();
        acc.name = 'Test Account ';
        acc.TypeOfAccount__c = 'Sales';
        acc.NumberofStudents__c = 1;
        acc.OperatingCompany__c = 'Plantyn';
        acc.Area__c = 'Dutch';
        insert acc;
        
        Contact con = new contact ();
        con.LastName = 'Test' ;
        con.OperatingCompany__c = 'Plantyn';
        insert con ;

        Opportunity opp = new Opportunity();
        opp.Name = con.LastName;
        opp.StageName = 'S4 Proposal';
        opp.CloseDate = Date.today();
        opp.OperatingCompany__c = 'Noordhoff';
        insert opp;

        Task t = new Task();
        t.WhoId = ld.Id;
        t.Subject = 'Test Task';
        insert t;
        
    }

    @isTest
    static void testMethod1() {
        
        List<Task> tasks = new List<Task>();
        List<Event> events = new List<Event>();
        list<lead> ld = [Select id, Account__c,Contact__c,Opportunity__c,ReadytoConvert__c,
                         AutoConvertCreateOpportunity__c ,AutoConvertError__c,Sales_season__c
                         from lead];
        System.debug('IL_LeadConversion - Lead: ' + ld);
        test.startTest();
        IL_LeadConversion.checkData(ld, tasks, events);
        test.stopTest();
        
    }

    @isTest
    static void testMethod2() {
        
        List<Task> tasks = new List<Task>();
        List<Event> events = new List<Event>();
        list<lead> ld = [Select id, Account__c,Contact__c,Opportunity__c,ReadytoConvert__c,
                         AutoConvertCreateOpportunity__c ,AutoConvertError__c,Sales_season__c
                         from lead];
        System.debug('IL_LeadConversion - Lead: ' + ld);
        Account acc = [select id from Account limit 1];
        Contact con = [select id from contact limit 1];
        ld[0].Account__c = acc.id;
        ld[0].Contact__c = con.id;
        update ld[0];
        test.startTest();
        IL_LeadConversion.checkData(ld, tasks, events);
        test.stopTest();
    }

    @isTest
    static void testMethod3() {
        list<list<lead>> collectionList = new list<list<lead>> ();
        list<lead> ld = [Select id, Account__c,Contact__c,Opportunity__c,ReadytoConvert__c,
                         AutoConvertCreateOpportunity__c ,AutoConvertError__c,Sales_season__c
                         from lead];
        System.debug('IL_LeadConversion - Lead: ' + ld);
        Account acc = [select id from Account limit 1];
        Contact con = [select id from contact limit 1];
        ld[0].Account__c =acc.id;
        ld[0].Contact__c =con.id;
        update ld[0];
        collectionList.add(ld);
        test.startTest();
        IL_LeadConversion.fetchInvocableData(collectionList);
        test.stopTest();
    }

    @isTest
    static void testMethod4() {
        list<list<lead>> collectionList = new list<list<lead>> ();
        list<lead> ld = [Select id, Account__c,Contact__c,Opportunity__c,ReadytoConvert__c,
                         AutoConvertCreateOpportunity__c ,AutoConvertError__c,Sales_season__c
                         from lead];
        System.debug('IL_LeadConversion - Lead: ' + ld);
        Account acc = [SELECT id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ld[0].Account__c = acc.Id;
        ld[0].Contact__c = con.Id;
        ld[0].Opportunity__c = opp.Id;
        update ld[0];
        collectionList.add(ld);

        test.startTest();
        IL_LeadConversion.fetchInvocableData(collectionList);
        test.stopTest();

        Task t = [SELECT Id, WhoId, WhatId FROM Task LIMIT 1];
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

    }
    
}