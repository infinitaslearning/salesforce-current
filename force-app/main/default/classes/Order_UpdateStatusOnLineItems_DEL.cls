public with sharing class Order_UpdateStatusOnLineItems_DEL {
    
    
    @invocablemethod
    public static void UpdateStatusOnLineItems(List<Id> OrderId){

               
        OrderItem[] lstOrderItem = [Select id,OrderStatus__c From OrderItem where OrderId in:OrderId];


        Order[] CurOrder = [Select Status from Order where id in: OrderId];

        Map<String,String> Map_OrdStatus = new Map<String,String>();

        for(Order  ord:CurOrder){
            Map_OrdStatus.put(ord.id,ord.Status);
        }

        for(OrderItem item:lstOrderItem){
            item.OrderStatus__c = Map_OrdStatus.get(item.OrderId);

        }
        
        update lstOrderItem;
        

    }
}