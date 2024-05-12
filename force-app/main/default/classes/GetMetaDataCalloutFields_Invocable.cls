public class GetMetaDataCalloutFields_Invocable {
    public class FlowOutput{
        @InvocableVariable public Id batchId;
        public FlowOutput(Id batchId) {this.batchId = batchId;}
    }
    
	@InvocableMethod(label='Export MetaData Callout Fields to Files')
    public static FlowOutput[] extractMDTCalloutFields(){
        FlowOutput[] results = new List<FlowOutput>();
        
        GetMetaDataCalloutFields bc = new GetMetaDataCalloutFields();
        Id batchId = Database.executeBatch(bc, 300);
        
        // small pause
        DateTime delaySt = System.Now();
        while(System.Now() < delaySt.addSeconds(2)){}
        
        // Check batch status - IF COMPLETED then 
        AsyncApexJob aJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :batchId];
        
        system.debug('aJob.Status: ' + aJob.Status);
        if(aJob.Status == 'Completed'){
            results.add(new FlowOutput(batchId));
            
        }
        return results;
    }
}