public with sharing class Order_AssetsCreateOnOrderActivation implements Queueable{
    



    // turn into queueable
    // On complete call
    // bg_AllObjectInvocableHandler.AllObjectInvocableHandler(Set_ItemId);
    
    private Boolean CalledFromInvocable;
    
    Private Set<Id> ItemId;
    Private List<Id> ItemIdFullList;
    

    
    Public Order_AssetsCreateOnOrderActivation(List<Id> ItemIdFullList, Set<Id> ItemId,Boolean CalledFromInvocable){
        this.ItemIdFullList = ItemIdFullList;
        this.ItemId = ItemId;
        this.CalledFromInvocable = CalledFromInvocable;
   }

    Public Order_AssetsCreateOnOrderActivation(List<Id> ItemIdFullList, Set<Id> ItemId){
        this.ItemIdFullList = ItemIdFullList;
        this.ItemId = ItemId;
   }
    
  public void execute(System.QueueableContext qc) {
    processAssetsFromOrder(ItemIdFullList,ItemId,CalledFromInvocable);
  }   



  @invocablemethod
  Public static void createAssetsFromOrderHeader(List<Id> OrderId){

      OrderItem[] lstOrderItem = [Select id from OrderItem where OrderId in: OrderId AND Asset__c =: null];

        Set<Id> ItemId = new Set<Id>(new Map<Id, OrderItem>(lstOrderItem).keySet());
        List<Id> ItemIdFullList = new List<Id>(new Map<Id, OrderItem>(lstOrderItem).keySet());
      
        System.enqueueJob(new Order_AssetsCreateOnOrderActivation(ItemIdFullList,ItemId,true));
  }

    public static void processAssetsFromOrder(List<Id> ItemIdFullList, Set<Id> ItemId,Boolean CalledFromInvocable){
        system.debug('**Order_AssetsCreateOnOrderActivation: 1**'+ CalledFromInvocable);

        if(ItemId.size()>0){

        
                    /*
                    OrderItem[] lstOrderItem = [Select id,Asset__c,Product2.EAN__c,Terms__c,Quantity,Order.Type,Order.CurrencyIsoCode,Order.ContractId,TrialStartDate__c,TrialEndDate__c,StartDate__c, Order.Pricebook2Id,Order.Pricebook2.Name,Order.Pricebook2.IndexationPercentage__c,UnitPrice,Order.Billto__c,Order.Source__c, EndDate,ManualDiscount__c,ManualDiscountPercent__c,
                                                        ListPrice,DiscountedPrice__c,ServiceDate,LicenseDuration__c,CreatedDate,ShipToAccount__c,Renewable__c,AssetIdValidate__c,ShipToAttentionOf__c,
                                                        Product2.CustomPricingAllowed__c,ComponentListPrice__c,Product2.Method__c,OrderLineType__c,CustomerReference__c,Product2.Name,OperatingCompany__c,Order.EndDate,ManualDiscountValue__c,NetsuiteQuantity__c,Order.shipToAttentionOf__c,
                                                        Order.PricingMethod__c,Product2Id,ShipToAccount__r.DigitalActivationEmail__c, Product2.Type__c,DigitalActivationEMail__c,
                                                        Order.Hfdstructuur__c,Hfdstructuur__c                                    
                                                        From OrderItem where Id in:ItemId limit 200];     
                    */
                    Set<string> Set_string = new Set<String>();
                    for(Id  item:ItemId){
                        Set_string.add(item);
                    }  

                    OrderItem[] lstOrderItem =  Order_SoqlFactory.returnQueryOrderItems(Set_string,null,null,'AssetsCreateOnOrderActivation');
                    system.debug('**Order_SoqlFactory.Order_AssetsCreateOnOrderA.lstOrderItem :Size**'+lstOrderItem.size());                                    
                                                        
                                                                //!-- INFORMAT RENEWALS
                
                    Set<String> Set_Asset = new Set<String>();
                    Set<String> Set_BillTo = new Set<String>();
                    Set<String> Set_ShipTo = new Set<String>();
                    Set<String> Set_PricingMethod = new Set<String>();
                    List<Asset> lstNewAsset = new List<Asset>();
                    Set<string> Set_AssetCreate = new Set<string>();
                    
                    String ProdShipto;
                    Integer varIterator = 0;
                    String OrderType = 'Standard';

                    /*
                    if(lstOrderItem[0].Order.Type == 'RenewalOrder'){

                                OrderType = 'RenewalOrder';

                                for(OrderItem  item:lstOrderItem){
                                    //Set_Asset.add(item.Product2Id);
                                    Set_Asset.add(item.Asset__c);
                                    Set_BillTo.add(item.Order.Billto__c);
                                    Set_ShipTo.add(item.ShipToAccount__c);
                                    Set_PricingMethod.add(item.Order.PricingMethod__c);
                                }        

                                system.debug('**AssetCreation: Set Assets**'+Set_Asset);

                                system.debug('**AssetCreation: Set Assets**'+Set_Asset);

                                Asset[] ListOfAssets= [Select AccountCustomerNumber__c,EndDate__c,AccountId,AccountName__c,ActivationDate__c,AssetLevel,AutomatedRenewProcess__c,OrderLineType__c,
                                                            BillToAccount__c,BillToName__c,CancellationDate__c,CancellationReason__c,CancellationTrigger__c,Channel__c,
                                                            ContactId,Contract__c,CreatedById,CreatedDate,Crebocode__c,CurrencyIsoCode,CurrentEdition__c,CurrentMethod__c,
                                                            CurrentPublisher__c,Description,DigitalFactor__c,DiscountedPrice__c,Id,InstallDate,IsActive__c,ISBN__c,
                                                            IsBooklistPresent__c,IsCompetitorProduct,IsDeleted,IsInternal,IsUpForRenewal__c,LastRenewalUpdate__c,
                                                            LastViewedDate,Level__c,LicenseDuration__c,ListPrice__c,LocationTotalNumberofStudents__c,
                                                            ManualDiscountPercent__c,ManualDiscountValue__c,ManualDiscount__c,MethodCode__c,MethodName__c,
                                                            Method__c,Name,NumberofActiveUsers__c,OperatingCompany__c,OrderProduct__c,OwnerId,ParentId,Price,Product2.Type__c,DigitalActivationEmail__c,
                                                            PriceBook__c,PriceValidTillDate__c,PricingMethod__c,Product2Id,ProductClass__c,ProductCode,ProductFamilyType__c,
                                                            ProductFamily__c,PurchaseDate,Reference__c,Quantity,RecordTypeId,RecordTypeName__c,RenewalDate__c,RenewalTerm__c,
                                                            Unit__c,UsageEndDate
                                                            from Asset where Id in:Set_Asset AND BillToAccount__c in:Set_BillTo AND AccountId in:Set_ShipTo AND PricingMethod__c in: Set_PricingMethod];

                                                            //Product2Id in:Set_Asset
                                system.debug('**AssetCreation: ListOfAssets**'+ListOfAssets);
                                
                                
                            
                                Boolean addNewAsset;

                    
                                
                                for(OrderItem  item:lstOrderItem){                           
                                    addNewAsset = true;
                                    
                                        for(Asset ass:ListOfAssets){
                                                if(item.Asset__c == ass.Id && item.ShipToAccount__c == ass.AccountId && item.Order.PricingMethod__c ==  ass.PricingMethod__c ){
                                                    //item.Product2Id == ass.Product2Id
                                                    
                                                    system.debug('**AssetCreation: Product2Id**'+'*Item**'+item.Product2Id+'**ass**'+ass.Product2Id);
                                                    system.debug('**AssetCreation: Product2Id**'+'*Item**'+item.Product2Id+'**ass**'+ass.Product2Id);
                                                                                
                                                    ass.OrderLineType__c = item.OrderLineType__c;
                                                    //item.Asset__c = ass.Id;
                                                    ass.PriceBook__c = item.Order.Pricebook2Id;
                                                   // item.AssetIdValidate__c  = ass.Id;
                                                    ass.Description = 'Description';
                                                    
                                                    if(item.Product2.Type__c =='Non-inventory Item'){
                                                        if(ass.DigitalActivationEmail__c == null){
                                                            item.DigitalActivationEMail__c =  item.ShipToAccount__r.DigitalActivationEmail__c;
                                                        }
                                                        else{
                                                            item.DigitalActivationEMail__c =  ass.DigitalActivationEmail__c;
                                                        }                                                        
                                                    }

                                                    if(item.Order.Type == 'RegularOrder'){
                                                        ass.Quantity = ass.Quantity+item.Quantity;  
                                                        item.AssetIdValidate__c  = ass.Id;
                                                        item.Asset__c = ass.Id;

                                                        system.debug('**AssetCreation: Regular Order**');
                                                    }
                                                    else if(item.Order.Type == 'RenewalOrder'){
                                                        //ass.Quantity = item.Quantity;

                                                        //To manage Item Group components
                                                        
                                                        //NESTUITE QUANTITY
                                                        ass.Quantity = item.Quantity;
                                                    //   ass.Quantity = item.NetsuiteQuantity__c;
                                                    item.AssetIdValidate__c  = ass.Id;

                                                        ass.Price = item.UnitPrice;
                                                        ass.Description = 'Description';
                                                        
                                                        
                                                        
                                                        ass.ManualDiscount__c = item.ManualDiscount__c;
                                                        ass.ManualDiscountPercent__c = item.ManualDiscountPercent__c;
                                                        ass.ManualDiscountValue__c = item.ManualDiscountValue__c;
                                                        ass.ListPrice__c = item.ListPrice; 
                                                        ass.DiscountedPrice__c = item.DiscountedPrice__c;
                                                    
                                                        ass.LicenseDuration__c = item.LicenseDuration__c;
                                                        ass.Terms__c = item.Terms__c;
                                                        ass.PriceBook__c = item.Order.Pricebook2Id ;
                                                    
                                                        system.debug('**AssetCreation: Renewal Order**');


                                                        ass.RenewalDate__c = item.EndDate;

                                                    }
                                                    if(item.Order.shipToAttentionOf__c != null){
                                                        ass.ShipToAttentionOf__c = item.Order.shipToAttentionOf__c;
                                                    }
                                                    else{
                                                        ass.ShipToAttentionOf__c = item.ShipToAttentionOf__c;
                                                    }
                                                        
                                                    addNewAsset=false;
                                                }                        
                                        }
                                        if(addNewAsset){
                                            ProdShipto = item.Product2Id;
                                            ProdShipto += item.ShipToAccount__c;
                                            Set_AssetCreate.add(ProdShipto);
                                        }
                                        
                            }  
                        
                    }
                    */ 

                    Set<Id> ItemIdRemove = new Set<Id>();

                    AssetQuantityTypeUpdateCheck__mdt[] lstQuantityType = [Select Pricebook__c from AssetQuantityTypeUpdateCheck__mdt];                 

                    //!-- INFORMAT RENEWALS
                    Set<String> Set_AssProdRenew = new Set<String>();
                    AssetProductRenewal__mdt[] lstAssetProductRenewal = [Select BusinessUnit__c,ProductEAN__c,ProductName__c,	Type__c from AssetProductRenewal__mdt];

                    for(AssetProductRenewal__mdt ass:lstAssetProductRenewal){
                        Set_AssProdRenew.add(ass.ProductEAN__c);
                    }

                    system.debug('**Order_AssetCreate: Set_AssProdRenew**'+Set_AssProdRenew);
                    //-->

                    for(OrderItem  item:lstOrderItem){

                               ItemIdRemove.add(item.id);
                                        ProdShipto = item.Product2Id;
                                        ProdShipto += item.ShipToAccount__c;
                                    
                                if(item.Asset__c == null && (OrderType == 'Standard' || (Set_AssetCreate.contains(ProdShipto) && OrderType == 'RenewalOrder') )){
                                    
                                            system.debug('**AssetCreation: Name**'+item.Product2.Name);
                                            Asset NewAsset = new Asset();
                                            NewAsset.AccountId = item.ShipToAccount__c; 
                                            NewAsset.Contract__c = item.Order.ContractId;
                                            NewAsset.OrderItemIdOnCreate__c = item.id;
                                            
                                            NewAsset.BillToAccount__c = item.Order.Billto__c;
                                            NewAsset.DiscountedPrice__c = item.DiscountedPrice__c;
                                            NewAsset.CurrencyIsoCode = item.Order.CurrencyIsoCode;
                                            NewAsset.IsActive__c = true;
                                            NewAsset.OrderLineType__c = item.OrderLineType__c;
                                            
                                            if(item.Product2.CustomPricingAllowed__c == true && item.ComponentListPrice__c != item.ListPrice){
                                                NewAsset.ApplyIndexationPercentage__c = true;
                                                NewAsset.ListPrice__c = item.ComponentListPrice__c;
                                                NewAsset.IndexationPercentage__c = item.Order.Pricebook2.IndexationPercentage__c;
                                            }
                                            else{
                                                NewAsset.ListPrice__c = item.ListPrice;
                                            }

                                            

                                            NewAsset.ManualDiscount__c = item.ManualDiscount__c;
                                            if(item.ManualDiscount__c != null){
                                                if(item.ManualDiscount__c.contains('Percent')){
                                                    NewAsset.ManualDiscountPercent__c = item.ManualDiscountPercent__c;
                                                    NewAsset.ManualDiscountValue__c = null;
                                                }
                                                else if(item.ManualDiscount__c.contains('Amount')){
                                                    NewAsset.ManualDiscountValue__c = item.ManualDiscountValue__c;
                                                    NewAsset.ManualDiscountPercent__c  = null;
                                                }
                                            }     
                                           else{
                                                NewAsset.ManualDiscountPercent__c = null;
                                                NewAsset.ManualDiscountValue__c = null;
                                           }
                                            
                                            
                                            
                                            NewAsset.Method__c = item.Product2.Method__c;
                                            NewAsset.Name = item.Product2.Name;
                                            NewAsset.OperatingCompany__c= item.OperatingCompany__c;
                                            NewAsset.Price = item.UnitPrice;
                                            NewAsset.PriceBook__c	= item.Order.Pricebook2Id;
                                            NewAsset.PriceValidTillDate__c = item.Order.EndDate;
                                            NewAsset.PricingMethod__c = item.Order.PricingMethod__c;
                                            NewAsset.Product2Id= item.Product2Id;                                        
                                            NewAsset.Description = string.valueof(varIterator);
                                            NewAsset.AutomatedRenewProcess__c = item.Renewable__c;
                                            NewAsset.LicenseDuration__c = item.LicenseDuration__c;
                                            NewAsset.InstallDate = item.ServiceDate;
                                            NewAsset.Terms__c = item.Terms__c;
                                            NewAsset.Quantity = item.Quantity;
                                            NewAsset.Reference__c = item.CustomerReference__c;
                                                                                                    
                                            if(item.Renewable__c == false && item.LicenseDuration__c>0 && item.StartDate__c != null){
                                                NewAsset.EndDate__c = item.StartDate__c.addMonths(integer.valueof(item.LicenseDuration__c))-1;                                                
                                            }
                                            else if(item.Renewable__c == true && item.LicenseDuration__c>0 && item.StartDate__c != null){
                                                NewAsset.EndDate__c = item.StartDate__c.addMonths(integer.valueof(item.LicenseDuration__c))-1;
                                                NewAsset.RenewalDate__c = NewAsset.EndDate__c+1;
                                            }
                                            NewAsset.RenewalRunDate__c = NewAsset.RenewalDate__c;

                                            if(item.TrialStartDate__c != null){
                                                NewAsset.ActivationDate__c = item.TrialStartDate__c;   
                                            }
                                            else{
                                                NewAsset.ActivationDate__c = item.ServiceDate;
                                            }
                                            

                                            if(item.Order.Source__c == 'B2B Salesforce'){
                                                NewAsset.PurchaseDate = NewAsset.ActivationDate__c;
                                            }
                                            else{
                                                NewAsset.PurchaseDate = date.valueof(item.CreatedDate);
                                            }
                                            
                                            
                                            if(item.Product2.Type__c =='Non-inventory Item' && item.DigitalActivationEmail__c !=null){
                                                    NewAsset.DigitalActivationEmail__c =  item.DigitalActivationEmail__c;
                                                    item.DigitalActivationEmail__c = item.DigitalActivationEmail__c;
                                            }
                                            else if(item.Product2.Type__c =='Non-inventory Item' && item.ShipToAccount__r.DigitalActivationEmail__c !=null){
                                                    NewAsset.DigitalActivationEmail__c =  item.ShipToAccount__r.DigitalActivationEmail__c;
                                                    item.DigitalActivationEmail__c = item.ShipToAccount__r.DigitalActivationEmail__c;
                                            }

                                            
                                            if(item.Order.shipToAttentionOf__c != null){
                                                NewAsset.ShipToAttentionOf__c = item.Order.shipToAttentionOf__c;
                                            }
                                            else{
                                                NewAsset.ShipToAttentionOf__c = item.ShipToAttentionOf__c;
                                            }

                                            system.debug('**Order_AssetCreate: item.Product2.EAN__c**'+item.Product2.EAN__c);
                                            //!-- INFORMAT RENEWALS
                                            if(Set_AssProdRenew.contains(item.Product2.EAN__c)){
                                                NewAsset.Informhfdstructuur__c = item.Order.Hfdstructuur__c;
                                                item.Hfdstructuur__c = item.Order.Hfdstructuur__c;
                                            }                                            
                                            //--->

                                            for(AssetQuantityTypeUpdateCheck__mdt type:lstQuantityType){
                                                if(item.Order.Pricebook2.Name.contains(type.Pricebook__c)){
                                                        NewAsset.QuantityUpdateCheckYearly__c = true;
                                                }
                                            }

                                            lstNewAsset.add(NewAsset);
                                            varIterator++;
                                    //  }         
                                    }                  
                    }    
                    system.debug('**AssetCreation: lstNewAsset**'+lstNewAsset);

                    try{
                    //FOR UPSELL: Commented out until needed
                    //update ListOfAssets;
                    
                    insert lstNewAsset;
                    
                    
                  
                  List<StudentAndUsernumbers__c> lstUserNum = new List<StudentAndUsernumbers__c>();
                    
                    for(OrderItem  item:lstOrderItem){
                            
                            for(Asset ass:lstNewAsset){
                                if(item.Product2Id == ass.Product2Id && item.ShipToAccount__c == ass.AccountId && ass.OrderItemIdOnCreate__c == item.id ){
                                    item.Asset__c = ass.Id;
                                    item.AssetIdValidate__c  = ass.Id;
                                    
                                }    
                            }

                      
                    } 
                    update lstOrderItem;

                   
                    system.debug('**AssetCreation: Updated**');

                    
                        ItemId.RemoveAll(ItemIdRemove);
                        if(CalledFromInvocable == true){
                            System.enqueueJob(new Order_AssetsCreateOnOrderActivation(ItemIdFullList,ItemId,CalledFromInvocable));
                        }
                        else{
                            System.enqueueJob(new Order_AssetsCreateOnOrderActivation(ItemIdFullList,ItemId));
                        }
                        
                                            
                        if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                            CalloutException e = new CalloutException();
                            e.setMessage('Error');
                            throw e;        
                        }
                    }
                    catch(exception e){

                         ItemId.RemoveAll(ItemIdRemove);
                         if(CalledFromInvocable == true){
                            System.enqueueJob(new Order_AssetsCreateOnOrderActivation(ItemIdFullList,ItemId,CalledFromInvocable));
                        }
                        else{
                            System.enqueueJob(new Order_AssetsCreateOnOrderActivation(ItemIdFullList,ItemId));
                        }

                        HandleCustomException.LogException(e,lstOrderItem[0].id);
                        system.debug('**AssetCreation: Error**'+e.getmessage());
                    }

        }
        else{
            //No More assets to process. OrderItemAPI Call
            system.debug('**Order_AssetsCreateOnOrderActivation: 2**'+CalledFromInvocable);
            if(CalledFromInvocable == null){
                bg_AllObjectInvocableHandler.AllObjectInvocableHandler(ItemIdFullList);
            }
        }          
                
    }    


}