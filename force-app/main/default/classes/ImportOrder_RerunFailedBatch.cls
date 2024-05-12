Global class ImportOrder_RerunFailedBatch implements Database.Batchable<sObject> {
    global class ImportOrderDTO {
        @InvocableVariable global String allOrSpecificRun;
        @InvocableVariable global String externalOrderId;
    }
    
	@InvocableMethod(Description = 'Rerun Failed Import Orders')
    global static void rerunImportOrders(ImportOrderDTO[] ioRun){
        system.debug('===ioRun: ' + ioRun);
        
        if(ioRun[0].allOrSpecificRun == 'Specific'){
            ImportOrder__c ioHeader = [SELECT Id, orderRef__c from ImportOrder__c where Status__c = 'Completed' AND ExternalOrderId__c =: ioRun[0].externalOrderId and ProductId__c = null LIMIT 1];
            List<ImportOrder__c> ioLs = [SELECT Id from ImportOrder__c where Status__c = 'Error' AND ExternalOrderId__c =: ioRun[0].externalOrderId];
            
            for(ImportOrder__c io : ioLs){
                io.Status__c = 'Pending';
                io.Error__c = '';
                io.orderRef__c = ioHeader.orderRef__c;
            }
            
            update ioLs;
        } else if(ioRun[0].allOrSpecificRun == 'All') {
			ImportOrder_RerunFailedBatch batchRun = new ImportOrder_RerunFailedBatch();
        	Database.executeBatch(batchRun, 100);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id from ImportOrder__c where Status__c = 'Error' AND (NOT Error__c LIKE '%UNABLE_TO_LOCK_ROW%')]);
    }
    
    global void execute(Database.BatchableContext BC, List<ImportOrder__c> scope){
        for(ImportOrder__c io : scope){
            io.Status__c = 'Pending';
            io.Error__c = '';
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}