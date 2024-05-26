/*
* Connor Huglin 2022/12/02: https://dev.azure.com/infinitas/Converse/_boards/board/t/Order%20to%20Cash/Backlog%20items/?workitem=189059
* Retry mechanism for import orders that fail with the 'ERROR_UNABLE_TO_LOCK_ROW' error
*/
global class ImportOrderRetrySchedulable implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        callJob();
    }
    
    public void callJob(){
        // import orders
        ImportOrderRetryBatch bc = new ImportOrderRetryBatch(null);
        Id batchId = Database.executeBatch(bc, 1);
    }
}