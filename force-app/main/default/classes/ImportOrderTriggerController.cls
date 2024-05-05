global class ImportOrderTriggerController implements Database.Batchable<Id> {
	Map<ImportOrder__c, ImportOrder__c> recordMap = new Map<ImportOrder__c, ImportOrder__c>();
   
    global ImportOrderTriggerController(Map<ImportOrder__c, ImportOrder__c> recMap){
        recordMap = recMap; 
    }
    
    global List<Id> start(Database.BatchableContext BC){
        List<Id> recLs = new List<Id>();
        
        for(ImportOrder__c newItem : recordMap.keySet()){
            ImportOrder__c oldItem = recordMap.get(newItem); // old record for comparison
            
            // handle logic checks to see if record matches entry criteria for flow
            if(newItem.Status__c == 'Pending' || oldItem == null || newItem.Status__c != oldItem.Status__c || newItem.ReadyForPrivateIndividual__c == true){
                recLs.add(newItem.Id); // just add the ID of the record
            }
        }
        
        return recLs;
    }
    
    global void execute(Database.BatchableContext BC, List<Id> scope){
        for(Id recId : scope){
            Map<String, Object> params = new Map<String, Object>();
            params.put('recordId', recId);
            
            Flow.Interview importHandlerProcess = new Flow.Interview.ImportOrderHandler(params);
            importHandlerProcess.start();
        }      
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}