public with sharing class Order_UpdateVatOnItems {
    
    
    Public static List<OrderItem> UpdateVatOnItems (List<OrderItem> lstOrderItem){

        system.debug('**UpdateVatOnItems: IN**');

          
        // Make a big try catch

            Map<String,String> Map_ShippingCOuntry = new Map<String,String>();

            Set<String> Set_ShippingCountry = new Set<String>();
            Set<String> Set_OperatingComapny = new Set<String>();
            Set<String> Set_VAT = new Set<String>();
            Set<String> Set_ItemId = new Set<String>();

            Set<String> Set_OrderId = new Set<String>();

            for(OrderItem item:lstOrderItem){
                Set_ItemId.add(item.id);
                
               // Set_ShippingCountry.add(item.ShippingCountry__c);
              //  Set_VAT.add(item.ProductVAT__c);
            }

           
            
            OrderItem[] lst_OrderItemSelected = [Select  Quantity,UnitPrice,OrderId,Product2.VAT__c,DigitalActivationEMail__c,ShipToAccount__r.DigitalActivationEmail__c, 
            ShippingCity__c,ShipToAccount__r.ShippingCity,ShippingCountry__c,ShipToAccount__r.ShippingCountry,ShippingPostalCode__c,ShipToAccount__r.ShippingPostalCode,ShipToAccount__r.OperatingCompany__c,
            ShippingState__c,ShipToAccount__r.ShippingState,ShippingStreet__c,Order.ShippingIndicationRule__c,ShipToAccount__r.ShippingStreet,ShippingIndicationRule__c,Weight__c,ShipToAccount__r.ShippingCountryCode
            from OrderItem where id in:Set_ItemId]; 

            for(OrderItem item:lst_OrderItemSelected){
               // Set_ShippingCountry.add(item.ShipToAccount__r.ShippingCountry);
               Set_OrderId.add(item.OrderId);
                if(item.ShipToAccount__r.ShippingCountry != null){
                    Set_ShippingCountry.add(item.ShipToAccount__r.ShippingCountry);
                }
                
                if(item.Product2.VAT__c != null){
                    Set_VAT.add(item.Product2.VAT__c);
                }

                
                Set_OperatingComapny.add(item.ShipToAccount__r.OperatingCompany__c);
                
            }
             

            system.debug('**Set_ShippingCountry**'+ Set_ShippingCountry);
            system.debug('**Set_VAT**'+ Set_VAT);
            system.debug('**Set_OperatingComapny**'+ Set_OperatingComapny);

            VAT__c[] lstVAT = [Select NexusCountry__c,Product__c,Rate__c,Subsidiary__c from VAT__c where toLabel(NexusCountry__c) in:Set_ShippingCountry AND Product__c in:Set_VAT AND Subsidiary__c in:Set_OperatingComapny];
            
            

            String VatProduct;
            Map<String,Decimal> Map_VATRate = new Map<String,Decimal>();
            for(VAT__c vat:lstVAT){
                VatProduct = vat.NexusCountry__c;
                VatProduct += vat.Product__c;
                VatProduct += vat.Subsidiary__c;
                system.debug('** VatProduct_1**'+ VatProduct);
                Map_ShippingCOuntry.put(VatProduct,vat.Id); 
                Map_VATRate.put(VatProduct,vat.Rate__c);
                system.debug('** vat.NexusCountry__c**'+ vat.NexusCountry__c);
            }

            Map<String,Decimal> Map_OrdVAT = new Map<String,Decimal>();
            
            system.debug('** Map_VATRate**'+ Map_VATRate);

            for(OrderItem item:lst_OrderItemSelected){

                VatProduct = item.ShipToAccount__r.ShippingCountryCode;
                VatProduct += item.Product2.VAT__c;
                VatProduct += item.ShipToAccount__r.OperatingCompany__c;
                system.debug('** VatProduct_2**'+ VatProduct);
                if(Map_ShippingCOuntry.get(VatProduct) != null){
                    item.VATRule__c = Map_ShippingCOuntry.get(VatProduct);
                    system.debug('** item.VATRule__c**'+ item.VATRule__c); 

                    Decimal VatTotal = item.Quantity * item.UnitPrice * (Map_VATRate.get(VatProduct)/100);
                    item.VATCalculated__c = VatTotal.setScale(2, System.RoundingMode.HALF_UP);//set VAT calculated per OrderItem for validation formula

                   if(Map_OrdVAT.get(item.OrderId) == null){                    
                        Map_OrdVAT.put(item.OrderId,VatTotal);
                   } 
                   else{
                        Map_OrdVAT.put(item.OrderId,Map_OrdVAT.get(item.OrderId)+VatTotal);
                   }
                    
                    
                }
            }
            system.debug('**Map_Ord**'+ Map_OrdVAT);
            system.debug('**Set_OrderId**'+ Set_OrderId);
          Order[] CurOrder = [Select id,TotalVAT__c from Order Where id in: Set_OrderId];
           try{
              //  UTIL_TriggerController.OrderItemTriggerSwitch = false;
                
                for(Order ord:CurOrder){

                    if(Map_OrdVAT.get(ord.id) != null){
                        ord.TotalVAT__c = Map_OrdVAT.get(ord.id).setScale(2, System.RoundingMode.HALF_UP);
                    }
                    else{
                        ord.TotalVAT__c = 0;  
                    }
                    
                }
                update CurOrder;

                Update lst_OrderItemSelected;

                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
                  }

           }
           catch(exception e){
                HandleCustomException.LogException(e);
                system.debug('** Error Message: '+e.getMessage());   
           }  

          return lst_OrderItemSelected;      


    }



}