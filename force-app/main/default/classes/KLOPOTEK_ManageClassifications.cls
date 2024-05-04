public class KLOPOTEK_ManageClassifications {
    
    public static void createClassifications(List<KlopotekClassification__c> klopotekClassificationList) {

        List<String> teacherNumbers = new List<String>();
        List<String> schoolNumbers = new List<String>();
        for (KlopotekClassification__c kc : klopotekClassificationList) {
                teacherNumbers.add(kc.DocNr__c);
                if (kc.SchNr__c != '' && kc.SchNr__c != null) {
                    schoolNumbers.add(kc.SchNr__c);
                }
        }

        // Get Noordhoff Data
        Map<String, ClassificationAttributeTemplate__c> noordhoffTemplates = getTemplates('Noordhoff');
        Map<String, Id> noordhoffContacts = getContacts('Noordhoff', teacherNumbers);
        Map<String, Id> noordhoffAccounts = getAccounts('Noordhoff', schoolNumbers);

        List<Id> noordhoffAccountIdList = new List<Id>();
        noordhoffAccountIdList.addAll(noordhoffAccounts.values());
        List<ClassificationData__c> noordhoffCdList = new List<ClassificationData__c>();
        List<Id> noordhoffContactIdList = new List<Id>();
        noordhoffContactIdList.addAll(noordhoffContacts.values());
        List<ClassificationData__c> noordhoffContactCdList = new List<ClassificationData__c>();

        noordhoffCdList = [SELECT Id, 
            Account__c, 
            Active__c, 
            ClassificationAttribute__c, 
            ClassificationAttributeValue__c, 
            ClassificationAttributeSubValue__c, 
            ClassificationAttributeSubValue2__c, 
            ClassificationAttributeSubValue3__c, 
            ClassificationAttributeSubValue4__c, 
            NumberOfStudents__c 
            FROM ClassificationData__c WHERE Account__c IN :noordhoffAccountIdList ORDER BY Account__c];
        noordhoffContactCdList = [SELECT Id, 
            Contact__c, 
            Active__c, 
            ClassificationAttribute__c, 
            ClassificationAttributeValue__c, 
            ClassificationAttributeSubValue__c, 
            ClassificationAttributeSubValue2__c, 
            ClassificationAttributeSubValue3__c, 
            ClassificationAttributeSubValue4__c, 
            NumberOfStudents__c 
            FROM ClassificationData__c WHERE Contact__c IN :noordhoffContactIdList ORDER BY Contact__c];

        Map<Id, List<ClassificationData__c>> noordhoffAccountClassificationMap = new Map<Id, List<ClassificationData__c>>();
        Map<Id, List<ClassificationData__c>> noordhoffContactClassificationMap = new Map<Id, List<ClassificationData__c>>();
        
        Id currentNhAccountId;
        List<ClassificationData__c> tempNhCdLst = new List<ClassificationData__c>();
        for (ClassificationData__c cd : noordhoffCdList) {
            if (currentNhAccountId == null || currentNhAccountId == cd.Account__c) {
                currentNhAccountId = cd.Account__c;
                tempNhCdLst.add(cd);
            } else {
                noordhoffAccountClassificationMap.put(currentNhAccountId, tempNhCdLst);
                currentNhAccountId = cd.Account__c;
                tempNhCdLst = new List<ClassificationData__c>();
                tempNhCdLst.add(cd);
            }
        }

        Id currentNhContactId;
        List<ClassificationData__c> tempNhContactCdLst = new List<ClassificationData__c>();
        for (ClassificationData__c cd : noordhoffContactCdList) {
            if (currentNhContactId == null || currentNhContactId == cd.Contact__c) {
                currentNhContactId = cd.Contact__c;
                tempNhContactCdLst.add(cd);
            } else {
                noordhoffContactClassificationMap.put(currentNhContactId, tempNhContactCdLst);
                currentNhContactId = cd.Contact__c;
                tempNhContactCdLst = new List<ClassificationData__c>();
                tempNhContactCdLst.add(cd);
            }
        }

        // Get Plantyn Data
        Map<String, ClassificationAttributeTemplate__c> plantynTemplates = getTemplates('Plantyn');
        Map<String, Id> plantynContacts = getContacts('Plantyn',teacherNumbers);
        Map<String, Id> plantynAccounts = getAccounts('Plantyn', schoolNumbers);

        List<Id> plantynAccountIdList = new List<Id>();
        plantynAccountIdList.addAll(plantynAccounts.values());
        List<ClassificationData__c> plantynCdList = new List<ClassificationData__c>();
        List<Id> plantynContactIdList = new List<Id>();
        plantynContactIdList.addAll(plantynContacts.values());
        List<ClassificationData__c> plantynContactCdList = new List<ClassificationData__c>();

        plantynCdList = [SELECT Id, 
            Account__c, 
            Active__c, 
            ClassificationAttribute__c, 
            ClassificationAttributeValue__c, 
            ClassificationAttributeSubValue__c, 
            ClassificationAttributeSubValue2__c, 
            ClassificationAttributeSubValue3__c, 
            ClassificationAttributeSubValue4__c, 
            NumberOfStudents__c 
            FROM ClassificationData__c WHERE Account__c IN :plantynAccountIdList ORDER BY Account__c];
        plantynContactCdList = [SELECT Id, 
            Contact__c, 
            Active__c, 
            ClassificationAttribute__c, 
            ClassificationAttributeValue__c, 
            ClassificationAttributeSubValue__c, 
            ClassificationAttributeSubValue2__c, 
            ClassificationAttributeSubValue3__c, 
            ClassificationAttributeSubValue4__c, 
            NumberOfStudents__c 
            FROM ClassificationData__c WHERE Contact__c IN :plantynContactIdList ORDER BY Contact__c];

        Map<Id, List<ClassificationData__c>> plantynAccountClassificationMap = new Map<Id, List<ClassificationData__c>>();
        Map<Id, List<ClassificationData__c>> plantynContactClassificationMap = new Map<Id, List<ClassificationData__c>>();
        
        Id currentPlAccountId;
        List<ClassificationData__c> tempPlCdLst = new List<ClassificationData__c>();
        for (ClassificationData__c cd : plantynCdList) {
            if (currentPlAccountId == null || currentPlAccountId == cd.Account__c) {
                currentPlAccountId = cd.Account__c;
                tempPlCdLst.add(cd);
            } else {
                plantynAccountClassificationMap.put(currentPlAccountId, tempPlCdLst);
                currentPlAccountId = cd.Account__c;
                tempPlCdLst = new List<ClassificationData__c>();
                tempPlCdLst.add(cd);
            }
        }

        Id currentPlContactId;
        List<ClassificationData__c> tempPlContactCdLst = new List<ClassificationData__c>();
        for (ClassificationData__c cd : plantynContactCdList) {
            if (currentPlContactId == null || currentPlContactId == cd.Contact__c) {
                currentPlContactId = cd.Contact__c;
                tempPlContactCdLst.add(cd);
            } else {
                plantynContactClassificationMap.put(currentPlContactId, tempPlContactCdLst);
                currentPlContactId = cd.Contact__c;
                tempPlContactCdLst = new List<ClassificationData__c>();
                tempPlContactCdLst.add(cd);
            }
        }

        // Get Liber Data
        Map<String, ClassificationAttributeTemplate__c> liberTemplates = getTemplates('Liber');
        Map<String, Id> liberContacts = getContacts('Liber', teacherNumbers);
        Map<String, Id> liberAccounts = getAccounts('Liber', schoolNumbers);
        
        List<Id> liberAccountIdList = new List<Id>();
        liberAccountIdList.addAll(liberAccounts.values());
        List<ClassificationData__c> liberCdList = new List<ClassificationData__c>();
        List<Id> liberContactIdList = new List<Id>();
        liberContactIdList.addAll(liberContacts.values());
        List<ClassificationData__c> liberContactCdList = new List<ClassificationData__c>();

        liberCdList = [SELECT Id, 
            Account__c, 
            Active__c, 
            ClassificationAttribute__c, 
            ClassificationAttributeValue__c, 
            ClassificationAttributeSubValue__c, 
            ClassificationAttributeSubValue2__c, 
            ClassificationAttributeSubValue3__c, 
            ClassificationAttributeSubValue4__c, 
            NumberOfStudents__c 
            FROM ClassificationData__c WHERE Account__c IN :liberAccountIdList ORDER BY Account__c];
        liberContactCdList = [SELECT Id, 
            Contact__c, 
            Active__c, 
            ClassificationAttribute__c, 
            ClassificationAttributeValue__c, 
            ClassificationAttributeSubValue__c, 
            ClassificationAttributeSubValue2__c, 
            ClassificationAttributeSubValue3__c, 
            ClassificationAttributeSubValue4__c, 
            NumberOfStudents__c 
            FROM ClassificationData__c WHERE Contact__c IN :liberContactIdList ORDER BY Contact__c];

        Map<Id, List<ClassificationData__c>> liberAccountClassificationMap = new Map<Id, List<ClassificationData__c>>();
        Map<Id, List<ClassificationData__c>> liberContactClassificationMap = new Map<Id, List<ClassificationData__c>>();
        
        Id currentLiAccountId;
        List<ClassificationData__c> tempLiCdLst = new List<ClassificationData__c>();
        for (ClassificationData__c cd : liberCdList) {
            if (currentLiAccountId == null || currentLiAccountId == cd.Account__c) {
                currentLiAccountId = cd.Account__c;
                tempLiCdLst.add(cd);
            } else {
                liberAccountClassificationMap.put(currentLiAccountId, tempLiCdLst);
                currentLiAccountId = cd.Account__c;
                tempLiCdLst = new List<ClassificationData__c>();
                tempLiCdLst.add(cd);
            }
        }

        Id currentLiContactId;
        List<ClassificationData__c> tempLiContactCdLst = new List<ClassificationData__c>();
        for (ClassificationData__c cd : liberContactCdList) {
            if (currentLiContactId == null || currentLiContactId == cd.Contact__c) {
                currentLiContactId = cd.Contact__c;
                tempLiContactCdLst.add(cd);
            } else {
                liberContactClassificationMap.put(currentLiContactId, tempLiContactCdLst);
                currentLiContactId = cd.Contact__c;
                tempLiContactCdLst = new List<ClassificationData__c>();
                tempLiContactCdLst.add(cd);
            }
        }
        

        List<ClassificationData__c> cdInsertList = new List<ClassificationData__c>();
        List<KlopotekClassification__c> kcUpdateList = new List<KlopotekClassification__c>();

        List<String> incompleteCatCodeList = new List<String>{'/1/FU00','/1/OP003','/1/OP003/FU00','/1/OP004/FU00','/1/OP003/V','/1/OP003/V/VDOC/V','/1/OP004','/1/OP004/V','/1/OP004/FU00','/2/FU00','/4/CL001/OP727/FU00','/4/CL005/OP703/FU00','/9/FU'};

        for (KlopotekClassification__c kc : klopotekClassificationList) {

            List<ClassificationData__c> duplicateCheckList = new List<ClassificationData__c>();

            kc.ErrorMessage__c = '';

            Boolean createClassificationData = true;
            Boolean templateFound = false;
            ClassificationAttributeTemplate__c cat;

            ClassificationData__c cd = new ClassificationData__c();
            
            if (kc.CatCode__c.left(3) == '/01' || (kc.CatCode__c.length() == 4 && (kc.CatCode__c.left(4) == '/1/E' || kc.CatCode__c.left(4) == '/1/F'))) {
                
                System.debug('CatCode ' + kc.CatCode__c + ' is for GDPR Purposes, this is changed by the Privacy Permissions.');
                kc.ErrorMessage__c = 'CatCode ' + kc.CatCode__c + ' is for GDPR Purposes, this is changed by the Privacy Permissions.';
                kc.IsProcessed__c = true;
                createClassificationData = false;
                kcUpdateList.add(kc);
                continue;

            } else if (kc.CatCode__c.right(2) == '/A' || kc.CatCode__c.contains('/A/')) {
                
                System.debug('CatCode ' + kc.CatCode__c + ' is an old Klopotek Classification Value and not used anymore.');
                kc.ErrorMessage__c = 'CatCode ' + kc.CatCode__c + ' is an old Klopotek Classification Value and not used anymore.';
                kc.IsProcessed__c = true;
                createClassificationData = false;
                kcUpdateList.add(kc);
                continue;
                
            } else if (incompleteCatCodeList.contains(kc.CatCode__c)) {

                System.debug('CatCode ' + kc.CatCode__c + ' not complete to generate correct Classification Data.');
                kc.ErrorMessage__c = 'CatCode ' + kc.CatCode__c + ' not complete to generate correct Classification Data.';
                kc.IsProcessed__c = true;
                createClassificationData = false;
                kcUpdateList.add(kc);
                continue;

            } else if (kc.OperatingCompany__c == 'Noordhoff') {

                cd.OperatingCompany__c = 'Noordhoff';
                cat = noordhoffTemplates.get(kc.CatCode__c);
                if (cat == null && kc.CatCode__c.left(kc.OperatingCompany__c.length()) == kc.OperatingCompany__c) {
                    cat = noordhoffTemplates.get(kc.CatCode__c.substring(kc.CatCode__c.indexOf('/')));
                }

                if (kc.ContactId__c != null) {
                    cd.Contact__c = kc.ContactId__c;
                    if (kc.AccountId__c != null) {
                        cd.ContactClassificationAccount__c = kc.AccountId__c;
                    }
                    if (noordhoffContactClassificationMap.keySet().contains(cd.Contact__c)) {
                        if (noordhoffAccountClassificationMap.get(cd.Contact__c).size() > 0) {
                            duplicateCheckList = noordhoffAccountClassificationMap.get(cd.Contact__c);
                        }
                    }
                } else if (kc.AccountId__c != null) {
                    cd.Account__c = kc.AccountId__c;
                    if (noordhoffAccountClassificationMap.keySet().contains(cd.Account__c)) {
                        if (noordhoffAccountClassificationMap.get(cd.Account__c).size() > 0) {
                            duplicateCheckList = noordhoffAccountClassificationMap.get(cd.Account__c);
                        }
                    }
                } else if (kc.DocNr__c != null && kc.DocNr__c != '') {
                    cd.Contact__c = noordhoffContacts.get(kc.DocNr__c);
                    cd.ContactClassificationAccount__c = noordhoffAccounts.get(kc.SchNr__c);
                } else {
                    cd.Account__c = noordhoffAccounts.get(kc.SchNr__c);
                    if (kc.ValueDecimal__c != null) {
                        cd.NumberOfStudents__c = kc.ValueDecimal__c;
                    }
                }


            } else if (kc.OperatingCompany__c == 'Plantyn') {

                cd.OperatingCompany__c = 'Plantyn';
                cat = plantynTemplates.get(kc.CatCode__c);
                if (cat == null && kc.CatCode__c.left(kc.OperatingCompany__c.length()) == kc.OperatingCompany__c) {
                    cat = noordhoffTemplates.get(kc.CatCode__c.substring(kc.CatCode__c.indexOf('/')));
                }

                if (kc.ContactId__c != null) {
                    cd.Contact__c = kc.ContactId__c;
                    if (kc.AccountId__c != null) {
                        cd.ContactClassificationAccount__c = kc.AccountId__c;
                    }
                    if (plantynContactClassificationMap.keyset().contains(cd.Contact__c)) {
                        if (plantynContactClassificationMap.get(cd.Contact__c).size() > 0) {
                            duplicateCheckList = plantynContactClassificationMap.get(cd.Contact__c);
                        }
                    }
                } else if (kc.AccountId__c != null) {
                    cd.Account__c = kc.AccountId__c;
                    if (plantynAccountClassificationMap.keySet().contains(cd.Account__c)) {
                        if (plantynAccountClassificationMap.get(cd.Account__c).size() > 0) {
                            duplicateCheckList = plantynAccountClassificationMap.get(cd.Account__c);
                        }
                    }
                } else if (kc.DocNr__c != null && kc.DocNr__c != '') {
                    cd.Contact__c = plantynContacts.get(kc.DocNr__c);
                    cd.ContactClassificationAccount__c = plantynAccounts.get(kc.SchNr__c);
                } else {
                    cd.Account__c = plantynAccounts.get(kc.SchNr__c);
                    if (kc.ValueDecimal__c != null) {
                        cd.NumberOfStudents__c = kc.ValueDecimal__c;
                    }
                }


            } else if (kc.OperatingCompany__c == 'Liber') {

                cd.OperatingCompany__c = 'Liber';
                cat = liberTemplates.get(kc.CatCode__c);
                if (cat == null && kc.CatCode__c.left(kc.OperatingCompany__c.length()) == kc.OperatingCompany__c) {
                    cat = noordhoffTemplates.get(kc.CatCode__c.substring(kc.CatCode__c.indexOf('/')));
                }

                if (kc.ContactId__c != null) {
                    cd.Contact__c = kc.ContactId__c;
                    if (kc.AccountId__c != null) {
                        cd.ContactClassificationAccount__c = kc.AccountId__c;
                    }
                    if (liberContactClassificationMap.keyset().contains(cd.Contact__c)) {
                        if (liberContactClassificationMap.get(cd.Contact__c).size() > 0) {
                            duplicateCheckList = liberContactClassificationMap.get(cd.Contact__c);
                        }
                    }
                } else if (kc.AccountId__c != null) {
                    cd.Account__c = kc.AccountId__c;
                    if (liberAccountClassificationMap.keySet().contains(cd.Account__c)) {
                        if (liberAccountClassificationMap.get(cd.Account__c).size() > 0) {
                            duplicateCheckList = liberAccountClassificationMap.get(cd.Account__c);
                        }
                    }
                } else if (kc.DocNr__c != null && kc.DocNr__c != '') {
                    cd.Contact__c = liberContacts.get(kc.DocNr__c);
                    cd.ContactClassificationAccount__c = liberAccounts.get(kc.SchNr__c);
                } else {
                    cd.Account__c = liberAccounts.get(kc.SchNr__c);
                    if (kc.ValueDecimal__c != null) {
                        cd.NumberOfStudents__c = kc.ValueDecimal__c;
                    }
                }


            } else {
                System.debug('ERROR - No OperatingCompany found on Klopotek Classification Record with Id ' + kc.Id);
                kc.ErrorMessage__c = 'ERROR - No OperatingCompany found on Klopotek Classification Record';
                kc.IsProcessed__c = true;
                createClassificationData = false;
                kcUpdateList.add(kc);
                continue;
            }

            if (cat != null) {
                cd.ClassificationAttribute__c = cat.ClassificationAttributeId__c;
                cd.ClassificationAttributeValue__c = cat.ClassificationAttributeValueId__c;
                cd.ClassificationAttributeSubValue__c = cat.ClassificationAttributeSubValueId__c;
                cd.ClassificationAttributeSubValue2__c = cat.ClassificationAttributeSubValueId2__c;
                cd.ClassificationAttributeSubValue3__c = cat.ClassificationAttributeSubValueId3__c;
                cd.ClassificationAttributeSubValue4__c = cat.ClassificationAttributeSubValueId4__c;
                cd.Active__c = true;
            } else {
                System.debug('ERROR - No template found for ==> ' + kc.CatCode__c);
                kc.ErrorMessage__c = 'ERROR - No template found for ==> ' + kc.CatCode__c;
                kc.IsProcessed__c = true;
                createClassificationData = false;
            }

            Boolean isDuplicate = checkDuplicates(cd, duplicateCheckList);
            

            if (createClassificationData && !isDuplicate) {
                cdInsertList.add(cd);
                kc.IsProcessed__c = true;
            } 
            
            if (isDuplicate) {
                kc.ErrorMessage__c = 'Classification already in Salesforce';
                kc.IsProcessed__c = true;
            }

            kcUpdateList.add(kc);

            System.debug('createClassificationData ==> ' + createClassificationData);
            System.debug('isDuplicate ==> ' + isDuplicate);
            System.debug('kc.IsProcessed ==> ' + kc.IsProcessed__c);
            System.debug('Klopotek Classification ==> ' + kc);
        }

        try {
            update kcUpdateList;
        } catch (Exception e) {
            HandleCustomException.LogException(e);
            System.debug('ERROR updating the Classification Template List ==> ' + e.getMessage());
        }

        try {
            insert cdInsertList;
        } catch (Exception e) {
            HandleCustomException.LogException(e);
            System.debug('ERROR inserting the Classification Data List ==> ' + e.getMessage());
        }

    }

    public static Map<String, ClassificationAttributeTemplate__c> getTemplates(String opCo) {

        List<ClassificationAttributeTemplate__c> templateList = new List<ClassificationAttributeTemplate__c>();
        Map<String, ClassificationAttributeTemplate__c> templateMap = new Map<String, ClassificationAttributeTemplate__c>();

        templateList = [SELECT Id, 
                            ClassificationCode__c, 
                            ClassificationAttributeId__c, 
                            ClassificationAttributeValueId__c, 
                            ClassificationAttributeSubValueId__c, 
                            ClassificationAttributeSubValueId2__c, 
                            ClassificationAttributeSubValueId3__c, 
                            ClassificationAttributeSubValueId4__c 
                            FROM ClassificationAttributeTemplate__c
                            WHERE OperatingCompany__c = :opCo];

        for (ClassificationAttributeTemplate__c cat : templateList) {
            templateMap.put(cat.ClassificationCode__c, cat);
            if (cat.ClassificationCode__c.left(opCo.length()) == opCo) {
                templateMap.put(cat.ClassificationCode__c.substring(cat.ClassificationCode__c.indexOf('/')), cat);
            }
        } 

        return templateMap;
    }

    public static Map<String, Id> getContacts(String opCo, List<String> teacherNumbers) {

        List<Contact> contactList = new List<Contact>();
        Map<String, Id> contactIdMap = new Map<String, Id>();

        // create ContactId Map
        contactList = [SELECT Id, TeacherNumber__c FROM Contact WHERE OperatingCompany__c = :opCo AND TeacherNumber__c != '' AND TeacherNumber__c IN :teacherNumbers];
        for (Contact c : contactList) {
            contactIdMap.put(c.TeacherNumber__c, c.Id);
        }

        return contactIdMap;
    }

    public static Map<String, Id> getAccounts(String opCo, List<String> schoolNumbers) {

        List<Account> accountList = new List<Account>();
        Map<String, Id> accountIdMap = new Map<String, Id>();

        // create AccountId Map
        accountList = [SELECT Id, ExternalCustomerId__c FROM Account WHERE OperatingCompany__c = :opCo AND ExternalCustomerId__c != '' AND ExternalCustomerId__c IN :schoolNumbers];
        for (Account a : accountList) {
            accountIdMap.put(a.ExternalCustomerId__c, a.Id);
        }

        return accountIdMap;
    }

    public static Boolean checkDuplicates(ClassificationData__c newCd, List<ClassificationData__c> cdList) {
        Boolean isDulicate = false;

        System.debug('#### Checking for duplicates ####');

        for (ClassificationData__c cd : cdList) {
            System.debug('Active = ' + cd.Active__c);
            System.debug('Compare ClassificationAttribute__c ==> Check: ' + Cd.ClassificationAttribute__c + ' New: ' + newCd.ClassificationAttribute__c);
            System.debug('Compare ClassificationAttributeValue__c ==> Check: ' + Cd.ClassificationAttributeValue__c + ' New: ' + newCd.ClassificationAttributeValue__c);
            System.debug('Compare ClassificationAttributeSubValue__c ==> Check: ' + Cd.ClassificationAttributeSubValue__c + ' New: ' + newCd.ClassificationAttributeSubValue__c);
            System.debug('Compare ClassificationAttributeSubValue2__c ==> Check: ' + Cd.ClassificationAttributeSubValue2__c + ' New: ' + newCd.ClassificationAttributeSubValue2__c);
            System.debug('Compare ClassificationAttributeSubValue3__c ==> Check: ' + Cd.ClassificationAttributeSubValue3__c + ' New: ' + newCd.ClassificationAttributeSubValue3__c);
            System.debug('Compare ClassificationAttributeSubValue4__c ==> Check: ' + Cd.ClassificationAttributeSubValue4__c + ' New: ' + newCd.ClassificationAttributeSubValue4__c);
            if (cd.Active__c && 
                cd.ClassificationAttribute__c == newCd.ClassificationAttribute__c && 
                cd.ClassificationAttributeValue__c == newCd.ClassificationAttributeValue__c && 
                cd.ClassificationAttributeSubValue__c == newCd.ClassificationAttributeSubValue__c && 
                cd.ClassificationAttributeSubValue2__c == newCd.ClassificationAttributeSubValue2__c &&
                cd.ClassificationAttributeSubValue3__c == newCd.ClassificationAttributeSubValue3__c &&
                cd.ClassificationAttributeSubValue4__c == newCd.ClassificationAttributeSubValue4__c) {
                    isDulicate = true;
                }
        }
        System.debug('IsDuplicate = ' + isDulicate);

        return isDulicate;
    }

}