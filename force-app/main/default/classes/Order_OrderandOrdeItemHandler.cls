public with sharing class Order_OrderandOrdeItemHandler {
    

@invocablemethod
    public static void UpdateShippingDates(List<Id> recordIdStrings){

        OrderItem[] lstOrderItem;
        try {
            List<string> ObjectName = UTIL_getObjectName.returnObjectName(recordIdStrings);

            if(ObjectName[0]=='Order'){
                

                Order[] CurOrder = [Select Type, AccountSubsidiary__c,MaxOrderLine__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c from Order where id in: recordIdStrings];
                List<Id> MaxOrderLineId = new List<Id>();
                Date ShipbyDate;

                /*
                for(Order  ord:CurOrder){
                    ord.EffectiveDate = ord.ShipByDate__c;
                }
                */

                /*
                lstOrderItem = [Select id,StartDate__c,Order.EffectiveDate,Order.Pricebook2.Name, Order.ShipByDate__c,LineItemTotal__c,ItemGroup__r.Product2Id,Product2.OrderLineType__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c,Product2.QuantitySelectionType__c,OrderId,ItemGroup__c,ShipToAccount__r.Name,ShipToAccount__r.CustomerDiscountGroup__c,ListPrice,UnitPrice,Quantity,Product2.ProductDiscountGroup__c,ListPriceDiscount__c,ListPriceDiscount__r.OrderLineType__c,ListPriceDiscount__r.Rate__c,Product2Id,PricebookEntryId,ShipToAccount__c,ManualDiscount__c,ManualDiscountPercent__c,ManualDiscountValue__c 
                From OrderItem where OrderId in:recordIdStrings];
                */

                lstOrderItem =  Order_SoqlFactory.returnQueryOrderItems(null,recordIdStrings,null,null);
                system.debug('**Order_SoqlFactory.UpdateShippingDates.lstOrderItem :Size**'+lstOrderItem.size());

                lstOrderItem = Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);  

                // to ensure that Order Item dates are greater or equal to Order dates
                system.debug('**OrderItem Dates: 1**');
                if(Order_ProductCalculationDates.AddOrSubtractYear != 'Subtract' && Order_ProductCalculationDates.AddOrSubtractYear !='CurrentSubtract'){
                    update lstOrderItem; 
                }
                
                system.debug('**OrderItem Dates: 1**');
                if(Order_ProductCalculationDates.Map_ShipByDate.size()>0){ 
                     system.debug('**OrderItem Dates: 2**');
                     List<Id> OrderId = new List<Id>();
                     for(Order  ord:CurOrder){

                        // To prevent running date trigger again
                        //ord.DateUpdateBlock__c = true;    
                       // ord.ShipByDate__c = Order_ProductCalculationDates.Map_ShipByDate.get(ord.id);

                        system.debug('**OrderItem Dates: EffectiveDate**'+ord.EffectiveDate);
                        system.debug('**OrderItem Dates: ShipByDate**'+ord.ShipByDate__c);
                        if(Order_ProductCalculationDates.Map_EffectiveDate.get(ord.id) < ord.EffectiveDate){
                            ord.EffectiveDate = Order_ProductCalculationDates.Map_EffectiveDate.get(ord.id);
                        }
                         
                        OrderId.add(ord.id);
                     }
                    update CurOrder;
                    if(Order_ProductCalculationDates.AddOrSubtractYear == 'Subtract' || Order_ProductCalculationDates.AddOrSubtractYear =='CurrentSubtract'){
                            update lstOrderItem; 
                    }

                    // reset date blocker 
                  //  System.enqueueJob(new Order_OrderUtilityQueueable('resetDates',OrderId));
                }    
                else{
                    update CurOrder;
                }
                /*
                update lstOrderItem;
                update CurOrder;
               */


               if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
               }
            }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            system.debug('**OrderItem Dates: Error**'+e.getmessage());
            HandleCustomException.LogException(e,lstOrderItem[0].id);
        }
        finally {
            // Something executed whether there was an error or not
        }
       
    }


  
    Public static List<OrderItem> OrderItemBusinessLogichandler(List<OrderItem> lstOrderItem, List<Order> CurOrder,List<String> Lst_OrdId, String Source,ListPriceDiscount__c[] lst_ListPriceDiscountRegular,Decimal index ){

        
        if(Source == 'ProductSelectorOrderItems'){
            lstOrderItem=Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItem);

            // Processed from Order_OrderInsertQueueable to handle ItemDates earlier than order date 
           // lstOrderItem=Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);
            Update lstOrderItem;
            
            Order_UpdateVatOnItems.UpdateVatOnItems (lstOrderItem);

            if(CurOrder[0].ShippingIndicationRule__c == null){
                Order_UpdateShippingCostsFromItems.UpdateShippingCostsFromItems(lstOrderItem,CurOrder[0]);
            }
            
        }
         else if(Source == 'TriggerBusinessRules'){
                    if(CurOrder[0].Source__c =='Trade' 
                        || CurOrder[0].Source__c =='B2B Shop' 
                        || CurOrder[0].Source__c =='B2B Salesforce' 
                        || CurOrder[0].Source__c == 'Trade - Early Season Order'
                        || CurOrder[0].Source__c == 'Tender'){    
                        
                        lstOrderItem = Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(Null,Lst_OrdId,Null,lstOrderItem,lst_ListPriceDiscountRegular);
                    }
  
                    lstOrderItem = Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItem);
                    
                   // Processed from Order_B2BOrderInvocable to handle ItemDates earlier than order date 
                   // lstOrderItem =Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);
                    update lstOrderItem;
 
                    //TO handle shipping costs AND VAT
                   
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new Order_OrderItemTriggerQueueable(CurOrder,'Start',CurOrder));
                    }
                    
        }
        
         else if(Source == 'AssetRenewal'){
                    
                lstOrderItem = Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(null,Lst_OrdId,Null,lstOrderItem,lst_ListPriceDiscountRegular);
                lstOrderItem = Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItem);
                lstOrderItem =Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);
            
                Update lstOrderItem;
                /*
                if(lstOrderItem.size()>400){
                    Order_OrderLineCountManager.ProcessLineCount(CurOrder[integer.valueof(index-1)]);
                } 
                */

               // VAT and ShippingCosts handled in the AssetRenewalLineItemQueueable since the items still being inserted.
         }
         
         else if(Source == 'TriggerBusinessRulesRelatedOrders'){
            if(CurOrder[0].Source__c =='Trade' 
                    || CurOrder[0].Source__c =='B2B Shop' 
                    || CurOrder[0].Source__c =='B2B Salesforce' 
                    || CurOrder[0].Source__c == 'Trade - Early Season Order'
                    || CurOrder[0].Source__c == 'Tender'){    
                lstOrderItem = Order_UpdateOrderListPriceDiscountAll.ProcessUpdate(Null,Lst_OrdId,Null,lstOrderItem,lst_ListPriceDiscountRegular);
            }
            lstOrderItem = Order_OrderandOrdeItemHandler.triggerhandler(lstOrderItem);
            lstOrderItem =Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);
            update lstOrderItem;    
        }

         return lstOrderItem;

    }    



    Public static List<OrderItem> triggerhandler(List<OrderItem> lstOrderItem){
        
        String orgId = [SELECT Id FROM Organization].Id;

        system.debug('**OrderItem Trigger: Handler: lstOrderItem**'+lstOrderItem);

        Set<String> Set_ShipTo = new Set<String> ();
        
        Set<String> Set_OrdId = new Set<String> ();
        Set<String> Set_ProdId = new Set<String> ();
        Set<String> Set_InvMulti = new Set<String>();
        Set<String> Set_InvMultiShippingAdd = new Set<String>();
        Map<String,Set<String>> Map_InvMulti = new Map<String,Set<String>>();
        Map<String,Set<String>> Map_InvMultiShippingAdd = new Map<String,Set<String>>();
        

        for(OrderItem item:lstOrderItem){
            Set_ShipTo.add(item.ShipToAccount__c);
            Set_OrdId.add(item.OrderId);
            Set_ProdId.add(item.Product2Id);
        }    
        system.debug('**OrderItem Trigger: Set_ProdId**'+Set_ProdId);

        Order[] CurOrder = [Select id,ShipComplete__c,Billto__r.NetsuiteInternalId__c,ShippingAddress, BillingAddress From Order where id in: Set_OrdId];
    

        Map<String,Boolean> Map_OrdShipComplete = new Map<String,Boolean>();
        Map<String,String> Map_BillToAccNS = new Map<String,String>();

        for(Order ord:CurOrder){
            Map_OrdShipComplete.put(ord.id,ord.ShipComplete__c);
            Map_BillToAccNS.put(ord.id,ord.Billto__r.NetsuiteInternalId__c);
        }

        Product2[] lstProduct = [Select id,DeliverComplete__c,IsInspectionCopyOrderPossible__c,IsRegularOrderPossible__c,IsUseCopyOrderPossible__c from Product2 where id in: Set_ProdId];

        Map<String,Boolean> Map_ProdDelCompl = new Map<String,Boolean>();
        Map<String,Boolean> Map_InspectionCopyOrder = new Map<String,Boolean>();
        Map<String,Boolean> Map_RegularOrder = new Map<String,Boolean>();
        Map<String,Boolean> Map_UseCopyOrder = new Map<String,Boolean>();  

        
        for(Product2 prod:lstProduct){

         //   system.debug('**OrderItem Trigger: ProductLoop**');

            Map_ProdDelCompl.put(prod.id, prod.DeliverComplete__c);
            Map_InspectionCopyOrder.put(prod.id,prod.IsInspectionCopyOrderPossible__c);
            Map_RegularOrder.put(prod.id,prod.IsRegularOrderPossible__c);
            Map_UseCopyOrder.put(prod.id,prod.IsUseCopyOrderPossible__c);
        }

/* ADDRESS CHANGE
        Account[] lstShipto = [SELECT ShippingCity,ShippingCountry,ExternalCustomerId__c,OperatingCompany__c,ShippingCostMethod__c,NetsuiteInternalId__c,ShippingPostalCode,ShippingState,ShippingStreet,DigitalActivationEmail__c, 
                                ShippingStreetName__c, ShippingHouseNumber__c, ShippingHouseNumberAddition__c, ShipToAddressValidated__c, ShippingAddress__c 
                                FROM Account WHERE id in: Set_ShipTo];
*/
//ADDRESS CHANGE
        Account[] lstShipto = [SELECT ShippingCity,ShippingCountry,ExternalCustomerId__c,OperatingCompany__c,ShippingCostMethod__c,NetsuiteInternalId__c,ShippingPostalCode,ShippingState,ShippingStreet,DigitalActivationEmail__c 
                                FROM Account WHERE id in: Set_ShipTo];


        Map<String,String> Map_ShippingCity = new Map<String,String>();
        Map<String,String> Map_ShippingCountry = new Map<String,String>();
        Map<String,String> Map_ShippingPostalCode = new Map<String,String>();
        Map<String,String> Map_ShippingState = new Map<String,String>();
        Map<String,String> Map_ShippingStreet = new Map<String,String>();
        Map<String,String> Map_DigitalActivationEmail = new Map<String,String>();
        Map<String,String> Map_NetsuiteId = new Map<String,String>();
        Map<String,String> Map_ShippingIndicationRule = new Map<String,String>();
        Map<String,String> Map_OperatingComapny = new Map<String,String>();
        //NEW - Address changes (map additional split address values)
        Map<String,String> Map_ShippingStreetName = new Map<String,String>();
        Map<String,String> Map_ShippingHouseNumber = new Map<String,String>();
        Map<String,String> Map_ShippingHouseNumberAddition = new Map<String,String>();
        Map<String,String> Map_ShippingAddress = new Map<String,String>();
        Map<String,Boolean> Map_ShippingAddressValidStatus = new Map<String,Boolean>();
        
        
        for(Account acc:lstShipto){
            Map_ShippingCity.put(acc.id,acc.ShippingCity);
            Map_ShippingCountry.put(acc.id,acc.ShippingCountry);
            Map_ShippingPostalCode.put(acc.id,acc.ShippingPostalCode);
            Map_ShippingState.put(acc.id,acc.ShippingState);
            Map_ShippingStreet.put(acc.id,acc.ShippingStreet);
            Map_DigitalActivationEmail.put(acc.id,acc.DigitalActivationEmail__c);
            Map_NetsuiteId.put(acc.id,acc.NetsuiteInternalId__c);
            Map_ShippingIndicationRule.put(acc.id,acc.ShippingCostMethod__c);
            Map_OperatingComapny.put(acc.id,acc.OperatingCompany__c);
            //NEW - Address changes (map additional split address values)
            /*
            Map_ShippingStreetName.put(acc.id,acc.ShippingStreetName__c);
            Map_ShippingHouseNumber.put(acc.id,acc.ShippingHouseNumber__c);
            Map_ShippingHouseNumberAddition.put(acc.id,acc.ShippingHouseNumberAddition__c);
            Map_ShippingAddress.put(acc.id,acc.ShippingAddress__c);
            Map_ShippingAddressValidStatus.put(acc.id,acc.ShipToAddressValidated__c);
            */
        }
       

        for(OrderItem item:lstOrderItem){
            item.ValidateDigitalActivationEmail__c = 0;

            
            if(item.DigitalActivationEMail__c == null){
            //If Non-Inventory then assign else check if there is a LicenseDuration
                if(Map_DigitalActivationEmail.get(item.ShipToAccount__c) != null && (item.ProductType__c == 'Non-inventory Item' || 
                (item.ProductLicenseDuration__c != null || item.Product2.LicenseDuration__c !=null))){
                    item.DigitalActivationEMail__c = Map_DigitalActivationEmail.get(item.ShipToAccount__c);
                }
            } 
           
           item.PricebookName__c = item.Order.Pricebook2.Name; // used for filtering for professional

        
            if(item.DigitalActivationEMail__c != null){
                    Boolean bValidateDigitalActivEmail = Pattern.matches('(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])', item.DigitalActivationEMail__c.trim());
                    String domainSuffix = (item.DigitalActivationEMail__c).substringAfterLast('.'); // the above regex doesn't catch domain suffixes such as .b, so add additional logic to check that             
                if(!bValidateDigitalActivEmail || domainSuffix.length() <= 1){
                        item.ValidateDigitalActivationEmail__c = 1;
                }
            }

            if(item.DigitalActivationEMail__c == null)    

            
            if(item.List_Price_Rate__c !=null){ 
                
                item.ListPriceDiscountAmount__c = (item.Quantity * item.ListPrice *   item.List_Price_Rate__c).setScale(2);
                
            }

           
            if(item.ShipToAccount__c !=null && item.ShippingCity__c == null){  
                             
               item.ShippingCity__c= Map_ShippingCity.get(item.ShipToAccount__c);
                item.ShippingCountry__c= Map_ShippingCountry.get(item.ShipToAccount__c);
                item.ShippingPostalCode__c= Map_ShippingPostalCode.get(item.ShipToAccount__c);
                item.ShippingState__c= Map_ShippingState.get(item.ShipToAccount__c);
                item.ShippingStreet__c= Map_ShippingStreet.get(item.ShipToAccount__c);
            }

            //Shiping cost exempt: true
            if( item.Order.ShippingCostExempt__c == true){ 
                item.ShippingIndicationRule__c = 'Shipping Cost Exempt';
            }

            //Shipping cost exempt: false
            else if( item.Order.ShippingCostExempt__c != true && item.Order.ShippingCostMethodNS__c != null){  //  item.Order.ShippingIndicationRule__c != null){ //&& {!Assign_Shipping_Cost_Exempt_false} Was visited == false
                   
                    item.ShippingIndicationRule__c = item.Order.ShippingCostMethodNS__c;
            }
            else if( item.Order.ShippingCostExempt__c != true && Map_ShippingIndicationRule.get(item.ShipToAccount__c) != null){  //  item.Order.ShippingIndicationRule__c != null){ //&& {!Assign_Shipping_Cost_Exempt_false} Was visited == false
                   
                    item.ShippingIndicationRule__c = Map_ShippingIndicationRule.get(item.ShipToAccount__c);
            }
            
                //Org is a Sandbox or tests is running (Test.isRunningTest() included to add code coverage independant of the Org type)
              

            item.OperatingCompany__c = Map_OperatingComapny.get(item.ShipToAccount__c);

            if(Map_OrdShipComplete.get(item.OrderId) == true){
                item.DeliveryType__c='Wait for full delivery';
            }

            if(item.ItemGroup__c != null){
                item.DeliveryType__c='Wait for full delivery';
            }

            if(item.ItemGroup__c == null && Map_ProdDelCompl.get(item.Product2Id)==true){
                item.DeliveryType__c='Wait for full delivery';
            }

            system.debug('**OrderItem Trigger: RegularOrder**'+Map_RegularOrder.get(item.Product2Id));

            item.IsInspectionCopyOrderPossible__c = Map_InspectionCopyOrder.get(item.Product2Id);
            item.IsRegularOrderPossible__c = Map_RegularOrder.get(item.Product2Id);
            item.IsUseCopyOrderPossible__c = Map_UseCopyOrder.get(item.Product2Id);

            item.NetSuiteIdBilltoAccount__c = Map_BillToAccNS.get(item.OrderId);
            item.NetSuiteIdShiptoAccount__c = Map_NetsuiteId.get(item.ShipToAccount__c);
            item.NetsuiteInternalId__c = Map_NetsuiteId.get(item.ShipToAccount__c);

            item.OrderMultipleShippingLocations__c = item.Order.MultipleShippingLocations__c;

            item.Subtype__c = item.Product2.ItemSubtype__c;

            // shipping address check
            if(item.ProductType__c == 'Inventory Item'){
                // Ship to check
                if(Map_InvMulti.get(item.OrderId) == null ){
                    Set_InvMulti = new Set<String>();
                    Set_InvMulti.add(item.ShipToAccount__c);
                    Map_InvMulti.put(item.OrderId, Set_InvMulti);
                }
                else{
                    Set_InvMulti = new Set<String>();
                    Set_InvMulti.addall(Map_InvMulti.get(item.OrderId));
                    Set_InvMulti.add(item.ShipToAccount__c);
                    Map_InvMulti.put(item.OrderId,Set_InvMulti);
                }
                item.MultiShiptoInventoryRollingCount__c = Map_InvMulti.get(item.OrderId).size(); 

                // shipping address check
                if(Map_InvMultiShippingAdd.get(item.OrderId) == null ){
                    Set_InvMultiShippingAdd = new Set<String>();
                    String concatenatedShippingAddy = item.ShippingStreet__c + item.ShippingPostalCode__c + item.ShippingCity__c + item.ShippingCountry__c;
                    Set_InvMultiShippingAdd.add(concatenatedShippingAddy);
                    Map_InvMultiShippingAdd.put(item.OrderId, Set_InvMultiShippingAdd);
                }
                else{
                    Set_InvMultiShippingAdd = new Set<String>();
                    Set_InvMultiShippingAdd.addall(Map_InvMultiShippingAdd.get(item.OrderId));
                    String concatenatedShippingAddy = item.ShippingStreet__c + item.ShippingPostalCode__c + item.ShippingCity__c + item.ShippingCountry__c;
                    Set_InvMultiShippingAdd.add(concatenatedShippingAddy);
                    Map_InvMultiShippingAdd.put(item.OrderId,Set_InvMultiShippingAdd);
                }
                system.debug('===> : Map_InvMultiShippingAdd: ' + Map_InvMultiShippingAdd);
                item.MultiShipAddressRollingCount__c = Map_InvMultiShippingAdd.get(item.OrderId).size(); 
            }
           // item.NetSuiteIdShiptoAccount__c = Map_Netsuite.get(item.ShipToAccount__c);

           
           if(item.ProductType__c != 'Item Group'){

            system.debug('**OrderItem Trigger: NetsuiteListPrice**'+item.NetsuiteListPrice__c);
            system.debug('**OrderItem Trigger: UnitPrice**'+item.UnitPrice);
            system.debug('**OrderItem Trigger: Quantity**'+item.Quantity);


            item.TotalDiscountAmount__c = (item.NetsuiteListPrice__c - item.UnitPrice) * item.Quantity;
            }

            if(item.List_Price_Rate__c != null){
                item.ListPriceDiscountRate__c = item.List_Price_Rate__c;
            }
           
          System.debug('**OrderItem Trigger: VATRule**: ' + item.VATRule__c);

          if(item.VATRule__c != null && item.VATRule__r.Rate__c != null){       
                     //   item.VATCalculated__c = item.LineItemTotal__c * (item.VATRule__r.Rate__c/100);        
           }

           if(item.Order.Pricebook2.Name.contains('Informat')){
            item.IsPricebookInformat__c = true;
        }
        }
        
        return lstOrderItem;
    }
 //
