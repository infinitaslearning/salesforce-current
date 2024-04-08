@IsTest
public class KLOPOTEK_TestDataFactory {
    
    public static void createData() {

        List<String> objects = new List<String>{'Contact','Account'};
        List<String> OpCos = new List<String>{'Noordhoff','Plantyn','Liber'};

        //Create Classification Attributes
        Map<String,ClassificationAttribute__c> caMap = new Map<String,ClassificationAttribute__c>();

        for (String objectName : objects) {
            for (String opco : OpCos) {
                ClassificationAttribute__c ca = new ClassificationAttribute__c();
                ca.Name = 'Test Attribute for ' + objectName + 's';
                ca.OperatingCompany__c = opco;
                ca.ObjectName__c = objectName;
                caMap.put(ca.ObjectName__c,ca);
            }
            
        }
        insert caMap.Values();

        //Create Classification Attribute Values
        Map<String, List<ClassificationAttributeValue__c>> cavMap = new Map<String, List<ClassificationAttributeValue__c>>();
        List<ClassificationAttributeValue__c> cavInsertLst = new List<ClassificationAttributeValue__c>();
        for (String objectName : objects) {
            List<ClassificationAttributeValue__c> cavLst = new List<ClassificationAttributeValue__c>();
            for (String opco : OpCos) {
                for (Integer i = 0; i < 5; i++) {
                    ClassificationAttributeValue__c cav = new ClassificationAttributeValue__c();
                    cav.Name = 'TestCustomAttribute ' + objectName + ' ' + i;
                    cav.ClassificationAttribute__c = caMap.get(objectName).Id;
                    cav.ObjectName__c = objectName;
                    cav.OperatingCompany__c = opco;
                    cav.Active__c = true;
                    cavLst.add(cav);
                    cavInsertLst.add(cav);
                }
            }
            
            cavMap.put(objectName,cavLst);
        }
        insert cavInsertLst;

        //Parent Classification Attribute Values
        List<ClassificationAttributeValue__c> cavUpdateLst = new List<ClassificationAttributeValue__c>();
        for (String objectName : cavMap.keySet()) {
            String cavId = '';
            for (ClassificationAttributeValue__c cav : cavMap.get(objectName)) {
                if (cavId != '') {
                    cav.ClassificationAttributeValue__c = cavId;
                    cavUpdateLst.add(cav);
                } else {
                    cavId = cav.Id;
                }
            }
        }
        update cavUpdateLst;

        //Create Classification Attribute Templates
        List<ClassificationAttributeTemplate__c> catLst = new List<ClassificationAttributeTemplate__c>();
        for (String objectName : cavMap.keySet()) {
            Integer catPrefix = 0;
            for (ClassificationAttributeValue__c cav : cavMap.get(objectName)) {
                ClassificationAttributeTemplate__c cat = new ClassificationAttributeTemplate__c();
                cat.ClassificationCode__c = '/' + catPrefix + '/Test/' + objectName;
                cat.ClassificationAttributeId__c = caMap.get(objectName).Id;
                cat.ClassificationAttributeValueId__c = cavMap.get(objectName)[0].Id;
                if (catPrefix > 0) {
                    cat.ClassificationAttributeSubValueId__c = cavMap.get(objectName)[1].Id;
                }
                if (catPrefix > 1) {
                    cat.ClassificationAttributeSubValueId2__c = cavMap.get(objectName)[2].Id;
                }
                if (catPrefix > 2) {
                    cat.ClassificationAttributeSubValueId3__c = cavMap.get(objectName)[3].Id;
                }
                if (catPrefix > 3) {
                    cat.ClassificationAttributeSubValueId4__c = cavMap.get(objectName)[4].Id;
                }
                if (catPrefix == 0) {
                    cat.OperatingCompany__c = 'Plantyn';
                } else if (catPrefix == 1) {
                    cat.OperatingCompany__c = 'Liber';
                } else {
                    cat.OperatingCompany__c = 'Noordhoff';
                }
                catPrefix ++;
                catLst.add(cat);
            }
        }
        insert catLst;

        //Create Test Accounts
        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        List<Account> accLst = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account a = new Account();
            a.Name = 'Test Account ' + i;
            a.RecordTypeId = recordTypeId;
            if (i == 0) {
                a.OperatingCompany__c = 'Plantyn';
                a.ExternalDatabase__c = 'Agodi';
            } else if (i == 1) {
                a.OperatingCompany__c = 'Liber';
            } else {
                a.OperatingCompany__c = 'Noordhoff';
            }
            a.ExternalCustomerId__c = '54321' + i;
            a.NumberofStudents__c = 0;
            accLst.add(a);
        }

