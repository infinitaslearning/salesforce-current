public with sharing class Order_OrderUtilityQueueable implements Queueable {
    // TO BE DELETED

    Private String UpdateType;
    Private List<Id> lstOrderId;


    public Order_OrderUtilityQueueable(String UpdateType,List<Id> lstOrderId) {
        this.UpdateType = UpdateType;
        this.lstOrderId = lstOrderId;
    }


    public void execute(System.QueueableContext qc) {

        system.debug('**OrderUtility: In**');
        if(UpdateType == 'resetDates'){
            Order[] CurOrder = [Select DateUpdateBlock__c,MaxOrderLine__c from Order where id in: lstOrderId]; 
            
            lstOrderId = new List<Id>();
            for(Order  ord:CurOrder){                
               
                if(ord.MaxOrderLine__c != null){
                    lstOrderId.add(ord.id);
                }
            }
            
            system.debug('**OrderUtility: resetDates 1**');
            UpdateOrderDates(CurOrder); 
            if(lstOrderId.size()>0 && !test.isRunningTest()){
                system.debug('**OrderUtility: resetDates 2**');
                System.enqueueJob(new Order_OrderUtilityQueueable('maxlineDates',lstOrderId));
            }
            
        }
        else if(UpdateType == 'maxlineDates'){
            Order[] processOrder = [Select DateUpdateBlock__c,MaxOrderLine__c,ShipByDate__c from Order where id in: lstOrderId]; 

            List<Id> lstOrderDone = new List<Id>();
            List<Id> MaxOrderLineId = new List<Id>();
            Date ShipbyDate;
            system.debug('**OrderUtility: maxlineDates 1**');
            for(Order  ord:processOrder){                               
                if(ord.MaxOrderLine__c != null){
                    system.debug('**OrderUtility: maxlineDates 2**');
                    MaxOrderLineId.add(ord.MaxOrderLine__c);
                    ShipbyDate = ord.ShipByDate__c;
                    break;
                }
            }

            Order[] CurOrder = Order_OrderandOrdeItemHandler.returnQueryOrder(null, MaxOrderLineId);
            List<Order> UpdateOrder = new List<Order>();

            for(Order  ord:CurOrder){
                if(ord.EffectiveDate != ShipbyDate ){
                    system.debug('**OrderUtility: maxlineDates 3**');
                    ord.EffectiveDate = ShipbyDate;
                    ord.ShipByDate__c = ShipbyDate;
                    UpdateOrder.add(ord);
                    break;
                }               
            }

            if(UpdateOrder.size()>0){
                system.debug('**OrderUtility: maxlineDates 4**');
                update UpdateOrder;
            }           
        }
    }    

    public static void UpdateOrderDates(Order[] CurOrder){
        
        Boolean OrderDateUpate = false;
        for(Order  ord:CurOrder){
            if(ord.DateUpdateBlock__c == true){
              ord.DateUpdateBlock__c = false;             
              OrderDateUpate = true;
            }
                  
          }
          
          if(OrderDateUpate == true){
              update CurOrder;
          }
    }

}