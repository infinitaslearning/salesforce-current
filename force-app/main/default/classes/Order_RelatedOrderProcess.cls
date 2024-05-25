public with sharing class Order_RelatedOrderProcess {
    
    public class Request{ 
        @invocablevariable Public String ProcessToRun; 
        @invocablevariable Public String MaxOrderLineId;
    }
    public class Response{ 
        @invocablevariable Public Boolean Status;
    }

    
    @invocablemethod
    public static void RelatedOrderProcess(List<Request> req){
        
        List<Id> MaxOrderLineId = new List<Id>();
        MaxOrderLineId.add(req[0].MaxOrderLineId);

        if(req[0].ProcessToRun =='TriggerBusinessRules'){
            RelatedOrderProcessIvocable(MaxOrderLineId);
        }
        else if(req[0].ProcessToRun =='ActivateOrders'){
            activateOrders(MaxOrderLineId);
        }
        
 
    }

    @future
    public static void RelatedOrderProcessIvocable(List<Id> MaxOrderLineId){
        MaxOrderLine__c[] lstMaxOrderLine = [Select id,ActivationReadyCount__c,ExpectedActivationCount__c,	TriggerBusinessRules__c from MaxOrderLine__c where id in: MaxOrderLineId]; 

        system.debug('**Order_RelatedOrderProcess**');
          
      //  Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(null, MaxOrderLineId);  
         Order[] lst_Order = Order_SoqlFactory.returnQueryOrder(null,MaxOrderLineId,null);
        system.debug('**Order_SoqlFactory.Order_RelatedOrderProcess1.lst_Order :Size**'+lst_Order.size());

        try{
                List<Id> Lst_OrdId = new List<Id>();

                for(Order ord:lst_Order){
                    Lst_OrdId.add(ord.id);
                    
                }

              //  OrderItem[]   lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,Lst_OrdId);
                OrderItem[]   lst_OrdItem =  Order_SoqlFactory.returnQueryOrderItems(null,Lst_OrdId,null,null);
                
                system.debug('**Order_SoqlFactory.Order_RelatedOrderProcess.lst_OrdItem :Size**'+lst_OrdItem.size());

                //LIST PRICE DISCOUNT
                Set<String> Set_CusDiscountGroup = new Set<String>();
                Set<String> Set_OperatingCo = new Set<String>();
                Set<String> Set_ProdDiscountGroup = new Set<String>();
                Set<String> Set_OrderLineItemType = new Set<String>();
                Set<String> Set_MarketSegment = new Set<String>();

                for(OrderItem item:lst_OrdItem){
                    Set_CusDiscountGroup.add(item.Order.Billto__r.CustomerDiscountGroup__c); 
                    Set_OperatingCo.add(item.Order.Billto__r.OperatingCompany__c);
                    Set_ProdDiscountGroup.add(item.Product2.ProductDiscountGroup__c);
                    Set_OrderLineItemType.add(item.OrderLineType__c);
                    Set_MarketSegment.add(item.Product2.MarketSegment__c);
                }
                
              //  ListPriceDiscount__c[] lst_ListPriceDiscountRegular = Order_OrderandOrdeItemHandler.returnListPriceDiscount(lst_Order, Set_CusDiscountGroup, Set_OperatingCo, Set_ProdDiscountGroup, Set_OrderLineItemType, Set_MarketSegment);
              
              ListPriceDiscount__c[] lst_ListPriceDiscountRegular =  Order_SoqlFactory.returnListPriceDiscount('AllDiscount',lst_Order[0].PricingMethod__c, Set_CusDiscountGroup, Set_OperatingCo, Set_ProdDiscountGroup, Set_OrderLineItemType, Set_MarketSegment);
              system.debug('**Order_SoqlFactory.Order_RelatedOrderProcess.lst_ListPriceDiscountRegular :Size**'+lst_ListPriceDiscountRegular.size());
            

                Order_OrderandOrdeItemHandler.OrderItemBusinessLogichandler(lst_OrdItem,lst_Order,Lst_OrdId, 'TriggerBusinessRules',lst_ListPriceDiscountRegular, null);
                
               // List<Order> lstInsertedOrd = [Select ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c from Order where id in: Lst_OrdId];
                 
                List<Order> lstInsertedOrd = Order_SoqlFactory.returnQueryOrder(null,MaxOrderLineId,null);
                    Integer Count=0, ActiveReady=0;
                    for(Order ord:lstInsertedOrd){
                        ord.OrderImportAmountExclVAT__c = ord.TotalAmount;
                        if(ord.ValidationErrorsOrder__c==0 && ord.ValidationErrorsOrderProducts__c==0){
                            ActiveReady++;
                        }
                        
                        Count++;
                    }

                    update lstInsertedOrd;

                    lstMaxOrderLine[0].ActivationReadyCount__c = ActiveReady;
                    lstMaxOrderLine[0].ExpectedActivationCount__c = Count;
                    lstMaxOrderLine[0].TriggerBusinessRules__c = false;
                    Update lstMaxOrderLine;
        }
        catch(exception e){
            HandleCustomException.LogException(e,lst_Order[0].id);
        }
            
    }

    
    public static void activateOrders(List<Id> MaxOrderLineId){
        MaxOrderLine__c[] lstMaxOrderLine = [Select id,RelatedOrderActivationready__c from MaxOrderLine__c where id in: MaxOrderLineId]; 
        
      //  Order[] lst_Order = Order_OrderandOrdeItemHandler.returnQueryOrder(null, MaxOrderLineId); 
        Order[] lst_Order = Order_SoqlFactory.returnQueryOrder(null,MaxOrderLineId,null);
        system.debug('**Order_SoqlFactory.Order_RelatedOrderProcess2.lst_Order :Size**'+lst_Order.size());

        try{ 
            for(Order ord:lst_Order){
                ord.ActivateforBatchProcessing__c =true;
            }

            update lst_Order;
        }
        catch(exception e){

            HandleCustomException.LogException(e,lst_Order[0].id);
        }

        if(lstMaxOrderLine[0].RelatedOrderActivationready__c ==True){
            Order_BatchOrderActivateAssetRenewal  orderActivate = new Order_BatchOrderActivateAssetRenewal();
            database.executebatch(orderActivate ,1);
        }
    }
}