public with sharing class LI_updateOrderLineItems {
    
    public static void updateOrderItemAfterInsert(List<OrderItem> orderItems) {
        System.debug(LoggingLevel.INFO, 'LI_updateOrderLineItems - updateOrderItemAfterInsert');

        Set<OrderItem> orderItemsToUpdate = new Set<OrderItem>();
        Set<Id> orderItemIds = new Set<Id>();

        for (OrderItem orderItem : orderItems) {
            orderItemIds.Add(orderItem.Id);
        }

        Set<Id> orderIds = new Set<Id>();
        Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>([SELECT Id, OrderId, Order.Type, Order.Status, Order.ShippingIndicationRule__c, Order.ShippingCostExempt__c FROM OrderItem WHERE Id IN :orderItemIds]);

        Boolean startShippingCost = false;
        for (OrderItem orderItem : orderItemMap.values()) {

            if (orderItem.Order.ShippingCostExempt__c == true){
                orderItem.ShippingIndicationRule__c = 'Shipping Cost Exempt';
            } else{
                orderItem.ShippingIndicationRule__c = orderItem.Order.ShippingIndicationRule__c;
            }
            
            if (orderItemMap.get(orderItem.Id).Order.Status != 'Activated' && orderItemMap.get(orderItem.Id).Order.ShippingIndicationRule__c != null) {
                startShippingCost = true;
            }

            orderItemsToUpdate.add(orderItem);
            OrderIds.add(orderItem.OrderId);
        }

        List<OrderItem> updateList = new List<OrderItem>();
        updateList.addAll(orderItemsToUpdate);

        update updateList;

        if (!Test.isRunningTest() && startShippingCost == true) {
            List<Order> orders = [SELECT Id FROM Order WHERE Id IN :orderIds];
            for (Order order : orders) {
                startShippingCostCalculationFlow(order.Id);
            }
        }
    }
    
    public static void updateShippingIndicationRuleAfterInsert(List<Order> orders) {
        System.debug(LoggingLevel.INFO, 'LI_updateOrderLineItems - updateShippingIndicationRuleAfterInsert');

        Set<OrderItem> orderItemsToUpdate = new Set<OrderItem>();
        Boolean startShippingCost = false;
        
        for (Order order : orders) {

            Boolean updateShippingIndicationRule = false;
            Boolean updateToFreeOrder = false;

            if (order.Status != 'Activated' && order.ShippingIndicationRule__c != null) {
                startShippingCost = true;
                updateShippingIndicationRule = true;
            }

            if (order.Type == 'FreeOrder') {
                updateToFreeOrder = true;
            }

            List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :order.Id];

            for (OrderItem oi : orderItems) {
                if (updateToFreeOrder) {
                    oi.OrderLineType__c = 'Free';
                }
                if (updateShippingIndicationRule) {
                    oi.ShippingIndicationRule__c = order.ShippingIndicationRule__c;
                    orderItemsToUpdate.add(oi);
                }
                
            }
            
        }

        List<OrderItem> updateList = new List<OrderItem>();
        updateList.addAll(orderItemsToUpdate);

        update updateList;

        if (!Test.isRunningTest() && startShippingCost == true) {
            for (Order order : orders) {
                startShippingCostCalculationFlow(order.Id);
            }
        }
    }

    public static void OrderTriggerHelper(Map<Id,Order> newMap, Map<Id,Order> oldMap) {
        System.debug(LoggingLevel.INFO, 'LI_updateOrderLineItems - OrderTriggerHelper');

        Boolean startShippingCost = false;
        List<Order> ordersForShippingCalculation = new List<Order>();
        Set<OrderItem> orderitemsForUpdate = new Set<OrderItem>();

        List<Order> ordersWithOrderItems = [SELECT Id, (SELECT Id FROM OrderItems) FROM Order WHERE Id IN :newMap.keySet()];
        
        Map<Id,List<OrderItem>> orderIdOrderItemMap = new Map<Id,List<OrderItem>>();
        for (Order order : ordersWithOrderItems) {
            orderIdOrderItemMap.put(order.Id, Order.OrderItems);
        }

        for (Order order : newMap.values()) {
            if (order.Type == 'FreeOrder' && OldMap.get(order.Id).Type != 'FreeOrder') {
                List<OrderItem> orderItems1 = orderIdOrderItemMap.get(order.Id);
                for (OrderItem oi1 : orderItems1) {
                    oi1.OrderLineType__c= 'Free';
                    orderitemsForUpdate.add(oi1);
                }
            }

            if (order.Status != 'Activated' && newMap.get(order.Id).ShippingIndicationRule__c != oldMap.get(order.Id).ShippingIndicationRule__c) {
                List<OrderItem> orderItems2 = orderIdOrderItemMap.get(order.Id);

                for (OrderItem oi2 : orderItems2) {
                    oi2.ShippingIndicationRule__c = order.ShippingIndicationRule__c;
                    orderitemsForUpdate.add(oi2);
                }
                ordersForShippingCalculation.add(order);
                startShippingCost = true;
            }
            
        }

        List<OrderItem> orderItemUpdateList = new List<OrderItem>();
        orderItemUpdateList.addAll(orderitemsForUpdate);

        update orderItemUpdateList;

        if (!Test.isRunningTest() && startShippingCost == true) {
            for (Order order : ordersForShippingCalculation) {
                startShippingCostCalculationFlow(order.Id);
            }
        }

    }

    public static void startShippingCostCalculationFlow(Id OrderId) {
        System.debug(LoggingLevel.INFO, 'LI_updateOrderLineItems - startShippingCostCalculationFlow');

        Map<String, Id> flowMap = new Map<String, Id>();
        flowMap.put('recordId', OrderId);

        Flow.Interview.StoreShippingCost flow = new Flow.Interview.StoreShippingCost(flowMap);
        flow.Start();
    }

}