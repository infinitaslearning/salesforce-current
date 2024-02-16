global with sharing class Batch_MergeContact implements Database.Batchable<sObject>, Database.Stateful {
    /*/
    *   @ Created By: Jannes Kleerebezem
    *   Use: 
    *   ==> Start Batch to first match on TeacherNumber and after that automaticly continue with Email matching:
    *   Batch_MergeContact  MergeCon = new Batch_MergeContact();
    *   Id batchprocessid = Database.executebatch(MergeCon, 1);
    *   or:
    *   ==> If you want to run Only the Mering on TeacherNumber Matching:
    *   Batch_MergeContact  MergeCon = new Batch_MergeContact(true, false);
    *   Id batchprocessid = Database.executebatch(MergeCon, 1);
    *   or:
    *   ==> If you want to run Only the Mering on Email Matching:
    *   Batch_MergeContact  MergeCon = new Batch_MergeContact(false, true);
    *   Id batchprocessid = Database.executebatch(MergeCon, 1);
    *   
    /*/

    global Boolean isEmailMatching;
    global Boolean isTeacherNumnerMatching;
    global Boolean unFinished = false;
    global Boolean runFullJob = false;

    global Batch_MergeContact() {
        this.isTeacherNumnerMatching = true;
        this.isEmailMatching = false;
        this.runFullJob = true;
    }

    global Batch_MergeContact(Boolean matchOnTeacherNumber, Boolean matchOnEmail) {
        this.isTeacherNumnerMatching = matchOnTeacherNumber;
        this.isEmailMatching = matchOnEmail;
    }

    global Batch_MergeContact(Boolean runAll, Boolean matchOnTeacherNumber, Boolean matchOnEmail) {
        this.isTeacherNumnerMatching = matchOnTeacherNumber;
        this.isEmailMatching = matchOnEmail;
        this.runFullJob = runAll;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug(LoggingLevel.INFO,'Class: Batch_MergeContact - Start method');
         
        String query = '';
        if (isEmailMatching && isTeacherNumnerMatching) {
            System.debug('Please make sure to only select one of the matchingTypes!');
        } else if (isEmailMatching) {
            query = 'SELECT Id, Email FROM Contact WHERE Email != null AND AccountId != null';
        } else if (isTeacherNumnerMatching) {
            query = 'SELECT Id, TeacherNumber__c FROM Contact where TeacherNumber__c != null AND AccountId != null';
        } else {
            System.debug('Make sure to select at least one of the matchingTypes');
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        System.debug(LoggingLevel.INFO,'Class: Batch_MergeContact - Execute method');
       
        List<Contact> contactList = new List<Contact>();
        
        if (isTeacherNumnerMatching) {
            String TeacherNumber;
            for (Contact c : scope) {
                TeacherNumber = c.TeacherNumber__c;
            }
            contactList = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId FROM Contact WHERE TeacherNumber__c = :TeacherNumber ORDER BY LastModifiedDate DESC];
        } else if (isEmailMatching) {
            String emailForMatching;
            for (Contact c : scope) {
                emailForMatching = c.Email;
            }
            List<Contact> tempContactList = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId, TeacherSchoolNumber__c FROM Contact WHERE Email = :emailForMatching ORDER BY LastModifiedDate DESC];
            Contact mainContact;
            for (Contact c : tempContactList) {
                if (mainContact == null) {
                    mainContact = c;
                    contactList.add(c);
                } else {
                    if (c.AccountId == mainContact.AccountId || (c.TeacherSchoolNumber__c != null && c.TeacherSchoolNumber__c == mainContact.TeacherSchoolNumber__c)) {
                        contactList.add(c);
                    }
                }
            }
        } else {
            System.debug('No Matching Type selected.');
        }


        List<Contact> lstContact = new List<Contact>();

        Integer loopSize;
        if (contactList.size() <= 3) {
            loopSize = contactList.size();
        } else {
            loopSize = 3;
            unFinished = true;
        }
        
        for (Integer i = 0; i < loopSize; i++) {
            lstContact.add(contactList[i]);
        }

        if (lstContact.size() > 1) {
            UTIL_MergeContact.MergeContacts(lstContact);
        }
       
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO,'Class: Batch_MergeContact - Finish method');

        if (unfinished) {
            if (runFullJob) {
                Batch_MergeContact  MergeCon = new Batch_MergeContact(true, isTeacherNumnerMatching, isEmailMatching);
                Id batchprocessid = Database.executebatch(MergeCon, 1);
                System.debug('Id of next batch Job: ' + batchprocessid);
            } else {
                Batch_MergeContact  MergeCon = new Batch_MergeContact(isTeacherNumnerMatching, isEmailMatching);
                Id batchprocessid = Database.executebatch(MergeCon, 1);
                System.debug('Id of next batch Job: ' + batchprocessid);
            }
        } else if (runFullJob && isTeacherNumnerMatching) {
            System.debug('TeacherNumber Matching is finished, starting Email matching');
            Batch_MergeContact  MergeCon = new Batch_MergeContact(true, false, true);
            Id batchprocessid = Database.executebatch(MergeCon, 1);
            System.debug('Id of next batch Job: ' + batchprocessid);
        } else {
            System.debug('Finished!');
        }

    }
}