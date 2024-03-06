public with sharing class Order_SoqlFactory {
  
//No Comment

        Public static List<OrderItem> returnQueryOrderItems(Set<String> Set_ItemId,List<Id> OrderId, Set<String> Set_ItemGroupBlock,  String Type){
    
            String Querystr;
            //Order.Hfdstructuur__c,Hfdstructuur__c 
            
            Querystr= 'Select id,'
            +' AccountSubsidiary__c,'
            +' CustomerReference__c,'
             +' ComponentListPrice__c,'
             +'  DeliveryType__c,'
             +' discount__c,'
             +' DigitalActivationEMail__c,'
             +' DiscountedPrice__c,' 
             +' DiscountedPriceItemGroup__c,'
             +' EndDate,'
             + 'Hfdstructuur__c,'
             +' ItemGroupId__c,'
             +'  ItemGroup__c,'     
             +' IsInspectionCopyOrderPossible__c,'
             +' IsRegularOrderPossible__c,'
             +' IsUseCopyOrderPossible__c,'
             +' ImportItemGroupEAN__c,'
             +' LicenseDuration__c,' 		    
             +' ListPriceDiscountRate__c,'        
             +' LineItemTotal__c,'
             +' ListPriceItemGroup__c,'
             +' ListPriceDiscount__c,'
             +'  ListPrice,'
             +'  List_Price_Rate__c,' 
             +' MultiShiptoInventoryRollingCount__c,'
             +' MultiShipAddressRollingCount__c,'       
             +' ManualDiscountValue__c,'
             +' ManualDiscount__c,'
             +' ManualDiscountPercent__c,'
             +' NetSuiteIdShiptoAccount__c,'
             +' NetSuiteIdBilltoAccount__c,'
             +' NetsuiteInternalId__c,'          
             +' NetSalesPriceItemGroup__c,'
             +' NetsuiteListPrice__c,'
             +'  NetsuiteQuantity__c,'
             +' OrderMultipleShippingLocations__c,'
             +' orderImportNumber__c,'
             +' OrderId,'
             +' OrderLineType__c,'
             +' ProductType__c,'
             +'  Product2Id,'
             +'  ProductLicenseDuration__c,'
             +' PricebookEntryId,'
             +' ProRataRate__c,'
             +' ProRataMonths__c,'
             +' ProductEAN__c,'
             +' ProductComponent__c,'
             +'  Quantity,'
             +' Renewable__c,'
             +' StartDate__c,'
             +' ServiceDate,'
             +' ShipToAccount__c,'
             +' ShippingCity__c,'
             +' ShippingCountry__c,'
             +' ShippingPostalCode__c,'
             +' ShippingState__c,'
             +' ShippingStreet__c,'
             +' ShippingIndicationRule__c,' 
             +' Terms__c,'
             +' TrialStartDate__c,'
             +' TrialEndDate__c,'  
             +' TotalDiscountAmount__c,'
             +' UnitPrice,'
             +' VATCalculated__c,' 
             +' ItemGroup__r.Product2Id,'
             +' ItemGroup__r.ProductEAN__c,'
             +'  ListPriceDiscount__r.OrderLineType__c,'
             +'  ListPriceDiscount__r.Rate__c,'
             +' Order.Hfdstructuur__c,'
             +' Order.ShippingCostExempt__c,'
             +' Order.Billto__r.CustomerDiscountGroup__c,'
             +' Order.Billto__r.OperatingCompany__c,'
             +' Order.ShippingIndicationRule__c,'
             +' Order.ShippingCostMethodNS__c,'
             +' Order.MasterOrder__c,'        
             +' Order.MultipleShippingLocations__c,' 
             +' Order.DigitalActivationEMail__c,'
             +' Order.PricingMethod__c,'
             +' Order.Pricebook2.Name,'
             +' Order.CurrencyIsoCode,'
             +' Order.Source__c,'
             +' Order.ShipbyDate__c,'
             +' Product2.CustomPricingAllowed__c,'
             +' Product2.ProductRateGroup__c,' 
             +' Product2.ItemSubtype__c,' 
             +' Product2.FixedStartDate__c,'
             +' Product2.FreeFromDate__c,'         
             +' Product2.MarketSegment__c,'
             +' Product2.LicenseDuration__c,'
             +' Product2.maxQuantity__c,'
             +' Product2.Name,'
             +' Product2.IsSuccessorItemActive__c,'
             +' Product2.OrderLineType__c,'
             +' Product2.ProductDiscountGroup__c,'
             +' Product2.ProRatoDiscount__c,'
             +' Product2.PlannedPrintDate__c,'
             +' Product2.QuantitySelectionType__c,'
             +' Product2.Renewable__c,'
             +' Product2.SoldInSegment__c,'
             +' Product2.SuccessorItem__c,'
             +' Product2.Stocknumber__c,'
             +' Product2.StockLevel__c,'              
             +' ProductComponent__r.Quantity__c,'
             +' ShipToAccount__r.NumberOfStudents__c,'
             +' ShipToAccount__r.CustomerDiscountGroup__c,'
             +' ShipToAccount__r.Name,'
             +' VATRule__c,'		
             +' VATRule__r.Rate__c'
             +'  from OrderItem where ';
             
             if(OrderId != null){
                 querystr += 'OrderId in: OrderId';
             }
             else if(Set_ItemGroupBlock != null){
                querystr += 'id in: Set_ItemId AND Product2Id not in: Set_ItemGroupBlock';
             }
             else{
                querystr += 'Id in: Set_ItemId';
             }
    
             if(Type == 'AssetsCreateOnOrderActivation'){
                querystr += ' limit 200 ';
             }
    
             else if(Type == 'ProductSelectController'){
                querystr += ' Order By createddate ASC';
             }
             
    
             OrderItem[] lst_OrdItem =  Database.query(querystr);
             
             system.debug('**Order_SoqlFactory.returnQueryOrderItems:Size**'+lst_OrdItem.size());

             return lst_OrdItem;
       }    
   
       
    Public static List<Order> returnQueryOrder(List<Id> OrderId, List<Id> MaxOrderLineId,  String Type){

        String Querystr;
       
     
        Querystr= 'Select id,'
    
         + 'ActivateforBatchProcessing__c, '
         +' AccountSubsidiary__c, ' 
         +' BillingCity, ' 
         +' BillingStreet, ' 
         +' BillingPOstalcode, ' 
         +' BillingCountry, ' 
         +' BillingAddressNote__c, ' 
         +' BillingReminderEmail__c,  '
         +' BillingReminderEmail2__c,  '      
         +' Billto__c, '   
         +' ContractId,'  
         + 'CurrencyIsoCode,'
         +' CustomerReference__c, '
         +' DigitalActivationEmail__c,  ' 
         +' DeliveryEmail__c, '
         +' DeliveryPhone__c, ' 
    //     +' DateUpdateBlock__c,' 
         +' EffectiveDate, ' 
         +' ExternalOrderId__c,'
         +' ForTheAttentionOf__c,'
         +' ItemGroupCount__c, '
         +' Hfdstructuur__c,'
         +' InvoiceEmail__c,  ' 
         +' InvoiceEmail2__c,  ' 
         +' LineCount__c, '
         +' MaxOrderLine__c,'
         +' MultipleShippingLocations__c,'
         +' MasterOrder__c, ' 
         +' NetSuiteIdAccountSubsidiary__c, '
         +' NetSuiteIdShiptoAccount__c, ' 
         + 'OrderNumber, '
         +' OrderImportLineCount__c, ' 
         +' OrderImportTotalLineQuantities__c,'
         +' OrderReferenceNumber, '
         +' OrderNotificationEmail__c, '
         +' OrderNotificationEmail2__c, '
         +' OrderTypeJobRun__c,' 
         +' OperatingCompany__c, '
         +' OrderImportAmountExclVAT__c,'
         +' PaymentMethod__c, '      
         +' PricingMethod__c, ' 
         +' Pricebook2Id, '       
         +' ShipByDate__c, '
         +' Shipto__c,  ' 
         +' ShippingCity, ' 
         +' ShippingStreet, ' 
         +' ShippingPOstalcode, ' 
         +' ShippingCountry, ' 
         +' Source__c, ' 
         +' ShippingCost__c, ' 
         +' ShippingCostDomestic__c, ' 
         +' ShippingCostNonDomestic__c, '
         +' ShippingCostMethod__c, '
         +' ShippingCostMethodNS__c, '
         +' ShippingCostMethodNsId__c, ' 
         +' ShippingIndicationRule__c,'
         +' ShippingCostExempt__c, '
         +' shipToAttentionOf__c,'
         +' ShippingAddressNote__c, ' 
         +' Status, ' 
         +' TotalAmount , ' 
         +' TotalLineItemQuantity__c,'
         +' TriggerBusinessRulesRetries__c,'
         +' Type, ' 
         + ' ValidateB2BLineCountError__c, '
         +' ValidationErrorsOrder__c, '
         +' ValidationErrorsOrderProducts__c, '
         +' ValidateIGComponentMismatch__c,'
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
         +' Account.NetsuiteInternalId__c,'    
         +' Account.BillingAddressNotes__c, ' 
         +' Account.ShippingAddressNotes__c, ' 
         +' Billto__r.PaymentMethod__c, '
         +' Billto__r.CustomerDiscountGroup__c, '
         +' Billto__r.OperatingCompany__c, '
         +' Billto__r.BillingReminderEmail__c, '
         +' Billto__r.BillingReminderEmail2__c, '
         +' Billto__r.InvoicingEmail__c,  ' 
         +' Pricebook2.Name,'
         +' Pricebook2.StartDate__c, '
         +' Pricebook2.EndDate__c, '
         +' Shipto__r.OrderNotificationEmail__c,  ' 
         +' Shipto__r.OrderNotificationEmail2__c '
         +'  from Order where ';
         
         if(Type == 'OrderActivateQueueHandler'){
            String Status='Activated';
            String checked='';
            querystr += ' Id not in: OrderId AND id !=:checked AND  ActivateforBatchProcessing__c = true AND ValidateB2BLineCountError__c= 0 AND  ActivateforBatchProcessing__c = true  and Status !=:  Status and ValidationErrorsOrder__c = 0 and ValidationErrorsOrderProducts__c = 0 and LineCount__c > 0 Order by LineCount__c ASC limit 1';
         }
         else if(MaxOrderLineId == null || Type == 'OrderInsertQueuable'){
             querystr += ' Id in: OrderId';
         }
         else{
            querystr += ' MaxOrderLine__c in:MaxOrderLineId';
         }
    
    
    
         Order[] lst_Ord =  Database.query(querystr);

         system.debug('**Order_SoqlFactory.returnQueryOrder:Size**'+lst_Ord.size());
    
         return lst_Ord;
    }

    
    Public static List<ListPriceDiscount__c> returnListPriceDiscount(String Type,String PricingMethod,Set<String> Set_CusDiscountGroup, Set<String> Set_OperatingCo, Set<String> Set_ProdDiscountGroup, Set<String> Set_OrderLineItemType, Set<String> Set_MarketSegment){

        String Querystr;
        Date CurDate = system.today();
        
        
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
    +' EndDate__c >=:CurDate  AND StartDate__c  <=:CurDate';
    
    if(Type =='AllDiscount' || Type == 'OrderTypeChange'){
        Querystr += ' AND CustomerDiscountGroup__c in: Set_CusDiscountGroup AND Subsidiary__c in: Set_OperatingCo  AND ProductDiscountGroup__c in: Set_ProdDiscountGroup  AND OrderLineType__c in: Set_OrderLineItemType '; // AND MarketSegment__c in: Set_MarketSegment
    }
    else if(Type =='ProductSelector'){
        Querystr += ' AND CustomerDiscountGroup__c in: Set_CusDiscountGroup AND Subsidiary__c in: Set_OperatingCo  '; 
    }
    if(Type =='AllDiscountv2' ){
        //Do nothing for now: remove later when call to method is done.
    }
    
    if(PricingMethod =='OrderTotalAmount'){
        Querystr += ' AND ValueType__c = \'Amount\' ';                
        Querystr += ' ORDER BY StartAmount__c DESC';
    }
    else{
        /*
        if(Type =='ProductSelectorv2'){
            Querystr += ' AND StartQuantity__c <=: NoStudents   '; 
        }
       */

        Querystr += ' AND ValueType__c = \'Quantity\' '; 
        Querystr += ' ORDER BY StartQuantity__c DESC'; 
    }

    system.debug('**Order_SoqlFactory.returnListPriceDiscount :Set_CusDiscountGroup**'+Set_CusDiscountGroup);
    system.debug('**Order_SoqlFactory.returnListPriceDiscount :Set_OperatingCo**'+Set_OperatingCo);
    system.debug('**Order_SoqlFactory.returnListPriceDiscount :Set_ProdDiscountGroup**'+Set_ProdDiscountGroup);
    system.debug('**Order_SoqlFactory.returnListPriceDiscount :Set_OrderLineItemType**'+Set_OrderLineItemType);

    system.debug('**Order_SoqlFactory.returnListPriceDiscount :querystr**'+querystr);
    ListPriceDiscount__c[] lst_ListPriceDiscountRegular =  Database.query(querystr);
    
    system.debug('**Order_SoqlFactory.returnListPriceDiscount :Size**'+lst_ListPriceDiscountRegular.size());

    return lst_ListPriceDiscountRegular;
    
  
    
    }

    Public static List<Product2> returnProduct(Set<String> Set_Products){

        String Querystr;
        Date CurDate = system.today();
    
        Querystr =  'Select id,'
        +'Type__c,'
        +'FreeFromDate__c,'
        +'IsRegularOrderPossible__c,'
        +'IsInspectionCopyOrderPossible__c,'
        +'IsUseCopyOrderPossible__c,'
        +'FixedStartDate__c,'
        +'StartDate__c,'
        +'LicenseDuration__c,'
        +'Renewable__c '
        +'from Product2 where id in: Set_Products';
               

        Product2[] lst_Product =  Database.query(querystr);

        system.debug('**Order_SoqlFactory.returnProduct :Size**'+lst_Product.size());

    
        return lst_Product;
    
    }

    Public static List<Pricebook2> returnPricebook(Set<String> Set_PriceBook, Set<String> Set_Subsid){

        String Querystr;
        Date CurDate = system.today();
        
       
    Querystr =  'Select id,'
    +' IsActive,'
    +' Subsidiary__c,'
    +' FollowUpPriceBook__c,'
    +' IndexationPercentage__c,'
    +' FollowUpPriceBook__r.IndexationPercentage__c,'
    +' ShippingComplete__c,'
    +' StartDate__c, '
    +' EndDate__c, '
    +' isStandard,'
    +' PricebookType__c,'
    +' SoldInSubSegment__c'
    +' from Pricebook2 where ';
    
    if(Set_Subsid != null){
        Querystr += ' Subsidiary__c in:Set_Subsid AND IsActive = true';
    }
    else{
        Querystr += 'id in:Set_PriceBook';   
    }
     
    Pricebook2[] lst_Pricebook =  Database.query(querystr);

    system.debug('**Order_SoqlFactory.returnPricebook :Size**'+lst_Pricebook.size());

    
    return lst_Pricebook;
    
    }
    
    
    Public static List<PricebookEntry> returnPricebookEntry(String Type, String SearchString, Set<String> Set_ProdId,Set<String> Set_Pricebook,String Pricebook2Id,Map<String,String> Map_ItemGroup,Set<String> Set_SuccProductId,Date PricebookStart, Date PricebookEnd){
        String Querystr;
        
    
       Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

       Id STPBId = standardPB.id;

        Querystr =  'Select id,'
        +' Pricebook2Id, '
        +' productcode,'
        +' Product2Id,'
        +' unitprice,' 
        +' Price__r.ListRate__c,'
        +' Price__c,'	 
        +' Product2.IsSuccessorItemActive__c,'
        +' Product2.maxQuantity__c,'
        +' Product2.DeliveryStatus__c,' 
        +' Product2.CustomPricingAllowed__c,'
        +' Product2.LicenseDuration__c,'
        +' Product2.ISBNArticleNumber__c,'
        +' Product2.MarketSegment__c,'
        +' Product2.name,'
        +' Product2.OrderLineType__c,'
        +' Product2.PlannedPrintDate__c,'
        +' Product2.ProductRateGroup__c,'
        +' Product2.ProductDiscountGroup__c,'
        +' Product2.QuantitySelectionType__c,'
        +' Product2.Renewable__c,'
        +' Product2.SoldInSegment__c,' 
        +' Product2.SuccessorItem__c,'
        +' Product2.SuccessorItem__r.IsActive,'        
        +' Product2.Stocknumber__c,'       
        +' Product2.Type__c,'
        +' PriceBook2.StartDate__c,'
        +' PriceBook2.EndDate__c'
        +' from PricebookEntry where ';


        if(Type =='AssetRenewalProductsbyPriceBook'){
            
                Querystr += 'IsActive =true ';
                Querystr += 'AND Pricebook2Id in:Set_Pricebook ' 
                +'AND (Product2Id in: Set_ProdId OR Product2Id in: Set_SuccProductId)';
        }
        else if(Type =='AssetRenewalProductsbyPriceBookSuccessor'){       
                
                Querystr += 'IsActive =true ';
                Querystr += 'AND Pricebook2Id in:Set_Pricebook ' 
                +'AND Product2Id in: Set_SuccProductId';
               
        }
        else if(Type == 'ProductSelectorSearch'){
                String Search = '%'+SearchString+'%';
                Querystr += 'IsActive =true ';
                Querystr += 'AND Pricebook2Id =:Pricebook2Id'  
                +'      AND Product2Id not in: Set_ProdId'
                +'      AND Price__r.IsActive__c = true'
                +'    AND PriceBook2.StartDate__c =: PricebookStart'
                +'    AND PriceBook2.EndDate__c =: PricebookEnd'
                +'       AND Product2.HasBlock__c=  false'
                +'      AND Product2.itemGroupManualBlock__c = false'
                +'      AND (Product2.Name  like:Search '
                +'          OR Product2.ISBNArticleNumber__c like:Search'
                +'          OR Product2.EAN__c like:Search'
                +'          OR Product2.ISBN__c like:Search'
                +'          OR Product2.Type__c like: Search'
                +'     ) Order by Product2.Name ASC limit 70';
        }    
        else if(Type == 'ProductSelectorLoad'){
                system.debug('**ProductSelectorLoad**');
                Querystr += 'IsActive =true ';
                Querystr += 'AND Pricebook2Id =:Pricebook2Id' 
                +'  AND IsActive = true '
                +'      AND Price__r.IsActive__c = true'
                +'    AND PriceBook2.StartDate__c =: PricebookStart'
                +'    AND PriceBook2.EndDate__c =: PricebookEnd'
                +' AND Product2.itemGroupManualBlock__c = false'
                +' AND Product2Id not in: Set_ProdId'
                +' AND Product2.HasBlock__c= false Order by Product2.Name ASC limit 70 ';
        } 
        else if(Type == 'ProductSelectorItemGroup'){
                List<String> lst_ItemGroup = new List<String>();

                lst_ItemGroup.addall(Map_ItemGroup.keyset());
                Querystr += 'IsActive =true ';
                Querystr +='AND Pricebook2Id =:Pricebook2Id AND Product2Id in:lst_ItemGroup';
        }
        else if(Type == 'Itemgroupcreate' ){
                
                Querystr += 'IsActive =true ';
                Querystr += 'AND Product2Id in:Set_ProdId' 
                +' AND Pricebook2Id !=:STPBId';
                
                if(Set_Pricebook.size()>0){           
                    Querystr += ' AND Pricebook2Id in: Set_Pricebook';
                } 
        }
        else if(Type=='SuccessorPricebookentrycreate_1'){
            Querystr += ' Product2Id in:Set_ProdId AND Pricebook2Id !=:STPBId AND Pricebook2Id in: Set_Pricebook'; 
        }
        else if(Type=='SuccessorPricebookentrycreate_2'){
                Querystr += ' Product2Id in:Set_ProdId AND Pricebook2Id !=:STPBId';  
        }  
        else if(Type=='SuccessorPricebookentrycreate_3'){
            Querystr += 'IsActive =true ';
            Querystr += 'AND Product2Id in:Set_SuccProductId AND Pricebook2Id =:Pricebook2Id'; 
        } 

        


        /*
        else if( Type=='Successorupdate'){
                Querystr += 'Product2Id in:Set_ProdId' 
                +'AND Pricebook2Id !=:standardPB.id'
                +'Product2Id in:Set_SuccProductId AND Pricebook2Id =: Pricebook2Id';
        }
        
        else if( Type=='Successorupdate'){
                Querystr += 'Product2Id in:Set_ProdId' 
                +'AND Pricebook2Id !=:standardPB.id'
                +'Product2Id in:Set_SuccProductId AND Pricebook2Id =: Pricebook2Id';
        }
        else if( Type=='Successorupdate_2'){
                Querystr += 'Product2Id in:Set_ProdId' 
                +'AND Pricebook2Id !=:standardPB.id'
                +'Product2Id in: Set_SuccProductId AND Pricebook2Id =: Pricebook2Id';
        } 
        */
         
        
        /*
        else if(Type=='AssetRenewal_1'){
                Querystr += 'Pricebook2Id in:Set_Pricebook ' 
                +'AND (Product2Id in: Set_ProductId OR Product2Id in: Set_SuccProductId)'
                +'IsActive =:true';
        }
        else if(Type=='AssetRenewal_2'){
                Querystr += 'Pricebook2Id in:Set_Pricebook ' 
                +'Product2Id in: Set_SuccProductId'
                +'IsActive =:true';
        }
        */
        
        system.debug('**Order_SoqlFactory.returnPricebookEntry :querystr**'+querystr);

        PricebookEntry[] lst_PricebookEntry =  Database.query(querystr);
        

        system.debug('**Order_SoqlFactory.returnPricebookEntry :Size**'+lst_PricebookEntry.size());


        return lst_PricebookEntry;


          
    
    }
        
    Public static List<Pricing__c> returnPricing(String Type,Set<String> Set_ProdItemGroup,List<Id> lst_ProdPriceId,Date PricebookStart, Date PricebookEnd){
      
    
       String Querystr;
       Date CurDate = system.today();
        
       Querystr =  'Select id,'
       +' ListRate__c,' 
       +' Product__c,'
       +' EndDate__c,'
       +' IsActive__c,'
       +' ExternalId__c,'
       +' StartDate__c,'
       +' Subsidiary__c,'
       +' CurrencyIsoCode,'
       +' Product__r.Type__c,'
       +' Product__r.MarketSegment__c,'
       +' Product__r.Stocknumber__c,'
       +' Product__r.SoldInSegment__c,'
       +' Product__r.SoldInSubSegment__c,'
       +' Product__r.DeliveryStatus__c,'
       +' Product__r.StockLevel__c,'
       +' Product__r.Name,' 
       +' Product__r.PlannedPrintDate__c,'
       +' Product__r.HasBlock__c,'
       +' Product__r.IsSuccessorItemActive__c,'
       +' Product__r.SuccessorItem__c,'
       +' Product__r.IsActive,'
       +' ProductComponent__c,'
       +' ProductComponent__r.IsActive__c,'
       +' ProductComponent__r.Quantity__c,'
       +' ProductComponent__r.Type__c,'
       +' ProductComponent__r.MainProduct__c,'
       +' ProductComponent__r.Product__c,'
       +' ProductComponent__r.Product__r.MarketSegment__c,'
       +' ProductComponent__r.Product__r.Type__c,'
       +' ProductComponent__r.MainProduct__r.itemGroupManualBlock__c,'  
       +' ProductComponent__r.Product__r.Name'
       +' from Pricing__c where IsActive__c =true ';
    
       if(Type != 'Pricebookentrycreate' && Type != 'UpdatePricingfromProduct'){
        Querystr += 'AND ((StartDate__c <=: PricebookStart AND EndDate__c >=: PricebookStart)'
                    + ' OR (StartDate__c <=: PricebookEnd AND EndDate__c >=: PricebookEnd)'
                    + ' OR (StartDate__c >=: PricebookStart AND EndDate__c <=: PricebookEnd)'
                    + ' OR  (StartDate__c <=: PricebookStart AND EndDate__c >=: PricebookEnd))';
            
       } 
       if(Type == 'ProductSelector1'){
            Querystr += 'AND(ProductComponent__r.MainProduct__c in: Set_ProdItemGroup OR ProductComponent__r.Product__c in: Set_ProdItemGroup OR Product__c in: Set_ProdItemGroup )';
        }
       else if(Type == 'ProductSelector2'){   
            Querystr += 'AND (ProductComponent__r.MainProduct__c in: Set_ProdItemGroup OR id in: lst_ProdPriceId)';
        } 
       else if(Type == 'ItemgroupCreate'){
            Querystr += 'AND (ProductComponent__r.MainProduct__c in: Set_ProdItemGroup )'; 
       }
       else if(Type == 'Itemgroupupdate'){
            Querystr += 'AND (ProductComponent__r.Product__c in: lst_ProdPriceId AND ProductComponent__r.MainProduct__c in: Set_ProdItemGroup)';
        }
       else if(Type == 'Pricebookentrycreate'){
            Querystr += 'AND id in:lst_ProdPriceId AND ProductComponent__c = null';   
        }
       else if(Type == 'UpdatePricingfromProduct'){
            Querystr += 'AND (Product__c in:lst_ProdPriceId OR ProductComponent__r.Product__c in: lst_ProdPriceId)';
       }
  
       system.debug('**Order_SoqlFactory.returnPricing :Querystr**'+Querystr);
       Pricing__c[] lst_Pricing =  Database.query(querystr);
       system.debug('**Order_SoqlFactory.returnPricing :Size**'+lst_Pricing.size());

       return lst_Pricing;

    }   
    
       
    
    
    Public static String returnasset(String Type,Set<String> Set_BillTo,Set<string> Set_ProdId){
    
        String Querystr;
        Date CurrentDay = system.today();
        Date RenewalDay = system.today();
     
        Querystr =  'Select id,'
        +' AccountId,'
        +' ApplyIndexationPercentage__c,'
        +' BillToAccount__c,'
        +' CancellationDate__c,'
        +' CurrencyIsoCode,'
        +' Contract__c,'
        +' DiscountedPrice__c, '
        +' DigitalActivationEMail__c,'
        +' Informhfdstructuur__c,'
        +' IsUpForRenewal__c,'
        +' LastRenewalUpdate__c, '
        +' ListPrice__c,'
        +' ManualDiscountPercent__c, '
        +' ManualDiscountValue__c, '
        +' ManualDiscount__c,'
        +' Name,'
        +' OrderLineType__c,' 
        +' Price,'
        +' PriceBook__c, '
        +' PricingMethod__c,'
        +' Product2Id,'
        +' Quantity,'
        +' Reference__c,'
        +' RenewalDate__c, '
        +' RenewalRunDate__c,'
        +' RenewalTerm__c,'
        +' ShipToAttentionOf__c,'
        +' Terms__c,'
        +' Account.NetsuiteInternalId__c,' 
        +' Account.NumberofStudents__c,'
        +' Account.DigitalActivationEmail__c , '
        +' Account.CustomerDiscountGroup__c,'
        +' Account.OperatingCompany__c,'
        +' BillToAccount__r.OperatingCompany__c,'
        +' BillToAccount__r.PaymentMethod__c,'
        +' BillToAccount__r.CustomerDiscountGroup__c,'
        +' BillToAccount__r.NetsuiteInternalId__c,'        
        +' BillToAccount__r.ShippingStreet,'
        +' BillToAccount__r.ShippingPostalCode,'
        +' BillToAccount__r.ShippingCountry,'
        +' BillToAccount__r.ShippingCity,'
        +' BillToAccount__r.BillingStreet,'
        +' BillToAccount__r.BillingPostalCode,'
        +' BillToAccount__r.BillingCountry,'
        +' BillToAccount__r.BillingCity,'
        +' Contract__r.Indexation__c,'
        +' BillToAccount__r.ShippingCostMethod__c,'
        +' Product2.CustomPricingAllowed__c,'
        +' Product2.IsSuccessorItemActive__c,'
        +' Product2.SuccessorItem__c,'
        +' Product2.SuccessorItem__r.IsActive,'
        +' Product2.Type__c,'
        +' Product2.LicenseDuration__c, '
        +' Product2.OrderLineType__c, '
        +' Product2.ProductDiscountGroup__c, '
        +' Product2.ProductRateGroup__c,'
        +' Product2.Name,'
        +' PriceBook__r.FollowUpPriceBook__c '
        +' from asset' 
        +' where ';

        if(Type.contains('renewal')){
            
            if(Set_BillTo != null){
                Querystr +='(Product2Id != null AND BillToAccount__c in: Set_BillTo AND PricingMethod__c != null )';
            }
            else{
                Querystr +='BillToAccount__r.RenewalAssetToday__c = false ';
                Querystr +='AND (Product2Id != null AND BillToAccount__c != null AND PricingMethod__c != null )';
            }
            Querystr +=' AND(('
            +' (CancellationDate__c >: CurrentDay OR CancellationDate__c = null)'
            +'AND ( '
                +' ('
                +    '(RenewalDate__c  =: RenewalDay AND RenewalRunDate__c = null) '
                +'   OR RenewalRunDate__c =: CurrentDay  '
                +'   OR (RenewalDate__c  <: CurrentDay AND QuantityUpdateCheckYearly__c = True)'
                +  ')'
                +'AND '
                +'('
                +' (QuantityUpdateCheckYearly__c = false)'
                +' OR(QuantityUpdateCheckYearly__c = True AND QuantityStartDate__c <=:CurrentDay AND QuantityEndDate__c >=:CurrentDay  )'
                +')'
            +')'
            +' AND LastRenewalUpdate__c !=: CurrentDay'
            +' AND AutomatedRenewProcess__c = true' 
            +' AND Product2.Type__c != \'Item Group\' '
            +' )'
            +' OR('
            +' AssetRenewalTrigger__c = true'
            +' AND Product2.Type__c != \'Item Group\' '
            +' )'
            +' )';
 
        }
        /*Commented out in the class
        else if(Type =='Activation'){
            Querystr += 'Product2Id in:Set_Asset ' 
            +'AND BillToAccount__c in:Set_BillTo ' 
            +'AND AccountId in:Set_ShipTo '
            +'AND PricingMethod__c in: Set_PricingMethod '; 
        }
        */
        else if(Type == 'AssetsFromOrder'){
            Querystr += 'Product2Id in: Set_ProdId ' 
            +'AND AccountId in: Set_BillTo ' 
            +'AND (CancellationDate__c >: CurrentDay OR CancellationDate__c=null)';
        }
        else if(Type =='ProductSelector' || Type =='ListPriceDiscount'){
    
            Querystr += '(CancellationDate__c >: CurrentDay OR CancellationDate__c =null)'
            + 'AND RenewalDate__c  >=: CurrentDay '
            + 'AND (ActivationDate__c <=: CurrentDay OR  ActivationDate__c = null) '
            + 'AND IsActive__c = true '
            + 'AND BillToAccount__c in:Set_BillTo '
            + 'AND Contract__c =null';  
        }
       

        system.debug('**Order_SoqlFactory.returnasset :querystr**'+querystr);
        Asset[] lst_Asset =  Database.query(querystr);
        system.debug('**Order_SoqlFactory.returnasset :Size**'+lst_Asset.size());
    
        return querystr;
    
    
    }
    
    public static List<Map<String,String>> returnAccountSubsidiary(Set<String> Set_Sub){
             
    
        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,LegalName__c,NetsuiteInternalId__c,Account__c,Account__r.OperatingCompany__c,Account__r.isVocationalEducation__c,Account__r.isHigherEducation__c from AccountSubsidiary__c where Account__c in:Set_Sub AND (Deleted__c =:false AND 	IsInactive__c =:false) ];

        Map<String,String> Map_Sub = new Map<String,String>();
        Map<String,String> Map_Netsuite = new Map<String,String>();
        
        List<Map<String,String>> lst_Maps = new List<Map<String,String>>();

        for(AccountSubsidiary__c acc:lstAccountSubsidiary){
            
            //Commented out because Noorhoff has no need for specific logic for LegalName 'NoordhoffDigitaalBedrijf' and 
            //the OpCo else condition would then have the same add mapp logic for all OpCo's
            /*if(acc.Account__r.OperatingCompany__c == 'Noordhoff'){

                if ((acc.Account__r.isVocationalEducation__c == true || acc.Account__r.isHigherEducation__c == true) && acc.LegalName__c=='NoordhoffDigitaalBedrijf' && Map_Sub.get(acc.Account__c) == null){
                    Map_Sub.put(acc.Account__c,acc.id);
                    Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);
                    
                }
                else if((acc.Account__r.isVocationalEducation__c == false && acc.Account__r.isHigherEducation__c == false) && acc.LegalName__c !='NoordhoffDigitaalBedrijf' && Map_Sub.get(acc.Account__c) == null){
                    Map_Sub.put(acc.Account__c,acc.id);
                    Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);   
                }       
            }
            else{
                    Map_Sub.put(acc.Account__c,acc.id);
                    Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);
            }*/    
            Map_Sub.put(acc.Account__c,acc.id);
            Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);
        }

        
        lst_Maps.add(Map_Sub);
        lst_Maps.add(Map_Netsuite);

        system.debug('**Order_SoqlFactory.returnAccountSubsidiary :Size**'+lst_Maps.size());


        return lst_Maps;
}

