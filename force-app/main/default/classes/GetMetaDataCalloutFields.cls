global class GetMetaDataCalloutFields implements Database.Batchable<AWSCalloutFields__mdt> {
    global Iterable<AWSCalloutFields__mdt> start(Database.BatchableContext bc) {        
		// get metadata records        
        return AWSCalloutFields__mdt.getAll().values();
    }
    
    global void execute(Database.BatchableContext bc, List<AWSCalloutFields__mdt> records){
        String fileHeader = 'Salesforce Field API Name,Destination Field Name,Field Data Type,Salesforce Object,Picklist Values (semi-colon separated)';
        
        fileHeader += ' \n';
        String finalStr = fileHeader;
        
        Set<String> sourceObjectLs = new Set<String>();
        
        for(AWSCalloutFields__mdt mdtRec : records){
            String recordStr = ''; 
            String fieldAPIName = mdtRec.SourceFieldName__c;
            
            sourceObjectLs.add(mdtRec.SourceObject__c);
            
            SObjectType sObjType = ((SObject)(Type.forName('Schema.' + mdtRec.SourceObject__c).newInstance())).getSObjectType();
            DescribeSObjectResult describeSobj = sObjType.getDescribe();
            
            Schema.DisplayType dataType = sObjType.getDescribe().fields.getMap().get(fieldAPIName).getDescribe().getType();
            //System.debug(fieldAPIName + ' data type is: ' + dataType);
            
            if(String.valueOf(dataType) == 'PICKLIST'){
                List<String> picklistOptions = new List<String>();
                Schema.DescribeFieldResult fieldResult = sObjType.getDescribe().fields.getMap().get(fieldAPIName).getDescribe();
                
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    picklistOptions.add(pickListVal.getValue());
                } 
                //system.debug('picklistOptions: ' + picklistOptions);
                
                String joinedPicklistVals = string.join(picklistOptions, ';');
                joinedPicklistVals = joinedPicklistVals.replaceAll(',', '');
                
                recordStr += fieldAPIName + ',' + mdtRec.DestinationFieldName__c + ',' + dataType + ',' + mdtRec.SourceObject__c + ',' + joinedPicklistVals + ' \n';
            } else {
                recordStr += fieldAPIName + ',' + mdtRec.DestinationFieldName__c + ',' + dataType + ',' + mdtRec.SourceObject__c + ' \n';
            }
            
            finalStr += recordStr;
        }
                
        Blob csvBlob = Blob.valueOf(finalStr);
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = 'METADATA EXTRACTION_' + DateTime.now() + '.csv'; //title of the file
        cv.PathOnClient = 'METADATA EXTRACTION_' + DateTime.now(); // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = csvBlob; //file data
        insert cv;
        
        // export validation formulas as well
        exportValidationFormulas(sourceObjectLs);
    } 
    
    private void exportValidationFormulas(Set<String> sourcObjects){
        String fileHeader = 'Salesforce Field API Name,Salesforce Object,Validation Formula';
        
        fileHeader += ' \n';
        String finalStr = fileHeader;
        
        for(String objAPIName : sourcObjects){
            SObjectType sObjType = ((SObject)(Type.forName('Schema.' + objAPIName).newInstance())).getSObjectType();
            
            Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : fieldMap.values()){
                
                Schema.DescribeFieldResult dfr = field.getDescribe();
                //isCalculated() is used to identify custom formula fields
                //getCalculatedFormula() != null is used to exclude rollup summary fields as they are treated as formulas
                if(dfr.isCalculated() && dfr.getCalculatedFormula() != null){
                    String fieldName = dfr.getName();
                    
                    if(fieldName.contains('Valid')){
                        String formula = dfr.getCalculatedFormula();
                        formula = formula.replaceAll('(\\r|\\n)+', ' ');
                        formula = '"' + formula.replaceAll('"', '\'')  + '"';
                        //system.debug('=== formula: ' + formula);
                        
                        String recordStr = fieldName + ',' + objAPIName + ',' + formula + ' \n';
                        finalStr += recordStr;
                    }
                }
            }
        }
        
        Blob csvBlob = Blob.valueOf(finalStr);
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = 'VALIDATION_FORMULA EXTRACTION_' + DateTime.now() + '.csv'; //title of the file
        cv.PathOnClient = 'VALIDATION_FORMULA EXTRACTION_' + DateTime.now(); // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = csvBlob; //file data
        insert cv;
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}