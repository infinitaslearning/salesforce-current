public with sharing class UTIL_GetVATIds {

    @InvocableMethod(label = 'Get VAT by OrderItem' description = 'Returns a list of Contacts corresponding to the input OpCo + Email (Searches in Email and Private Email).' category = 'Contact')
    public static List<returnWrapper> getVATByOrderItem(List<fieldwrapper> fieldwrappers) {
        
        
            List<returnWrapper> returnList = new List<returnWrapper>();

            Map<String,String> Map_ShippingCOuntry = new Map<String,String>();
        
            Set<String> Set_ShippingCountry = new Set<String>();
            Set<String> Set_VAT = new Set<String>();
            Set<String> Set_ItemId = new Set<String>();

            for(OrderItem item:fieldwrappers[0].lstOrderItems){
                Set_ItemId.add(item.id);

               // Set_ShippingCountry.add(item.ShippingCountry__c);
              //  Set_VAT.add(item.ProductVAT__c);
            }

           
            
            OrderItem[] lst_OrderItemSelected = [Select Product2.VAT__c,DigitalActivationEMail__c,ShipToAccount__r.DigitalActivationEmail__c, 
            ShippingCity__c,ShipToAccount__r.ShippingCity,ShippingCountry__c,ShipToAccount__r.ShippingCountry,ShippingPostalCode__c,ShipToAccount__r.ShippingPostalCode,
            ShippingState__c,ShipToAccount__r.ShippingState,ShippingStreet__c,ShipToAccount__r.ShippingStreet,ShippingIndicationRule__c,Weight__c
            from OrderItem where id in:Set_ItemId]; 

            for(OrderItem item:lst_OrderItemSelected){
                Set_ShippingCountry.add(item.ShipToAccount__r.ShippingCountry);
                Set_VAT.add(item.Product2.VAT__c);
            }
             

           // system.debug('**Set_ShippingCountry**'+ Set_ShippingCountry);
           // system.debug('**Set_VAT**'+ Set_VAT);

            VAT__c[] lstVAT = [Select NexusCountry__c,Product__c from VAT__c where NexusCountry__c in:Set_ShippingCountry AND Product__c in:Set_VAT];
            
            String VatProduct;
            for(VAT__c vat:lstVAT){
                VatProduct = vat.NexusCountry__c;
                VatProduct += vat.Product__c;
                Map_ShippingCOuntry.put(VatProduct,vat.Id); 
           //     system.debug('** vat.NexusCountry__c**'+ vat.NexusCountry__c);
            }

            Decimal NonDomesticWeight=0;
            Decimal DomesticWeight=0;

            for(OrderItem item:lst_OrderItemSelected){

                VatProduct = item.ShipToAccount__r.ShippingCountry;
                VatProduct += item.Product2.VAT__c;
                if(Map_ShippingCOuntry.get(VatProduct) != null){
                    item.VATRule__c = Map_ShippingCOuntry.get(VatProduct);
             //       system.debug('** item.VATRule__c**'+ item.VATRule__c);
                }
                
                item.DigitalActivationEMail__c = item.ShipToAccount__r.DigitalActivationEmail__c;
                item.ShippingCity__c=item.ShipToAccount__r.ShippingCity;
                item.ShippingCountry__c=item.ShipToAccount__r.ShippingCountry;
                item.ShippingPostalCode__c=item.ShipToAccount__r.ShippingPostalCode;
                item.ShippingState__c=item.ShipToAccount__r.ShippingState;
                item.ShippingStreet__c=item.ShipToAccount__r.ShippingStreet;


      //          system.debug('**Shipping IndicationRule**'+ item.ShippingIndicationRule__c);
     //           system.debug('**Weight**'+ item.Weight__c);
                if( item.ShippingIndicationRule__c == 'Based on weight Domestic' && item.Weight__c > 0){
                    DomesticWeight  += item.Weight__c;
                }
                else if(item.ShippingIndicationRule__c == 'Based on weight non Domestic' && item.Weight__c > 0){
                    NonDomesticWeight += item.Weight__c;
                }
                else if(item.ShippingIndicationRule__c =='Shipping Cost Exempt'){

                }

                
                
            }
      //      system.debug('**DomesticWeight**'+ DomesticWeight);
      //      system.debug('**NonDomesticWeight**'+ NonDomesticWeight);
            
                ShippingCost__c[] lstSCNonDomesticWeight = [Select Charge__c,ShippingRule__c From ShippingCost__c Where 
                RangeValue__c <: NonDomesticWeight 
                AND Subsidiary__c =: fieldwrappers[0].CurOrder.Billto__r.OperatingCompany__c
                AND ShippingRule__c like: '%Based on weight non Domestic%'
                AND IsActive__c =: true
                ORDER BY RangeValue__c DESC limit 1];


            
           
            
                ShippingCost__c[] lstSCDomesticWeight = [Select Charge__c,ShippingRule__c From ShippingCost__c Where 
                    RangeValue__c <: DomesticWeight
                    AND Subsidiary__c =: fieldwrappers[0].CurOrder.Billto__r.OperatingCompany__c
                    AND ShippingRule__c like: '%Based on weight Domestic%'
                    AND IsActive__c =: true
                    ORDER BY RangeValue__c DESC limit 1];
            
            
            if(lstSCNonDomesticWeight.size() > 0 && lstSCDomesticWeight.size() > 0){
                        fieldwrappers[0].CurOrder.ShippingCost__c = lstSCNonDomesticWeight[0].Charge__c;
                        fieldwrappers[0].CurOrder.ShippingCost__c =+ lstSCDomesticWeight[0].Charge__c;
                        fieldwrappers[0].CurOrder.ShippingCostDomestic__c = lstSCDomesticWeight[0].Charge__c;
                        fieldwrappers[0].CurOrder.ShippingCostNonDomestic__c = lstSCDomesticWeight[0].Charge__c; 
            }
            else if(lstSCNonDomesticWeight.size() > 0){    
                        fieldwrappers[0].CurOrder.ShippingCostDomestic__c = lstSCNonDomesticWeight[0].Charge__c;
                        fieldwrappers[0].CurOrder.ShippingCost__c = lstSCNonDomesticWeight[0].Charge__c;   
                        
       //                 system.debug('**lstSCNonDomesticWeight**'+ lstSCDomesticWeight[0].Charge__c);
            }        
            else if(lstSCDomesticWeight.size() > 0){
                        fieldwrappers[0].CurOrder.ShippingCostNonDomestic__c = lstSCDomesticWeight[0].Charge__c; 
                        fieldwrappers[0].CurOrder.ShippingCost__c = lstSCDomesticWeight[0].Charge__c;    
                        
       //                 system.debug('**lstSCDomesticWeight**'+ lstSCDomesticWeight[0].Charge__c);
            }
            

            
         //   system.debug('**fieldwrappers[0].CurOrder.ShippingCost__c**'+ fieldwrappers[0].CurOrder.ShippingCost__c);
         
            system.debug('**OrderItem Trigger: UTIL_GetVATIds: ORDEID**'+fieldwrappers[0].CurOrder.id);
            system.debug('**OrderItem Trigger: UTIL_GetVATIds: OrderItem:Size **'+lst_OrderItemSelected.size());

            UTIL_TriggerController.OrderItemTriggerSwitch = false;
            update fieldwrappers[0].CurOrder;
            update lst_OrderItemSelected;

            returnWrapper rw = new returnWrapper();
            rw.lstOrderItems = lst_OrderItemSelected;
         
            returnList.add(rw);
            
        
        return returnList;
    }

    public class fieldwrapper {
        
        @InvocableVariable(label = 'OrderItems')
        public List<OrderItem> lstOrderItems;
        public Order CurOrder;
       

    }
    
    public class returnWrapper {

        @InvocableVariable(label = 'returnOrderItems')
        public List<OrderItem> lstOrderItems;
    }

}