Public static List<OpportunityLineItem> returnOpportunityLine(String curOrderId){

            String Querystr;
            Date CurDate = system.today();

            Querystr =  'Select id,' 
            +'  ComponentListPrice__c,'
            +'  DiscountedPriceItemGroup__c,'
            +'  ItemGroup__c,'
            +'  LicenseDuration__c,'
            +'  ListPriceItemGroup__c,'
            +'  ListPriceDiscount__c,'
            +'  ListPrice,'
            +'  ManualDiscount__c,'
            +'  ManualDiscountPercent__c,'
            +'  ManualDiscountValue__c,'
            +'  OrderLineType__c,'
            +'  OpportunityId,'
            +'  Product2Id,'
            +'  ProductType__c,'
            +'  ProductComponent__c,'
            +'  Quantity,'
            +'  ServiceDate,'
            +'  Terms__c,'
            +'  UnitPrice,'
            +'  ItemGroup__r.Product2Id,'
            +'  ListPriceDiscount__r.OrderLineType__c,'
            +'  ListPriceDiscount__r.Rate__c,'
            +'  Opportunity.Account.CustomerDiscountGroup__c,'
            +'  Opportunity.Account.OperatingCompany__c,'
            +'  Opportunity.Account.Name,'
            +'  Opportunity.AccountId,'
            +'  Product2.ProductDiscountGroup__c,'
            +'  Product2.CustomPricingAllowed__c,'
            +'  Product2.name,'
            +'  Product2.OrderLineType__c,'
            +'  Product2.ProductRateGroup__c,'
            +'  Product2.Renewable__c'
            +' from OpportunityLineItem where OpportunityId =:curOrderId order by createddate ASC';

            OpportunityLineItem[] lst_OpportunityLineItem =  Database.query(querystr);
            system.debug('**Order_SoqlFactory.returnOpportunityLine :Size**'+lst_OpportunityLineItem.size());


            return lst_OpportunityLineItem;

}

Public static List<ImportOrder__c> returnImportOrders(String Type,List<Id> OrderId,Set<String> Set_ExternalOrderId,Set<String> Set_ImportOrderId){

    String Querystr;
    Querystr =  'Select id,' 
    +'  ExternalOrderId__c,'
    +'  Error__c,'
    +'  itemGroupId__c,'
    +'  LineItemType__c,'
    +'  NetSalesPrice__c,'
    +'  OrderProduct__c,'
    +'  ProductId__c,'
    +'  OrderProduct__r.Product2Id,'
    +'  quantity__c,'
    +'  Status__c '
    +'  From ImportOrder__c where ';

     if(Type == 'ImportOrderItemGroupUpdate'){
        Querystr += 'ExternalOrderId__c in: Set_ExternalOrderId AND ProductId__c != null AND id not in: Set_ImportOrderId';
     }
     else if(Type == 'ItemGroupSweeperQueueable'){
        Querystr += 'Order__c in: OrderId AND OrderProduct__c != null';
     }
   
    ImportOrder__c[] lst_ImportOrder =  Database.query(querystr);
    system.debug('**Order_SoqlFactory.returnImportOrders :Size**'+lst_ImportOrder.size());


    return lst_ImportOrder;

}
    
}