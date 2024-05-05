global class MERGE_csvContactMergeBatchJob implements Database.Batchable<sObject>, Database.Stateful {
    
    global Map<String,String> masterAndDuplicateIdMap = new Map<String,String>();
    global String emailForDetails;
    global Boolean sendEmail = false;
    global String csvString = 'MasterId,DuplicateId,Status\n';

    global MERGE_csvContactMergeBatchJob(Map<String,String> masterIdDuplicateIdMap) {
        System.debug('masterIdDuplicateIdMap = ' + masterIdDuplicateIdMap);
        this.masterAndDuplicateIdMap = masterIdDuplicateIdMap;
    }

    global MERGE_csvContactMergeBatchJob(Map<String,String> masterIdDuplicateIdMap, String email) {
        System.debug('masterIdDuplicateIdMap = ' + masterIdDuplicateIdMap + email);
        this.masterAndDuplicateIdMap = masterIdDuplicateIdMap;
        this.emailForDetails = email;
        this.sendEmail = true;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug(LoggingLevel.INFO, 'MERGE_csvContactMergeBatchJob - start');

        Set<String> masterIds = masterAndDuplicateIdMap.keyset();
        System.debug('masterIds = ' + masterIds);

        return Database.getQueryLocator([SELECT Id FROM Contact WHERE Id IN :masterIds]);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        System.debug(LoggingLevel.INFO, 'MERGE_csvContactMergeBatchJob - execute');

        if (scope.size() > 1) {
            System.debug(LoggingLevel.ERROR, 'Scope size is to large, should be 1');
        } else if (scope.size() < 1) {
            System.debug(LoggingLevel.ERROR, 'Scope size is to small, should be 1');
        } else {
            Contact masterContact = scope[0];
            System.debug('masterContact: ' + masterContact);
            String duplicateContactId = masterAndDuplicateIdMap.get(masterContact.Id);
            Contact duplicateContact = [SELECT Id FROM Contact WHERE Id = :duplicateContactId];
            System.debug('duplicateContact: ' + duplicateContact);


            /*
            AccountContactRelation MasterAccountContactRelation = [SELECT Id, AccountId, isDirect FROM AccountContactRelation WHERE ContactId = :masterContact.Id];
            AccountContactRelation DuplicateAccountContactRelation = [SELECT Id, AccountId, isDirect FROM AccountContactRelation WHERE ContactId = :duplicateContactId];

            if (MasterAccountContactRelation?.AccountId == DuplicateAccountContactRelation?.AccountId) {
                Id AccountId = masterAccountContactRelation?.AccountId;
                if (DuplicateAccountContactRelation?.isDirect) {
                    masterContact.AccountId = AccountId;
                    List<AccountContactRelation> acrLst = new List<AccountContactRelation>();
                    acrLst.add(MasterAccountContactRelation);
                    acrLst.add(DuplicateAccountContactRelation);
                    delete acrLst;
                } else {
                    delete duplicateAccountContactRelation;
                }
            }
            */

            Database.MergeResult res = Database.merge(masterContact, duplicateContact, false);
                    
            if (res.isSuccess()) {
                System.Debug('Successfuly merged Contacts into Contact with ID: ' + res.getId());
                // Add details of merge = success to csv
                csvString += masterContact.Id + ',' + duplicateContactId + ',' + 'Successfuly merged\n';
            } else {
                String errors = '';
                for (Database.Error err : res.getErrors()) {
                    System.Debug('ERROR: ' + err.getMessage());
                    errors += err.getMessage();
                }
                // Add details of merge + error to csv
                csvString += masterContact.Id + ',' + duplicateContactId + ',' + 'ERROR: ' + errors + '\n';
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 'MERGE_csvContactMergeBatchJob - finish');

        if (sendEmail) {
            if (!Test.isRunningTest() && ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox) {
                // Create csv attachment from String
                Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                csvAttc.setFileName('Merging_results.csv');
                csvAttc.setBody(Blob.valueOf(csvString));

                // Create email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String[] toAddresses = new list<string> {emailForDetails};
                email.setSubject('Merge process had finished');
                email.setToAddresses( toAddresses );
                email.setPlainTextBody('The merging process has finished. Attached you can find the details of the merging process.');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});

                //Sent email
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            } else if (Test.isRunningTest()) {
                System.debug('---- Running Test so no email was sent ----');
                System.debug('contents of csv to be sent:');
                List<String> csvForDebug = csvString.split('\n');
                for (String csvLine : csvForDebug) {
                    System.debug(csvLine);
                }
            } else {
                System.debug('---- In Sandbox Org so no email was sent ----');
                System.debug('contents of csv to be sent:');
                List<String> csvForDebug = csvString.split('\n');
                for (String csvLine : csvForDebug) {
                    System.debug(csvLine);
                }
            }
        }
    }

}