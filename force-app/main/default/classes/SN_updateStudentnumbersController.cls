public class SN_updateStudentnumbersController {
    
    @AuraEnabled
    public static List<StudentAndUsernumbers__c> handleFiles(String base64Data){

        List<StudentAndUsernumbers__c> studentNumbersList = new List<StudentAndUsernumbers__c>();

        String data = JSON.deserializeUntyped(base64Data).toString();

        List<String> lstCSVLines = data.split('\n');

        for (Integer i = 1; i < lstCSVLines.size(); i++) {

            StudentAndUsernumbers__c sun = new StudentAndUsernumbers__c();

            String csvLine = lstCSVLines[i];

            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;

            while (csvLine.indexOf('"') > -1) {

                if (startIndex == null) {
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex + 1, csvLine.length());
                } else {
                    if (endIndex == null) {
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex + 1, csvLine.length());
                    }
                }

                if (startIndex != null && endIndex != null) {
                    String sub = csvLine.substring(startIndex,endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }

            List<String> csvRowData = new List<String>();

            for (String column : csvLine.split(',')) {

                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                csvRowData.add(column);
                
            }

            // het columnValues and put in sun record

            studentNumbersList.add(sun);
            
        }

        insert studentNumbersList;

        return studentNumbersList;
    }
}