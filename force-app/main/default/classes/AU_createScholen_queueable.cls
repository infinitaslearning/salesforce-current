public class AU_createScholen_queueable implements Queueable {

    public String fileContent;
    public Map<String,Account> plantynAccountmap;
    public Id agodiUpdateId;
    public Integer fileNo;
    public Set<String> handledAgodiNumbers;
    public List<Id> contentDocumentIds;
    public List<Id> createdAccountIdList, updatedAccountIdList;

    public AU_createScholen_queueable(String file, Map<String,Account> plantynAccounts, Id agodiUpdate, Integer fileNr, Set<String> handledAgodiNumberlist, List<Id> contentDocumentIdList, List<Id> createdAccountIds, List<Id> updatedAccountIds) {

        this.fileContent = file;
        this.plantynAccountmap = plantynAccounts;
        this.agodiUpdateId = agodiUpdate;
        this.fileNo = fileNr;
        this.handledAgodiNumbers = handledAgodiNumberlist;
        this.contentDocumentIds = contentDocumentIdList;
        this.createdAccountIdList = createdAccountIds;
        this.updatedAccountIdList = updatedAccountIds;

    }

    public void execute(QueueableContext context) {
        System.debug('AU_createScholen_queueable - execute START');

        System.debug('**** AU_createScholen_queueable PARAMETERS:');
        System.debug('**** this.fileContent.length() ==> ' + this.fileContent.length());
        System.debug('**** this.plantynAccountmap.keySet().size() ==> ' + this.plantynAccountmap.keySet().size());
        System.debug('**** this.agodiUpdateId ==> ' + this.agodiUpdateId);
        System.debug('**** this.fileNo ==> ' + this.fileNo);
        System.debug('**** this.handledAgodiNumbers ==> ' + this.handledAgodiNumbers);
        System.debug('**** this.contentDocumentIds ==> ' + this.contentDocumentIds);

        //VAT_checkVat.triggerFutureClass = false;
        
        Set<String> processedAgodiNumbers = this.handledAgodiNumbers;
        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

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
                    System.debug('##### ERROR: Row ' + i + ' of the Scholen File has an incorrect amount of columns!');
                }
                fileMap.add(tempMap);
            }
            
        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }

        List<Account> accountsForUpsert = new List<Account>();
        Integer accountsForInsert = 0;
        Integer accountsForUpdate = 0;
        Integer doubleAccounts = 0;
        Date todaysDate = date.today();
        Integer countLoops = 0;
        String resultString = '';

        // Create Account for each Agodi Account
        try {

            Set<Id> accountsAddedToUpdateList = new Set<Id>();
            Id GuyId;
            if (!Test.isRunningTest()) {
                GuyId = [SELECT Id, Name FROM User WHERE Username = 'maarten.vanhoof@plantyn.com' LIMIT 1].Id;
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
                    if (agodiAccount.get('e_mail') != null && agodiAccount.get('e_mail') != '') {
                        emailAdres = agodiAccount.get('e_mail');
                    }
                    
                    // create new Account for upsert
                    Account a = new Account();
                    a.LegalName__c = agodiAccount.get('lange_naam_instelling').replace('�', 'è');
                    a.LastAgodiUpdate__c = todaysDate;
                    a.AgodiUpdateInProgress__c = true;
                    a.DataMigrationHistory__c = 'Agodi Update - ' + Date.today();

                    // Update Scholengemeenschap (ParentId) lookup
                    if (this.plantynAccountmap.containsKey(agodiAccount.get('scholengemeenschap'))) {
                        a.ParentId = this.plantynAccountmap.get(agodiAccount.get('scholengemeenschap')).Id;
                    }

                    
                    // ONLY ON UPDATE
                    if (this.plantynAccountmap.containsKey(agodiAccount.get('nummer'))) {
                        Account currentAccount = this.plantynAccountmap.get(agodiAccount.get('nummer'));
                        Id inrichtendeMachtenId = null;

                        if (!accountsAddedToUpdateList.contains(currentAccount.Id)) {
                            a.Id = currentAccount.Id;

                            // Conditional updates
                            if (this.plantynAccountmap.containsKey(agodiAccount.get('IM_nummer'))) {
                                inrichtendeMachtenId = this.plantynAccountmap.get(agodiAccount.get('IM_nummer')).Id;
                                if (currentAccount.PurchasingGroup__c != inrichtendeMachtenId) {
                                    a.PurchasingGroup__c = inrichtendeMachtenId;
                                }
                            }
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
                            // System.debug('WARNING: There is a double account with Agodi Nummer ' + agodiAccount.get('nummer') + ' in the list!');
                            doubleAccounts ++;
                        }
                    } 
                    
                    // ONLY ON INSERT
                    else {
                        if (!Test.isRunningTest()) {
                            a.OwnerId = GuyId;
                        }
                        a.Name = agodiAccount.get('lange_naam_instelling').replace('�', 'è');
                        a.TypeOfAccount__c = 'Sales and Order';
                        a.ConverseImport__c = 'Agodi import';
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
                        // Inrichtende Macht lookup
                        if (this.plantynAccountmap.containsKey(agodiAccount.get('IM_nummer'))) {
                            a.PurchasingGroup__c = this.plantynAccountmap.get(agodiAccount.get('IM_nummer')).Id;
                        }
                        // --------------------------------------------------
                        //a.Type = 'School';
                        a.OperatingCompany__c = 'Plantyn';
                        a.RecordTypeId = recordTypeId;
                        // a.SchoolType__c = 'Institution'; // ADDED
                        a.CustomerCategory__c = 'Educational Institution'; // ADDED
                        a.CustomerDiscountGroup__c = a.CustomerCategory__c; // ADDED
                        a.AccountSource = 'Agodi';
                        a.ShippingCostMethod__c = 'Based on weight Domestic'; // UPDATED
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
                        a.NumberofStudents__c = 0;
                        a.Area__c = 'Dutch';
                        a.ExternalDatabase__c = 'Agodi';
                        accountsForUpsert.add(a);
                        accountsForInsert ++;
                    }
                }
                
            }

        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }

        System.debug('rows.size() = ' + rows.size());
        System.debug('fileMap.Size() = ' + fileMap.size());
        System.debug('FILEMAP: ' + filemap);
        System.debug('countLoops = ' + countLoops);
        System.debug('We have found (and filtered out)  ' + doubleAccounts + ' double accounts in the Agodi list.');
        System.debug('this process should update ' + accountsForUpdate + ' and insert ' + accountsForInsert + ' Scholen Accounts.');
        

        Integer updatedAccounts = 0;
        Integer insertedAccounts = 0;
        Integer errorAccounts = 0;
        
        // upsert Accounts and post Error to Debug log when an error occurs
        Database.UpsertResult[] results = Database.upsert(accountsForUpsert, false);

        for (Integer i = 0; i < results.size(); i++) {
            if (results[i].isSuccess()) {
                if (results[i].isCreated()) {
                    resultString += 'Scholen,' + accountsForUpsert[i].Id + ',' + accountsForUpsert[i].ExternalCustomerId__c + ',inserted,\n';
                    this.createdAccountIdList.add(accountsForUpsert[i].Id);
                    insertedAccounts ++;
                } else {
                    resultString += 'Scholen,' + accountsForUpsert[i].Id + ',' + accountsForUpsert[i].ExternalCustomerId__c + ',updated,\n';
                    this.updatedAccountIdList.add(accountsForUpsert[i].Id);
                    updatedAccounts ++;
                }
            } else {
                String tmperr = '';
                for (Database.Error err : results[i].getErrors()) {
                    tmperr += '==> ' + err.getStatusCode() + ' : ' + err.getMessage();
                    System.debug('==========> ERROR: ' + err.getMessage());
                    errorAccounts ++;
                }
                resultString += 'Scholen,' + accountsForUpsert[i].Id + ',' + accountsForUpsert[i].ExternalCustomerId__c + ',error,' + tmperr + '\n';
            }
        }
        System.debug('RESULTS: We have updated ' + updatedAccounts + ' and inserted ' + insertedAccounts + ' Scholen. We experienced ' + errorAccounts + ' errors while upserting.');

        String content = 'AccountType,ID,ExternalCustomerId,Result,error\n';
        content += resultString;

        // create File (ContentVersion)
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'Results_Scholen' + this.fileNo + '.csv';
        conVer.Title = 'Results_Scholen' + this.fileNo + '.csv';
        conVer.VersionData = Blob.valueOf(content);
        insert conVer;

        // Link file to object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = this.agodiUpdateId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;

        
        if (this.fileNo < 4) {

            Map<String,Account> currentPlantynAccounts = AU_createAccountsFromAgodiData.getCurrentPlantynAccounts();
            Integer newFileNo = this.fileNo + 1;
            String title = 'scholen' + newFileNo + '.txt';

            if (!Test.isRunningTest()) {
                // Enqueue next School
                ContentVersion SchoolContentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId IN :this.contentDocumentIds AND Title = :title LIMIT 1];
                String file = SchoolContentVersion.VersionData.toString();

                System.debug('We found the file for school ' + newFileNo);
                Id jobId = System.enqueueJob(new AU_createScholen_queueable(file, currentPlantynAccounts, this.agodiUpdateId, newFileNo, processedAgodiNumbers, this.contentDocumentIds, this.createdAccountIdList, this.updatedAccountIdList));
                System.debug('AU_createScholen_queueable is enqueued with Job Id: ' + jobID);
            }
        } else {
            System.debug('AGODI UPDATE FINISHED, RESULTS CAN BE FOUND IN AGODI UPDATE RECORD WITH ID: ' + this.agodiUpdateId);
            AgodiUpdate__c au = [SELECT Id, Processed__c FROM AgodiUpdate__c WHERE Id = :this.agodiUpdateId LIMIT 1];
            au.Processed__c = true;
            au.UpdateIsRunning__c = false;
            update au;

            VAT_checkVat.triggerFutureClass = null;

            if (!Test.isRunningTest()) {
                // Enqueue Creteation of Account Subsisiaries (and Activation of Accounts)
                Id jobId = System.enqueueJob(new AU_createAccSubsidiaries_queueable(this.createdAccountIdList, this.updatedAccountIdList));
                System.debug('AU_createAccSubsidiaries_queueable is enqueued with Job Id: ' + jobID);
            }
        }
        System.debug('AU_createScholen_queueable - execute END');
    }
}