/*
    Public static List<OrderItem> returnQueryOrderItems(Set<String> Set_ItemId,List<Id> OrderId){

        String Querystr;
        
            Querystr= 'Select id,'
         +'  ShipToAccount__c,'
         +'  ProductLicenseDuration__c, '                
         +'  Quantity,'
         +'  NetsuiteQuantity__c,'
         +'  ListPrice,'
         +'  List_Price_Rate__c,'       
         +'  Product2Id,'
         +'  ItemGroup__c,'
         +' ShippingCity__c,'
         +' ShippingCountry__c,'
         +'  ShippingPostalCode__c,'
         +' ShippingState__c,'
         +' ShippingStreet__c,'
         +' ShippingIndicationRule__c,'         
         +'  DeliveryType__c,'
         +' discount__c,'
         +' PricebookEntryId,'
         +' ListPriceDiscountRate__c,'
         +' TotalDiscountAmount__c,'
         +' LineItemTotal__c,'
         +' VATCalculated__c,'
         +' DiscountedPrice__c,' 
         +' DiscountedPriceItemGroup__c,'
         +' NetSalesPriceItemGroup__c,'
         +' NetsuiteListPrice__c,'
         +' ProductType__c,'
         +' AccountSubsidiary__c,'
         +' NetSuiteIdShiptoAccount__c,'
         +' NetSuiteIdBilltoAccount__c,'
         +' OrderMultipleShippingLocations__c,'
         +' IsInspectionCopyOrderPossible__c,'
         +' IsRegularOrderPossible__c,'
         +' IsUseCopyOrderPossible__c,'
         +' NetsuiteInternalId__c,'          
         +' ManualDiscountValue__c,'
         +' ManualDiscount__c,'
         +' ManualDiscountPercent__c,'
         +' DigitalActivationEMail__c,'
         +' UnitPrice,'
         +' ListPriceItemGroup__c,'
         +' ListPriceDiscount__c,'
         +' ComponentListPrice__c,'
         +' MultiShiptoInventoryRollingCount__c,'
         +' MultiShipAddressRollingCount__c,'
         +' StartDate__c,'
         +' ServiceDate,'
         +' EndDate,'
         +' TrialStartDate__c,'
         +' TrialEndDate__c,'
         +' Renewable__c,'
         +' orderImportNumber__c,'
         +' ImportItemGroupEAN__c,'             
         +' OrderId,'
         +' CustomerReference__c,'
         +' Order.ShippingCostExempt__c,'
         +' Order.Billto__r.CustomerDiscountGroup__c,'
         +' Order.Billto__r.OperatingCompany__c,'
         +' Order.ShippingIndicationRule__c,'
         +' Order.ShippingCostMethodNS__c,'        
         +' Order.MultipleShippingLocations__c,' 
         +' Order.DigitalActivationEMail__c,'
         +' Order.PricingMethod__c,'
         +' Order.Pricebook2.Name,'
         +' Order.CurrencyIsoCode,'
         +' Order.Source__c,'
         +' Order.ShipbyDate__c,'
         +' ShipToAccount__r.NumberOfStudents__c,'
         +' Product2.ProductRateGroup__c,'  
         +' Product2.FixedStartDate__c,'
         +' Product2.FreeFromDate__c,'         
         +' Product2.MarketSegment__c,'
         +' Product2.LicenseDuration__c,'
         +' Product2.ItemSubtype__c,'
         +' Product2.Name,'
         +' ProductEAN__c,'
         +' ItemGroup__r.ProductEAN__c,'
         +' Product2.OrderLineType__c,'
         +' Product2.ProductDiscountGroup__c,'
         +' OrderLineType__c,'
         +' ProductComponent__c,'
         +' Product2.IsSuccessorItemActive__c,'
         +' Product2.SuccessorItem__c,'
         +' Product2.Stocknumber__c,'
         +' Product2.StockLevel__c,' 
         +'  Product2.PlannedPrintDate__c,'
         +' ProductComponent__r.Quantity__c,'
         +' VATRule__c,'        
         +' VATRule__r.Rate__c'
         +'  from OrderItem where ';
         
         if(OrderId != null){
             querystr += 'OrderId in: OrderId';
         }
         else{
            querystr += 'Id in: Set_ItemId';
         }
         

         system.debug('***querystr**'+querystr);

         OrderItem[] lst_OrdItem =  Database.query(querystr);

         system.debug('***lst_OrdItem**'+lst_OrdItem);

         return lst_OrdItem;
   }    

   Public static List<Order> returnQueryOrder(List<Id> OrderId, List<Id> MaxOrderLineId){

    String Querystr;
    
    Querystr= 'Select id,'
     + 'OrderNumber, '
     + 'ActivateforBatchProcessing__c, '
     + ' TriggerBusinessRulesRetries__c,'
     + ' ValidateIGComponentMismatch__c,'
     + 'CurrencyIsoCode,'
     + ' ValidateB2BLineCountError__c, '
     +' EffectiveDate, ' 
     +' ShipByDate__c, '
   //  +' DateUpdateBlock__c,' 
     +' LineCount__c, '
     +' OrderImportLineCount__c, ' 
     +' MasterOrder__c, ' 
     +' Pricebook2Id, '       
     +' Type, ' 
     +' NetSuiteIdAccountSubsidiary__c, '
     +' NetSuiteIdShiptoAccount__c, ' 
     +' PaymentMethod__c , '      
     +' PricingMethod__c, ' 
     +' Billto__c, ' 
     +' Billto__r.PaymentMethod__c, '
     +' Billto__r.CustomerDiscountGroup__c, '
     +' Billto__r.OperatingCompany__c, '
     +' Billto__r.BillingReminderEmail__c, '
     +' Billto__r.BillingReminderEmail2__c, '
     +' Source__c, ' 
     +' ItemGroupCount__c, '       
     +' ShippingCost__c, ' 
     +' ShippingCostDomestic__c, ' 
     +' ShippingCostNonDomestic__c, '
     +' ShippingCostMethod__c, '
     +' ShippingCostMethodNS__c, '
     +' ShippingCostMethodNsId__c, ' 
     +' ShippingIndicationRule__c,'
     +' ShippingCostExempt__c, '
     +' CustomerReference__c, '
     +' OrderReferenceNumber, '
     +' ExternalOrderId__c,'
     +' ForTheAttentionOf__c,'
     +' shipToAttentionOf__c,'
     +' WarehouseReference__c, '
     +' WarehouseReferenceActive__c,'
     +' Shipto__r.NetsuiteInternalId__c, ' 
     +' Account.BillingReminderEmail__c,  ' 
     +' Account.DigitalActivationEmail__c,  ' 
     +' Account.InvoicingEmail__c,  ' 
     +' Account.OrderNotificationEmail__c, ' 
     +' Account.BillingReminderEmail2__c,  ' 
     +' Account.InvoiceEmail2__c,  ' 
     +' Account.OrderNotificationEmail2__c, ' 
     +' Shipto__r.OrderNotificationEmail2__c, '
     +' Account.BillingAddressNotes__c, ' 
     +' Account.ShippingAddressNotes__c, ' 
     +' ShippingAddressNote__c, ' 
     +' BillingAddressNote__c, ' 
     +' BillingReminderEmail__c,  ' 
     +' DigitalActivationEmail__c,  ' 
     +' InvoiceEmail__c,  ' 
     +' OrderNotificationEmail__c, '
     +' DeliveryEmail__c, '
     +' DeliveryPhone__c, ' 
     +' Status, ' 
     +' BillingReminderEmail2__c,  ' 
     +' InvoiceEmail2__c,  ' 
     +' OrderNotificationEmail2__c, ' 
     +' OperatingCompany__c, ' 
     +' AccountSubsidiary__c, ' 
     +' Billto__r.InvoicingEmail__c,  ' 
     +' Shipto__r.OrderNotificationEmail__c,  ' 
     +' Shipto__c,  ' 
     +' TotalAmount , ' 
     +' BillingCity, ' 
     +' BillingStreet, ' 
     +' BillingPOstalcode, ' 
     +' BillingCountry, ' 
     +' ShippingCity, ' 
     +' ShippingStreet, ' 
     +' ShippingPOstalcode, ' 
     +' ShippingCountry, ' 
     +' ValidationErrorsOrder__c, '
     +' ValidationErrorsOrderProducts__c, '
     +' Courier__c, '
     +' CourierInformation__c, '
     +' CourierWholeSalerId__c, '
     +' DeliveryRouting__c '
     +'  from Order where ';
     
     if(MaxOrderLineId == null){
         querystr += 'Id in: OrderId';
     }
     else{
        querystr += 'MaxOrderLine__c in:MaxOrderLineId';
     }
     

     system.debug('***querystr**'+querystr);

     Order[] lst_Ord =  Database.query(querystr);

     system.debug('***lst_OrdItem**'+lst_Ord);

     return lst_Ord;
}

Public static List<ListPriceDiscount__c> returnListPriceDiscount(Order[] lst_Order ,Set<String> Set_CusDiscountGroup, Set<String> Set_OperatingCo, Set<String> Set_ProdDiscountGroup, Set<String> Set_OrderLineItemType, Set<String> Set_MarketSegment){

    String Querystr;
    Date CurDate = system.today();
    
    system.debug('***ListPriceDiscount: Set_CusDiscountGroup**'+Set_CusDiscountGroup);
    system.debug('***ListPriceDiscount: Set_OperatingCo**'+Set_OperatingCo);
    system.debug('***ListPriceDiscount: Set_ProdDiscountGroup**'+Set_ProdDiscountGroup);
    system.debug('***ListPriceDiscount: Set_OrderLineItemType**'+Set_OrderLineItemType);
    system.debug('***ListPriceDiscount: Set_MarketSegment**'+Set_MarketSegment);

Querystr =  'Select id,'
+' DiscountType__c, '
+' ProductDiscountGroup__c, '
+' Subsidiary__c, '
+' ValueType__c, '
+' StartAmount__c, '
+' CustomerDiscountGroup__c, '
+' OrderLineType__c, ' 
+' MarketSegment__c, '
+' Rate__c, '
+' StartQuantity__c ' 
+' from ListPriceDiscount__c where '
+' EndDate__c >=:CurDate  AND StartDate__c  <=:CurDate'
+' AND CustomerDiscountGroup__c in: Set_CusDiscountGroup AND Subsidiary__c in: Set_OperatingCo  AND ProductDiscountGroup__c in: Set_ProdDiscountGroup  AND OrderLineType__c in: Set_OrderLineItemType '; // AND MarketSegment__c in: Set_MarketSegment
if(lst_Order[0].PricingMethod__c=='OrderTotalAmount'){
    Querystr += ' AND ValueType__c = \'Amount\' ';                
    Querystr += ' ORDER BY StartAmount__c DESC';
}
else{
    Querystr += ' AND ValueType__c = \'Quantity\' '; 
    Querystr += ' ORDER BY StartQuantity__c DESC'; 
}


    // system.debug('***querystr**'+querystr);

     ListPriceDiscount__c[] lst_ListPriceDiscountRegular =  Database.query(querystr);

     system.debug('***lst_ListPriceDiscountRegular**'+lst_ListPriceDiscountRegular);

     return lst_ListPriceDiscountRegular;
}
*/



}