public with sharing class Order_OrderItemTriggerQueueable implements Queueable {
    
    
    Private List<Order> CurOrder;
    Private List<Order> MaxOrder;
    Private String load;

    
    
    
    public Order_OrderItemTriggerQueueable(List<Order> CurOrder, String load, List<Order> MaxOrder) {
      //  this.OrderItems = OrderItems;

      this.load = load;
      system.debug('**Order_OrderItemTrigger: load**'+load);
      if(load == 'Start'){
          this.CurOrder = CurOrder;
          // this.MaxOrder = MaxOrder;
          this.MaxOrder = new List<Order>();
          
           for(Order ord:CurOrder){
              this.MaxOrder.add(ord);
           }
            system.debug('**Order_OrderItemTrigger: Constructor:CurOrder **'+CurOrder);
            system.debug('**Order_OrderItemTrigger: Constructor: MaxOrder**'+MaxOrder);
         
      }
      else {
        
        CurOrder.remove(0);
        this.CurOrder= CurOrder;
        this.MaxOrder = MaxOrder;
        system.debug('**Order_OrderItemTrigger: load else: CurOrder.size**'+CurOrder.size());
        system.debug('**Order_OrderItemTrigger: load else: MaxOrder**'+MaxOrder);
      }   


    }

    public void execute(System.QueueableContext qc) {
      system.debug('**Order_OrderItemTrigger: execute**');

      
      if(CurOrder.size()>0){      
            
        system.debug('**Order_OrderItemTrigger: execute: Size>0**');
          //  UTIL_TriggerController.OrderItemTriggerSwitch = false;
            /*
            OrderItem[] lstOrderItem = [Select Product2.VAT__c,DigitalActivationEMail__c,ShipToAccount__r.DigitalActivationEmail__c, 
            ShippingCity__c,ShipToAccount__r.ShippingCity,ShippingCountry__c,ShipToAccount__r.ShippingCountry,ShippingPostalCode__c,ShipToAccount__r.ShippingPostalCode,
            ShippingState__c,ShipToAccount__r.ShippingState,ShippingStreet__c,ShipToAccount__r.ShippingStreet,ShippingIndicationRule__c,Weight__c,Order.ShippingIndicationRule__c
            from OrderItem where OrderId =:CurOrder[0].id];
            */
            List<Id> OrderId = new List<Id>();
            OrderId.add(CurOrder[0].id);
            OrderItem[]   lstOrderItem =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
            system.debug('**Order_SoqlFactory.Order_OrderItemTrigger.lstOrderItem :Size**'+lstOrderItem.size());

           try{

            system.debug('**Order_OrderItemTrigger: execute: lstOrderItem **'+lstOrderItem);
            lstOrderItem =  Order_UpdateVatOnItems.UpdateVatOnItems(lstOrderItem);
           }
          catch(exception e){
            system.debug('**Order_OrderItemTrigger: execute: Error **'+e.getmessage());
          }
 
          Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItem,CurOrder[0]);
         

         if(!test.isrunningtest()){
                System.enqueueJob(new Order_OrderItemTriggerQueueable(CurOrder,'Next',MaxOrder));
         }
              
              
               
      }
      else{

       
        List<Id> Set_OrdId = new List<Id>();

        for(Order ord: MaxOrder){
          Set_OrdId.add(ord.id);
        } 

        //Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(Set_OrdId, null);

        Order[] lst_Order = Order_SoqlFactory.returnQueryOrder(Set_OrdId,null,null);
        system.debug('**Order_SoqlFactory.Order_OrderItemTrigger.lst_Order :Size**'+lst_Order.size());

       
        //Check if Date block needs to be reset    
		    //Possibly add its own if and then make Maxcount the last else

        OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount;
       
        if(test.isrunningtest()){
                OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];
        }
        else{
                OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='LiveCount'];
        }

        Decimal FIXEDLINECOUNT;
        FIXEDLINECOUNT =  OrderLineItemMaxCount[0].Count__c;

        Boolean checkListLineCount = false;    
        for(Order ord:lst_Order){
          if(ord.LineCount__c>FIXEDLINECOUNT && ord.ValidateB2BLineCountError__c == 0){
            List<Order> lstMaxOrder = new List<Order>();
            lstMaxOrder.add(ord);
            if(!test.isrunningtest()){
              System.enqueueJob(new Order_OrderLineCountManager(lstMaxOrder,'Start'));
            }       
         }  
        }    
        


    }    
    }    

}