        System.debug('AccountList:\n' + accLst);
        insert accLst;
        
        //Create Test Contacts
        List<Contact> ctLst = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact' + i;
            c.TeacherNumber__c = '12345' + i;
            if (i == 0) {
                c.OperatingCompany__c = 'Plantyn';
            } else if (i == 1) {
                c.OperatingCompany__c = 'Liber';
            } else {
                c.OperatingCompany__c = 'Noordhoff';
            }
            ctLst.add(c);
        }
        insert ctLst;

        //Create Test Klopotek Classifications for Contacts
        List<KlopotekClassification__c> kcLst = new List<KlopotekClassification__c>();
        for (Integer i = -1; i < 5; i++) {
            KlopotekClassification__c kc = new KlopotekClassification__c();
            kc.DocNr__c = '12345' + i;
            kc.SchNr__c = '54321' + i;
            if (i == -1) {
                kc.CatCode__c = '/01/TestGDPRCakCode';
            } else {
                kc.CatCode__c = '/' + i + '/Test/Contact';
            }
            if (i == 0) {
                kc.OperatingCompany__c = 'Plantyn';
            } else if (i == 1) {
                kc.OperatingCompany__c = 'Liber';
            } else {
                kc.OperatingCompany__c = 'Noordhoff';
            }
            if (i > 3) {
                kc.DocNr__c = '';
                kc.SchNr__c = '';
                kc.ContactId__c = ctLst[i-1].Id;
            }
            kcLst.add(kc);
        }

        //Create Test Klopotek Classifications for Accounts
        for (Integer i = -3; i < 5; i++) {
            KlopotekClassification__c kc = new KlopotekClassification__c();
            kc.SchNr__c = '54321' + i;
            if (i == -2) {
                kc.CatCode__c = 'TestCatcodeForOldValues/A';
            } else if (i == -1) {
                kc.CatCode__c = '/1/FU00';
            } else {
                kc.CatCode__c = '/' + i + '/Test/Account';
            }
            
            if (i == 0) {
                kc.OperatingCompany__c = 'Plantyn';
            } else if (i == 1) {
                kc.OperatingCompany__c = 'Liber';
            } else if (i > -3) {
                kc.OperatingCompany__c = 'Noordhoff';
            }
            if (i > 3) {
                kc.SchNr__c = '';
                kc.AccountId__c = accLst[i-1].Id;
            }
            kcLst.add(kc);
        }
        insert kcLst;

        //Create Classification Data Test records
        List<ClassificationData__c> cdLst = new List<ClassificationData__c>();
        for (Account  acc : accLst) {
            cdLst.add(createClassificationDataForAccount(acc));
        }
        for (Contact con : ctLst) {
            cdLst.add(createClassificationDataForContact(con));
        }
        insert cdLst;

    }

    public static ClassificationData__c createClassificationDataForAccount(Account acc) {
        ClassificationData__c cd = new ClassificationData__c();
        cd.Account__c = acc.Id;
        return cd;
    }

    public static ClassificationData__c createClassificationDataForContact(Contact con) {
        ClassificationData__c cd = new ClassificationData__c();
        cd.Contact__c = con.Id;
        return cd;
    }

}