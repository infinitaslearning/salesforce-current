public class MERGE_csvContactMerge {

    @AuraEnabled
    public static Id mergeContacts(String base64Data, String email) {
        System.debug(LoggingLevel.INFO, 'MERGE_csvContactMerge - mergeContacts');
        
        String data = JSON.deserializeUntyped(base64Data).toString();

        Map<String,String> masterAndDuplicateMap = new Map<String,String>();
        list<String> lstCSVLines = data.split('\n');

        for(Integer i = 1; i < lstCSVLines.size(); i++){

            String masterRecord;
            String duplicateRecord;

            // Account acc = new Account();
            String csvLine = lstCSVLines[i];

            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;
            
            while(csvLine.indexOf('"') > -1){
            
                if(startIndex == null){
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                }else{
                    if(endIndex == null){
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                    }
                }
                
                if(startIndex != null && endIndex != null){
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }
            
            List<String> csvRowData = new List<String>();
            for(String column : csvLine.split(',')){
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',').replaceAll('\r','');
                csvRowData.add(column);
            }

            masterRecord = csvRowData[0];
            duplicateRecord = csvRowData[1];

            masterAndDuplicateMap.put(masterRecord,duplicateRecord);
        }

        Id batchprocessId;
        if (email.length() > 1) {
            MERGE_csvContactMergeBatchJob csvConMergeBatch = new MERGE_csvContactMergeBatchJob(masterAndDuplicateMap, email);
            batchprocessId = Database.executeBatch(csvConMergeBatch, 1);
        } else {
            MERGE_csvContactMergeBatchJob csvConMergeBatch = new MERGE_csvContactMergeBatchJob(masterAndDuplicateMap);
            batchprocessId = Database.executeBatch(csvConMergeBatch, 1);
        }

        return batchprocessId;

    }

    @AuraEnabled
    public static String getEmailFromUser(Id userId) {
        System.debug(LoggingLevel.INFO, 'MERGE_csvContactMerge - getEmailFromUser');
        return [SELECT email FROM User WHERE Id = :userId LIMIT 1].email;
    }

}