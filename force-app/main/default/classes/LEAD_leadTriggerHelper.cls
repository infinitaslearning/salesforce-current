public without sharing class LEAD_leadTriggerHelper {

    public static void afterUpdate(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {

        LeadStatus convertStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        List<Lead> updateList = new List<Lead>();
        List<Lead> deleteList = new List<Lead>();

        Map<Id, Account> accountMap;
        Map<String, Id> userIdMap = new Map<String, Id>();

        List<Id> accountIds = New List<Id>();
        for (Lead l : newMap.values()) {
            accountIds.add(l.Account__c);
        }

        if (accountIds.size() > 0) {
            accountMap = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]);
        }

        for (Lead l : newMap.values()) {
            
            if (l.Status != oldMap.get(l.Id).Status && l.Status == 'Discarded') {

                if (l.ReasonClosed__c == '7-Duplicate/test/wrong data') {

                    Lead deleteLead = new Lead();
                    deleteLead.Id = l.Id;
                    deleteList.add(deleteLead);

                } else {

                    Lead ld = New Lead();
                    ld.Id = l.Id;
                    
                    if (String.ValueOf(l.OwnerId).substring(0,3) != '005') {
                        if (l.Account__c != null) {
                            ld.OwnerId = accountMap.get(l.Account__c).OwnerId;
                        } else if (l.OperatingCompany__c == 'Liber' && ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').LiberId__c != null) {
                            ld.OwnerId = Id.valueOf(ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').LiberId__c);
                        } else if (l.OperatingCompany__c == 'Plantyn' && ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').PlantynId__c != null) {
                            ld.OwnerId = Id.valueOf(ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').PlantynId__c);
                        } else {
                            ld.OwnerId = Id.valueOf(ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').GeneralId__c);
                        }
                    }

                    ld.AutoConvert__c = true;
                    updateList.add(ld);

                }
            }
        }

        if (updateList.size() > 0) {
            update updateList;
        }

        if (deleteList.size() > 0) {
            delete deleteList;
        }

    }

    public static void afterInsert(List<Lead> leads) {

        LeadStatus convertStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        List<Lead> updateList = new List<Lead>();
        List<Lead> deleteList = new List<Lead>();

        Map<Id, Account> accountMap;
        Map<String, Id> userIdMap = new Map<String, Id>();

        List<Id> accountIds = New List<Id>();
        for (Lead l : leads) {
            accountIds.add(l.Account__c);
        }

        if (accountIds.size() > 0) {
            accountMap = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]);
        }

        for (Lead l : leads) {
            
            if (l.Status == 'Discarded') {

                if (l.ReasonClosed__c == '7-Duplicate/test/wrong data') {

                    Lead deleteLead = new Lead();
                    deleteLead.Id = l.Id;
                    deleteList.add(deleteLead);

                } else {

                    Lead ld = New Lead();
                    ld.Id = l.Id;
                    
                    if (String.ValueOf(l.OwnerId).substring(0,3) != '005') {
                        if (l.Account__c != null) {
                            ld.OwnerId = accountMap.get(l.Account__c).OwnerId;
                        } else if (l.OperatingCompany__c == 'Liber' && ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').LiberId__c != null) {
                            ld.OwnerId = Id.valueOf(ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').LiberId__c);
                        } else if (l.OperatingCompany__c == 'Plantyn' && ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').PlantynId__c != null) {
                            ld.OwnerId = Id.valueOf(ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').PlantynId__c);
                        } else {
                            ld.OwnerId = Id.valueOf(ApexIds__mdt.getInstance('LEAD_leadTriggerHelper').GeneralId__c);
                        }
                    }

                    ld.AutoConvert__c = true;
                    updateList.add(ld);

                }
            }
        }

        if (updateList.size() > 0) {
            update updateList;
        }

        if (deleteList.size() > 0) {
            delete deleteList;
        }

    }

}