public with sharing class Order_OrdeItemFromOrderFlow {
    
    public class Request{ 
        @invocablevariable Public List<String> OrderId;
    }  

    @invocablemethod
    Public static void Flowhandler(List<Request> req){
             

            List<Order> lstOrder = [Select id,Billto__r.OperatingCompany__c,ShippingCost__c from Order where id in:req[0].OrderId];
            OrderItem[] lstOrderItem = [Select ShipToAccount__c,OrderId,Product2Id,ItemGroup__c,TotalDiscountAmount__c,Discount__c,Quantity, 
                                                Order.ShippingIndicationRule__c,Order.ShippingCostExempt__c,ShippingStreet__c,ShippingState__c,   
                                                ShippingPostalCode__c,ShippingCountry__c,ShippingCity__c,ProductLicenseDuration__c,DigitalActivationEMail__c, 
                                                Product2.LicenseDuration__c,List_Price_Rate__c,ListPriceDiscountAmount__c
                                                from OrderItem where OrderId in:req[0].OrderId];

            Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItem,lstOrder[0]);
            
            
             // lstOrderItem = Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItem);
            //update lstOrderItem;
           
    }



}