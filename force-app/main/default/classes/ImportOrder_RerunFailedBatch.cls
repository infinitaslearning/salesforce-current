Global class ImportOrder_RerunFailedBatch implements Database.Batchable<sObject> {
    global class ImportOrderDTO {
        @InvocableVariable global String allOrSpecificRun;
        @InvocableVariable global String externalOrderId;
    }
    
	@InvocableMethod(Description = 'Rerun Failed Import Orders')
    global static void rerunImportOrders(ImportOrderDTO[] ioRun){
        system.debug('===ioRun: ' + ioRun);
        
        if(ioRun[0].allOrSpecificRun == 'Specific'){
            List<ImportOrder__c> ioLs = [SELECT Id from ImportOrder__c where Status__c = 'Error' AND ExternalOrderId__c =: ioRun[0].externalOrderId];
            
            for(ImportOrder__c io : ioLs){
                io.Status__c = 'Pending';
            }
            
            update ioLs;
        } else if(ioRun[0].allOrSpecificRun == 'All') {
			ImportOrder_RerunFailedBatch batchRun = new ImportOrder_RerunFailedBatch();
        	Database.executeBatch(batchRun, 100);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id from ImportOrder__c where Status__c = 'Error']);
    }
    
    global void execute(Database.BatchableContext BC, List<ImportOrder__c> scope){
        for(ImportOrder__c io : scope){
            io.Status__c = 'Pending';
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}