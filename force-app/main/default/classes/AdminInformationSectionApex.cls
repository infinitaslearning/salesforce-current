public with sharing class AdminInformationSectionApex {

    @AuraEnabled(cacheable=true)
    public static List<String> getFields(String objectName) {
        // Query the fields from the metadata for the object passed into the parameter
        List<AdminInformationSection__mdt> AdminInformationSectionMetadata = [SELECT Field_API_Name__c, Display_Position__c 
                                                                                FROM AdminInformationSection__mdt 
                                                                                WHERE Object__c =: objectName 
                                                                                ORDER BY Display_Position__c ASC];
        List<String> fieldsList = new List<String>();
        for(AdminInformationSection__mdt ais : AdminInformationSectionMetadata){
            fieldsList.add(ais.Field_API_Name__c);
        }

        System.debug('fieldsList: ' + fieldsList);
        // Return the list of fields from the metadata
        return fieldsList;
    }

}