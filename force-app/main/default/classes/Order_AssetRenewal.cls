public with sharing class Order_AssetRenewal {
    
    
    
    @auraenabled
    Public static void RenewAssets(){
        
        
        /*
        asset[] lstAssets = [Select id,PriceBook__c,LastRenewalUpdate__c,ListPrice__c,Contract__c,Contract__r.Indexation__c,CurrencyIsoCode,Reference__c,RenewalRunDate__c,DiscountedPrice__c,ManualDiscountPercent__c,ManualDiscountValue__c,
                                    PriceBook__r.FollowUpPriceBook__c,Product2.LicenseDuration__c,Product2.OrderLineType__c,RenewalDate__c,
                                    Account.DigitalActivationEmail__c ,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,OrderLineType__c,
                                    RenewalTerm__c,IsUpForRenewal__c,AccountId,PricingMethod__c,BillToAccount__r.ShippingCostMethod__c,ManualDiscount__c,
                                    BillToAccount__r.PaymentMethod__c,BillToAccount__r.CustomerDiscountGroup__c,Account.CustomerDiscountGroup__c,
                                    Price,Quantity, BillToAccount__c,BillToAccount__r.OperatingCompany__c,Account.OperatingCompany__c,DigitalActivationEMail__c,
                                    ApplyIndexationPercentage__c, IndexationPercentage__c, Product2.CustomPricingAllowed__c,Product2Id,BillToAccount__r.NetsuiteInternalId__c,Account.NetsuiteInternalId__c, Account.NumberofStudents__c,ShipToAttentionOf__c,
                                    BillToAccount__r.ShippingStreet,BillToAccount__r.ShippingPostalCode,BillToAccount__r.ShippingCountry,BillToAccount__r.ShippingCity,
                                    BillToAccount__r.BillingStreet,BillToAccount__r.BillingPostalCode,BillToAccount__r.BillingCountry,BillToAccount__r.BillingCity,
                                    Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.Type__c
                                    from asset 
                                    where 
                                    (Product2Id !=: null AND BillToAccount__c !=: null AND PricingMethod__c !=: null )
                                    AND((
                                        (CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)
                                        AND (
                                            ((RenewalDate__c  =: RenewalDay AND RenewalRunDate__c =: null) OR RenewalRunDate__c =: CurrrentDay OR RenewalDate__c  <=: RenewalDay)
                                            
                                            AND 
                                            (
                                                QuantityUpdateCheckYearly__c =: false 
                                                OR(QuantityUpdateCheckYearly__c =: True  AND QuantityStartDate__c <=:CurrrentDay AND QuantityEndDate__c >=:CurrrentDay  )
                                            )
                                            
                                        )
                                        AND LastRenewalUpdate__c !=: CurrrentDay 
                                        AND AutomatedRenewProcess__c =: true 
                                        //AND Contract__c =:null
                                        AND Product2.Type__c != 'Item Group'
                                    )
                                    OR(
                                        AssetRenewalTrigger__c =: true
                                        AND Product2.Type__c != 'Item Group'
                                    )

                                    )
                                    ];
        */
        String Querystr = Order_SoqlFactory.returnasset('renewal',null,null);
        system.debug('**Order_SoqlFactory.Order_AssetRenewal.Querystr**'+Querystr);
        Date CurrentDay = system.today();
        Date RenewalDay = system.today(); 
        asset[] lstAssets = Database.query(Querystr);

        system.debug('**Order_SoqlFactory.Order_AssetRenewal.lstAssets**'+lstAssets);
 
        if(lstAssets.size()==1){
            Initiate_Order_AssetRenewal(lstAssets,CurrentDay,RenewalDay);
       }                             
       else if(lstAssets.size()>1){
        Order_Batch_AccountswithRenwalAssets  AssetRenewal = new Order_Batch_AccountswithRenwalAssets();
        database.executebatch(AssetRenewal ,500);
       }     
       

      
       
    }
    
    
    Public static void Initiate_Order_AssetRenewal(asset[] lstAssetInit,Date CurrrentDay,Date RenewalDay){

        List<OrderItem> lstOrderItem = new List<OrderItem>();
        List<ErrorLog__c> lstErrorLog = new List<ErrorLog__c>();          
        List<Asset> lst_AssetErrorLog = new List<Asset>();

        Map<String,String> Map_SwapSuccProductId = new Map<String,String>();        
        Map<String,String> Map_SwapSuccPBEId = new Map<String,String>();
        
        Map<String,String> Map_PriceBook = new Map<String,String>();
        Map<String,String> Map_BillTOPB = new Map<String,String>();
        Map<String,String> Map_PBBIllTo = new Map<String,String>();
        

        Map<String,String> Map_PBShipTo = new Map<String,String>();
        Map<String,String> Map_ShipToCount = new Map<String,String>();
        Map<String,Decimal> Map_PBIndexation = new Map<String,Decimal>(); 
        Map<String,Decimal> Map_MultiShipTo = new Map<String,Decimal>();

        Map<String,String> Map_ShipToNetsuiteId = new Map<String,String>();
        Map<String,String> Map_OperatingCompany = new Map<String,String>();

        Map<String,String> Map_PricingMethod = new Map<String,String>();
        Map<String,String> Map_ShippingCostMethod = new Map<String,String>();
        Map<String,String> Map_PaymentMethod = new Map<String,String>();
        Map<String,String> Map_Contract = new Map<String,String>();
        Map<String,Decimal> Map_OrderLineCount = new Map<String,Decimal>();
        Map<String,Date> Map_OrderDate = new Map<String,Date>();
        Map<String,Date> Map_RenwalRunDate = new Map<String,Date>(); 
        Map<String,String> Map_ShippingStreet = new Map<String,String>();
        Map<String,String> Map_ShippingPostalCode = new Map<String,String>();
        Map<String,String> Map_ShippingCountry = new Map<String,String>();
        Map<String,String> Map_ShippingCity = new Map<String,String>();
        Map<String,String> Map_ShipToAttentionOf = new Map<String,String>();
        List<OrderShipto__c> lstOrderShipto = new List<OrderShipto__c>();
        List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
        Map<String,String> Map_Sub = new Map<String,String>();
        Map<String,String> Map_Netsuite = new Map<String,String>();
        
        Map<String,Boolean> Map_ProdCustomPricing = new Map<String,Boolean>();
        Map<String,String> Map_ProdType = new Map<String,String>();
        Map<String,String> Map_ProdLicenseDuration = new Map<String,String>();
        Map<String,String> Map_ProductId = new Map<String,String>();
        Map<String,String> Map_BillingStreet = new Map<String,String>();
        Map<String,String> Map_BillingPostalCode = new Map<String,String>();
        Map<String,String> Map_BillingCountry = new Map<String,String>();
        Map<String,String> Map_BillingCity = new Map<String,String>();
        Map<String,Boolean> Map_ShipComplete = new Map<String,Boolean>();
        Map<String,String> Map_PBE = new Map<String,String>();
        Map<String,Decimal> Map_PBEUnitPrice = new Map<String,Decimal>();
        Map<String,String> Map_CurrencyIsoCode = new Map<String,String>();
        Map<String,List<Asset>> Map_AssetPricingMethod = new Map<String,List<Asset>>();
       
        Set<String> Set_BillTo = new Set<String>(); 
        Set<String> Set_ShipTo = new Set<String>();
        Set<String> Set_OperatingCompany = new Set<String>();
        Set<String> Set_PriceBook = new Set<String>();
        Set<String> Set_ProductId = new Set<String>();
        Set<String> Set_SuccProductId = new Set<String>();
        Set<String> Set_Sub = new Set<String>();
        Set<String> Set_ProductActive = new Set<String>();
              
        Date earliestRenewalDate;
        String PricebookPricingMethod;
        String PBId;
        
        List<asset> lstAssets = new List<asset>();

        for(asset ass:lstAssetInit){

            if(ass.CancellationDate__c == null || (ass.CancellationDate__c != null && ass.CancellationDate__c > ass.RenewalDate__c)){
                Map_OrderDate.put(ass.PriceBook__c,ass.RenewalDate__c);

                Set_PriceBook.add(ass.PriceBook__c);
                Set_ProductId.add(ass.Product2Id);
            
                if(ass.Product2.IsSuccessorItemActive__c == true && ass.Product2.SuccessorItem__c != null && ass.Product2.SuccessorItem__r.IsActive == true){
                    Set_SuccProductId.add(ass.Product2.SuccessorItem__c);                
                    Map_SwapSuccProductId.put(ass.Product2Id,ass.Product2.SuccessorItem__c);
                    Map_SwapSuccPBEId.put(ass.Product2.SuccessorItem__c,ass.Product2Id);
                }
                lstAssets.add(ass);
            } 
        }    
      
        Pricebook2[] lstPriceBook =   [Select id,IsActive,StartDate__c,EndDate__c,FollowUpPriceBook__r.StartDate__c,FollowUpPriceBook__r.EndDate__c, FollowUpPriceBook__c,IndexationPercentage__c,FollowUpPriceBook__r.IndexationPercentage__c,ShippingComplete__c from Pricebook2 where id in:Set_PriceBook];
 
        Set_PriceBook = new Set<String>();
        for(Pricebook2 pbe:lstPriceBook){
                                
            if(pbe.FollowUpPriceBook__c != null && Map_OrderDate.get(pbe.id)>= pbe.FollowUpPriceBook__r.StartDate__c && Map_OrderDate.get(pbe.id) <= pbe.FollowUpPriceBook__r.EndDate__c ){                
                Map_PriceBook.put(pbe.id,pbe.FollowUpPriceBook__c);
                Map_PBIndexation.put(pbe.FollowUpPriceBook__c,pbe.FollowUpPriceBook__r.IndexationPercentage__c);
                Set_PriceBook.add(pbe.FollowUpPriceBook__c);
                Map_ShipComplete.put(pbe.FollowUpPriceBook__c,pbe.ShippingComplete__c);
            }
            else{
                Map_PriceBook.put(pbe.id,pbe.id);
                Map_PBIndexation.put(pbe.id,pbe.IndexationPercentage__c);
                Set_PriceBook.add(pbe.id);
                Map_ShipComplete.put(pbe.id,pbe.ShippingComplete__c);
            }
  
        }
       


        List<PricebookEntry> ProductsbyPriceBook = new List <PricebookEntry>([Select id,Pricebook2Id,	Price__r.ListRate__c, Product2.name,Product2.SoldInSegment__c, Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive, Product2.QuantitySelectionType__c,Product2.ProductRateGroup__c,productcode,Product2Id,unitprice from PricebookEntry where Pricebook2Id in:Set_Pricebook AND (Product2Id in: Set_ProductId OR Product2Id in: Set_SuccProductId) AND IsActive =:true]); 
        
        List<PricebookEntry> ProductsbyPriceBookSuccessor = new List <PricebookEntry>([Select id,Pricebook2Id,	Price__r.ListRate__c, Product2.name,Product2.SoldInSegment__c, Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive, Product2.QuantitySelectionType__c,Product2.ProductRateGroup__c,productcode,Product2Id,unitprice from PricebookEntry where Pricebook2Id in:Set_Pricebook AND Product2Id in: Set_SuccProductId AND IsActive =:true]); 
        
        Set_SuccProductId = new Set<String>();
        for(PricebookEntry pbe:ProductsbyPriceBookSuccessor){
            Set_SuccProductId.add(pbe.Product2Id);
        }

        
        

//ERROR IF ASSET PRODUCT NOT IN FOLLOW UP PRICEBOOK

        
        system.debug('**Order_AssetRenewal:  ProductsbyPriceBook: size**'+ProductsbyPriceBook.size());
        system.debug('**Order_AssetRenewal: Map_SwapSuccProductId**'+Map_SwapSuccProductId);
        
        Map_OrderDate = new Map<String,Date>();
        for(PricebookEntry pbe:ProductsbyPriceBook){

            system.debug('**Order_AssetRenewal:  pbe.Product2Id**'+pbe.Product2Id);
            PBId = pbe.Pricebook2Id;

            //Product has active successor item (required for use) - use the product to populate the successor item, don't do anything with successor item
            //Excludes Original Product that has a successor in the loop. If Successor in
            if(Set_SuccProductId.contains(Map_SwapSuccProductId.get(pbe.Product2Id))){                
                system.debug('**Order_AssetRenewal: Set_SuccProductId**'+Set_SuccProductId.contains(Map_SwapSuccProductId.get(pbe.Product2Id))); 
            }
            /*
            else if(Map_SwapSuccProductId.get(pbe.Product2Id) != null){ 
                //Possible delete of this since a successor must be in Pricebook. 
                //If this is reached then it means there is successor not in the PB which will cause an error.
               
                PBId += Map_SwapSuccPBEId.get(pbe.Product2Id);
                
              //Can't use the success product with old PBE
                Map_PBE.put(PBId,pbe.id);

                if(pbe.Price__r.ListRate__c != null){               
                    Map_PBEUnitPrice.put(PBId,pbe.Price__r.ListRate__c); 
                }
                else{
                    Map_PBEUnitPrice.put(PBId,pbe.unitprice);  
                }

                Set_ProductActive.add(pbe.Product2Id);
            }*/

            else{ // No successor or Active Successor Item
                PBId += pbe.Product2Id;
                Map_PBE.put(PBId,pbe.id);

                if(pbe.Price__r.ListRate__c != null){               
                    Map_PBEUnitPrice.put(PBId,pbe.Price__r.ListRate__c);  
                }
                else{
                    Map_PBEUnitPrice.put(PBId,pbe.unitprice);  
                }

                Set_ProductActive.add(pbe.Product2Id);
            }
            
            
            
            
         //DEL   Set_Product.add(pbe.Pricebook2Id);
        }
        system.debug('**Order_AssetRenewal: Set_ProductActive**'+Set_ProductActive);
        system.debug('**Order_AssetRenewal: Map_PBE**'+Map_PBE);
        system.debug('**Order_AssetRenewal: lstAssets: Size**'+lstAssets.size());

        Integer i=0;

    //DEL    Set<String> Set_OrderLineType = new Set<String>();
    //DEL    Set<String> Set_ProductDiscountGroup = new Set<String>();
   //DEL     Set<String> Set_CustomerDiscountGroup = new Set<String>();
   //DEL Set<String> Set_Prod  = new Set<String>();
  //DEL Set<String> Set_Product = new set<String>();
  // DEL Map<String,List<String>> Map_PriceProductType = new Map<String,List<String>>();
//SUM QUANITY CALCULATION FOR LPD REMOVE
//   Map<String,Decimal> Map_StudentNoShipTotal = new Map<String,Decimal>();
        //User Number/quantity record must exist with asset relation
        

        for(asset ass:lstAssets){
           
            string AccPB;
            
            AccPB = ass.BillToAccount__c;
            AccPB += Map_PriceBook.get(ass.PriceBook__c);
            AccPB += ass.PricingMethod__c;
            

            if(ass.Contract__c != null){
                AccPB += ass.Contract__c;
            }

            if(Map_OrderLineCount.get(AccPB) == null){
                Map_OrderLineCount.put(AccPB,1);
            }
            else{
                Map_OrderLineCount.put(AccPB,Map_OrderLineCount.get(AccPB)+1);
            }


            String ProductId;
            if(Set_ProductActive.contains(Map_SwapSuccProductId.get(ass.Product2Id))){
                ProductId = Map_SwapSuccProductId.get(ass.Product2Id);
                Map_ProductId.put(ass.Product2Id,ProductId);
                Map_ProdLicenseDuration.put(ass.Product2Id,ass.Product2.SuccessorItem__r.LicenseDuration__c);
                Map_ProdType.put(ass.Product2Id,ass.Product2.SuccessorItem__r.Type__c);
                Map_ProdCustomPricing.put(ass.Product2Id,ass.Product2.SuccessorItem__r.CustomPricingAllowed__c);
                                    
            }
            else if (Set_ProductActive.contains(ass.Product2Id)){
                ProductId = ass.Product2Id; 
                Map_ProductId.put(ass.Product2Id,ass.Product2Id);               
                Map_ProdLicenseDuration.put(ass.Product2Id,ass.Product2.LicenseDuration__c);
                Map_ProdType.put(ass.Product2Id,ass.Product2.Type__c);
                Map_ProdCustomPricing.put(ass.Product2Id,ass.Product2.CustomPricingAllowed__c);
            }
            else{
                ProductId = 'Inactive';
            }


            system.debug('**Order_AssetRenewal: Before IF: ProductId**'+ProductId);

            if(ass.BillToAccount__c != null && Map_PriceBook.get(ass.PriceBook__c) != null && ass.PricingMethod__c != null && Set_ProductActive.contains(ProductId) /*ass.Product2Id*/ ){
                system.debug('**Order_AssetRenewal: IN IF**');

                
                
              //DEL  Set_OrderLineType.add(ass.Product2.OrderLineType__c);
             //DEL   Set_ProductDiscountGroup.add(ass.Product2.ProductDiscountGroup__c);
             //DEL   Set_CustomerDiscountGroup.add(ass.BillToAccount__r.CustomerDiscountGroup__c);
             //DEL  Set_Prod.add(ass.Product2Id); 
             Set_OperatingCompany.add(ass.BillToAccount__r.OperatingCompany__c);

                Set_BillTo.add(ass.BillToAccount__c);
                

                Set_Sub.add(ass.BillToAccount__c);
                Set_Sub.add(ass.AccountId);

                Map_OperatingCompany.put(AccPB, ass.BillToAccount__r.OperatingCompany__c);
                   
                Map_ShippingStreet.put(AccPB, ass.BillToAccount__r.ShippingStreet);
                Map_ShippingPostalCode.put(AccPB, ass.BillToAccount__r.ShippingPostalCode);
                Map_ShippingCountry.put(AccPB, ass.BillToAccount__r.ShippingCountry);
                Map_ShippingCity.put(AccPB, ass.BillToAccount__r.ShippingCity);

                Map_BillingStreet.put(AccPB, ass.BillToAccount__r.BillingStreet);
                Map_BillingPostalCode.put(AccPB, ass.BillToAccount__r.BillingPostalCode);
                Map_BillingCountry.put(AccPB, ass.BillToAccount__r.BillingCountry);
                Map_BillingCity.put(AccPB, ass.BillToAccount__r.BillingCity);

                Map_ShipToAttentionOf.put(AccPB, ass.ShipToAttentionOf__c);

                Map_BillTOPB.put(AccPB, Map_PriceBook.get(ass.PriceBook__c));
                Map_PBBIllTo.put(AccPB,ass.BillToAccount__c);
                Map_CurrencyIsoCode.put(AccPB,ass.CurrencyIsoCode);
                
                
                if(ass.Contract__c != null){
                    Map_Contract.put(AccPB,ass.Contract__c);
                }
                
                if(earliestRenewalDate == null){
                    earliestRenewalDate = ass.RenewalDate__c;
                }
                else if(earliestRenewalDate < ass.RenewalDate__c){
                    earliestRenewalDate = ass.RenewalDate__c;
                }

                if(Map_OrderDate.get(AccPB)==null || Map_OrderDate.get(AccPB)>ass.RenewalDate__c){
                    Map_OrderDate.put(AccPB,ass.RenewalDate__c);
                    
                }
                Map_RenwalRunDate.put(ass.id,ass.RenewalDate__c);

                String multi;
                multi = AccPB+ ass.AccountId;

                
                if(!Set_ShipTo.contains(multi)){
                    Set_ShipTo.add(multi);
                    if(Map_MultiShipTo.get(AccPB)==null){
                        Map_MultiShipTo.put(AccPB,1);
                    }
                    else{
                        Map_MultiShipTo.put(AccPB,Map_MultiShipTo.get(AccPB)+1);
                    }                    
                }
                

                if(Map_MultiShipTo.get(AccPB) == 1 && Map_ShipToCount.get(AccPB) == null){
                    Map_ShipToCount.put(AccPB,ass.AccountId);
                    Map_ShipToNetsuiteId.put(AccPB,ass.Account.NetsuiteInternalId__c);
                }
                else if(Map_MultiShipTo.get(AccPB)>1){
                    Map_ShipToCount.put(AccPB,'MULTIPLE');
                }
                

                Map_PricingMethod.put(ass.BillToAccount__c,ass.PricingMethod__c);  //ass.BillToAccount__r.PricingMethod__c
              
                Map_ShippingCostMethod.put(ass.BillToAccount__c,ass.BillToAccount__r.ShippingCostMethod__c); 
                Map_PaymentMethod.put(ass.BillToAccount__c,ass.BillToAccount__r.PaymentMethod__c);
             
               PricebookPricingMethod = Map_PriceBook.get(ass.PriceBook__c);
               PricebookPricingMethod += ass.PricingMethod__c;
                

               if(Map_AssetPricingMethod.get(AccPB)==null){
                
                    List<Asset> lst_PriceAsset = new List<Asset>();
                    lst_PriceAsset.add(ass);

                    Map_AssetPricingMethod.put(AccPB,lst_PriceAsset);
               }
               else{
                    Map_AssetPricingMethod.get(AccPB).add(ass);
               }
               i++;
               //SUM QUANITY CALCULATION FOR LPD REMOVE
            /* 
               if(ass.PricingMethod__c == 'AccountStudents'){

                    if(Map_StudentNoShipTotal.get(AccPB)==null){                      
                        Map_StudentNoShipTotal.put(AccPB,ass.Account.NumberofStudents__c);
                    }
                    else{
                        Map_StudentNoShipTotal.put(AccPB,Map_StudentNoShipTotal.get(AccPB) + ass.Account.NumberofStudents__c);
                    }

               }
             */

               AccPB +=ass.AccountId;
                Map_PBShipTo.put(AccPB,  ass.AccountId);
            }
            else{
                //ERROR HANDLING FOR NO PRICEBOOK

                ErrorLog__c errorLog = new ErrorLog__c();
                errorLog.Errororigin__c = 'Apex';
                errorLog.RelatedToId__c = ass.id;
                errorLog.ExceptionMessage__c = 'Inactive Pricebook Entry on renewal';
                errorLog.ExceptionType__c = 'Inactive Pricebook Entry on renewal';
                lstErrorLog.add(errorLog);
                ass.RenewalMessage__c = 'Inactive Pricebook Entry on renewal';
                ass.AssetRenewalTrigger__c = false;
                lst_AssetErrorLog.add(ass);
            }
            
        }   


        


        system.debug('**Order_AssetRenewal: Map_BillTOPB**'+Map_BillTOPB);
        system.debug('**Order_AssetRenewal: Map_PBBIllTo**'+Map_PBBIllTo);

        system.debug('**Order_AssetRenewal: Size i*'+i);
        


//lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);

lst_AccSubMaps =  Order_SoqlFactory.returnAccountSubsidiary(Set_Sub);
system.debug('**Order_SoqlFactory.Order_AssetRenewal.lst_AccSubMaps :Size**'+lst_AccSubMaps.size());

Map_Sub = lst_AccSubMaps[0];
Map_Netsuite = lst_AccSubMaps[1];

Date CurDate = system.today();
                                       
Map<String,Decimal> Map_BillToPRod = new Map<String,Decimal>();      
List<Order> lst_Order = new List<Order>();
Decimal index=0;
Map<Decimal,List<OrderItem>> Map_OrderItems = new Map<Decimal,List<OrderItem>>();
OrderActivationRules__mdt[] OrderActivationRules = [Select Source__c, Status__c,OperatingCompany__c from OrderActivationRules__mdt where Source__c =:'B2B Salesforce Renewal' AND OperatingCompany__c in:Set_OperatingCompany];
 
Map<String,Boolean> Map_AutoActivate = new Map<String,Boolean>();




for(OrderActivationRules__mdt act:OrderActivationRules){
    
    if(act.Status__c == 'Active'){
        Map_AutoActivate.put(act.OperatingCompany__c,true);
    }
    else{
        Map_AutoActivate.put(act.OperatingCompany__c,false);
    }
}


            for(String BT:Map_PBBIllTo.keyset()){


                    String AssetPricingMethod;
                    if(BT.contains('AccountStudents')){
                        AssetPricingMethod = 'AccountStudents';
                    }
                    else if(BT.contains('OrderProductQuantity')){
                        AssetPricingMethod = 'OrderProductQuantity';
                    }
                    else if(BT.contains('ProductUsageBased')){
                        AssetPricingMethod ='ProductUsageBased';
                    }
                    else if(BT.contains('ProductDiscountGroupUsageBased') ){ 
                        AssetPricingMethod = 'ProductDiscountGroupUsageBased';
                    }
                        String ShippingCostMethod = Map_ShippingCostMethod.get(Map_PBBIllTo.get(BT)); 
                        String PaymentMethod = Map_PaymentMethod.get(Map_PBBIllTo.get(BT));


            Order NewOrder;
            if(Map_BillTOPB.get(BT) != null){

                       
                        NewOrder = new Order();
                        NewOrder.ContractId = Map_Contract.get(BT);
                        NewOrder.AccountId = Map_PBBIllTo.get(BT); 

                        if(Map_OrderDate.get(BT) != null){
                            NewOrder.EffectiveDate = Map_OrderDate.get(BT);
                            NewOrder.ShipByDate__c = Map_OrderDate.get(BT);
                        }
                        else{
                            NewOrder.EffectiveDate = system.today();
                            NewOrder.ShipByDate__c = system.today();
                        }

                        
                        
                   
                        NewOrder.Pricebook2Id = Map_BillTOPB.get(BT);

                        if(Map_ShipComplete.get(NewOrder.Pricebook2Id) != null){
                            NewOrder.ShipComplete__c = Map_ShipComplete.get(NewOrder.Pricebook2Id);
                        }
                        
                        NewOrder.Billto__c = Map_PBBIllTo.get(BT); 
                        NewOrder.Status = 'Draft';
                        NewOrder.PricingMethod__c = AssetPricingMethod;
                        NewOrder.ShippingCostMethod__c = ShippingCostMethod;
                        NewOrder.ShippingIndicationRule__c = null;
                        NewOrder.PaymentMethod__c = PaymentMethod;
                        NewOrder.Type = 'RenewalOrder';
                        NewOrder.Source__c = 'B2B Salesforce';
                        NewOrder.PaymentStatus__c = 'payment_pending'; 
                        NewOrder.PaymentMethodType__c = 'Invoice';   
                        NewOrder.CurrencyIsoCode = Map_CurrencyIsoCode.get(BT);
                        NewOrder.AccountSubsidiary__c =  Map_Sub.get(Map_PBBIllTo.get(BT));
                        NewOrder.NetSuiteIdAccountSubsidiary__c = Map_Netsuite.get(Map_PBBIllTo.get(BT));
                        NewOrder.OperatingCompany__c = Map_OperatingCompany.get(BT);
                        NewOrder.BillingStreet   = Map_BillingStreet.get(BT);
                        NewOrder.BillingPostalCode   = Map_BillingPostalCode.get(BT);
                        NewOrder.BillingCountry   = Map_Billingcountry.get(BT);
                        NewOrder.BillingCity   = Map_BillingCity.get(BT);                        
                        NewOrder.OrderImportLineCountSent__c = Map_OrderLineCount.get(BT);                      
                        NewOrder.ActivateforBatchProcessing__c = Map_AutoActivate.get(NewOrder.OperatingCompany__c);
                        
                        if(Map_ShipToCount.get(BT)=='MULTIPLE'){
                            NewOrder.MultipleShippingLocations__c= true;
                        }
                        else{
                            NewOrder.Shipto__c = Map_ShipToCount.get(BT);
                            NewOrder.ShipToAttentionOf__c = Map_ShipToAttentionOf.get(BT);
                            NewOrder.NetSuiteIdShiptoAccount__c = Map_ShipToNetsuiteId.get(BT); 
                            
                            NewOrder.ShippingStreet   = Map_ShippingStreet.get(BT);
                            NewOrder.ShippingPostalCode   = Map_ShippingPostalCode.get(BT);
                            NewOrder.ShippingCountry   = Map_ShippingCountry.get(BT);
                            NewOrder.ShippingCity   = Map_ShippingCity.get(BT);
                        }
                        
                        String OrderError = null;
                        try{

                            Insert NewOrder;
                            lst_Order.add(NewOrder);
                                                  
                        }
                        catch(exception e){
                            ErrorLog__c errorLog = new ErrorLog__c();
                            errorLog.Errororigin__c = 'Apex';
                            errorLog.RelatedToId__c = Map_PBBIllTo.get(BT);
                            errorLog.ExceptionMessage__c = e.getMessage();
                            errorLog.ExceptionType__c = e.getMessage();
                            lstErrorLog.add(errorLog);

                            OrderError = e.getMessage();
                        }
                        index++;
                        system.debug('**Order_AssetRenewal: NewOrder 1**index**'+index);
                        
             
              
                        Map<String,String> Map_RateId;
                        
                        String type;
 
                        Decimal NumberofStudents;
                        String shiptoAcc;
          
                        Set<String> Set_AddUniqueShip = new Set<String>();
               
                List<OrderItem> lst_OrderItemAsset = new  List<OrderItem>();       
                for(Asset ass:Map_AssetPricingMethod.get(BT)){
                        
                            shiptoAcc = BT + ass.AccountId;
                          //  system.debug('***Order_AssetRenewal:Add Order: Map_PBShipTo**'+Map_PBShipTo.get(shiptoAcc));
                          //  system.debug('***Order_AssetRenewal:Add Order: Map_ShipAsset**'+ass.AccountId);
                         //   system.debug('***Order_AssetRenewal:Add Order: Map_BillTOPB.get(PB)**'+Map_BillTOPB.get(BT));
                         //   system.debug('***Order_AssetRenewal:Add Order: PriceBook**'+ass.PriceBook__c);
                         //   system.debug('***Order_AssetRenewal:Add Order: FollowUpPriceBook**'+ass.PriceBook__r.FollowUpPriceBook__c);

                            

                                if(Map_PBShipTo.get(shiptoAcc) == ass.AccountId && (ass.PriceBook__c == Map_BillTOPB.get(BT) || ass.PriceBook__r.FollowUpPriceBook__c == Map_BillTOPB.get(BT))){
                                  
                                    String BilltoProd;
                                   
                                    system.debug('**Order_AssetRenewal: Add Order: IN 1**');

                                   
                                    PBId = NewOrder.Pricebook2Id;
                                    PBId += Map_ProductId.get(ass.Product2Id);

                                    system.debug('**Order_AssetRenewal: PBId**'+PBId);

                                    if(Map_PBE.get(PBId) != null){
                                     
                                      system.debug('**Order_AssetRenewal: Add Order: IN 2 **');
                                    OrderItem item = new OrderItem();
                                    item.ShipToAccount__c = ass.AccountId;

                                    //Add Ship tos    
                                    if(!Set_AddUniqueShip.Contains(ass.AccountId)){
                                        OrderShipto__c OrderShipto = new OrderShipto__c();
                                        OrderShipto.Order__c = NewOrder.id;
                                        OrderShipto.ShiptoAccount__c =ass.AccountId;
                                        lstOrderShipto.add(OrderShipto);
                                        Set_AddUniqueShip.add(ass.AccountId);
                                        system.debug('**Order_AssetRenewal: Add Order: ass.AccountId**'+ass.AccountId);
                                    }
                                    
                                        

                                    item.Account__c = Map_PBBIllTo.get(BT);
                                    item.AccountSubsidiary__c = Map_Sub.get(ass.AccountId);

                                    item.NetsuiteInternalId__c = ass.Account.NetsuiteInternalId__c;
                                    item.NetSuiteIdShiptoAccount__c = ass.Account.NetsuiteInternalId__c;
                                    item.NetSuiteIdBilltoAccount__c = ass.BillToAccount__r.NetsuiteInternalId__c;                              
                                    item.ShipToAttentionOf__c = ass.ShipToAttentionOf__c;

                                        
                                    /* 
                                    if(Map_PriceProductType.get(ass.Product2Id) == null){
                                        List<String> PriceProductType = new List<String>();
                                        PriceProductType.AddAll(ass.Product2.OrderLineType__c.Split(';'));
                                        Map_PriceProductType.put(ass.Product2Id,PriceProductType);
                                    }
                                    */
                                    
                                    if(Map_PBEUnitPrice.get(PBId) != null && (ass.Contract__c ==null || ((ass.Contract__c !=null) && ass.Contract__r.Indexation__c == true ))){
                                        item.unitprice = Map_PBEUnitPrice.get(PBId);
                                        
                                        if(Map_PBIndexation.get(Map_BillTOPB.get(BT)) != null && Map_ProdCustomPricing.get(ass.Product2Id) != null && Map_ProdCustomPricing.get(ass.Product2Id) == true && ass.ApplyIndexationPercentage__c == true){
                                           
                                            ass.IndexationPercentage__c =   Map_PBIndexation.get(Map_BillTOPB.get(BT));
                                            item.ComponentListPrice__c = ass.ListPrice__c + (ass.ListPrice__c * (ass.IndexationPercentage__c/100));
                                            item.unitprice = item.ComponentListPrice__c;
                                        }   
                                         
                                    }
                                    else{
                                        item.unitprice =ass.Price;
                                        item.ComponentListPrice__c = ass.ListPrice__c;
                                    }
                                
                                    
                                   if(ass.ManualDiscount__c != null && ass.ManualDiscount__c.contains('Recurring')){ 
                                        if(ass.ManualDiscount__c != null && ass.ManualDiscountValue__c != null && (ass.ManualDiscount__c.contains('Amount'))){
                                            item.ManualDiscount__c = ass.ManualDiscount__c;
                                            item.ManualDiscountValue__c = ass.ManualDiscountValue__c;
                                            item.UnitPrice = item.UnitPrice-item.ManualDiscountValue__c;  
                                            
                                        }
                                        else if(ass.ManualDiscount__c != null && ass.ManualDiscountPercent__c != null && (ass.ManualDiscount__c.contains('Percentage'))){
                                            item.ManualDiscount__c = ass.ManualDiscount__c;
                                            item.ManualDiscountPercent__c = ass.ManualDiscountPercent__c;
                                            item.UnitPrice = item.UnitPrice-(item.UnitPrice*(Item.ManualDiscountPercent__c/100));
                                            
                                        } 
                                    }                                
                                 

                                    item.PricebookEntryId = Map_PBE.get(PBId);
                                    item.OrderStatus__c = 'Draft';
                                    item.OrderId = NewOrder.id;
                                    item.OrderLineType__c = ass.OrderLineType__c; 

                                    item.Renewable__c= true;
                                    item.Asset__c = ass.id;
                                   // item.ProductType__c = ass.Product2.Type__c;
                                   item.ProductType__c = Map_ProdType.get(ass.Product2Id);
                                     

                                    
                                    item.orderImportNumber__c = 'Asset Renewal';
                                    
                                    if(item.ProductType__c =='Non-inventory Item' && ass.DigitalActivationEmail__c !=null){                                       
                                            item.DigitalActivationEMail__c =  ass.DigitalActivationEmail__c;                                                       
                                    }
                                    else if(item.ProductType__c =='Non-inventory Item'){
                                        item.DigitalActivationEMail__c = ass.Account.DigitalActivationEmail__c; 
                                        ass.DigitalActivationEMail__c = ass.Account.DigitalActivationEmail__c;
                                    }
                                    else{
                                        item.DigitalActivationEMail__c = ass.Account.DigitalActivationEmail__c; 
                                    }

                                    item.StartDate__c = ass.RenewalDate__c; 
                                    item.ServiceDate = ass.RenewalDate__c;


                                    //NB ADd licence duration (ie number of months) instead of renewal term
                                    if(Map_ProdLicenseDuration.get(ass.Product2Id) != null && ass.RenewalDate__c != null){
                                        item.EndDate  = ass.RenewalDate__c.addMonths(integer.valueof(Map_ProdLicenseDuration.get(ass.Product2Id)))-1 ; //system.today()
                                        ass.PreviousRenewalDate__c = ass.RenewalDate__c;
                                        ass.RenewalDate__c = ass.RenewalDate__c.addMonths(integer.valueof(Map_ProdLicenseDuration.get(ass.Product2Id))) ; //system.today()
                                    }
                                    if(ass.RenewalRunDate__c != null && Map_ProdLicenseDuration.get(ass.Product2Id) != null){
                                        ass.PreviousRenewalDate__c = ass.RenewalRunDate__c;
                                        ass.RenewalRunDate__c = ass.RenewalRunDate__c.addMonths(integer.valueof(Map_ProdLicenseDuration.get(ass.Product2Id))) ;
                                        
                                    }
                                    else{
                                        ass.RenewalRunDate__c = ass.RenewalDate__c;
                                    }
                                    item.CustomerReference__c = ass.Reference__c;
                                    
                                    
                                    //NETSUITE QUANTITY
                                    item.Quantity = ass.Quantity;
                                    item.NetsuiteQuantity__c = ass.Quantity;



                                    if(OrderError == null){
                                        lst_OrderItemAsset.add(item);
                                        system.debug('**Order_AssetRenewal: NewOrder **unitprice**'+item.unitprice);
                                    
                                        system.debug('**Order_AssetRenewal: NewOrder MAP **index**'+index);
                                         Map_OrderItems.put(index,lst_OrderItemAsset);
                                         ass.LastRenewalUpdate__c = system.today();
                                         ass.AssetRenewalTrigger__c = false;
                                         ass.PriceBook__c = Map_BillTOPB.get(BT);
                                         ass.RenewalMessage__c = '';
                                        ass.Product2Id = Map_ProductId.get(ass.Product2Id);
                                         ass.EndDate__c = ass.RenewalDate__c - 1;
            
                                    }
                                    else{
                                        
                                        system.debug('**Order_AssetRenewal: Error **RenewalDate**'+ass.RenewalDate__c);
                                        system.debug('**Order_AssetRenewal: Error **RenewalRunDate**'+ass.RenewalRunDate__c);
                                        
                                        ass.RenewalMessage__c = OrderError;
                                        ass.AssetRenewalTrigger__c = false;
                                        ass.RenewalDate__c = ass.RenewalDate__c.addMonths(-integer.valueof(ass.Product2.LicenseDuration__c)) ;
                                        ass.RenewalRunDate__c = ass.RenewalRunDate__c.addMonths(-integer.valueof(ass.Product2.LicenseDuration__c));
                                        lst_AssetErrorLog.add(ass);
                                    }
                                    

                                    }
                                }
                        }

          
                        
                    }
                     

            }    
        system.debug('**Order_AssetRenewal: NewOrder OUT **index**'+index);
        
        try {
            
            Insert lstOrderShipto;


            if(lst_Order.size()>0){
                //SUM QUANITY CALCULATION FOR LPD REMOVE
                // System.enqueueJob(new Order_AssetRenewalLineItemQueueable(lst_Order,Map_OrderItems,lstAssets,Map_BillToPRod,Map_PriceProductType,1));

                //System.enqueueJob(new Order_AssetRenewalLineItemQueueable(lst_Order,Map_OrderItems,lstAssets,Map_PriceProductType,1));
            
                System.enqueueJob(new Order_AssetRenewalLineItemQueueable(lst_Order,Map_OrderItems,lstAssets,1));
            
            }
            

            if(lstErrorLog.size()>0){
               insert lstErrorLog;
               update lst_AssetErrorLog;
            }

             if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
              }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            if(lstErrorLog.size()>0){
                insert lstErrorLog;
                update lst_AssetErrorLog;
             }
            system.debug('**Order_AssetRenewal" Add Order: Error**'+e.getMessage());
            HandleCustomException.LogException(e,lstOrderShipto[0].id);
                
        }
        
        

        
}
/*
public static Map<String,Decimal> returnUsageBasedAssets(asset[] lstAssets){

   
        Map<String,Decimal> Map_BillToPRod = new Map<String,Decimal>();                            
        for(asset ass:lstAssets){

            if(ass.Quantity!= null){
                String BilltoProd;
                BilltoProd = ass.BillToAccount__c;
                
                if(Map_BillToPRod.get(BilltoProd)==null){
                    Map_BillToPRod.put(BilltoProd,ass.Quantity);
                }
                else{                
                        Map_BillToPRod.put(BilltoProd,Map_BillToPRod.get(BilltoProd)+ass.Quantity);      
                }

                BilltoProd += ass.Product2.ProductRateGroup__c; //  ProductDiscountGroup__c

                if(Map_BillToPRod.get(BilltoProd)==null){
                    Map_BillToPRod.put(BilltoProd,ass.Quantity);
                }
                else{
                    Map_BillToPRod.put(BilltoProd,Map_BillToPRod.get(BilltoProd)+ass.Quantity);      
                }
            }
           

            
           
        }
        system.debug('**BilltoProd Call**'+Map_BillToPRod);
        return Map_BillToPRod;
}
*/


}