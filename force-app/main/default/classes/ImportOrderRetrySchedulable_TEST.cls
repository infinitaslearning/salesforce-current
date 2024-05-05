@isTest
public class ImportOrderRetrySchedulable_TEST {
    @testSetup
    public static void makeData(){
        ImportOrder__c io = new ImportOrder__c();
        io.Status__c = 'Error';
        io.ExternalOrderId__c = 'contest';
        io.Error__c = 'This error occurred when the flow tried to create records: UNABLE_TO_LOCK_ROW: unable to obtain exclusive access to this record or 1 records: 0013V00000AIZ7wQAH';
        
        insert io;
        
        ImportOrder__c io2 = new ImportOrder__c();
        io2.Status__c = 'Error';
        io2.ExternalOrderId__c = 'contest';
        io2.Error__c = 'Cant find parent';
        io2.TriggerBusinessLogic__c = true;
        
        insert io2;
    }
    
    public static testMethod void testImportOrderRetrySchedulable(){
        test.startTest();
        DateTime dtBefore9 = DateTime.newInstance(2023, 08, 17, 08, 00, 00);
        DateTime dtBefore11 = DateTime.newInstance(2023, 08, 17, 10, 00, 00);
        DateTime dtBefore17 = DateTime.newInstance(2023, 08, 17, 14, 00, 00);
        DateTime dtBefore23 = DateTime.newInstance(2023, 08, 17, 21, 00, 00);
        
        ImportOrderRetrySchedulable ioRetry = new ImportOrderRetrySchedulable();
        ioRetry.execute(null);
        
        ImportOrderRetryBatch bc1 = new ImportOrderRetryBatch(dtBefore9);
        Id batchId1 = Database.executeBatch(bc1, 1);
        
        ImportOrderRetryBatch bc2 = new ImportOrderRetryBatch(dtBefore11);
        Id batchId2 = Database.executeBatch(bc2, 1);
        
        ImportOrderRetryBatch bc3 = new ImportOrderRetryBatch(dtBefore17);
        Id batchId3 = Database.executeBatch(bc3, 1);
        
        ImportOrderRetryBatch bc4 = new ImportOrderRetryBatch(dtBefore23);
        Id batchId4 = Database.executeBatch(bc4, 1);
        test.stopTest();
    }
}