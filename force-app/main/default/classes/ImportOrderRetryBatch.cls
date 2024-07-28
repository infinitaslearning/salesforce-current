global class ImportOrderRetryBatch implements Database.Batchable<ImportOrder__c>, Database.AllowsCallouts {
    global Iterable<ImportOrder__c> start(Database.BatchableContext bc) {        
        List<ImportOrder__c> ioLs = [SELECT Id, ExternalOrderId__c FROM ImportOrder__c WHERE Status__c = 'Error' AND Error__c LIKE '%UNABLE_TO_LOCK_ROW%'];
        
        return ioLs;
    }
    
    global void execute(Database.BatchableContext bc, List<ImportOrder__c> records){
        string response;
        
        for(ImportOrder__c io : records){
            response = ImportOrderRetryRESTAPI.retryImportOrder(io.ExternalOrderId__c);
        }
        
        system.debug('response: ' + response);
        /*List<String> externalOrderIdLs = new List<String>();
        
        for(ImportOrder__c io : records){
            io.Status__c = 'Pending';
            externalOrderIdLs.add(io.ExternalOrderId__c);
        }
        
        update records;
        
        // update the related import orders that failed because of the headers failing
        List<ImportOrder__c> childRecords = [SELECT Id from ImportOrder__c WHERE ExternalOrderId__c IN: externalOrderIdLs AND Status__c = 'Error'];
        
        for(ImportOrder__c ioChild : childRecords){
            ioChild.Status__c = 'Pending';
        }
        
        update childRecords;*/
    } 
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        
        /*ImportOrder_RerunFailedBatch bc2 = new ImportOrder_RerunFailedBatch();
        Id batchId2 = Database.executeBatch(bc2, 200);*/
    }    
}