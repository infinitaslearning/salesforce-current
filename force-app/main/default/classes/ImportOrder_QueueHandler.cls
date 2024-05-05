public with sharing class ImportOrder_QueueHandler implements Queueable,Database.AllowsCallouts {
    

    Public Decimal Count;

    public ImportOrder_QueueHandler(Decimal Count) {
        this.Count = Count;
    }

    public void execute(System.QueueableContext qc) {
       
        
            String response = ImportOrder_ApiInsertUtility.dummyInsertImportOrders();
            System.debug('response: ' + response);
            
            Count = Count-1;
            checknextOrder(Count);
        

    }    

    public static void checknextOrder(Decimal Count){
          
          if(Count>0){
              System.enqueueJob(new ImportOrder_QueueHandler(Count));
          }
          
    }

}