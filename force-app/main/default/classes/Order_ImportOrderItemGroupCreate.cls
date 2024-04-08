public with sharing class Order_ImportOrderItemGroupCreate {
    public class Request{ 
        @invocablevariable Public OrderItem SingleOrderItems; 
        @invocablevariable Public ImportOrder__c ImportOrder;
  
    }
    public class Response{ 
      //  @invocablevariable Public List<OrderItem> OrderItemsGroup;
      @invocablevariable Public OrderItem SingleOrderItems; 
      @invocablevariable Public ImportOrder__c ImportOrder;      
    }


   
    @invocablemethod
    public static List<Response> OrderItemGroupCreate(List<Request> req){
        
        Set<String> Set_ItemGroup = new Set<String>();
        Set<String> Set_ProdId = new Set<String> ();
        Set<String> Set_OrdId = new Set<String>();
        Set<String> Set_ItemId = new Set<String>();
        Map<String,String> Map_Prod = new Map<String,String>();
        Map<String,String> Map_OrderId = new Map<String,String>();
        Map<String,Decimal> Map_Quantity = new Map<String,Decimal>();
        Map<String,String> Map_ShipTo = new Map<String,String>();
        Map<String,String> Map_NetSuiteIdBillto = new Map<String,String>();
        Map<String,String> Map_NetSuiteIdShipto = new Map<String,String>();
        Map<String,String> Map_LineItemType = new Map<String,String>();
        Map<String,String> Map_ItemId = new Map<String,String>();
        Map<String,String> Map_ItemIdGroup = new Map<String,String>();

        List<Response> responses = new List<Response>();
        for(Request r:req){
            Set_ItemGroup.add(r.SingleOrderItems.Product2Id);
            Set_OrdId.add(r.SingleOrderItems.OrderId);
            Map_Quantity.put(r.SingleOrderItems.Product2Id,r.SingleOrderItems.Quantity);
            Map_ShipTo.put(r.SingleOrderItems.Product2Id,r.SingleOrderItems.ShipToAccount__c);
            Map_NetSuiteIdBillto.put(r.SingleOrderItems.Product2Id,r.SingleOrderItems.NetSuiteIdBilltoAccount__c);
            Map_NetSuiteIdShipto.put(r.SingleOrderItems.Product2Id,r.SingleOrderItems.NetSuiteIdShiptoAccount__c);
           // Map_LineItemType.put(r.SingleOrderItems.Product2Id,r.SingleOrderItems.OrderLineItemType__c);
            Map_LineItemType.put(r.SingleOrderItems.Product2Id,r.SingleOrderItems.OrderLineType__c);


            Map_OrderId.put(r.SingleOrderItems.Product2Id,r.SingleOrderItems.OrderId);
            Map_ItemId.put(r.SingleOrderItems.Product2Id,r.SingleOrderItems.Id);
            
            system.debug('**Order_ImportOrderItemGroupCreate:1: Items.Id**'+r.SingleOrderItems.Id);


            Response res = new Response();
            res.SingleOrderItems = r.SingleOrderItems;
            res.ImportOrder = r.ImportOrder;
            responses.add( res);

        }
        Order[] lstOrder = [Select id,Pricebook2Id, Source__c,Pricebook2.StartDate__c,Pricebook2.EndDate__c from Order where id in:Set_OrdId ];

        Set<String> Set_PB = new Set<String>();

        for(Order ord:lstOrder){
            Set_PB.add(ord.Pricebook2Id);
        }

        /*
        Pricing__c[] lstPriceActive = [Select ProductComponent__r.MainProduct__r.itemGroupManualBlock__c,ListRate__c,ProductComponent__r.Product__r.Type__c,ProductComponent__r.Product__r.Name,Product__c,EndDate__c,IsActive__c,ProductComponent__r.Quantity__c,ProductComponent__r.Type__c,ProductComponent__r.MainProduct__c,ProductComponent__r.Product__c from Pricing__c 
        Where   (ProductComponent__r.MainProduct__c in: Set_ItemGroup )
        AND StartDate__c <=: system.today()
        AND EndDate__c >=: system.today()
        AND IsActive__c =:true];
        */

        Pricing__c[] lstPriceActive = Order_SoqlFactory.returnPricing('ItemgroupCreate',Set_ItemGroup,null,lstOrder[0].Pricebook2.StartDate__c,lstOrder[0].Pricebook2.EndDate__c);
            system.debug('**Order_SoqlFactory.Order_ImportOrderItemGroupCreate.lstPriceActive :Size**'+lstPriceActive.size());


        
        List<Pricing__c> lstPrice = new List<Pricing__c>();
        Set<String> Set_DupCheckComponent = new Set<String>();
        
        for(Pricing__c price:lstPriceActive){ 

            if(!Set_DupCheckComponent.contains(price.ProductComponent__c)){
                Set_DupCheckComponent.add(price.ProductComponent__c);
                lstPrice.add(price);

                Set_ProdId.add(price.ProductComponent__r.Product__c);
                system.debug('**Order_ImportOrderItemGroupCreate:3: ProductName**'+price.ProductComponent__r.Product__r.Name);
                 Map_ItemIdGroup.put(price.ProductComponent__r.MainProduct__c,Map_ItemId.get(price.ProductComponent__r.MainProduct__c));
            
            }
            
        }    


        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry[] lstPricebookEntryExist;
        if(Set_PB.size()>0){
           // lstPricebookEntryExist = [Select id,Product2Id,Product2.Name, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c from PricebookEntry where Product2Id in:Set_ProdId AND Pricebook2Id !=:standardPB.id AND Pricebook2Id in: Set_PB]; // 
            
           lstPricebookEntryExist = Order_SoqlFactory.returnPricebookEntry('SuccessorPricebookentrycreate_1', null, Set_ProdId,Set_PB,null,null,null,null,null);
            system.debug('**Order_SoqlFactory.Order_ImportOrderItemGroupCreate1.lstPricebookEntryExist :Size**'+lstPricebookEntryExist.size());
     
        }
        else{
           // lstPricebookEntryExist = [Select id,Product2Id,Product2.Name, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c from PricebookEntry where Product2Id in:Set_ProdId AND Pricebook2Id !=:standardPB.id ]; // 
            
           lstPricebookEntryExist = Order_SoqlFactory.returnPricebookEntry('SuccessorPricebookentrycreate_2', null, Set_ProdId,null,null,null,null,null,null);
            system.debug('**Order_SoqlFactory.Order_ImportOrderItemGroupCreate2.lstPricebookEntryExist :Size**'+lstPricebookEntryExist.size());
     
        }

        
        for(PricebookEntry pbe:lstPricebookEntryExist){
            Map_Prod.put(pbe.Product2Id, pbe.id);           
        }
        

        
        List<OrderItem> OrderItemsGroup = new List<OrderItem>();
        

        Map<String,Decimal> Map_ListPrice = new Map<String,Decimal>();
        Map<String,Decimal> Map_NetSalesPrice = new Map<String,Decimal>();

        

        for(Order ord:lstOrder){
            
        
            for(Request r:req){


                for(Pricing__c price:lstPrice){   
               
                        if(price.ProductComponent__r.MainProduct__r.itemGroupManualBlock__c == true){
                            r.ImportOrder.Error__c = 'This Item Group is missing Components in Salesforce';
                            r.ImportOrder.Status__c = 'Error';
                        }
                        else{
                                if(r.SingleOrderItems.Product2Id == price.ProductComponent__r.MainProduct__c && ord.id == r.SingleOrderItems.OrderId ){ 
                                    system.debug('**Order_ImportOrderItemGroupCreate:4: r.SingleOrderItems.OrderId: ' + r.SingleOrderItems.OrderId);
                                    system.debug('**Order_ImportOrderItemGroupCreate:5: r.SingleOrderItems: ' + r.SingleOrderItems);
                                    OrderItem item = new OrderItem();
                                    item.Product2Id = price.ProductComponent__r.Product__c;
                                    item.PricebookEntryId = Map_Prod.get(price.ProductComponent__r.Product__c);
                                    //item.quantity = r.SingleOrderItems.Quantity;
                                    item.quantity = r.SingleOrderItems.Quantity* price.ProductComponent__r.Quantity__c; 
                                    item.NetsuiteQuantity__c =  r.SingleOrderItems.Quantity* price.ProductComponent__r.Quantity__c; 
                                    item.UnitPrice = price.ListRate__c;
                                    item.ComponentListPrice__c = price.ListRate__c;
                                    
                                    // CH 2022/08/18 - https://dev.azure.com/infinitas/Converse/_boards/board/t/Order%20to%20Cash/Backlog%20items/?workitem=178366
                                    if(r.SingleOrderItems.ShipToAccount__c != null){
                                        item.ShipToAccount__c = r.SingleOrderItems.ShipToAccount__c; 
                                        item.ShippingCity__c = r.SingleOrderItems.ShippingCity__c;
                                        item.ShippingCountry__c = r.SingleOrderItems.ShippingCountry__c;
                                        item.ShippingPostalCode__c = r.SingleOrderItems.ShippingPostalCode__c;
                                        item.ShippingState__c = r.SingleOrderItems.ShippingState__c;
                                        item.ShippingStreet__c = r.SingleOrderItems.ShippingStreet__c;
                                    }
                                    
                                    
                                    item.ShippingIndicationRule__c = 'Based on weight Domestic';
                                    item.NetSuiteIdBilltoAccount__c = r.SingleOrderItems.NetSuiteIdBilltoAccount__c; 
                                    item.NetSuiteIdShiptoAccount__c = r.SingleOrderItems.NetSuiteIdShiptoAccount__c;
                                    item.CustomerReference__c =  r.SingleOrderItems.CustomerReference__c;
                                    
                                    item.OrderLineType__c = r.SingleOrderItems.OrderLineType__c; 
                                    
                                    item.OrderId = r.SingleOrderItems.OrderId; 
                                    item.OrderStatus__c ='Draft';

                                    item.ProductType__c = price.ProductComponent__r.Product__r.Type__c; //'Inventory Item'; 

                                    if(price.ProductComponent__r.Product__r.Type__c =='Non-inventory Item'){
                                        item.DigitalActivationEMail__c = r.SingleOrderItems.DigitalActivationEmail__c; 
                                    }
                                       

                                    item.ItemGroup__c = r.SingleOrderItems.id; 
                                    item.ProductComponent__c = price.ProductComponent__c;
                                    item.ImportItemGroupEAN__c = item.ItemGroup__c;

                                    
                                    Decimal fullprice = price.ListRate__c*price.ProductComponent__r.Quantity__c;
                                    Decimal fullNetSales = price.ListRate__c*price.ProductComponent__r.Quantity__c;

                                
                                    if(r.SingleOrderItems.ManualDiscountPercent__c !=null){
                                        item.ManualDiscount__c = 'One-Off Percentage';
                                        item.ManualDiscountPercent__c = r.SingleOrderItems.ManualDiscountPercent__c;
                                        item.UnitPrice = item.UnitPrice-(item.UnitPrice*(Item.ManualDiscountPercent__c/100));
                                        fullNetSales = item.UnitPrice*price.ProductComponent__r.Quantity__c;
                                    }
                                    
                                    
                                    if(Map_NetSalesPrice.get(item.ItemGroup__c)==null){
                                        system.debug('****Order_ImportOrderItemGroupCreate:6 item.ItemGroup__c: null**'+fullprice);
                                        Map_NetSalesPrice.put(item.ItemGroup__c,fullNetSales);
                                        Map_ListPrice.put(item.ItemGroup__c,fullprice);
                                    }
                                    else{
                                        system.debug('****Order_ImportOrderItemGroupCreate:7 item.ItemGroup__c: NOT NULL**'+fullprice);
                                        Map_NetSalesPrice.put(item.ItemGroup__c,Map_NetSalesPrice.get(item.ItemGroup__c)+fullNetSales);
                                        Map_ListPrice.put(item.ItemGroup__c,Map_ListPrice.get(item.ItemGroup__c) + fullprice);
                                    }

                                    // CH 05/10/2023: Tender Transfer item group components must have 0 pricing 
                                    // https://dev.azure.com/infinitas/Converse/_workitems/edit/211210
                                    if(item.OrderLineType__c == 'Transfer' && ord.Source__c == 'Tender'){
                                        // set all pricing to 0
                                        item.ComponentListPrice__c = 0;
                                        item.UnitPrice = 0;
                                    }

                                    OrderItemsGroup.add(item);
                                    Set_ItemId.add(r.SingleOrderItems.Id);
                                   // Set_DupCheckComponent.add(price.ProductComponent__c);
                            
                                } 
                    }
                }
            }     
        } 



              
       
       try{
            
            if(OrderItemsGroup.size()>0){
            
                    Insert OrderItemsGroup;


                    OrderItem[] lstItemGroup = [Select id,UnitPrice,ProductType__c,FormGroupId__c,NetSalesPriceItemGroup__c,DiscountedPriceItemGroup__c,ComponentListPrice__c from OrderItem where id in:Set_ItemId];

                    for(OrderItem item:lstItemGroup){
                        item.UnitPrice = 0;
                        item.ProductType__c = 'Item Group';
                        item.NetSalesPriceItemGroup__c = Map_NetSalesPrice.get(item.id);
                        item.DiscountedPriceItemGroup__c = Map_ListPrice.get(item.id);
                        item.ListPriceItemGroup__c = Map_ListPrice.get(item.id);
                        item.ComponentListPrice__c = 0;
                        item.FormGroupId__c = item.id;
                        
                        item.ManualDiscount__c = '';
                        item.ManualDiscountPercent__c = null;
                    }

                    update lstItemGroup;
            }
       } 
       catch(exception e){
        system.debug('****Order_ImportOrderItemGroupCreate: Error**'+ e.getMessage());
       }


        system.debug('****Order_ImportOrderItemGroupCreate: 8: OrderItemsGroup.size**'+OrderItemsGroup.size());


        
      //  Response res = new Response();
      //  res.OrderItemsGroup = OrderItemsGroup;
      //  responses.add( res);

        return responses;

    }    
}