@isTest
public with sharing class UTIL_GetContactIds_TEST {

    @TestSetup
    static void makeData(){
        List<Account> accounts = UTIL_TestDatafactory.createAccounts(1, true);
        List<Contact> contacts = UTIL_TestDatafactory.createContacts(3, accounts, true);
    }

    @IsTest
    static void ShouldReturn1contact(){

        List<Contact> contactList = [SELECT Id, Email FROM Contact];

        for (Contact con : contactList) {
            con.OperatingCompany__c = 'Noordhoff';
        }
        update contactList;

        UTIL_GetContactIds.fieldwrapper fw = new UTIL_GetContactIds.fieldwrapper();
        fw.OpCo = 'Noordhoff';
        fw.Email = 'email0@test.com';

        List<UTIL_GetContactIds.fieldwrapper> fwLst = new List<UTIL_GetContactIds.fieldwrapper>();
        fwLst.add(fw);

        Test.startTest();
            List<UTIL_GetContactIds.returnWrapper> rwLst = UTIL_GetContactIds.getContactsByOpcoAndEmail(fwLst);
        Test.stopTest();

        for(UTIL_GetContactIds.returnWrapper rw : rwLst) {
            System.assertEquals(1, rw.ContactList.size());
        }
    }

    @IsTest
    static void ShouldReturn2contacts(){
        
        List<Contact> contactList = [SELECT Id, Email FROM Contact];

        for (Contact con : contactList) {
            if (con.Email == 'email1@test.com') {
                con.PrivateEmail__c = 'email0@test.com';
            }
            con.OperatingCompany__c = null;
        }
        update contactList;

        UTIL_GetContactIds.fieldwrapper fw = new UTIL_GetContactIds.fieldwrapper();
        fw.OpCo = null;
        fw.Email = 'email0@test.com';

        List<UTIL_GetContactIds.fieldwrapper> fwLst = new List<UTIL_GetContactIds.fieldwrapper>();
        fwLst.add(fw);

        Test.startTest();
            List<UTIL_GetContactIds.returnWrapper> rwLst = UTIL_GetContactIds.getContactsByOpcoAndEmail(fwLst);
        Test.stopTest();

        for(UTIL_GetContactIds.returnWrapper rw : rwLst) {
            System.assertEquals(2, rw.ContactList.size());
        }
    }
    
}