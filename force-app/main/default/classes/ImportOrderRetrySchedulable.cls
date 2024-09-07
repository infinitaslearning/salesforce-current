/*
* Connor Huglin 2022/12/02: https://dev.azure.com/infinitas/Converse/_boards/board/t/Order%20to%20Cash/Backlog%20items/?workitem=189059
* Retry mechanism for import orders that fail with the 'ERROR_UNABLE_TO_LOCK_ROW' error
*/
global class ImportOrderRetrySchedulable implements System.Schedulable {
    global void execute(SchedulableContext sc)
    {
        callJob();
    }
    
    public void callJob(){
        // fix parents
        ImportOrderRetryBatch bc = new ImportOrderRetryBatch();
        Id batchId = Database.executeBatch(bc, 1);
        
        // fix children
        /*ImportOrder_RerunFailedBatch bc2 = new ImportOrder_RerunFailedBatch();
        Id batchId2 = Database.executeBatch(bc2, 50);*/
        
        /*List<ImportOrder__c> records = [SELECT Id, ExternalOrderId__c FROM ImportOrder__c WHERE Status__c = 'Error' AND Error__c LIKE '%UNABLE_TO_LOCK_ROW%'];
        List<String> extIdLs = new List<String>();
        
        for(ImportOrder__c io : records){
            io.Status__c = 'Pending';
            extIdLs.add(io.ExternalOrderId__c);
        }
        
        update records;
        
        // get children and retry those
        List<ImportOrder__c> childRecs = [SELECT Id, ExternalOrderId__c FROM ImportOrder__c WHERE Status__c = 'Error' AND ExternalOrderId__c IN :extIdLs];
        
        for(ImportOrder__c io : childRecs){
            io.Status__c = 'Pending';
        }
        
        update childRecs;*/
    }
}