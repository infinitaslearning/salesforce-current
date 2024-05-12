public with sharing class Order_TESTBULKINSERT implements Queueable {
    
        // Private List<Order_ProductSelectController.OrderLineItem> OrderItems;
        // Private List<OrderItem> lstOrderItem;
        //List<Order_ProductSelectController.OrderLineItem> OrderItems,
         
        List<Asset> LstAsset;
     
         public Order_TESTBULKINSERT(List<Asset> LstAsset) {
           //  this.OrderItems = OrderItems;
             this.LstAsset = LstAsset;     
         }

         public void execute(System.QueueableContext qc) {

            if(LstAsset.size()>0){

                Date RenewalDay = system.today();
                for(Asset ass:LstAsset){
	                ass.RenewalDate__c  = RenewalDay;
                    ass.LastRenewalUpdate__c = null; 
                    ass.AutomatedRenewProcess__c = true; 
                }
                update LstAsset;
                Integer endindex = LstAsset.size()-1;
                //AND LastRenewalUpdate__c !=: null 
                system.debug('**End ID**'+LstAsset[endindex].id);
                Asset[] lst_AssetResets = [Select id,RenewalDate__c,LastRenewalUpdate__c,AutomatedRenewProcess__c from Asset  where id >:LstAsset[endindex].id   Order by Id ASC limit 2000 ];
                system.debug('**SIZE**'+LstAsset.size());
                System.enqueueJob(new Order_TESTBULKINSERT(lst_AssetResets));
            }


         }   
        }