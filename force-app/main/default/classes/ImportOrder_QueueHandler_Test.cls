@isTest
public class ImportOrder_QueueHandler_Test {
    
    @isTest static void testImportOrderInsertQueueable(){
        
        ImportOrder_QueueHandler ioq = new ImportOrder_QueueHandler(1);
        
        Test.startTest();
        System.enqueueJob(ioq);
        Test.stopTest();
    }
    
}