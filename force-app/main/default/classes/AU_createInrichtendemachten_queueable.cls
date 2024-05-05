public class AU_createInrichtendemachten_queueable implements Queueable {

    public String fileContent;
    public Map<String,Account> plantynAccountmap;
    public Id agodiUpdateId;
    public List<Id> contentDocumentIds;

    public AU_createInrichtendemachten_queueable(String file, Map<String,Account> plantynAccounts, ID agodiUpdate, List<Id> contentDocumentIdList) {

        this.fileContent = file;
        this.plantynAccountmap = plantynAccounts;
        this.agodiUpdateId = agodiUpdate;
        this.contentDocumentIds = contentDocumentIdList;

    }

    public void execute(QueueableContext context) {
        System.debug('AU_createInrichtendemachten_queueable - execute - START');

        System.debug('**** AU_createInrichtendemachten_queueable PARAMETERS:');
        System.debug('**** this.fileContent.length() ==> ' + this.fileContent.length());
        System.debug('**** this.plantynAccountmap.keySet().size() ==> ' + this.plantynAccountmap.keySet().size());
        System.debug('**** this.agodiUpdateId ==> ' + this.agodiUpdateId);
        System.debug('**** this.contentDocumentIds ==> ' + this.contentDocumentIds);

        AgodiUpdate__c au = new AgodiUpdate__c();
        au.Id = this.agodiUpdateId;
        au.UpdateIsRunning__c = true;
        update au;

        //VAT_checkVat.triggerFutureClass = false;

        Set<String> processedAgodiNumbers = new Set<String>();
        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Purchasing Groups' LIMIT 1].Id;

        // Split the String to a list if strings (each string containing 1 row of the csv)
        List<String> rows = new List<String>();
        rows = UTIL_RowIterator.getList(this.fileContent, '\r\n');

        // Get the headers from the csv
        List<String> headers = new List<String>();
        headers = rows[0].replace('"', '').replace('\r', '').replace('\n', '').split(';');

        // cretae Map from csv File
        List<Map<String,String>> fileMap = New List<Map<String,String>>();

        try {

            for (Integer i = 1; i < rows.size(); i++) {
                Map<String,String> tempMap = new Map<String,String>();
                List<String> seperatedRow = rows[i].replace('"', '').replace('\r', '').replace('\n', '').split(';');
                if(headers.size() == seperatedRow.size()) {
                    for (Integer j = 0; j < seperatedRow.size(); j++) {
                        tempMap.put(headers[j], seperatedRow[j]);
                    }
                } else {
                    System.debug('##### ERROR: Row ' + i + ' of the Inrichtende Machten File has an incorrect amount of columns!');
                }
                fileMap.add(tempMap);
            }

        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }

        List<Account> accountsForUpsert = new List<Account>();
        List<Id> createdAccountIdList = new List<Id>();
        List<Id> updatedAccountIdList = new List<Id>();
        Integer accountsForInsert = 0;
        Integer accountsForUpdate = 0;
        Integer doubleAccounts = 0;
        Date todaysDate = date.today();
        Integer countLoops = 0;
        String resultString = '';

        // Create Account for each Agodi Account
        try {

            Set<Id> accountsAddedToUpdateList = new Set<Id>();
            Id MaartenId;
            if (!Test.isRunningTest()) {
                MaartenId = [SELECT Id, Name FROM User WHERE Username = 'maarten.vanhoof@plantyn.com' LIMIT 1].Id;
            }
            for(Map<String,String> agodiAccount : fileMap) {
                if (Date.valueOf(agodiAccount.get('datum_opheffing')) > todaysDate || agodiAccount.get('datum_opheffing') == '' || agodiAccount.get('datum_opheffing') == null) {
                    resultString += 'Inrichtende Machten,' + '' + ',' + agodiAccount.get('nummer') + ',' + agodiAccount.get('telefoon').replace('-','').replace('.','').replace('/','').replace(' ','') + ',skipped -- closed,\n';
                } else if(!processedAgodiNumbers.contains(agodiAccount.get('nummer'))) {
                    processedAgodiNumbers.add(agodiAccount.get('nummer'));
                    countLoops ++;

                    // concatenate street for shipping and billing
                    String street = agodiAccount.get('crab_straat').replace('�', 'è') + ' ' + agodiAccount.get('huisnr');
                    if(agodiAccount.get('huisnr_ext') != null && agodiAccount.get('huisnr_ext') != '' && agodiAccount.get('huisnr_ext') != ' ') {
                        street += ' ' + agodiAccount.get('huisnr_ext');
                    }

                    String emailAdres = '';
                    if (agodiAccount.get('e_mail') != null && agodiAccount.get('e_mail') != '' && agodiAccount.get('e_mail') != ' ') {
                        emailAdres = agodiAccount.get('e_mail');
                    }
                    

                    // create new Account for upsert
                    Account a = new Account();
                    a.LegalName__c = agodiAccount.get('lange_naam_instelling').replace('�', 'è');
                    a.LastAgodiUpdate__c = todaysDate;
                    a.AgodiUpdateInProgress__c = true;
                    

                    // ONLY ON UPDATE
                    if(this.plantynAccountmap.get(agodiAccount.get('nummer')) != null) {
                        Account currentAccount = this.plantynAccountmap.get(agodiAccount.get('nummer'));
                        a.DataMigrationHistory__c = 'Agodi Update - ' + Date.today();
                        
                        if (!accountsAddedToUpdateList.contains(currentAccount.Id)) {
                            a.Id = currentAccount.Id;

                            // Conditional updates
                            if (this.plantynAccountmap.get(currentAccount.ExternalCustomerId__c).NumberofStudents__c == null) {
                                a.NumberofStudents__c = 0;
                            }

                            // only update is current Account fieldvalue is empty
                            if (currentAccount.PhoneCountry__c == '') {
                                a.PhoneCountry__c = 'Belgium';
                            }
                            if (currentAccount.CustomerDiscountGroup__c == '') {
                                a.CustomerDiscountGroup__c = currentAccount.CustomerCategory__c;
                            }

                            accountsAddedToUpdateList.add(a.Id);
                            accountsForUpsert.add(a);
                            accountsForUpdate ++;
                        } else {
                            doubleAccounts ++;
                        }
                    } 
                    
                    // ONLY ON INSERT
                    else {
                        
                        if (!Test.isRunningTest()) {
                            a.OwnerId = MaartenId;
                        }
                        a.DataMigrationHistory__c = 'Agodi Insert - ' + Date.today();
                        a.ConverseImport__c = 'Agodi import';
                        a.Name = agodiAccount.get('lange_naam_instelling').replace('�', 'è');
                        a.TypeOfAccount__c = 'Sales and Order';
                        a.ExternalCustomerId__c = agodiAccount.get('nummer');
                        a.PhoneCountry__c = 'Belgium';
                        a.Phone = agodiAccount.get('telefoon').replace('-','').replace('.','').replace('/','').replace(' ','');
                        a.fax = agodiAccount.get('telefax');
                        // ---------- UPDATED WITH HTTP VALIDATION ----------
                        if (agodiAccount.get('website').left(4) == 'http') {
                            a.Website = agodiAccount.get('website');
                        } else {
                            a.Website = 'http://' + agodiAccount.get('website');
                        }
                        // --------------------------------------------------
                        //a.Type = 'Customer';
                        a.OperatingCompany__c = 'Plantyn';
                        a.RecordTypeId = recordTypeId;
                        a.CustomerCategory__c = 'Government Agency';  // ADDED
                        a.CustomerDiscountGroup__c = a.CustomerCategory__c; // ADDED
                        a.ShippingCostMethod__c = 'Based on weight Domestic'; // UPDATED
                        a.AccountSource = 'Agodi';
                        a.InvoicingEmail__c = emailAdres;
                        a.OrderNotificationEmail__c = emailAdres;
                        a.BillingReminderEmail__c = emailAdres;
                        a.DigitalActivationEmail__c = emailAdres;
                        a.ShippingStreet = street;
                        a.ShippingPostalCode = agodiAccount.get('postcode');
                        a.ShippingCity = agodiAccount.get('fusiegemeente');
                        a.ShippingCountry = 'Belgium';
                        a.BillingStreet = street;
                        a.BillingPostalCode = agodiAccount.get('postcode');
                        a.BillingCity = agodiAccount.get('fusiegemeente');
                        a.BillingCountry = 'Belgium';
                        a.CommunicationLanguage__c = 'nl_NL'; // UPDATED
                        if (agodiAccount.get('kbo_nummer') != null) {
                            if (agodiAccount.get('kbo_nummer').length() == 10 && agodiAccount.get('kbo_nummer').left(1) == '0') {
                                a.VATNumber__c = agodiAccount.get('kbo_nummer');
                            } else if (agodiAccount.get('kbo_nummer').length() == 9) {
                                a.VATNumber__c = '0' + agodiAccount.get('kbo_nummer');
                            } else {
                                a.VATNumber__c = agodiAccount.get('kbo_nummer');
                            }
                        }
                        a.Area__c = 'Dutch';
                        a.NumberofStudents__c = 0;
                        a.ExternalDatabase__c = 'Agodi';
                        accountsForUpsert.add(a);
                        accountsForInsert ++;
                    }
                }
                
            }

        } catch (Exception e) {
            System.debug('==========> ERROR: ' + e.getMessage() + ' -- StackTrace: ' + e.getStackTraceString());
            HandleCustomException.LogException(e);
        }
        
        System.debug('rows.size() = ' + rows.size());
        System.debug('fileMap.Size() = ' + fileMap.size());
        System.debug('FILEMAP: ' + filemap);
        System.debug('countLoops = ' + countLoops);
        System.debug('We have found (and filtered out)  ' + doubleAccounts + ' double accounts in the Agodi list.');
        System.debug('this process should update ' + accountsForUpdate + ' and insert ' + accountsForInsert + ' Purchasing Group Accounts.');

        Integer updatedAccounts = 0;
        Integer insertedAccounts = 0;
        Integer errorAccounts = 0;
        String errormessages = '';

        // upsert Accounts and post Error to Debug log when an error occurs
        Database.UpsertResult[] results = Database.upsert(accountsForUpsert, false);

        Map<String,String> resultMap = new Map<String,String>();

        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                if (results[i].isCreated()) {
                    resultString += 'Inrichtende Machten,' + accountsForUpsert[i].Id + ',' + accountsForUpsert[i].ExternalCustomerId__c + ',' + accountsForUpsert[i].Phone + ',inserted,\n';
                    createdAccountIdList.add(accountsForUpsert[i].Id);
                    insertedAccounts ++;
                } else {
                    resultString += 'Inrichtende Machten,' + accountsForUpsert[i].Id + ',' + accountsForUpsert[i].ExternalCustomerId__c + ',' + accountsForUpsert[i].Phone + ',updated,\n';
                    updatedAccountIdList.add(accountsForUpsert[i].Id);
                    updatedAccounts ++;
                }
            } else {
                String tmpErr = '';
                for (Database.Error err : results[i].getErrors()) {
                    tmpErr += '==> ' + err.getStatusCode() + ' : ' + err.getMessage();
                    System.debug('==========> ERROR: field: ' + err.getFields() + ' message: ' + err.getMessage());
                    errorAccounts ++;
                }
                resultString += 'Inrichtende Machten,' + accountsForUpsert[i].Id + ',' + accountsForUpsert[i].ExternalCustomerId__c + ',' + accountsForUpsert[i].Phone + ',error,' + tmpErr + '\n';
                errormessages += tmpErr + '\n';
            }
        }
        System.debug('RESULTS: We have updated ' + updatedAccounts + ' Accounts, Inserted ' + insertedAccounts + ' and we experienced ' + errorAccounts + ' errors while upserting.');
        if (errorAccounts > 0) {
            System.debug('ERRORS: ' + errormessages);
        }

        String content = 'AccountType,ID,ExternalCustomerNumber,Phone,Result,error\n';
        content += resultString;

        // create File (ContentVersion)
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'Results_InrichtendeMachten.csv';
        conVer.Title = 'Results_InrichtendeMachten.csv';
        conVer.VersionData = Blob.valueOf(content);
        insert conVer;

        // Link file to object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = this.agodiUpdateId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;

        Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();

        if (!Test.isRunningTest()) {
            // enqueue Scolengemeenschappen
            ContentVersion scholengemeenschappenContentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId IN :this.contentDocumentIds AND Title = 'scholenGemeenschappen.txt' LIMIT 1];
            String file = scholengemeenschappenContentVersion.VersionData.toString();

            System.debug('We found the file for Scholengemeenschappen');
            Id jobId = System.enqueueJob(new AU_createScholenGemeenschappen_queueable(file, currentPlantynAccounts, this.agodiUpdateId, this.contentDocumentIds, createdAccountIdList, updatedAccountIdList));
            System.debug('AU_createScholenGemeenschappen_queueable is enqueued with Job Id: ' + jobID);
        }
        System.debug('AU_createInrichtendemachten_queueable - execute - END');
    }
}