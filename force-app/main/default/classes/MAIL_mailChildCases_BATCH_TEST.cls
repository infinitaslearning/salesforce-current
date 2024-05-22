@IsTest
public  class MAIL_mailChildCases_BATCH_TEST {

    @TestSetup
    static void makeData(){

        List<Account> accounts = UTIL_TestDatafactory.createAccounts(1, true);
        List<Contact> contacts = UTIL_TestDatafactory.createContacts(4, accounts, true);


        // Get Noordhoff Case recordtypeId
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Noordhoff').getRecordTypeId();

        // Get Noordhoff BusinessHoursId
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Noordhoff' LIMIT 1].Id;

        // Create Parent Cases
        List<Case> parentCases = new List<Case>();
        for (String OpCo : new List<String>{'Noordhoff','Plantyn','Liber','Noordhoff Zorg'}) {
            Case pC = new Case();
            pC.recordTypeId = recordTypeId;
            pC.Subject = 'Test ParentCase';
            pC.Type = 'Problem';
            pC.Status = 'New';
            pC.Origin = 'Phone';
            // pC.CategoryLevel1__c = 'General';
            // pC.CategoryLevel2__c = 'Assortiment';
            pC.BusinessHoursId = businessHoursId;
            if (OpCo != 'Noordhoff Zorg') {
                pC.ContactId = contacts[contacts.size()-1].Id;
            } else {
                pC.SuppliedEmail = 'testSuppliedEmail@test.invalid';
                pC.suppliedName = 'Test SuppliedName';
            }
            pC.OperatingCompany__c = OpCo;
            parentCases.add(pC);
        }

        insert parentCases;

        // Create child Cases
        List<Case> childCases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            Case cC = new Case();
            cC.recordTypeId = recordTypeId;
            cC.Subject = 'Test ChildCase ' + (i + 1);
            cC.ParentId = parentCases[i].Id;
            cC.Type = 'Question';
            cC.Status = 'New';
            cC.Origin = 'Phone';
            // cC.CategoryLevel1__c = 'General';
            // cC.CategoryLevel2__c = 'Assortiment';
            cC.BusinessHoursId = businessHoursId;
            if (i > 0) {
                cC.ContactId = contacts[i].Id;
            } else {
                cC.SuppliedEmail = 'testSuppliedEmail@test.invalid';
                cC.suppliedName = 'Test SuppliedName';
            }
            cC.OperatingCompany__c = parentCases[i].OperatingCompany__c;
            childCases.add(cC);
        }
        insert childCases;
    }

    @IsTest
    static void TestNoordhoff(){
        
        MAIL_mailChildCases_BATCH.FlowInputs fi = new MAIL_mailChildCases_BATCH.FlowInputs();
        fi.parentCase = [SELECT Id FROM Case WHERE Type = 'Problem' AND OperatingCompany__c = 'Noordhoff' LIMIT 1];
        fi.childCases = [SELECT Id, ContactEmail, ContactId, ContactFirstName__c, SuppliedName, SuppliedEmail, ParentId, OperatingCompany__c FROM Case WHERE Type = 'Question'];
        fi.title = 'Test title';
        fi.body ='Test Body';
        fi.doMailParentCase = true;

        List<MAIL_mailChildCases_BATCH.FlowInputs> fiLst = new List<MAIL_mailChildCases_BATCH.FlowInputs>();
        fiLst.add(fi);
        
        Test.startTest();
            MAIL_mailChildCases_BATCH.sendEmailToChildCases(fiLst);
        Test.stopTest();
    }

    @IsTest
    static void TestPlantyn(){

        MAIL_mailChildCases_BATCH.FlowInputs fi = new MAIL_mailChildCases_BATCH.FlowInputs();
        fi.parentCase = [SELECT Id FROM Case WHERE Type = 'Problem' AND OperatingCompany__c = 'Plantyn' LIMIT 1];
        fi.childCases = [SELECT Id, ContactEmail, ContactId, ContactFirstName__c, SuppliedName, SuppliedEmail, ParentId, OperatingCompany__c FROM Case WHERE Type = 'Question'];
        fi.title = 'Test title';
        fi.body ='Test Body';
        fi.doMailParentCase = true;

        List<MAIL_mailChildCases_BATCH.FlowInputs> fiLst = new List<MAIL_mailChildCases_BATCH.FlowInputs>();
        fiLst.add(fi);
        
        Test.startTest();
            MAIL_mailChildCases_BATCH.sendEmailToChildCases(fiLst);
        Test.stopTest();
    }

    @IsTest
    static void TestLiber(){

        MAIL_mailChildCases_BATCH.FlowInputs fi = new MAIL_mailChildCases_BATCH.FlowInputs();
        fi.parentCase = [SELECT Id FROM Case WHERE Type = 'Problem' AND OperatingCompany__c = 'Liber' LIMIT 1];
        fi.childCases = [SELECT Id, ContactEmail, ContactId, ContactFirstName__c, SuppliedName, SuppliedEmail, ParentId, OperatingCompany__c FROM Case WHERE Type = 'Question'];
        fi.title = 'Test title';
        fi.body ='Test Body';
        fi.doMailParentCase = true;

        List<MAIL_mailChildCases_BATCH.FlowInputs> fiLst = new List<MAIL_mailChildCases_BATCH.FlowInputs>();
        fiLst.add(fi);
        
        Test.startTest();
            MAIL_mailChildCases_BATCH.sendEmailToChildCases(fiLst);
        Test.stopTest();
    }

    @IsTest
    static void TestZorg(){

        MAIL_mailChildCases_BATCH.FlowInputs fi = new MAIL_mailChildCases_BATCH.FlowInputs();
        fi.parentCase = [SELECT Id FROM Case WHERE Type = 'Problem' AND OperatingCompany__c = 'Noordhoff Zorg' LIMIT 1];
        fi.childCases = [SELECT Id, ContactEmail, ContactId, ContactFirstName__c, SuppliedName, SuppliedEmail, ParentId, OperatingCompany__c FROM Case WHERE Type = 'Question'];
        fi.title = 'Test title';
        fi.body ='Test Body';
        fi.doMailParentCase = true;

        List<MAIL_mailChildCases_BATCH.FlowInputs> fiLst = new List<MAIL_mailChildCases_BATCH.FlowInputs>();
        fiLst.add(fi);
        
        Test.startTest();
            MAIL_mailChildCases_BATCH.sendEmailToChildCases(fiLst);
        Test.stopTest();
    }
}