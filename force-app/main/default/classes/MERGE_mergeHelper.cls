public class MERGE_mergeHelper {
    
    public static void dedupeContactClassificationsOneMerge(List<Contact> contacts) {

        Boolean isMerge = false;

        Set<Id> masterRecordIds = new Set<id>();
        for (Contact c : contacts) {

            // Check if the delete is from a merge
            if (c.MasterRecordId != null) {
                isMerge = true;
                System.debug('MasterRecordId ==> ' + c.MasterRecordId);
                masterRecordIds.add(c.MasterRecordId);
            }
        }

        if (isMerge) {
            
            List<ClassificationData__c> classificationDataList = 
            [SELECT 
            Id,
            Active__c,
            Contact__c,
            createdDate,
            ClassificationAttribute__c,
            ClassificationAttributeValue__c,
            ClassificationAttributeSubValue__c,
            ClassificationAttributeSubValue2__c,
            ClassificationAttributeSubValue3__c,
            ClassificationAttributeSubValue4__c 
            FROM ClassificationData__c 
            WHERE Contact__c IN :masterRecordIds];

            System.debug('We have found ' + classificationDataList.size() + ' ClassificationData records.');
        
            Map<Id,List<ClassificationData__c>> classificationDataPerDeletedRecordMap = new Map<Id,List<ClassificationData__c>>();
            for (Id accountId : masterRecordIds) {

                List<ClassificationData__c> cdLst = new List<ClassificationData__c>();
                for (ClassificationData__c cd : classificationDataList) {
                    if (cd.Contact__c == accountId) {
                        cdLst.add(cd);
                    }
                }
                classificationDataPerDeletedRecordMap.put(accountId, cdLst);
            }

            List<ClassificationData__c> classificationDataDeleteList = new List<ClassificationData__c>();
            for (List<ClassificationData__c> cdLst : classificationDataPerDeletedRecordMap.values()) {
                
                for (Integer i = 0; i < cdLst.size(); i++) {
                    for (Integer j = 0; j < cdLst.size(); j++) {

                        if (i < j && !(classificationDataDeleteList.contains(cdLst[i]) || classificationDataDeleteList.contains(cdLst[j]))) {

                            if (cdLst[i].ClassificationAttribute__c == cdLst[j].ClassificationAttribute__c 
                                && cdLst[i].ClassificationAttributeValue__c == cdLst[j].ClassificationAttributeValue__c 
                                && cdLst[i].ClassificationAttributeSubValue__c == cdLst[j].ClassificationAttributeSubValue__c
                                && cdLst[i].ClassificationAttributeSubValue2__c == cdLst[j].ClassificationAttributeSubValue2__c 
                                && cdLst[i].ClassificationAttributeSubValue3__c == cdLst[j].ClassificationAttributeSubValue3__c 
                                && cdLst[i].ClassificationAttributeSubValue4__c == cdLst[j].ClassificationAttributeSubValue4__c) {
                                    
                                    // Duplicate Classification Record Found check what record needs to be deleted
                                    System.debug(LoggingLevel.INFO, 'Duplicate ClassificationData found with Id\'s ' + cdLst[i].Id + ' & ' + cdLst[j].Id);
                                    if ((cdLst[i].Active__c && cdLst[j].Active__c) || (!cdLst[i].Active__c && !cdLst[j].Active__c)) {
                                        System.debug('Both ClassificationData records are active');
                                        // if Both records are active or both are non active keep most recently created record
                                        if (cdLst[i].CreatedDate > cdLst[j].CreatedDate) {
                                            classificationDataDeleteList.add(cdLst[j]);
                                            System.debug('Adding CustomDetail with Id ' + cdLst[j].Id + ' and CreatedDate of ' + cdLst[j].CreatedDate + ' to the delete list. CustomDetail with Id ' + cdLst[i].Id + ' has a CreatedDate of ' + cdLst[i].CreatedDate);
                                        } else {
                                            classificationDataDeleteList.add(cdLst[i]);
                                            System.debug('Adding CustomDetail with Id ' + cdLst[i].Id + ' and CreatedDate of ' + cdLst[i].CreatedDate + ' to the delete list. CustomDetail with Id ' + cdLst[j].Id + ' has a CreatedDate of ' + cdLst[j].CreatedDate);
                                        }

                                    } else if (cdLst[i].Active__c) {
                                        // if only the record in i is active delete record j
                                        System.debug('Only the record with Id ' + cdLst[i].Id + ' is Active, we will delete the record with Id ' + cdLst[j].Id);
                                        classificationDataDeleteList.add(cdLst[j]);
                                    } else {
                                        // only option left is that only the record in j is active and the record in i is inactive so delete the record from i
                                        System.debug('Only the record with Id ' + cdLst[j].Id + ' is Active, we will delete the record with Id ' + cdLst[i].Id);
                                        classificationDataDeleteList.add(cdLst[i]);
                                    }

                            }

                        }

                    }
                }
            }

            String debugString = 'We will delete the records with the next Id\'s:\n';
            for (ClassificationData__c cd : classificationDataDeleteList) {
                debugString += 'Id: ' + cd.Id + '\n';
            }
            System.debug(debugString);
            
            try {
                delete classificationDataDeleteList;
            } catch (Exception e) {
                HandleCustomException.LogException(e);
            }

        }
    }

    public static void dedupeAccounttClassificationsOneMerge(List<Account> accounts) {

        Boolean isMerge = false;

        Set<Id> masterRecordIds = new Set<id>();
        for (Account a : accounts) {

            // Check if the delete is from a merge
            if (a.MasterRecordId != null) {
                isMerge = true;
                System.debug('MasterRecordId ==> ' + a.MasterRecordId);
                masterRecordIds.add(a.MasterRecordId);
            }
        }

        if (isMerge) {
            
            List<ClassificationData__c> classificationDataList = 
            [SELECT 
            Id,
            Active__c,
            Account__c,
            createdDate,
            ClassificationAttribute__c,
            ClassificationAttributeValue__c,
            ClassificationAttributeSubValue__c,
            ClassificationAttributeSubValue2__c,
            ClassificationAttributeSubValue3__c,
            ClassificationAttributeSubValue4__c 
            FROM ClassificationData__c 
            WHERE Account__c IN :masterRecordIds];

            System.debug('We have found ' + classificationDataList.size() + ' ClassificationData records.');
        
            Map<Id,List<ClassificationData__c>> classificationDataPerDeletedRecordMap = new Map<Id,List<ClassificationData__c>>();
            for (Id accountId : masterRecordIds) {

                List<ClassificationData__c> cdLst = new List<ClassificationData__c>();
                for (ClassificationData__c cd : classificationDataList) {
                    if (cd.Account__c == accountId) {
                        cdLst.add(cd);
                    }
                }
                classificationDataPerDeletedRecordMap.put(accountId, cdLst);
            }
            
            List<ClassificationData__c> classificationDataDeleteList = new List<ClassificationData__c>();
            for (List<ClassificationData__c> cdLst : classificationDataPerDeletedRecordMap.values()) {
                
                for (Integer i = 0; i < cdLst.size(); i++) {
                    for (Integer j = 0; j < cdLst.size(); j++) {

                        if (i < j && !(classificationDataDeleteList.contains(cdLst[i]) || classificationDataDeleteList.contains(cdLst[j]))) {

                            if (cdLst[i].ClassificationAttribute__c == cdLst[j].ClassificationAttribute__c 
                                && cdLst[i].ClassificationAttributeValue__c == cdLst[j].ClassificationAttributeValue__c 
                                && cdLst[i].ClassificationAttributeSubValue__c == cdLst[j].ClassificationAttributeSubValue__c
                                && cdLst[i].ClassificationAttributeSubValue2__c == cdLst[j].ClassificationAttributeSubValue2__c 
                                && cdLst[i].ClassificationAttributeSubValue3__c == cdLst[j].ClassificationAttributeSubValue3__c 
                                && cdLst[i].ClassificationAttributeSubValue4__c == cdLst[j].ClassificationAttributeSubValue4__c) {
                                    
                                    // Duplicate Classification Record Found check what record needs to be deleted
                                    System.debug(LoggingLevel.INFO, 'Duplicate ClassificationData found with Id\'s ' + cdLst[i].Id + ' & ' + cdLst[j].Id);
                                    if ((cdLst[i].Active__c && cdLst[j].Active__c) || (!cdLst[i].Active__c && !cdLst[j].Active__c)) {
                                        System.debug('Both ClassificationData records are active');
                                        // if Both records are active or both are non active keep most recently created record
                                        if (cdLst[i].CreatedDate > cdLst[j].CreatedDate) {
                                            classificationDataDeleteList.add(cdLst[j]);
                                            System.debug('Adding CustomDetail with Id ' + cdLst[j].Id + ' and CreatedDate of ' + cdLst[j].CreatedDate + ' to the delete list. CustomDetail with Id ' + cdLst[i].Id + ' has a CreatedDate of ' + cdLst[i].CreatedDate);
                                        } else {
                                            classificationDataDeleteList.add(cdLst[i]);
                                            System.debug('Adding CustomDetail with Id ' + cdLst[i].Id + ' and CreatedDate of ' + cdLst[i].CreatedDate + ' to the delete list. CustomDetail with Id ' + cdLst[j].Id + ' has a CreatedDate of ' + cdLst[j].CreatedDate);
                                        }

                                    } else if (cdLst[i].Active__c) {
                                        // if only the record in i is active delete record j
                                        System.debug('Only the record with Id ' + cdLst[i].Id + ' is Active, we will delete the record with Id ' + cdLst[j].Id);
                                        classificationDataDeleteList.add(cdLst[j]);
                                    } else {
                                        // only option left is that only the record in j is active and the record in i is inactive so delete the record from i
                                        System.debug('Only the record with Id ' + cdLst[j].Id + ' is Active, we will delete the record with Id ' + cdLst[i].Id);
                                        classificationDataDeleteList.add(cdLst[i]);
                                    }

                            }

                        }

                    }
                }
            }

            String debugString = 'We will delete the records with the next Id\'s:\n';
            for (ClassificationData__c cd : classificationDataDeleteList) {
                debugString += 'Id: ' + cd.Id + '\n';
            }
            System.debug(debugString);
            
            try {
                delete classificationDataDeleteList;
            } catch (Exception e) {
                HandleCustomException.LogException(e);
            }

        }
    }

}