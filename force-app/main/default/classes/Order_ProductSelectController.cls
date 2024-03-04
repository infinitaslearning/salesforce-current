public class Order_ProductSelectController {
    

    //------------------------------ Aura Methods
    
        @auraenabled
        Public static  OrderOpportunity  returnOrder(String OrderId){       
            
            Order[] Order; 
                try {
                    Id recordId = Id.valueOf(OrderId);
                    String objectName = recordId.getSobjectType().getDescribe().getName();
                    
                    OrderOpportunity OrdOpp = new OrderOpportunity();
                     
                    if(objectName == 'Order'){
                        Order = [Select Type from Order where id=:OrderId];
                        
                        OrdOpp.HeaderType = 'Order';
                        OrdOpp.Type = Order[0].Type;
                      //  return  Order[0];
                      return OrdOpp;
                    }
                    else if(objectName == 'Opportunity'){
                        Opportunity[] Opportunity = [Select PriceBook2Id,Type from Opportunity where id=: OrderId];

                        OrdOpp.HeaderType = 'Opportunity';
                        OrdOpp.Type = Opportunity[0].Type;

                        //return null;
                        return OrdOpp;
                    }
                    return null;
    
                } 
                catch (Exception e) {
                    HandleCustomException.LogException(e,OrderId);
                    system.debug('**Order_ProductSelectController ReturnOrder: '+ e.getMessage());
                    throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'Please contact system administator'); 
                }
                
           // return  Order[0];
        
        } 
        
        @auraenabled
        Public static  decimal  returnOrderLineItemMaxCount(){ 
            OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='LiveCount'];
            system.debug('**Order_ProductSelectController OrderLineItemMaxCount: '+ OrderLineItemMaxCount[0].Count__c);                 
            return OrderLineItemMaxCount[0].Count__c;

        }    
        @auraenabled
        Public static  String  returnPricebook(String PricebookId){       
            
             
                try {
                    
                    if(PricebookId != null){
                        PriceBook2[] curPricebook = [Select name from PriceBook2 where id =: PricebookId];

                        if(curPricebook[0].Name.contains('Professional')){
                            return 'Professional';
                        }
                        else{
                            return 'Standard';
                           // return 'Professional';
                        }
                    }
                    else{
                        return ''; 
                    }


    
                } 
                catch (Exception e) {
                    HandleCustomException.LogException(e,PricebookId);
                    system.debug('**Order_ProductSelectController ReturnOrder: '+ e.getMessage());
                    throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'Please contact system administator'); 
                }
         
        
        } 

    
        @auraenabled
        Public static List<ProductListPrice>  loadProductsbyPriceBookContract(List<OrderLineItem> OrderItems, String ContractId,Decimal NoStudents,List<String> ShiptoId,String ExistingContract,String ContractRenewal,String PricingMethod){      
            
    
            List<ProductListPrice> lstProductListPrice;
            try {
                Date PricebookStart, PricebookEnd;
                Contract[] Contract = [Select PriceBook2Id,PriceBook2.StartDate__c,PriceBook2.EndDate__c from Contract where id=:ContractId];
                
                      PricebookStart =Contract[0].PriceBook2.StartDate__c ;  
                      PricebookEnd = Contract[0].PriceBook2.EndDate__c;
                lstProductListPrice = loadProductsbyPriceBook(Contract[0].Pricebook2Id,null,PricebookStart,PricebookEnd);
                return  lstProductListPrice;
            }
            catch (Exception e) {
                HandleCustomException.LogException(e,ContractId);
                system.debug('**Order_ProductSelectController: loadProductsby Contract: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: ' + e.getMessage() + ' - Please contact system administator');    
            }
           
    
    
            
        }   
    
        @auraenabled
        Public static List<ProductListPrice>  loadProductsbyPriceBookOrder(List<OrderLineItem> OrderItems,String OrderId,Decimal NoStudents,List<String> ShiptoId,String ExistingContract,String ContractRenewal,String PricingMethod){        
            
            List<ProductListPrice> lstProductListPrice;
            try {
    
                /*
                Id recordId = Id.valueOf(OrderId);
                String objectName = recordId.getSobjectType().getDescribe().getName();
    
                String Pricebook2Id;
                if(objectName == 'Order'){
                    Order[] Order = [Select PriceBook2Id,PricingMethod__c from Order where id=: OrderId];
                    PricingMethod = Order[0].PricingMethod__c;
                    Pricebook2Id = Order[0].Pricebook2Id;
                }
                else if(objectName == 'Opportunity'){
                    Opportunity[] Opportunity = [Select PriceBook2Id from Opportunity where id=: OrderId];               
                    Pricebook2Id = Opportunity[0].Pricebook2Id;
                }           

                lstProductListPrice = loadProductsbyPriceBook(OrderItems,null,Pricebook2Id,NoStudents,ShiptoId,ExistingContract,ContractRenewal,PricingMethod,null);
                */

            
            lstProductListPrice = loadProductsbySearch(OrderItems,null,OrderId,null);                
            return  lstProductListPrice;
    
    
    
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e,OrderId);
                system.debug('**Order_ProductSelectController: loadProductsby Order: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: '  + e.getMessage() + ' - Please contact system administator');    
            }
            
            
        
        } 
        @auraenabled
        Public static List<ProductListPrice>  loadProductsbySearch(List<OrderLineItem> OrderItems,List<OrderLineItem> SelectedItems,String OrderId,String searchString){        
            
                
    
            try {
               
    
                List<ProductListPrice> lstProductListPrice;
     
                  Id recordId = Id.valueOf(OrderId);
                  String objectName = recordId.getSobjectType().getDescribe().getName();
      
                  String Pricebook2Id;
                  Date PricebookStart, PricebookEnd;
                  if(objectName == 'Order'){
                      Order[] Order = [Select PriceBook2Id,PriceBook2.StartDate__c,PriceBook2.EndDate__c,PricingMethod__c,ShipbyDate__c from Order where id=: OrderId];
                     //ShipbyDate = Date.newInstance(Order[0].ShipbyDate__c.year(), Order[0].ShipbyDate__c.month(), Order[0].ShipbyDate__c.day());
                    
                     // ShipbyDate = Date.newInstance(2023, 11, 20);
                       PricebookStart =Order[0].PriceBook2.StartDate__c ;  
                       PricebookEnd = Order[0].PriceBook2.EndDate__c;
                      Pricebook2Id = Order[0].Pricebook2Id;
                  }
                  else if(objectName == 'Opportunity'){
                      Opportunity[] Opportunity = [Select PriceBook2Id,PriceBook2.StartDate__c,PriceBook2.EndDate__c,ContractStartDate__c,CloseDate from Opportunity where id=: OrderId];                   
                      Pricebook2Id = Opportunity[0].Pricebook2Id;
                      PricebookStart =Opportunity[0].PriceBook2.StartDate__c ;  
                      PricebookEnd = Opportunity[0].PriceBook2.EndDate__c;
                  }
      
      
                  system.debug('**Order_ProductSelectController: loadProductsby Search: PricebookStart :'+PricebookStart);     
                  lstProductListPrice = loadProductsbyPriceBook( Pricebook2Id,searchString,PricebookStart, PricebookEnd);
                  return  lstProductListPrice;
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e,OrderId);
                system.debug('**Order_ProductSelectController: loadProductsby Search: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: '  + e.getMessage() + ' - Please contact system administator');    
            }
           
            
        
        }
        
    
    
        @auraenabled
        Public static List<OrderLineItem>  loadOrderItems(String OrderId, Decimal NoStudents, String PricingMethod){ 
            
            
                 try {
    
                    List<OrderLineItem> lstOrderLineItems = new List<OrderLineItem>();
    
                    Id recordId = Id.valueOf(OrderId);
                    String objectName = recordId.getSobjectType().getDescribe().getName();
    
                    String Pricebook2Id;
                    if(objectName == 'Order'){               
                        Order[] Order = [Select PriceBook2Id,PricingMethod__c from Order where id=: OrderId];
                        if(Order.size()>0){
                            PricingMethod = Order[0].PricingMethod__c;
                            lstOrderLineItems = returnOrderItems(OrderId, NoStudents,PricingMethod);
                        }               
                    }
                    else if(objectName == 'Opportunity'){
                        lstOrderLineItems = returnOpportunityItems(OrderId, NoStudents,PricingMethod);
                    
                    }
                    
                    return lstOrderLineItems;
    
                }
                catch (Exception e) {
                    // "Convert" the exception into an AuraHandledException
                    HandleCustomException.LogException(e,OrderId);
                    system.debug('**Order_ProductSelectController: loadOrderItems: '+ e.getMessage());
                    throw new AuraHandledException('Something went wrong: ' + e.getMessage() + ' - Please contact system administator');    
            }
           
    
                
        }
        
    
        @auraenabled
        Public static String   InsertOrderItems(List<OrderLineItem> OrderItems,String ContractId,String OrderId, Decimal TotalNumberofStudents,List<Account> AccountbyShipto){      

    
           Id recordId = Id.valueOf(OrderId);
           String objectName = recordId.getSobjectType().getDescribe().getName();
    
           String Pricebook2Id;
           if(objectName == 'Order'){              
               System.enqueueJob(new Order_OrderInsertQueueable(ContractId,OrderId, TotalNumberofStudents,true,AccountbyShipto));
               ProcessInsertOrderItems(OrderItems,ContractId,OrderId,TotalNumberofStudents, AccountbyShipto);          
           }
           else if(objectName == 'Opportunity'){
               ProcessInsertOpportunityLines(OrderItems,ContractId,OrderId,TotalNumberofStudents, AccountbyShipto); 
           }
    
            return OrderId;
        }
    
    
    
        @auraenabled
        Public static List<ListPriceDiscount__c> loadListPriceDiscountType(String OrderId){        
             
            ListPriceDiscount__c[] lst_ListPriceDiscountRegular;
            try {       
    
                    Id recordId = Id.valueOf(OrderId);
                    String objectName = recordId.getSobjectType().getDescribe().getName();
    
                    String Subsidiary;
                    String Source;
                    String OperatingCompany,CustomerDiscountGroup,PricingMethod;
                    
                    Date CurDate = system.today();
                    Set<String> Set_CusDiscountGroup = new Set<String>();		
                    Set<String> Set_OperatingCo = new Set<String>();
                   Order[] Order;
                    if(objectName == 'Order'){
                            Order = [Select Billto__r.OperatingCompany__c,Source__c,Billto__r.CustomerDiscountGroup__c,PricingMethod__c  from Order where id=:OrderId];     
                            Source = Order[0].Source__c;
                            PricingMethod = Order[0].PricingMethod__c; 

                            Set_OperatingCo.add(Order[0].Billto__r.OperatingCompany__c);
                            Set_CusDiscountGroup.add(Order[0].Billto__r.CustomerDiscountGroup__c);
                            //OperatingCompany = Order[0].Billto__r.OperatingCompany__c;
                            //CustomerDiscountGroup = Order[0].Billto__r.CustomerDiscountGroup__c;
                                          
                    }
                    else if(objectName == 'Opportunity'){
                        Opportunity[] Opportunity = [Select PriceBook2Id,Account.CustomerDiscountGroup__c,Account.OperatingCompany__c,PricingMethod__c from Opportunity where id=: OrderId];
                        OperatingCompany = Opportunity[0].Account.OperatingCompany__c;
                        CustomerDiscountGroup = Opportunity[0].Account.CustomerDiscountGroup__c;
                        PricingMethod = Opportunity[0].PricingMethod__c;
                        Source = 'B2B Salesforce';
                    }
    
                //------------ADD OPERATING COMPANY
                if(Source =='Trade' || Source =='B2B Shop' || Source =='B2B Salesforce' || Source == 'Trade - Early Season Order' || Source == 'Tender'){
                    
                    /*
                    String Querystr;
                    querystr = 'Select Id,ProductDiscountGroup__c,Subsidiary__c,ValueType__c,StartAmount__c,    DiscountType__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c where  EndDate__c >=:CurDate AND StartDate__c  <=:CurDate AND CustomerDiscountGroup__c =: CustomerDiscountGroup AND Subsidiary__c =: OperatingCompany';
                    if(PricingMethod =='OrderTotalAmount'){
                        querystr += ' AND ValueType__c = \'Amount\' ';
                        querystr += ' ORDER BY StartAmount__c DESC';
                    }
                    else{
                        querystr += ' AND ValueType__c = \'Quantity\' '; 
                        querystr += ' ORDER BY StartQuantity__c DESC'; 
                    }
                    lst_ListPriceDiscountRegular =Database.query(querystr);    
                    */

                    lst_ListPriceDiscountRegular  =  Order_SoqlFactory.returnListPriceDiscount('ProductSelector',PricingMethod, Set_CusDiscountGroup, Set_OperatingCo, null, null, null);			                    
                    system.debug('**Order_SoqlFactory.Order_ProductSelectController.lst_ListPriceDiscountRegular :Size**'+lst_ListPriceDiscountRegular.size());
    
                }                                                              
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e,OrderId);
                system.debug('**Order_ProductSelectController ListPriceDiscount: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'Please contact system administator');    
            }
            
            
            system.debug('**Order_ProductSelectController: lst_ListPriceDiscountRegular**'+ lst_ListPriceDiscountRegular);
            return  lst_ListPriceDiscountRegular;
    
    
        }
    
        @auraenabled
        Public static List<AssetList> loadAssetsforRate (String OrderId, List<String> ShiptoId, String PricingMethod){
           
            List<AssetList> lstAssetList = new List<AssetList>();
            try { 
               
                //----------TEST MODAL ORDER---------------
                Set<String> Set_BillTo = new Set<String>();
                        if(OrderId != null){
    
                            Id recordId = Id.valueOf(OrderId);
                            String objectName = recordId.getSobjectType().getDescribe().getName();
    
                            String Pricebook2Id;
                            if(objectName == 'Order'){                  
                                Order[] Order = [Select PriceBook2Id,PricingMethod__c,Billto__c from Order where id=:OrderId];
                                Set_BillTo.add(Order[0].Billto__c);  
                            }
                            else if(objectName == 'Opportunity'){
                                Opportunity[] Opportunity = [Select PriceBook2Id,Account.OperatingCompany__c,AccountId from Opportunity where id=: OrderId];
                                Set_BillTo.add(Opportunity[0].AccountId);
                            }
                        }
                //-------------------------
    

    
                    system.debug('**Order_ProductSelectController: Asset Load: Set_BillTo**'+Set_BillTo);
                    /*
                    Date CurrrentDay = system.today();
                    asset[] loadAssetsListGroupRate  = [Select id,Name,Product2.Name,PriceBook__c,PriceBook__r.FollowUpPriceBook__c,RenewalDate__c,Account.DigitalActivationEmail__c ,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,RenewalTerm__c,IsUpForRenewal__c,AccountId,PricingMethod__c,BillToAccount__r.ShippingCostMethod__c,BillToAccount__r.PaymentMethod__c,Price,Quantity, BillToAccount__c,Product2Id 
                                                from asset 
                                                where (CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)
                                                AND RenewalDate__c  >=: CurrrentDay
                                                AND (ActivationDate__c <=: CurrrentDay OR  ActivationDate__c =: null)
                                                AND IsActive__c =: true
                                                AND BillToAccount__c in:Set_BillTo];
                                               // AND Contract__c =:null];              
                    */
                    Date CurrentDay = system.today();
                    Date RenewalDay = system.today();

                    asset[] loadAssetsListGroupRate  = Database.query(Order_SoqlFactory.returnasset('ProductSelector',Set_BillTo,null));		
                    system.debug('**Order_SoqlFactory.Order_ProductSelectController.loadAssetsListGroupRate :Size**'+loadAssetsListGroupRate.size());
                    
                    for(asset ass:loadAssetsListGroupRate){
                     
                        AssetList asset = new AssetList();
                        asset.Id = ass.id;
                        asset.Name = ass.Name ;
                        asset.ProductName = ass.Product2.Name;
                        asset.ProductId = ass.Product2Id;
                        asset.Quantity = ass.Quantity;
                        asset.ProductRateGroup = ass.Product2.ProductRateGroup__c;
                        asset.BillToAccount = ass.BillToAccount__c;
                        lstAssetList.add(asset);
                    }  
                    return lstAssetList; 
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e,OrderId);
                system.debug('**Order_ProductSelectController: AssetsforRate: '+ e.getMessage());
                throw new AuraHandledException('Something went wrong: '+ e.getMessage() + 'Please contact system administator');    
            }
                   
    
                                        
    
        }
        @auraenabled
        Public static Account  loadAccountbyBillto(String OrderId){    
             
            Account[] AccountbyBillto;
            
                try {
 
                     
                     Id recordId = Id.valueOf(OrderId);
                     String objectName = recordId.getSobjectType().getDescribe().getName();         
                     system.debug('**Order_ProductSelectController: AccountbyBillto: objectName '+ objectName + '***'+ OrderId);
                     if(objectName == 'Order'){                      
                             Order[] Order = [Select Billto__r.OperatingCompany__c  from Order where id=:OrderId];
                             AccountbyBillto = [Select Id,name,OperatingCompany__c,CustomerDiscountGroup__c  from Account where id =:Order[0].Billto__c  ]; 
                            
                     }
                     else if(objectName == 'Opportunity'){
                         Opportunity[] Opportunity = [Select PriceBook2Id,Account.OperatingCompany__c from Opportunity where id=: OrderId];
                         AccountbyBillto = [Select Id,name,OperatingCompany__c,CustomerDiscountGroup__c  from Account where id =:Opportunity[0].AccountId]; 
                            
                     }              
    
    
    
                     return AccountbyBillto[0];
    
                } 
                catch (Exception e) {
                    // "Convert" the exception into an AuraHandledException
                    
                    HandleCustomException.LogException(e,OrderId);
                    system.debug('**Order_ProductSelectController: AccountbyBillto: '+ e.getMessage());
                    throw new AuraHandledException('Something went wrong: ' + e.getMessage() + 'Please contact system administator');    
                }
                 
    
                
            }        
        
        @auraenabled
        Public static List<ShiptoAccount>  loadAccountbyShipto(String OrderId, List<String> ShiptoId){    
            List<ShiptoAccount> lstShiptoAccount = new List<ShiptoAccount>();
            
            try {
                
                List<Account> AccountbyShipto = new List <Account>([Select Id,name,NumberofStudents__c, OperatingCompany__c,DefaultBillto__r.CustomerDiscountGroup__c, PurchasingGroup__r.CustomerDiscountGroup__c,CustomerDiscountGroup__c from Account where NumberofStudents__c >=: 0 AND id in:ShiptoId  ]); //      ]); //   Use_in_flow__c =:true 
               
                    system.debug('**Order_ProductSelectController: AccountbyShipto**'+AccountbyShipto);
    
                    for(Account acc:AccountbyShipto){
                        
                        ShiptoAccount ShiptoAccount = new ShiptoAccount();
                        ShiptoAccount.Name = acc.Name;
                        ShiptoAccount.Id =acc.Id;
                        ShiptoAccount.NumberofStudents =acc.NumberofStudents__c;
                        ShiptoAccount.OperatingCompany = acc.OperatingCompany__c;
    
                        if(acc.DefaultBillto__r.CustomerDiscountGroup__c != null ){
                            ShiptoAccount.CustomerDiscountGroup =   acc.DefaultBillto__r.CustomerDiscountGroup__c;
                        }
                        else if(acc.PurchasingGroup__r.CustomerDiscountGroup__c != null ){
                            ShiptoAccount.CustomerDiscountGroup =   acc.PurchasingGroup__r.CustomerDiscountGroup__c;
                        }
                        else if(acc.CustomerDiscountGroup__c != null ){
                            ShiptoAccount.CustomerDiscountGroup =   acc.CustomerDiscountGroup__c;
                        }
                        lstShiptoAccount.add(ShiptoAccount);
                    }
                }
                
                catch (Exception e) {
                    // "Convert" the exception into an AuraHandledException
                    HandleCustomException.LogException(e,OrderId);
                    system.debug('**Order_ProductSelectController: AccountbyShipto: '+ e.getMessage());
                    throw new AuraHandledException('Something went wrong: '    + e.getMessage() + 'Please contact system administator');    
                }
              
            Return lstShiptoAccount;
            
        }
        
    
        //--------------------------------Handler Methods
        public static List<OrderLineItem>   returnOpportunityItems(String curOrderId, Decimal NoStudents, String PricingMethod){
             
     //       OpportunityLineItem[] lstOppItem = [Select Product2Id,OrderLineType__c,Product2.CustomPricingAllowed__c,ProductType__c,ListPriceItemGroup__c,ListPriceDiscount__c,ListPriceDiscount__r.Rate__c,ProductComponent__c,DiscountedPriceItemGroup__c,ItemGroup__r.Product2Id,ItemGroup__c,LicenseDuration__c,ManualDiscount__c,ManualDiscountPercent__c,ManualDiscountValue__c,OpportunityId,Product2.name,ComponentListPrice__c,Quantity,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Opportunity.Account.CustomerDiscountGroup__c,Opportunity.Account.OperatingCompany__c,Opportunity.Account.Name,Opportunity.AccountId,Product2.OrderLineType__c,ListPrice,UnitPrice,Terms__c,ServiceDate,Product2.Renewable__c from OpportunityLineItem where OpportunityId =:curOrderId order by createddate ASC];
     
     OpportunityLineItem[] lstOppItem = Order_SoqlFactory.returnOpportunityLine(curOrderId);		
     system.debug('**Order_SoqlFactory.Order_ProductSelectController.returnOpportunityItems.lstOppItem :Size**'+lstOppItem.size());
     
     List<OrderLineItem> lstOrderItems = new List<OrderLineItem>();
            List<String> ManualDiscount  = new List<String>();
            String ItemId;
            Set<String> Set_ItemGroup = new Set<String>();
            Set<String> Set_ProdItemGroup = new Set<String>();
           
            for(OpportunityLineItem oppItem: lstOppItem){
               Set_ProdItemGroup.add(oppItem.Product2Id);
               Set_ItemGroup.add(oppItem.ItemGroup__c); 
            }
            
            
            for(OpportunityLineItem oppItem: lstOppItem){
                
                OrderLineItem item = new OrderLineItem();
                ItemId = oppItem.id;
             //  ItemId = oppItem.Opportunity.AccountId;
              // ItemId += oppItem.Product2Id;
               Item.ItemId = ItemId; // 
               Item.OrderId = oppItem.OpportunityId; 
               Item.IId = oppItem.id;

                if(oppItem.ItemGroup__c != null){
                    Item.ItemGroupProductId =  oppItem.ItemGroup__r.Product2Id;
                    ItemId = oppItem.ItemGroup__c;
                    Item.ItemGroup =ItemId;
                }

                if(Set_ItemGroup.contains(oppItem.id)){
                    Item.ItemGroupComponent = true;
                }
                else{
                    Item.ItemGroupComponent = false; 
                }
                Item.ItemGroupId = oppItem.ProductComponent__c;    
                item.ProductId = oppItem.Product2Id;
                Item.CustomPricingAllowed = oppItem.Product2.CustomPricingAllowed__c;
                item.Quantity = oppItem.Quantity;
                item.LicenceDuration = oppItem.LicenseDuration__c;
                item.OppTerms = oppItem.Terms__c;
                item.OppServiceDate = oppItem.ServiceDate;
                item.ProductTYPE = oppItem.ProductType__c;
                Item.listPriceDiscountType  = oppItem.Product2.ProductDiscountGroup__c;		
                Item.ProductRateGroup = oppItem.Product2.ProductRateGroup__c;		
                Item.Subsidiary = oppItem.Opportunity.Account.OperatingCompany__c;		
                Item.CustomerDiscountGroup =oppItem.Opportunity.Account.CustomerDiscountGroup__c;
    
                item.UnitPrice = oppItem.UnitPrice;

                if(oppItem.ItemGroup__c != null || oppItem.Product2.CustomPricingAllowed__c == true){
                    Item.BasePrice = oppItem.ComponentListPrice__c.setScale(2);
                }
                else{
                    Item.BasePrice = oppItem.ListPrice.setScale(2);               
                }
                /*
                if(oppItem.ListPrice != 0 && oppItem.Product2.CustomPricingAllowed__c != true){
                    item.BasePrice = oppItem.ListPrice;
                }
                else if(oppItem.ComponentListPrice__c != null){
                    item.BasePrice = oppItem.ComponentListPrice__c;
                }
                */

                item.STDPrice  = oppItem.UnitPrice;
                
                item.listPriceRateId = oppItem.ListPriceDiscount__c;  
                 
                     system.debug('**Order_ProductSelectController: Opp Items: PricingMethod**'+PricingMethod);
                     if(PricingMethod == 'OrderTotalRate'){
                         Item.STDPrice = oppItem.UnitPrice;
                     }
                     else if(oppItem.ListPriceDiscount__c != null){
                        if(oppItem.ItemGroup__c != null || oppItem.ComponentListPrice__c != null){
                            Item.STDPrice  = oppItem.ComponentListPrice__c - (oppItem.ComponentListPrice__c* (oppItem.ListPriceDiscount__r.Rate__c)/100);
                        }
                        else{
                            Item.STDPrice  = oppItem.ListPrice - (oppItem.ListPrice* (oppItem.ListPriceDiscount__r.Rate__c)/100);                
                        }
                        Item.Rate = (oppItem.ListPriceDiscount__r.Rate__c)/100;
                         
                     }
                     else{
                        if(oppItem.ItemGroup__c != null || oppItem.Product2.CustomPricingAllowed__c == true){
                            Item.STDPrice  = oppItem.ComponentListPrice__c;
                        }
                        else{
                            Item.STDPrice  = oppItem.ListPrice;                
                        }                     
                     }
     
                     if(Set_ItemGroup.contains(oppItem.id)){                    
                        // Item.UnitPrice =  OItem.NetSalesPriceItemGroup__c;  
                         Item.STDPrice = oppItem.DiscountedPriceItemGroup__c;
                         Item.BasePrice = oppItem.ListPriceItemGroup__c;
                     }  
                
                      
                 List<String> PriceProductType = new List<String>();
                 PriceProductType.AddAll(oppItem.Product2.OrderLineType__c.Split(';'));
                 Item.listPriceProductType = PriceProductType;
                 
                 Item.ProductName =  oppItem.Product2.name;
                 Item.ShipToAccountId = oppItem.Opportunity.AccountId;
                 Item.ShipToAccountName = oppItem.Opportunity.Account.Name; 
                 Item.Amount = (oppItem.Quantity * oppItem.UnitPrice); 
                 Item.NoDiscAmount =Item.Amount;
                 Item.PriceDiscount = oppItem.OrderLineType__c;
                ManualDiscount  = new List<String>();
                  
                 ManualDiscount.add('--None--');
                 if(oppItem.Product2.Renewable__c ==true){
                     ManualDiscount.add('Recurring Percentage');
                     ManualDiscount.add('Recurring Amount');
                     ManualDiscount.add('One-Off Percentage');
                     ManualDiscount.add('One-Off Amount');
                     ManualDiscount.add('One-Off Amount (Subtotal)');
                 }
                 else{
                     ManualDiscount.add('One-Off Percentage');
                     ManualDiscount.add('One-Off Amount');
                     ManualDiscount.add('One-Off Amount (Subtotal)');
                 }
                 if(oppItem.ManualDiscount__c == 'Recurring Percentage' || oppItem.ManualDiscount__c == 'One-Off Percentage' ){
                    Item.DiscountPercentShow = true;
                    Item.DiscountValueShow = false;
                    Item.NoDiscAmount =oppItem.Quantity * (Item.STDPrice);
                }
                else if(oppItem.ManualDiscount__c == 'Recurring Amount' || oppItem.ManualDiscount__c == 'One-Off Amount' || oppItem.ManualDiscount__c == 'One-Off Amount (Subtotal)'){
                    Item.DiscountValueShow = true;
                    Item.DiscountPercentShow = false;
                    Item.NoDiscAmount =oppItem.Quantity * (Item.STDPrice);
                }
                
                else{
                    Item.DiscountValueShow = false;
                    Item.DiscountPercentShow = false;
                    Item.NoDiscAmount =Item.Amount;
                }
                 Item.ManualDiscount = ManualDiscount;          
                 Item.DiscountOption = oppItem.ManualDiscount__c;
                 Item.DiscountPercent = oppItem.ManualDiscountPercent__c; 
                 Item.DiscountAmount = oppItem.ManualDiscountValue__c;  
                 
    
                lstOrderItems.add(item);
            }
            
           return lstOrderItems;   
        }
    
    
        Public static List<OrderLineItem>  returnOrderItems(String curOrderId, Decimal NoStudents, String PricingMethod){     
            
            List<OrderLineItem> lstOrderLineItems = new List<OrderLineItem>();
    
          /*
            OrderItem[] lstOrderItem = [Select id,Product2.CustomPricingAllowed__c,NetsuiteQuantity__c,CustomerReference__c,StartDate__c,Order.MasterOrder__c,ProRataMonths__c,ProRataRate__c,EndDate,Product2.ProRatoDiscount__c,Terms__c,LicenseDuration__c,ProductComponent__c,ProductComponent__r.Quantity__c, ComponentListPrice__c, Product2.maxQuantity__c,NetSalesPriceItemGroup__c,DiscountedPriceItemGroup__c,ListPriceItemGroup__c,
            Product2.ProductRateGroup__c,LineItemTotal__c,Product2.Renewable__c,ItemGroup__r.Product2Id,Product2.OrderLineType__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c,
            Product2.QuantitySelectionType__c,OrderId,ItemGroup__c,ShipToAccount__r.Name,ShipToAccount__r.CustomerDiscountGroup__c,ListPrice,UnitPrice,Quantity,Product2.ProductDiscountGroup__c,OrderLineType__c,
            ListPriceDiscount__c,ListPriceDiscount__r.OrderLineType__c,ListPriceDiscount__r.Rate__c,Product2Id,PricebookEntryId,ShipToAccount__c,ManualDiscount__c,ManualDiscountPercent__c,ManualDiscountValue__c 
            From OrderItem where OrderId =:curOrderId Order By createddate ASC];
           */
          List<Id> OrderId = new List<Id>();	            
	      OrderId.add(curOrderId);		
	      OrderItem[]   lstOrderItem =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);		
          system.debug('**Order_SoqlFactory.Order_ProductSelectController.returnOrderItems.lst_OrdItem :Size**'+lstOrderItem.size()); 
            
    
            //Return ProductsbyPriceBook;
            Order[] curOrder = [Select Pricebook2Id,Pricebook2.StartDate__c, Pricebook2.EndDate__c,Billto__r.CustomerDiscountGroup__c,Billto__r.OperatingCompany__c from Order where Id =:curOrderId]; 
           
            //List Price Discount - Need to recaculate for any updates to values since last save / adding ship to's will change the quantity                        
            Date CurDate = system.today();
    
            
                                                                     
    
            Map<String,Decimal> Map_OrderProdMap = new Map<String,Decimal>(); 
            Map<String,List<String>> Map_PriceProductType = new Map<String,List<String>>();
            Map<String,List<OrderLineItem>> Map_Component = new Map<String,List<OrderLineItem>>();
    
            Set<String> Set_ItemGroup = new Set<String>();
            Set<String> Set_ProdItemGroup = new Set<String>();
            String ProdGroup;
       
            List<OrderLineItem> lst_Component;
            
             List<OrderItem> lstNonComponentOrderItem = new  List<OrderItem>();
            
            for(OrderItem Item:lstOrderItem){
                Set_ProdItemGroup.add(Item.Product2Id);
                Set_ItemGroup.add(Item.ItemGroup__c); 
            }    
    
    /*
            Pricing__c[] lstPrice = [Select ListRate__c,Product__c,EndDate__c,IsActive__c,ProductComponent__r.Quantity__c,ProductComponent__r.Type__c,ProductComponent__r.MainProduct__c,ProductComponent__r.Product__c from Pricing__c 
            Where   (ProductComponent__r.MainProduct__c in: Set_ProdItemGroup OR Product__c in: Set_ProdItemGroup OR ProductComponent__r.Product__c in: Set_ProdItemGroup )
            AND StartDate__c <=: system.today()
            AND EndDate__c >=: system.today()
            AND IsActive__c =:true];
    */
            
      
    
        Pricing__c[] lstPrice = Order_SoqlFactory.returnPricing('ProductSelector1',Set_ProdItemGroup,null,curOrder[0].Pricebook2.StartDate__c,curOrder[0].Pricebook2.EndDate__c);		
	    system.debug('**Order_SoqlFactory.Order_ProductSelectController.returnOrderItems.lstPrice :Size**'+lstPrice.size());
        
        
        Map<String,Decimal> Map_ComponentQuantity  =  new Map<String,Decimal>();
             
           for(Pricing__c item:lstPrice){   
                if(item.ProductComponent__r.Type__c=='Item Group Component' || item.ProductComponent__r.Type__c=='Kit Component' ){ //
                    
                    Map_ComponentQuantity.put(item.ProductComponent__r.Product__c,item.ProductComponent__r.Quantity__c);
                     
                }                   
            }
    
           //This is used to make sure that item groups display together on the Product selector
           Integer Count = 1;
            for(OrderItem Item:lstOrderItem){
    
                //List Price discount information
                ProdGroup = Item.Product2.Name+ Item.Product2.ProductDiscountGroup__c+ Item.ShipToAccount__r.CustomerDiscountGroup__c;
    
                if(PricingMethod != 'AccountStudents'){
                    if(Map_OrderProdMap.get(ProdGroup)== null){      
                        Map_OrderProdMap.put(ProdGroup,Item.Quantity);       
                    }
                    else{
                        Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+Item.Quantity);         
                    }
                } 
                else{
                        Map_OrderProdMap.put(ProdGroup ,Item.Quantity);   
                }
    
                List<String> PriceProductType = new List<String>();
                PriceProductType.AddAll(Item.Product2.OrderLineType__c.Split(';'));
                                
                Map_PriceProductType.put(Item.id,PriceProductType);
    
                //Product Component information--------Determine if there are any PackComponents
               
    
                //---------------------------
                if(Item.ItemGroup__c != null){
    
                    if(Map_Component.get(Item.ItemGroup__c)==null){
                        lst_Component = new List<OrderLineItem>();
                        lst_Component.add(OrderLineItemWrapperCreate(curOrder, Set_ItemGroup,Item, PricingMethod, Map_ComponentQuantity,Count)); 
                        Map_Component.put(Item.ItemGroup__c,lst_Component);
                    }
                    else{
                          Map_Component.get(Item.ItemGroup__c).add(OrderLineItemWrapperCreate(curOrder, Set_ItemGroup, Item, PricingMethod, Map_ComponentQuantity,Count));
                    }                
                    Count++;
                }
                else{
                    lstNonComponentOrderItem.add(Item);
                }
            //---------------------------
    
                
            }
          
       
           
    
           List<String> ManualDiscount  = new List<String>();
           ManualDiscount.add('--None--');
            ManualDiscount.add('Percent');
            ManualDiscount.add('Value');
    
            Boolean listPriceSelected;
            String ItemId;
            
            //This is used to make sure that item groups display together on the Product selector
            for(OrderItem OItem:lstNonComponentOrderItem){
               //---------------------------
              if(OItem.ItemGroup__c == null){
                lstOrderLineItems.Add(OrderLineItemWrapperCreate(curOrder, Set_ItemGroup,OItem, PricingMethod, Map_ComponentQuantity,Count));
    
                 Count++;
              }  
              
    
              if(Map_Component.get(OItem.id)!=null){
                         for(OrderLineItem item:Map_Component.get(OItem.id)){
                            lstOrderLineItems.add(item);
                        }
              }
            }
            
    
            return lstOrderLineItems;
    
        }     
                    
    
            public Static OrderLineItem OrderLineItemWrapperCreate(Order[] curOrder, Set<String> Set_ItemGroup,OrderItem OItem,String PricingMethod, Map<String,Decimal> Map_ComponentQuantity,Integer Count){
    
            
             Boolean listPriceSelected;
             String ItemId;
             
             List<String> ManualDiscount;
                  
                 OrderLineItem Item = new OrderLineItem();
    
                 
                 ItemId =OItem.id;
                 Item.Count = Count;
                 Item.ItemId = ItemId; // 
                 Item.OrderId = OItem.OrderId; 
                 Item.IId = OItem.id;
                 Item.Subsidiary = curOrder[0].Billto__r.OperatingCompany__c;
                 if(OItem.ItemGroup__c != null){
                     Item.ItemGroupProductId =  OItem.ItemGroup__r.Product2Id;
                     ItemId = OItem.ItemGroup__c;
                     Item.ItemGroup =ItemId;
                 }
     
                 if(Set_ItemGroup.contains(OItem.id)){
                     Item.ItemGroupComponent = true;
                 }
                 else{
                     Item.ItemGroupComponent = false; 
                 }
                 Item.ItemGroupId = OItem.ProductComponent__c;
                 Item.Quantity = OItem.Quantity;
                 Item.maxQuantity = OItem.Product2.maxQuantity__c; 
                 Item.ProductName =  OItem.Product2.name;
                 Item.MarketSegment = OItem.Product2.MarketSegment__c;
                 Item.ProductId = OItem.Product2Id;
                 Item.CustomPricingAllowed = OItem.Product2.CustomPricingAllowed__c;
                 Item.PricebookEntryId = OItem.PricebookEntryId;
                 Item.ShipToAccountId = OItem.ShipToAccount__c; 
                 Item.CustomerDiscountGroup =curOrder[0].Billto__r.CustomerDiscountGroup__c;
                 Item.DiscountPercent = OItem.ManualDiscountPercent__c;
                 Item.DiscountAmount = OItem.ManualDiscountValue__c;  
                 Item.OppTerms = OItem.Terms__c; //LicenseDuration__c; 
                 Item.OppServiceDate = OItem.StartDate__c;
                 Item.CustomerReference = OItem.CustomerReference__c;
                 Item.ItemEndDate  = OItem.EndDate;
                 Item.ItemStartDate = OItem.StartDate__c;
                 Item.ProRata = OItem.Product2.ProRatoDiscount__c;
                 Item.ProRataRate = Oitem.ProRataRate__c;
                 Item.ProRataMonths = Oitem.ProRataMonths__c;
                 Item.LicenceDuration = Oitem.LicenseDuration__c;

                 if(Oitem.Order.MasterOrder__c != null){
                    Item.MasterOrder = true;
                 }

                 if(Map_ComponentQuantity.get(OItem.Product2Id) != null){
                  
                    if(OItem.NetsuiteQuantity__c != null){   
                        Item.ComponentQuantity = OItem.ProductComponent__r.Quantity__c;
                        Item.Quantity = OItem.NetsuiteQuantity__c;
    
                    }
                    else{
                        Item.ComponentQuantity = OItem.Quantity;
                        Item.Quantity = OItem.Quantity;
                    }
                     
                      Item.ComponentQuantityFinal = OItem.Quantity; 
                    Item.ComponentQuantityTitle = 'Pack quantity: '+Item.ComponentQuantity; 
                 }
                 else{
                    Item.ComponentQuantity =  OItem.Quantity;
                    Item.ComponentQuantityTitle = 'Pack quantity: '+OItem.Quantity;
                 }         
                 
                 Item.ShipToAccountId = OItem.ShipToAccount__c;
                 Item.ShipToAccountName = OItem.ShipToAccount__r.Name;            
                 Item.QuantitySelectionType =  OItem.Product2.QuantitySelectionType__c;
                  
                 Item.listPriceDiscountType  = OItem.Product2.ProductDiscountGroup__c;
                 Item.ProductRateGroup = OItem.Product2.ProductRateGroup__c;
     
                 List<String> PriceProductType = new List<String>();
                
                 PriceProductType.AddAll(OItem.Product2.OrderLineType__c.Split(';'));
                 Item.listPriceProductType = PriceProductType;
     
               
                if(OItem.OrderLineType__c != null){    
                     Item.PriceDiscount = OItem.OrderLineType__c;                 
                 }
                 else{
                   //  Item.PriceDiscount =  '--None--';
                 }
                 
                 
                 ManualDiscount  = new List<String>();
                  
                 ManualDiscount.add('--None--');
                 if(OItem.Product2.Renewable__c ==true){
                     ManualDiscount.add('Recurring Percentage');
                     ManualDiscount.add('Recurring Amount');
                     ManualDiscount.add('One-Off Percentage');
                     ManualDiscount.add('One-Off Amount');
                     ManualDiscount.add('One-Off Amount (Subtotal)');
                 }
                 else{
                     ManualDiscount.add('One-Off Percentage');
                     ManualDiscount.add('One-Off Amount');
                     ManualDiscount.add('One-Off Amount (Subtotal)');
                 }
                 
                 Item.ManualDiscount = ManualDiscount;
     
                 Item.DiscountOption = OItem.ManualDiscount__c;
     
                 Set<String> Set_SoldInSegment = new Set<String>();
                 
                 List<ListPriceDiscount> AddlistPriceDiscount;
                 
                
                 if(OItem.ItemGroup__c != null || OItem.Product2.CustomPricingAllowed__c == true){
                    Item.BasePrice = OItem.ComponentListPrice__c;
                }
                else{
                    Item.BasePrice = OItem.ListPrice;                
                }
        
                 //Populate totals and discount
                     Item.listPriceRateId = OItem.ListPriceDiscount__c;  
                  
                     if(PricingMethod == 'OrderTotalRate'){
                         Item.STDPrice = OItem.UnitPrice;
                     }
                     else if(OItem.ListPriceDiscount__c != null){
                        Item.Rate = (OItem.ListPriceDiscount__r.Rate__c)/100;
                        if(OItem.ItemGroup__c != null){
                            Item.STDPrice  = OItem.ComponentListPrice__c - (OItem.ComponentListPrice__c* (OItem.ListPriceDiscount__r.Rate__c)/100);
                        }
                        else{
                            Item.STDPrice  = Item.BasePrice - (Item.BasePrice* (OItem.ListPriceDiscount__r.Rate__c)/100);                
                        }                      
                     }
                     else{
                        if(OItem.ItemGroup__c != null || OItem.Product2.CustomPricingAllowed__c == true){
                            Item.STDPrice  = OItem.ComponentListPrice__c;
                        }
                        else{
                            Item.STDPrice  = Item.BasePrice;                
                        }                     
                     }
     
                     if(Set_ItemGroup.contains(OItem.id)){                    
                        // Item.UnitPrice =  OItem.NetSalesPriceItemGroup__c;  
                         Item.STDPrice = OItem.DiscountedPriceItemGroup__c;
                         Item.BasePrice = OItem.ListPriceItemGroup__c;
                     }  
     
                     if(OItem.ManualDiscount__c == 'Recurring Percentage' || OItem.ManualDiscount__c == 'One-Off Percentage' ){
                         Item.DiscountPercentShow = true;
                         Item.DiscountValueShow = false;
                         Item.NoDiscAmount =OItem.Quantity * (Item.STDPrice);
                     }
                     else if(OItem.ManualDiscount__c == 'Recurring Amount' || OItem.ManualDiscount__c == 'One-Off Amount' || OItem.ManualDiscount__c == 'One-Off Amount (Subtotal)'){
                         Item.DiscountValueShow = true;
                         Item.DiscountPercentShow = false;
                        Item.NoDiscAmount =OItem.Quantity * (Item.STDPrice);
                     }
                     
                     else{
                         Item.DiscountValueShow = false;
                         Item.DiscountPercentShow = false;
 
                         Item.NoDiscAmount =Item.Amount;
                     }
     
                     if(Set_ItemGroup.contains(OItem.id)){      
                         system.debug('**Order_ProductSelectController: Load Orders: contains(OItem.id)**');              
                          Item.UnitPrice =  OItem.NetSalesPriceItemGroup__c;  
                          
                     }  
                     else{
                        Item.UnitPrice = OItem.UnitPrice;
                     }
                    
    
                     Item.Amount = (OItem.Quantity * Item.UnitPrice);
    
            return Item;
        }
    
    
    
        Public static List<ProductListPrice>  loadProductsbyPriceBook(String Pricebook2Id, String SearchString,Date PricebookStart, Date PricebookEnd){ 
            
    
            Set<String> Set_OrdProd = new Set<String>();
          
            system.debug('***Order_ProductSelectController: Product Search: Start ');
     
            /*
            List<PricebookEntry> ProductsbyPriceBook;
            if(SearchString == null){
               
                ProductsbyPriceBook = new List <PricebookEntry>([Select Price__c,PriceBook2.StartDate__c,PriceBook2.EndDate__c,Product2.CustomPricingAllowed__c,Product2.Stocknumber__c,Product2.maxQuantity__c,Product2.DeliveryStatus__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id,Product2.LicenseDuration__c from PricebookEntry //,
                where Pricebook2Id =:Pricebook2Id 
                AND Price__r.IsActive__c =: true
                AND PriceBook2.StartDate__c =: PricebookStart
                AND PriceBook2.EndDate__c =: PricebookEnd
                AND IsActive =: true 
                AND Product2.itemGroupManualBlock__c =: false
                AND Product2Id not in: Set_OrdProd
                AND Product2.HasBlock__c=: false Order by Product2.Name ASC limit 70 ]); //AND IsActive =:true
    
            }
            else{

                String Search = '%'+SearchString+'%';
                ProductsbyPriceBook = new List <PricebookEntry>([Select Price__c,PriceBook2.StartDate__c,PriceBook2.EndDate__c,Product2.CustomPricingAllowed__c,Product2.Stocknumber__c,Product2.maxQuantity__c,Product2.DeliveryStatus__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id,Product2.LicenseDuration__c from PricebookEntry //,
                where Pricebook2Id =:Pricebook2Id 
                AND Price__r.IsActive__c =: true
                AND IsActive =: true
                AND PriceBook2.StartDate__c =: PricebookStart
                AND PriceBook2.EndDate__c =: PricebookEnd
                AND Product2Id not in: Set_OrdProd
                AND Product2.HasBlock__c=: false
                AND Product2.itemGroupManualBlock__c =: false
                AND (Product2.Name  like:Search 
                OR Product2.ISBNArticleNumber__c like:Search
                OR Product2.EAN__c like:Search
                OR Product2.ISBN__c like:Search
                OR Product2.Type__c like: Search
                ) Order by Product2.Name ASC limit 70]);
            }
            */
            
            PricebookEntry[] ProductsbyPriceBook;		        
	        Set<String> Set_ProdId = new Set<String>();

            if(SearchString == null){

                ProductsbyPriceBook = Order_SoqlFactory.returnPricebookEntry('ProductSelectorLoad', SearchString, Set_ProdId,null,Pricebook2Id,null,null,PricebookStart,PricebookEnd);		
	                system.debug('**Order_SoqlFactory.Order_ProductSelectController.loadProductsbyPriceBook.ProductsbyPriceBook:Load :Size**'+ProductsbyPriceBook.size());		
	            }		
	            else{		
	                ProductsbyPriceBook = Order_SoqlFactory.returnPricebookEntry('ProductSelectorSearch', SearchString, Set_ProdId,null,Pricebook2Id,null,null,PricebookStart,PricebookEnd);             		
	                system.debug('**Order_SoqlFactory.Order_ProductSelectController.loadProductsbyPriceBook.ProductsbyPriceBook:Search :Size**'+ProductsbyPriceBook.size());            		
	            }   
        
           // Set<String> Set_ItemGroup = new Set<String>();
           // Set<String> Set_ItemPrice = new Set<String>();

            Set<String> Set_ProdItemGroup = new Set<String>();
            List<Id>  lst_ItemPrice = new List<Id>();
            for(PricebookEntry pbe:ProductsbyPriceBook){
                PricebookStart =  pbe.PriceBook2.StartDate__c;
                PricebookEnd = pbe.PriceBook2.EndDate__c;
                Set_ProdItemGroup.add(pbe.Product2Id);
                lst_ItemPrice.add(pbe.Price__c);
            }    
            system.debug('**Order_ProductSelectController: Search Set_ProdItemGroup**'+Set_ProdItemGroup);
            system.debug('**Order_ProductSelectController: Search lst_ItemPrice**'+lst_ItemPrice);
            
            
            /*
            Pricing__c[] lstPrice = [Select ListRate__c,Product__c,Product__r.Type__c,EndDate__c,IsActive__c,ProductComponent__r.Quantity__c,ProductComponent__r.Type__c,ProductComponent__r.MainProduct__c,ProductComponent__r.Product__c from Pricing__c 
            Where (ProductComponent__r.MainProduct__c in: Set_ItemGroup OR id in: Set_ItemPrice)
            AND 
            ((StartDate__c <=: PricebookStart AND EndDate__c >=: PricebookStart)
            OR 
            (StartDate__c <=: PricebookEnd AND EndDate__c >=: PricebookEnd)
            )
            AND IsActive__c =: true];
            */

            Pricing__c[] lstPrice = Order_SoqlFactory.returnPricing('ProductSelector2',Set_ProdItemGroup,lst_ItemPrice,PricebookStart,PricebookEnd);
            system.debug('**Order_SoqlFactory.Order_ProductSelectController.loadProductsbyPriceBook.lstPrice :Size**'+lstPrice.size());


            system.debug('**Order_ProductSelectController: Search lstPrice**'+lstPrice);

            Map<String,Decimal> Map_ProductPrice  =  new Map<String,Decimal>();
            Map<String,Decimal> Map_ProductQuantity  =  new Map<String,Decimal>();
            
    
            Map<String,Decimal> Map_ItemGroupBasePrice =  new Map<String,Decimal>();            
            Map<String,String> Map_ItemGroup =  new Map<String,String>();
            Map<String,String> Map_ItemGroupId =  new Map<String,String>();
            Map<String,Decimal> Map_ItemGroupPrice  =  new Map<String,Decimal>();
            Map<String,Decimal> Map_ComponentQuantity  =  new Map<String,Decimal>();
            Map<String,Decimal> Map_ComponentCount  =  new Map<String,Decimal>();
            
            Set<String> Set_ItemKitId =  new Set<String>();
          //  Set_ItemGroup = new Set<String>();
    
      
    
        for(Pricing__c item:lstPrice){   
            
                if(item.ProductComponent__r.Type__c=='Item Group Component' || item.ProductComponent__r.Type__c=='Kit Component' ){ //
                    Map_ItemGroup.put(item.ProductComponent__r.Product__c,item.ProductComponent__r.MainProduct__c);
                    Map_ItemGroupId.put(item.ProductComponent__r.Product__c,item.ProductComponent__c); //item.id
                    Map_ItemGroupPrice.put(item.ProductComponent__r.Product__c,item.ListRate__c);
                    Map_ComponentQuantity.put(item.ProductComponent__r.Product__c,item.ProductComponent__r.Quantity__c);
                 //  Set_ItemGroup.add(item.ProductComponent__r.MainProduct__c);
                    
                    
                    Decimal ListRateMain;
                    if(item.ProductComponent__r.Quantity__c != null && item.ListRate__c != null){
                        ListRateMain = item.ProductComponent__r.Quantity__c*item.ListRate__c;
                    }
                    else{
                        ListRateMain = 0;     
                    }
                    
                    if(Map_ItemGroupPrice.get(item.ProductComponent__r.MainProduct__c) == null){
                        Map_ItemGroupPrice.put(item.ProductComponent__r.MainProduct__c,ListRateMain);
                      
                    }
                    else{
                        Map_ItemGroupPrice.put(item.ProductComponent__r.MainProduct__c,Map_ItemGroupPrice.get(item.ProductComponent__r.MainProduct__c)+ListRateMain);
                    }
                   
    
                
                }
                
                if(item.ProductComponent__r.Type__c=='Kit Component'){
                    Set_ItemKitId.add(item.ProductComponent__r.Product__c); 
                }
    
                
              // NETSUITE QUANTITY UPDATE// MAIN PRODUCT RATE &&  item.Product__r.Type__c !='Item Group'
               if(item.Product__c != null ){
                    Map_ProductPrice.put(item.Product__c,item.ListRate__c);
               } 
               
    
        }        
     
      
    
            List<ProductListPrice> lstProductListPrice = new List<ProductListPrice>();
            //Used for Item Group Components
            Map<String,List<ProductListPrice>> Map_ProductListPrice = new Map<String,List<ProductListPrice>>();
      
            Set<String> Set_ProductId = new Set<String>();
    
            
           List<String> ManualDiscount  = new List<String>();
           ManualDiscount.add('--None--');
           
    
            //Populate Item Group map
            List<PricebookEntry> ProductsbyItemGroup;
            if(Map_ItemGroup.size()>0){
                /*
                ProductsbyItemGroup = new List <PricebookEntry>([Select Product2.CustomPricingAllowed__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id from PricebookEntry //,
                where Pricebook2Id =:Pricebook2Id AND Product2Id in:Map_ItemGroup.keyset() ]); //AND IsActive =:true
                */

                ProductsbyItemGroup = Order_SoqlFactory.returnPricebookEntry('ProductSelectorItemGroup', null, null,null,Pricebook2Id,Map_ItemGroup,null,null,null);		
	            system.debug('**Order_SoqlFactory.Order_ProductSelectController.loadProductsbyPriceBook.ProductsbyPriceBook:Load :Size**'+ProductsbyPriceBook.size());

                    for(PricebookEntry pbe:ProductsbyItemGroup){
                        
                        if(Map_ItemGroup.get(pbe.Product2Id) != null){ 
                                ProductListPrice prodlp = new ProductListPrice();                  
                                prodlp.ProductName =  pbe.Product2.name;
                                prodlp.ItemGroup = Map_ItemGroup.get(pbe.Product2Id);
                                
                                prodlp.ItemGroupId = Map_ItemGroupId.get(pbe.Product2Id);
    
                                prodlp.listPriceDiscountType = pbe.Product2.ProductDiscountGroup__c;
                                prodlp.ProductRateGroup = pbe.Product2.ProductRateGroup__c;
    
                                prodlp.ProductId = pbe.Product2Id;
                                prodlp.BasePrice  = Map_ItemGroupPrice.get(pbe.Product2Id);
                                prodlp.ComponentQuantity = Map_ComponentQuantity.get(pbe.Product2Id);
                                prodlp.ComponentQuantityTitle = 'Pack quantity: '+Map_ComponentQuantity.get(pbe.Product2Id);
                                prodlp.CustomPricingAllowed = pbe.Product2.CustomPricingAllowed__c;
                                
                             
    
                                prodlp.UnitPrice  = pbe.UnitPrice; 
                                prodlp.STDPrice = prodlp.BasePrice;
                                
                                prodlp.ProductTYPE = pbe.Product2.Type__c; 
                                prodlp.ProductEAN = pbe.Product2.ISBNArticleNumber__c;
                               
                                prodlp.QuantitySelectionType =  pbe.Product2.QuantitySelectionType__c;
                        
                                prodlp.PricebookEntryId = pbe.Id;
                                
                                
                                Set<String> Set_SoldInSegment = new Set<String>();
                                
                                prodlp.lstMarketSegment = new List<String>();
                               
                            
                                //Only link LPD for that ProductDiscountGroup
    
                                List<ListPriceDiscount> AddlistPriceDiscount;
                           
                               
                               Set_ProductId.add(prodlp.ProductId);
                                
                                List<String> PriceProductType = new List<String>();
                            
   
                                PriceProductType.AddAll(pbe.Product2.OrderLineType__c.Split(';'));
                                prodlp.listPriceProductType = PriceProductType;
                                
                                ManualDiscount  = new List<String>();
                                ManualDiscount.add('--None--');
    
                                if(pbe.Product2.Renewable__c ==true){
                                    ManualDiscount.add('Recurring Percentage');
                                    ManualDiscount.add('Recurring Amount');
                                    ManualDiscount.add('One-Off Percentage');                                       
                                    ManualDiscount.add('One-Off Amount');
                                    ManualDiscount.add('One-Off Amount (Subtotal)');
                                }
                                else{
                                    ManualDiscount.add('One-Off Percentage');
                                    ManualDiscount.add('One-Off Amount');
                                    ManualDiscount.add('One-Off Amount (Subtotal)');
                                }
    
                                prodlp.ManualDiscount = ManualDiscount;
                                prodlp.MarketSegment =  pbe.Product2.MarketSegment__c;
                                
                            if(Map_ProductListPrice.get(Map_ItemGroup.get(pbe.Product2Id)) == null){
                                lstProductListPrice = new List<ProductListPrice>();
                                lstProductListPrice.add(prodlp);
                                Map_ProductListPrice.put(Map_ItemGroup.get(pbe.Product2Id),lstProductListPrice);
                            }
                            else if(Map_ProductListPrice.get(Map_ItemGroup.get(pbe.Product2Id)) != null){
                                Map_ProductListPrice.get(Map_ItemGroup.get(pbe.Product2Id)).add(prodlp);
                            }
    
                        }        
                }
        }
      
    
            lstProductListPrice = new List<ProductListPrice>();
        for(PricebookEntry pbe:ProductsbyPriceBook){
            
            if(Map_ProductPrice.get(pbe.Product2Id) != null  ){    // Exclude Item Group items from main list       
                    ProductListPrice prodlp = new ProductListPrice();                  
                    prodlp.ProductName =  pbe.Product2.name;
               
                 
                    prodlp.listPriceDiscountType = pbe.Product2.ProductDiscountGroup__c;
                    prodlp.ProductRateGroup = pbe.Product2.ProductRateGroup__c;
                    prodlp.CustomPricingAllowed = pbe.Product2.CustomPricingAllowed__c;
                    
                     
                    prodlp.ProductId = pbe.Product2Id;
    
                    //Removed the option to use component price in main product list
                    prodlp.BasePrice  = Map_ProductPrice.get(pbe.Product2Id); 
                    prodlp.UnitPrice  = Map_ProductPrice.get(pbe.Product2Id);
                    if(pbe.Product2.LicenseDuration__c != null){
                        prodlp.licenceduration = decimal.valueof(pbe.Product2.LicenseDuration__c); 
                    }
                        
    
                    prodlp.STDPrice = prodlp.UnitPrice;
                 
    
                    prodlp.STDPrice = prodlp.UnitPrice;
    
                    prodlp.ProductTYPE = pbe.Product2.Type__c; 
                    prodlp.ProductEAN = pbe.Product2.ISBNArticleNumber__c;
                    prodlp.Stocknumber = pbe.Product2.Stocknumber__c;
                    prodlp.maxQuantity = pbe.Product2.maxQuantity__c;
                    
                    prodlp.DeliveryStatus = pbe.Product2.DeliveryStatus__c;
    
    
                        Set<String> Set_SoldInSegment = new Set<String>();
                        prodlp.lstMarketSegment = new List<String>();
                       
                       
    
                        List<ListPriceDiscount> AddlistPriceDiscount = new List<ListPriceDiscount>();
                        
    
                        prodlp.MarketSegment =  pbe.Product2.MarketSegment__c;
                       
    
                       
                        List<String> PriceProductType = new List<String>();
                        // PriceProductType.add('--None--');
                        PriceProductType.AddAll(pbe.Product2.OrderLineType__c.Split(';'));
                        prodlp.listPriceProductType = PriceProductType;
                        List<String> AmountDiscountManual  = new List<String>();
                        List<String> PercentDiscountManual = new List<String>();
            
                            ManualDiscount  = new List<String>();
                            ManualDiscount.add('--None--');
    
                                if(pbe.Product2.Renewable__c ==true){
                                    ManualDiscount.add('Recurring Percentage');
                                    ManualDiscount.add('Recurring Amount');
                                    ManualDiscount.add('One-Off Percentage');                                               
                                    ManualDiscount.add('One-Off Amount');
                                    ManualDiscount.add('One-Off Amount (Subtotal)');
                                }
                                else{
                                    ManualDiscount.add('One-Off Percentage');
                                    ManualDiscount.add('One-Off Amount');
                                    ManualDiscount.add('One-Off Amount (Subtotal)');
                                }
    
                                prodlp.ManualDiscount = ManualDiscount;
                            prodlp.QuantitySelectionType =  pbe.Product2.QuantitySelectionType__c;
                            if(prodlp.QuantitySelectionType == 'Defaulted to Quantity'){
                                prodlp.Quantity =1;
                            }    
                            else{
                                prodlp.Quantity=null;
                            }
    
                            prodlp.PricebookEntryId = pbe.Id;
                    
                            
                            
                            
    
                            if(Map_ProductListPrice.get(pbe.Product2Id) != null){
                                prodlp.listItemGroupComponent  = Map_ProductListPrice.get(pbe.Product2Id);
                                prodlp.ItemGroupComponent = true;
                            }
                            else{
                                prodlp.ItemGroupComponent = false;   
                            }
    
                        
    
                            Set_ProductId.add(prodlp.ProductId);
                            lstProductListPrice.add(prodlp);
                }
                
            }
            
           
              
            Return lstProductListPrice;
           
           
            
        }
        
        
  
        public static string  ProcessInsertOpportunityLines(List<OrderLineItem> OrderItems,String ContractId,String OrderId, Decimal TotalNumberofStudents,List<Account> AccountbyShipto){
           

            List<OpportunityLineItem> lstOppItem = new List<OpportunityLineItem>();

            List<OrderLineItem> lstOrderItemGroup = new List<OrderLineItem>();
            Set<String> Set_DontDelete = new Set<String>();
            Set<String> Set_Products = new Set<String>();
            
            for(OrderLineItem item:OrderItems){
                Set_Products.add(item.ProductId);
            }  
    
           // Product2[] lstProduct = [Select id,Type__c,FreeFromDate__c,IsRegularOrderPossible__c,IsInspectionCopyOrderPossible__c,IsUseCopyOrderPossible__c,FixedStartDate__c,StartDate__c,LicenseDuration__c,Renewable__c from Product2 where id in: Set_Products];
    
           Product2[] lstProduct = Order_SoqlFactory.returnProduct(Set_Products);	    
           system.debug('**Order_SoqlFactory.Order_ProductSelectController.ProcessInsertOpportunityLines.lstProduct :Size**'+lstProduct.size());

            Map<String,String> Map_ProdType = new Map<String,String>();
            Map<String,Boolean> Map_Renewable = new Map<String,Boolean>();
            Map<String,Date> Map_StartDate = new Map<String,Date>();
            Map<String,Decimal> Map_Terms = new Map<String,Decimal>();
            

            Date FixedStartDate;

            for(Product2 prod:lstProduct){
                
                Map_Renewable.put(prod.id, prod.Renewable__c);
                Map_ProdType.put(prod.id, prod.Type__c);
                
            }
            
            Date LatestDate=system.today();
            Date EarliestDate=null;
            
            for(OrderLineItem item:OrderItems){
                
                if(item.IsEdited==true){
                  
                        OpportunityLineItem oppItem = new OpportunityLineItem();
                        oppItem.OpportunityId = OrderId;
                        oppItem.Product2Id = item.ProductId;
                        oppItem.ProductType__c = Map_ProdType.get(item.ProductId);
                        oppItem.Renewable__c =  Map_Renewable.get(item.ProductId);
                        oppItem.Quantity = item.Quantity;
                        oppItem.UnitPrice = item.UnitPrice;
                        oppItem.ComponentListPrice__c = item.BasePrice;
                        oppItem.LicenseDuration__c = item.LicenceDuration;
                        oppItem.Terms__c = item.OppTerms;
                        oppItem.ListPriceDiscount__c = item.listPriceRateId;
                        oppItem.ServiceDate = item.OppServiceDate;
                        oppItem.OrderLineType__c = item.PriceDiscount;
                        oppItem.ShipTo__c  = item.ShipToAccountId;  //BILL TO
                        
                        if(oppItem.Terms__c != null && oppItem.ServiceDate != null){
                            Map_Terms.put(item.ItemId, oppItem.Terms__c);
                            Map_StartDate.put(item.ItemId, oppItem.ServiceDate);    
                        }

                        if(oppItem.Terms__c != null && oppItem.ServiceDate != null){
                            if(LatestDate < oppItem.ServiceDate.addMonths(integer.valueof(oppItem.Terms__c))){
                                LatestDate =  oppItem.ServiceDate.addMonths(integer.valueof(oppItem.Terms__c));
                            }
                        }
                        
                        if(EarliestDate > oppItem.ServiceDate || EarliestDate == null){
                            EarliestDate = oppItem.ServiceDate;
                        }

                        if(item.ItemId != null && item.IsnewItem !='True'){
                            oppItem.Id = item.IId;
                        }       

                        if(item.DiscountOption !='--None--'){
                            oppItem.ManualDiscount__c = item.DiscountOption;
                        }

                        if(oppItem.ManualDiscount__c != null){
                            if(oppItem.ManualDiscount__c.contains('Percent')){
                                oppItem.ManualDiscountPercent__c = item.DiscountPercent;
                                oppItem.ManualDiscountValue__c = item.STDPrice * item.Quantity*((item.DiscountPercent)/100);
                            }
                            else if(oppItem.ManualDiscount__c.contains('Amount')){
                                oppItem.ManualDiscountPercent__c = null;
                                oppItem.ManualDiscountValue__c = item.DiscountAmount;
                            }
                           else{
                                oppItem.ManualDiscountPercent__c = null;
                                oppItem.ManualDiscountValue__c = null;
                           }
                        }


                        if(item.ItemGroup == null && item.ItemGroupComponent== true){
                            oppItem.UnitPrice = 0;
                            oppItem.NetSalesPriceItemGroup__c = item.UnitPrice.setScale(2);
                            oppItem.DiscountedPriceItemGroup__c = item.STDPrice;
                            oppItem.ListPriceItemGroup__c = Item.BasePrice;
                            oppItem.ComponentListPrice__c = 0;
                                                        
                        }
                        else{
                            oppItem.UnitPrice = item.UnitPrice.setScale(2);
                            oppItem.ComponentListPrice__c = Item.BasePrice;                            
                        }
                        
                        if(item.ItemGroup == null){
                            oppItem.Quantity = item.Quantity;
                            oppItem.NetsuiteQuantity__c = item.Quantity;
                           
                        }
                        else{
                            oppItem.Quantity = item.ComponentQuantityFinal;
                            oppItem.NetsuiteQuantity__c =  item.Quantity;
                        }
                        
            
                        if(item.ItemGroup == null && item.ItemGroupComponent != true){
                            oppItem.Renewable__c= Map_Renewable.get(item.ProductId);
                        }


                        if(item.ItemGroup == null){
                            oppItem.FormGroupId__c = item.ItemId;
                        }
 //Item Groups           
                        

                        if(item.ItemGroup != null){
                            lstOrderItemGroup.add(item);
                            oppItem.Group__c = item.ItemGroup;
                        }
//Item Groups

                        lstOppItem.add(oppItem);
                } 
    
                if(item.IId != null){
                    Set_DontDelete.add(item.IId);
                }      
            }
            try{   
                    upsert lstOppItem id;

                    

                //----------- item groups
                    
                        Map<String,String> Map_itemGroup = new Map<String,String>();
                          
                        String ShiptoProdGroup;
                        for(OpportunityLineItem  item:lstOppItem){
                
                            if(item.FormGroupId__c != null){                
                                Map_itemGroup.put(item.FormGroupId__c ,item.id );
                            }
                        }    
                
                
                    //This could get moved to UPDATE BELOW
                
                        List<OpportunityLineItem> lstOrderItemComponent = new List<OpportunityLineItem>();
                      
                
                        Set<String> Set_ItemProd = new Set<String>();

                            for(OrderLineItem Oitem:lstOrderItemGroup){
                                
                                for(OpportunityLineItem  item:lstOppItem){
                                 
                                
                                     ShiptoProdGroup = OItem.ItemGroup;
                                     ShiptoProdGroup += item.Product2Id;
                               
                                     if(OItem.ProductId == item.Product2Id && OItem.ItemGroup != null && item.Shipto__c  == OItem.ShipToAccountId && !Set_ItemProd.contains(ShiptoProdGroup) && item.Group__c== OItem.ItemGroup){
                                        
                                        Set_ItemProd.add(item.id);
                                        
                                        item.ProductComponent__c = OItem.ItemGroupId; //New line
                                        
                                        if(Map_itemGroup.get(OItem.ItemGroup) != null){
                                            item.ItemGroup__c = Map_itemGroup.get(OItem.ItemGroup);
                                            item.ItemGroupId__c = Map_itemGroup.get(OItem.ItemGroup);
                                        }
                                        else{
                                            item.ItemGroup__c = OItem.ItemGroup;
                                            item.ItemGroupId__c = OItem.ItemGroup;
                                        }
                
                                        item.Terms__c = Map_Terms.get(item.ItemGroupId__c);
                                        item.ServiceDate = Map_StartDate.get(item.ItemGroupId__c);

                                        lstOrderItemComponent.add(item);
                                    }
                                
                                } 
                            }

                            if(lstOrderItemComponent.size()>0){
                                
                                update  lstOrderItemComponent;
                            } 
                              
                        

                        //----------- item groups


                    for(OpportunityLineItem item:lstOppItem){
                        Set_DontDelete.add(item.id);
                    }
                  
                    OpportunityLineItem[] lstOppItemToDelete = [Select id from OpportunityLineItem where id not in:Set_DontDelete  and OpportunityId  =:OrderId];    
                    delete lstOppItemToDelete;
                    
                    
                    Opportunity[] CurOpportunity = [Select 	ContractEndDate__c,EndDate__c,ContractStartDate__c from Opportunity where id =:OrderId ];

                    if(CurOpportunity.size()>0){
                        
                        CurOpportunity[0].ContractStartDate__c = EarliestDate;
                        CurOpportunity[0].EndDate__c = LatestDate;                     
                        update CurOpportunity;
                    }
                        
            }
            catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
                system.debug('****Order_ProductSelectController: Opp Insert: ERROR**'+e.getMessage());
                HandleCustomException.LogException(e);
                OrderId = e.getMessage();
                return OrderId;
            }
            
    
            
            
    
            return OrderId;
        }
    
        
        Public static string   ProcessInsertOrderItems(List<OrderLineItem> OrderItems,String ContractId,String OrderId, Decimal TotalNumberofStudents,List<Account> AccountbyShipto){       
            
            Contract[] Contract = [Select AccountId,NumberofUsers__c,SoldUsers__c,StartDate,Pricebook2Id,PaymentMethod__c,ShippingCostMethod__c,PricingMethod__c,defaultBilltoAccount__c from Contract where id =: ContractId];
            
            system.debug('****Order_ProductSelectController: OrderItems 1**');
    
            //GET Subsidoaries
            if(Contract.size()>0){    
              
            }
    
            Id NewOrderId = OrderId;
             
    
            Set<String> Set_Sub = new Set<String>();
            Map<String,String> Map_Sub = new Map<String,String>(); 
            Map<String,String> Map_Netsuite = new Map<String,String>(); 
          // RETURN: Hfdstructuur__c,   
          //  Order[] CurOrder = [SELECT AccountSubsidiary__c,MaxOrderLine__c,MultipleShippingLocations__c,Hfdstructuur__c,Pricebook2.Name,Billto__r.OperatingCompany__c,Type,Account.NetsuiteInternalId__c,OperatingCompany__c,ShippingIndicationRule__c,ShippingCost__c,InsertProductSelector__c,CustomerReference__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c, Source__c FROM Order WHERE id=: NewOrderId];
          
        //  Order[] CurOrder = [SELECT AccountSubsidiary__c,MaxOrderLine__c,MultipleShippingLocations__c,Pricebook2.Name,Billto__r.OperatingCompany__c,Type,Account.NetsuiteInternalId__c,OperatingCompany__c,ShippingIndicationRule__c,ShippingCost__c,InsertProductSelector__c,CustomerReference__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c, Source__c FROM Order WHERE id=: NewOrderId];
        List<Id> lstOrderId = new List<Id>();
        lstOrderId.add(OrderId);

        Order[] CurOrder = Order_SoqlFactory.returnQueryOrder(lstOrderId,null,null);
        system.debug('**Order_SoqlFactory.Order_ProductSelectController.CurOrder :Size**'+CurOrder.size());

          List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
            if(Contract.size()>0){
                Set_Sub.add(Contract[0].defaultBilltoAccount__c);
              
            }
            else if(CurOrder.size()>0){
                Set_Sub.add(CurOrder[0].Billto__c);
              
                if(CurOrder[0].ContractId != null){
                    ContractId = CurOrder[0].ContractId;
                }
            }    
            
           
            List<OrderItem> lstOrderItem = new List<OrderItem>();
            List<OrderItem> lstOrderItemToDelete = new List<OrderItem>();
            List<OrderLineItem> lstOrderItemGroup = new List<OrderLineItem>();
    
            Set<String> Set_ExistingAccIdCon = new Set<String>(); 
            Set<String> Set_ExistingAccIdOrd = new Set<String>(); 
    
            Set<String> Set_NewAccIdCon = new Set<String>();
            Set<String> Set_NewAccIdOrd = new Set<String>();
    
           
    
    
            if(ContractId != null){
    
                ContractShipto__c[] lstContractShipto = [Select id,ShiptoAccount__c from ContractShipto__c where Contract__c =: ContractId];
    
                for(ContractShipto__c con:lstContractShipto){
                    Set_ExistingAccIdCon.add(con.ShiptoAccount__c);
                }
    
            }
            if(NewOrderId != null){
    
                OrderShipto__c[] lstOrderShipto = [Select id,ShiptoAccount__c from OrderShipto__c where Order__c =: NewOrderId];
                
                for(OrderShipto__c ord:lstOrderShipto){
                    Set_ExistingAccIdOrd.add(ord.ShiptoAccount__c);
                }
    
            }
    
    
            for(Account shipto:AccountbyShipto){
                if(!Set_ExistingAccIdOrd.Contains(shipto.Id)){
                    Set_NewAccIdOrd.Add(shipto.Id);
                }
                if(!Set_ExistingAccIdCon.Contains(shipto.Id)){
                    Set_NewAccIdCon.Add(shipto.Id);
                }
            }
    
            Set_Sub = new Set<String>();
    
            Set<String> Set_Products = new Set<String>();
            for(OrderLineItem item:OrderItems){
                Set_Sub.add(item.ShipToAccountId);
                Set_Products.add(item.ProductId);
            }  
    
          //  Product2[] lstProduct = [Select id,Type__c,FreeFromDate__c,IsRegularOrderPossible__c,IsInspectionCopyOrderPossible__c,IsUseCopyOrderPossible__c,FixedStartDate__c,StartDate__c,LicenseDuration__c,Renewable__c from Product2 where id in: Set_Products];
    
          Product2[] lstProduct = Order_SoqlFactory.returnProduct(Set_Products);		
          system.debug('**Order_SoqlFactory.Order_ProductSelectController.ProcessInsertOrderItems.lstProduct :Size**'+lstProduct.size());

            Map<String,Date> Map_FreeFromDate = new Map<String,Date>();
            Map<String,Date> Map_FixedStartDate = new Map<String,Date>();
        
            Map<String,Decimal> Map_LicenseDuration = new Map<String,Decimal>();
            Map<String,Boolean> Map_Renewable = new Map<String,Boolean>();
            Map<String,String> Map_ProdType = new Map<String,String>();
    
            //To be deleted: Moved to trigger
            Map<String,Boolean> Map_InspectionCopyOrder = new Map<String,Boolean>();
            Map<String,Boolean> Map_RegularOrder = new Map<String,Boolean>();
            Map<String,Boolean> Map_UseCopyOrder = new Map<String,Boolean>();       
            //To be deleted: Moved to trigger
           
            Date FixedStartDate;
            for(Product2 prod:lstProduct){
                
                //To be deleted: Moved to trigger
                Map_InspectionCopyOrder.put(prod.id,prod.IsInspectionCopyOrderPossible__c);
                Map_RegularOrder.put(prod.id,prod.IsRegularOrderPossible__c);
                Map_UseCopyOrder.put(prod.id,prod.IsUseCopyOrderPossible__c);
                //To be deleted: Moved to trigger
    
                if(prod.FixedStartDate__c != null){
                    FixedStartDate = date.newinstance(system.today().year(), prod.FixedStartDate__c.month(), prod.FixedStartDate__c.day());
                    Map_FixedStartDate.put(prod.id,FixedStartDate);
                }
          

                if(prod.LicenseDuration__c != null){
                    Map_LicenseDuration.put(prod.id,decimal.valueof(prod.LicenseDuration__c));
                }
    
                Map_Renewable.put(prod.id,prod.Renewable__c);
                Map_ProdType.put(prod.id, prod.Type__c);
                
            }
    
            
          //  lst_AccSubMaps = returnAccountSubsidiary(Set_Sub);
    
          lst_AccSubMaps =  Order_SoqlFactory.returnAccountSubsidiary(Set_Sub);		    
          system.debug('**Order_SoqlFactory.Order_ProductSelectController.ProcessInsertOrderItems.lst_AccSubMaps :Size**'+lst_AccSubMaps.size());
    
           Map_Sub = lst_AccSubMaps[0];
           Map_Netsuite = lst_AccSubMaps[1];
           
    
           
        Set<String> Set_DontDelete = new Set<String>();
        Map<String,Date> Map_StartDate = new Map<String,Date>();
        Map<String,Date> Map_EndDate = new Map<String,Date>();
        Map<String,Decimal> Map_Terms = new Map<String,Decimal>();

        

        for(OrderLineItem item:OrderItems){
              if(item.IsEdited==true){
    
                OrderItem OItem = new OrderItem();
                             
                OItem.OrderStatus__c = 'Draft';
                OItem.OrderId = NewOrderId; 
                OItem.InsertProductSelector__c = true;
               
                if(CurOrder[0].MultipleShippingLocations__c == false && CurOrder[0].Hfdstructuur__c != null){
                    OItem.Hfdstructuur__c = CurOrder[0].Hfdstructuur__c;
                }    
                
                
                OItem.ComponentListPrice__c = Item.BasePrice;
                if(item.ItemGroup == null && item.ItemGroupComponent== true){
                    OItem.UnitPrice = 0;
                    OItem.NetSalesPriceItemGroup__c = item.UnitPrice.setScale(2);
                    OItem.DiscountedPriceItemGroup__c = item.STDPrice;
                    OItem.ListPriceItemGroup__c = Item.BasePrice;
                    OItem.ComponentListPrice__c = 0;                   
                }
                else{
                    OItem.UnitPrice = item.UnitPrice.setScale(2);                   
                }
                
                if(item.ItemGroup == null){
                    OItem.Quantity = item.Quantity;
                    OItem.NetsuiteQuantity__c = item.Quantity;
                }
                else{
                    OItem.Quantity = item.ComponentQuantityFinal;
                    OItem.NetsuiteQuantity__c =  item.Quantity;
                }
                
    
                if(item.ItemGroup == null && item.ItemGroupComponent != true){
                    OItem.Renewable__c= Map_Renewable.get(item.ProductId);
                }
                
           
                OItem.ListPriceDiscount__c =  item.listPriceRateId;  
                OItem.Product2Id = item.ProductId;
                
                
                OItem.PricebookEntryId = item.PricebookEntryId;
                OItem.ShipToAccount__c  = item.ShipToAccountId; 
                OItem.Account__c = CurOrder[0].Billto__c ;
                
                OItem.OrderSource__c = CurOrder[0].Source__c;		
                OItem.OrderType__c = CurOrder[0].Type;


                OItem.AccountSubsidiary__c = Map_Sub.get(item.ShipToAccountId);            
                

                Oitem.NetSuiteIdBilltoAccount__c = CurOrder[0].Account.NetsuiteInternalId__c;
                
                if(item.CustomerReference == null){
                    OItem.CustomerReference__c  =  CurOrder[0].CustomerReference__c;
                }
                
                OItem.OperatingCompany__c  = CurOrder[0].OperatingCompany__c;
    
                //To be deleted: Moved to trigger
                OItem.NetsuiteInternalId__c = Map_Netsuite.get(item.ShipToAccountId);
                OItem.NetSuiteIdShiptoAccount__c = Map_Netsuite.get(item.ShipToAccountId);
                Oitem.ShippingIndicationRule__c = CurOrder[0].ShippingIndicationRule__c;
                
                Oitem.IsInspectionCopyOrderPossible__c = Map_InspectionCopyOrder.get(item.ProductId);
                Oitem.IsRegularOrderPossible__c = Map_RegularOrder.get(item.ProductId);
                Oitem.IsUseCopyOrderPossible__c = Map_UseCopyOrder.get(item.ProductId);
                //To be deleted: Moved to trigger
                
                
                Oitem.ProductLicenseDuration__c = Map_LicenseDuration.get(item.ProductId);
                OItem.ProRataMonths__c = item.ProRataMonths;
                OItem.ProRataRate__c = item.ProRataRate;

                if(CurOrder[0].Pricebook2.Name.contains('Professional')){
                    Oitem.StartDate__c = item.OppServiceDate;

                    if(item.OppServiceDate >= CurOrder[0].EffectiveDate ){
                        Oitem.ServiceDate = item.OppServiceDate;
                    }
                    
                    if(Oitem.ProductLicenseDuration__c != null && CurOrder[0].MaxOrderLine__c == null && OItem.ProRataMonths__c == null){
                        Oitem.EndDate = date.valueof(item.OppServiceDate).addMonths(integer.valueof(Oitem.ProductLicenseDuration__c))-1;
                    }
                    if(CurOrder[0].MaxOrderLine__c == null){
                        Oitem.Terms__c = item.OppTerms;
                    }    
                }
                
                if(Oitem.Terms__c != null){
                    Map_Terms.put(item.ItemId, Oitem.Terms__c);
                    Map_StartDate.put(item.ItemId, Oitem.ServiceDate);
                    Map_EndDate.put(item.ItemId, Oitem.EndDate);      
                }

                OItem.ProductType__c = Map_ProdType.get(item.ProductId);
               
                 OItem.OrderLineType__c = item.PriceDiscount;
    
                 if(!Set_ExistingAccIdCon.Contains(OItem.ShipToAccount__c)){
                    Set_NewAccIdCon.Add(OItem.ShipToAccount__c);
                }
                if(!Set_ExistingAccIdOrd.Contains(OItem.ShipToAccount__c)){
                    Set_NewAccIdOrd.Add(OItem.ShipToAccount__c);
                }
                
                if(item.DiscountOption !='--None--'){
                    OItem.ManualDiscount__c = item.DiscountOption;
                }
    
                if(OItem.ManualDiscount__c != null){
                    if(OItem.ManualDiscount__c.contains('Percent')){
                        OItem.ManualDiscountPercent__c = item.DiscountPercent;
                        OItem.ManualDiscountValue__c = item.STDPrice * item.Quantity*((item.DiscountPercent)/100);
                    }
                    else if(OItem.ManualDiscount__c.contains('Amount')){
                        OItem.ManualDiscountPercent__c = null;
                        OItem.ManualDiscountValue__c = item.DiscountAmount;
                    }
                   else{
                        OItem.ManualDiscountPercent__c = null;
                        OItem.ManualDiscountValue__c = null;
                   }
                }
              
              
    
                if(item.ItemId != null && item.IsnewItem !='True'){
                    OItem.Id = item.IId;
                    
                } 
                
                if(item.ItemGroup == null){
                    OItem.FormGroupId__c = item.ItemId;
                }
                
        
               
                lstOrderItem.Add(OItem); 
                if(item.ItemGroup != null){
                    lstOrderItemGroup.add(item);
                    OItem.Group__c = item.ItemGroup;
                }



              }     
 
             
                if(item.IId != null){
                    Set_DontDelete.add(item.IId);
                }   
                
              
                
            }
          
        
            try{
                system.debug('****Order_ProductSelectController: OrderItem Trigger: Before Insert**');
                upsert lstOrderItem id;
             
            }
            catch(exception e){
                
                HandleCustomException.LogException(e);
                NewOrderId = e.getMessage();
                system.debug('****Order_ProductSelectController: Error: After Insert Order Item**'+NewOrderId);
                return NewOrderId;
            }
            
            
             
         /* FUTURE + REST OPTION */
         try{
            Map<String,String> Map_itemGroup = new Map<String,String>();
              
            String ShiptoProdGroup;
            for(OrderItem  item:lstOrderItem){
    
                if(item.FormGroupId__c != null){
    
                    Map_itemGroup.put(item.FormGroupId__c ,item.id );
                    
                }
            }    
    
    
        //This could get moved to UPDATE BELOW
    
            List<OrderItem> lstOrderItemComponent = new List<OrderItem>();
          
    
            Set<String> Set_ItemProd = new Set<String>();
    
                for(OrderLineItem Oitem:lstOrderItemGroup){
                    
                    for(OrderItem  item:lstOrderItem){
                
                    
                       ShiptoProdGroup = OItem.ItemGroup;
                         ShiptoProdGroup += item.Product2Id;
                        if(OItem.ProductId == item.Product2Id && OItem.ItemGroup != null && item.ShipToAccount__c  == OItem.ShipToAccountId && !Set_ItemProd.contains(ShiptoProdGroup) && item.Group__c== OItem.ItemGroup){
                            
                            Set_ItemProd.add(item.id);
                            
                            item.ProductComponent__c = OItem.ItemGroupId; //New line
                            
                            if(Map_itemGroup.get(OItem.ItemGroup) != null){
                                item.ItemGroup__c = Map_itemGroup.get(OItem.ItemGroup);
                                item.ItemGroupId__c = Map_itemGroup.get(OItem.ItemGroup);
                            }
                            else{
                                item.ItemGroup__c = OItem.ItemGroup;
                                item.ItemGroupId__c = OItem.ItemGroup;
                            }
                            
                            item.Terms__c = Map_Terms.get(item.ItemGroupId__c);
                            item.ServiceDate = Map_StartDate.get(item.ItemGroupId__c);
                            item.EndDate = Map_EndDate.get(item.ItemGroupId__c);
 
                            lstOrderItemComponent.add(item);
                        }
                    
                    } 
                }
 
                if(lstOrderItemComponent.size()>0){
                    
                    update  lstOrderItemComponent;
                } 
                  
            }
            catch(exception e){
                
                HandleCustomException.LogException(e);
                NewOrderId = e.getMessage();
                system.debug('****Order_ProductSelectController: Item Group Error:**'+NewOrderId);
                return NewOrderId;
            }
            
            
            system.debug('****Order_ProductSelectController: Insert Item: After Group 1**');
            if(ContractId != null){
               
             
                list<ContractShipto__c> lstContractShiptoAdd = new  list<ContractShipto__c>();
                for(String str:Set_NewAccIdCon){
                   
                       if(str != null){ 
                            ContractShipto__c ContractShipto = new  ContractShipto__c();
                            ContractShipto.ShiptoAccount__c = str;
                            ContractShipto.Contract__c = ContractId;
                            lstContractShiptoAdd.add(ContractShipto);
                        } 
                    
                }
                try{
                    if(lstContractShiptoAdd.size()>0){
                        insert lstContractShiptoAdd;
                    }
                }
                catch(exception e){
                    HandleCustomException.LogException(e);
                    NewOrderId = e.getMessage();
                    return NewOrderId;
                }
                
                
            }
            system.debug('****Order_ProductSelectController: After Group Insert Item 2**');
            if(NewOrderId != null){
    
                List<OrderShipto__c>  lstOrderShiptoAdd = new List<OrderShipto__c> ();
                
                for(String str:Set_NewAccIdOrd){
                    if(str != null){
                        OrderShipto__c  OrderShipto = new OrderShipto__c();
                        OrderShipto.ShiptoAccount__c = str;
                        OrderShipto.Order__c =NewOrderId ;
                        lstOrderShiptoAdd.add(OrderShipto);
                    }
                }
                try{
                    if(lstOrderShiptoAdd.size()>0){
                        insert lstOrderShiptoAdd;
                    } 
                }
                catch(exception e){
                    HandleCustomException.LogException(e);
                    NewOrderId = e.getMessage();
                    return NewOrderId;
                }
                  
                
            }
       
            try{
                for(OrderItem item:lstOrderItem){
                    Set_DontDelete.add(item.id);
                }
                system.debug('****Order_ProductSelectController: Save Order: Set_DontDelete**'+Set_DontDelete);
                
                lstOrderItemToDelete = [Select id from OrderItem where id not in:Set_DontDelete  and OrderId =:NewOrderId];    
                delete lstOrderItemToDelete;
               
            }
            catch(exception e){
                HandleCustomException.LogException(e);
                NewOrderId = e.getMessage();
                return NewOrderId;
            }
           
    
        /* FUTURE + REST OPTION */
    
        
        
          try{
                
                List<String> Set_NewOrderId = new List<String>();
                Set_NewOrderId.add(NewOrderId);
                system.debug('****Order_ProductSelectController: Helper: triggerhandler**');
    
    
                //OrderItem[] lst_OrdItem;
                //lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(Set_DontDelete,null);
            
                OrderItem[] lst_OrdItem =  Order_SoqlFactory.returnQueryOrderItems(Set_DontDelete,null,null,null);		
                system.debug('**Order_SoqlFactory.Order_ProductSelectController.returnOrderItems.lst_OrdItem :Size**'+lstOrderItem.size());

                Order_OrderandOrdeItemHandler.OrderItemBusinessLogichandler(lst_OrdItem, CurOrder,null, 'ProductSelectorOrderItems', null,null );
    
                
    
           }
           catch(exception e){
               HandleCustomException.LogException(e);
               NewOrderId = e.getMessage();
               return NewOrderId;
           }
    
            return NewOrderId;
    
    
        } 

    
    /*
    public static List<Map<String,String>> returnAccountSubsidiary(Set<String> Set_Sub){
             
    
            AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,LegalName__c,NetsuiteInternalId__c,Account__c,Account__r.OperatingCompany__c,Account__r.isVocationalEducation__c,Account__r.isHigherEducation__c from AccountSubsidiary__c where Account__c in:Set_Sub AND (Deleted__c =:false AND 	IsInactive__c =:false) ];
    
            Map<String,String> Map_Sub = new Map<String,String>();
            Map<String,String> Map_Netsuite = new Map<String,String>();
            
            List<Map<String,String>> lst_Maps = new List<Map<String,String>>();
    
            for(AccountSubsidiary__c acc:lstAccountSubsidiary){
                
                //Commented out because Noorhoff has no need for specific logic for LegalName 'NoordhoffDigitaalBedrijf' and 
                //the OpCo else condition would then have the same add mapp logic for all OpCo's
                //if(acc.Account__r.OperatingCompany__c == 'Noordhoff'){                   
                    //if ((acc.Account__r.isVocationalEducation__c == true || acc.Account__r.isHigherEducation__c == true) && acc.LegalName__c=='NoordhoffDigitaalBedrijf' && Map_Sub.get(acc.Account__c) == null){
                      //  Map_Sub.put(acc.Account__c,acc.id);
                     //   Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);                       
                    //}
                    //else if((acc.Account__r.isVocationalEducation__c == false && acc.Account__r.isHigherEducation__c == false) && acc.LegalName__c !='NoordhoffDigitaalBedrijf' && Map_Sub.get(acc.Account__c) == null){
                    //    Map_Sub.put(acc.Account__c,acc.id);
                    //    Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);   
                   // }       
                //}
                //else{
                 //       Map_Sub.put(acc.Account__c,acc.id);
                   //     Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);
                //}    


                Map_Sub.put(acc.Account__c,acc.id);
                Map_Netsuite.put(acc.Account__c,acc.NetsuiteInternalId__c);
            }
    
            
            lst_Maps.add(Map_Sub);
            lst_Maps.add(Map_Netsuite);
            return lst_Maps;
    }
    */
     
    Public Class OrderOpportunity{
        
        @auraenabled Public String HeaderType {get;set;}
        @auraenabled Public String Type{get;set;} 
               
    }
    
    
    Public Class ProductListPrice{
            
        @auraenabled Public String ProductId {get;set;} 
        @auraenabled Public String ItemGroup {get;set;} 
        @auraenabled Public String ItemGroupId {get;set;}
        @auraenabled Public String ItemGroupType {get;set;}    
        @auraenabled Public String ProductName {get;set;} 
        @auraenabled Public String ProductSKU {get;set;} 
        @auraenabled Public String ProductTYPE {get;set;} 
        @auraenabled Public String ProductEAN {get;set;} 
        @auraenabled Public String PricebookEntryId {get;set;}
        @auraenabled Public String RateId {get;set;}
        @auraenabled Public Decimal Rate {get;set;}
        @auraenabled Public Decimal Stocknumber {get;set;}
        @auraenabled Public Decimal maxQuantity {get;set;}
        @auraenabled Public String DeliveryStatus {get;set;}
        @auraenabled Public Decimal licenceduration {get;set;}
        
        @auraenabled Public Decimal UnitPrice {get;set;}  
        @auraenabled Public Decimal Quantity {get;set;}
        @auraenabled Public Decimal BasePrice {get;set;}  
        @auraenabled Public Decimal STDPrice {get;set;} 
    
        @auraenabled Public Decimal ComponentQuantity {get;set;}
        @auraenabled Public Decimal ComponentQuantityFinal {get;set;}
        @auraenabled Public String ComponentQuantityTitle {get;set;}
        
    
        @auraenabled Public String listPriceRateId {get;set;}
        @auraenabled Public List<ListPriceDiscount> listPriceDiscount {get;set;}
        @auraenabled Public List<String> listPriceProductType {get;set;}
        @auraenabled Public String listPriceDiscountType {get;set;}
        @auraenabled Public String ProductRateGroup {get;set;}   
        @auraenabled Public List<String> ManualDiscount {get;set;}
        @auraenabled Public List<String> PercentDiscountManual {get;set;}
        @auraenabled Public List<String> AmountDiscountManual {get;set;}
        
        @auraenabled Public String QuantitySelectionType {get;set;}
        @auraenabled Public String MarketSegment {get;set;}
        @auraenabled Public List<String> lstMarketSegment {get;set;}
        @auraenabled Public List<Asset2Product> listAsset2Product {get;set;}
        @auraenabled Public List<ProductListPrice> listItemGroupComponent {get;set;}
        @auraenabled Public Boolean ItemGroupComponent {get;set;}
        @auraenabled Public Boolean CustomPricingAllowed {get;set;}
        
        
    }
    
       Public class OrderLineItem{
            
            @auraenabled Public String ItemId {get;set;} 
            @auraenabled Public String IId {get;set;}
            @auraenabled Public Boolean IsEdited {get;set;}
            @auraenabled Public String ItemGroup {get;set;} 
            @auraenabled Public String ItemGroupId {get;set;}
            @auraenabled Public String ItemGroupProductId {get;set;}
            @auraenabled Public Boolean ItemGroupComponent {get;set;}
            @auraenabled Public Decimal maxQuantity {get;set;}
            @auraenabled Public String IsnewItem {get;set;}
            @auraenabled Public String CustomerReference {get;set;}

            @auraenabled Public String OrderId {get;set;}
            @auraenabled Public Decimal Quantity {get;set;} 
            @auraenabled Public String ComponentQuantityTitle {get;set;}
            @auraenabled Public Decimal ComponentQuantityFinal {get;set;}
            @auraenabled Public Decimal ComponentQuantity {get;set;}
            @auraenabled Public Decimal Rate {get;set;}
           @auraenabled Public String DiscountOption {get;set;}
           @auraenabled Public Decimal DiscountPercent {get;set;}
           @auraenabled Public Decimal DiscountAmount {get;set;}
           
          //  @auraenabled Public String RateId {get;set;}
            @auraenabled Public Decimal Amount {get;set;}
            @auraenabled Public Decimal NoDiscAmount {get;set;}   
    
            @auraenabled Public Decimal BasePrice {get;set;}
            @auraenabled Public Decimal STDPrice {get;set;}
            @auraenabled Public Decimal UnitPrice {get;set;} 
            @auraenabled Public Decimal Count {get;set;}
    
    
            @auraenabled Public String ProductId {get;set;}
            @auraenabled Public String ShipToAccountId {get;set;}
            @auraenabled Public String CustomerDiscountGroup {get;set;}
            @auraenabled Public String Subsidiary {get;set;}
            @auraenabled Public String MarketSegment {get;set;}
    
            @auraenabled Public String ShipToAccountName {get;set;}
            @auraenabled Public String ProductName {get;set;} 
            @auraenabled Public String listPriceRateId {get;set;}
            @auraenabled Public String PricebookEntryId {get;set;}
            @auraenabled Public String PriceDiscount {get;set;}
            @auraenabled Public String ProductTYPE {get;set;}
            @auraenabled Public List<ListPriceDiscount> listPriceDiscount {get;set;}
            @auraenabled Public String listPriceDiscountType {get;set;}
            @auraenabled Public String ProductRateGroup {get;set;}
            @auraenabled Public List<String> listPriceProductType {get;set;}
            @auraenabled Public List<ProductListPrice> listItemGroupComponent {get;set;}
    
            @auraenabled Public List<String> ManualDiscount {get;set;}
            @auraenabled Public List<String> PercentDiscountManual {get;set;}
            @auraenabled Public List<String> AmountDiscountManual {get;set;}
            @auraenabled Public String QuantitySelectionType {get;set;}
            @auraenabled Public Boolean DiscountValueShow {get;set;}
            @auraenabled Public Boolean DiscountPercentShow {get;set;}
            @auraenabled Public Decimal LicenceDuration {get;set;}
            @auraenabled Public Decimal OppTerms {get;set;}
            
            @auraenabled Public Date OppServiceDate {get;set;}
            @auraenabled Public Date ItemEndDate {get;set;}
            @auraenabled Public Date ItemStartDate {get;set;}
            @auraenabled Public Decimal ProRataMonths {get;set;}
            @auraenabled Public Decimal ProRataRate {get;set;}            
            @auraenabled Public Boolean ProRata {get;set;}
            @auraenabled Public Boolean MasterOrder {get;set;}
            @auraenabled Public Boolean CustomPricingAllowed {get;set;}
            

        }
        
        
        
        Public Class ListPriceDiscount{
            
            @auraenabled Public String LPDId {get;set;} 
            @auraenabled Public String MarketSegment {get;set;} 
            @auraenabled Public String DiscountType {get;set;}       
            @auraenabled Public String OrderLineType {get;set;} 
            @auraenabled Public Decimal Discount {get;set;}
            @auraenabled Public String ProductGroup {get;set;}  
            @auraenabled Public String CustomerDiscountGroup {get;set;}
    
            
            
        }
        
        Public Class Asset2Product{
            
            @auraenabled Public String ProductId {get;set;} 
            @auraenabled Public String MarketSegment {get;set;}   
            @auraenabled Public String AccountId {get;set;}  
            @auraenabled Public Decimal Quantity {get;set;}
            @auraenabled Public Decimal ActivatedUsers {get;set;} 
            @auraenabled Public Decimal ShipToQuantity {get;set;} 
            @auraenabled Public Boolean IsMarketSegment {get;set;}      
            
        }
       
        Public Class ShiptoAccount{ 
            
            @auraenabled Public String Name {get;set;} 
            @auraenabled Public String Id {get;set;}   
            @auraenabled Public String CustomerDiscountGroup {get;set;} 
            @auraenabled Public String OperatingCompany {get;set;}  
            @auraenabled Public Decimal NumberofStudents {get;set;}
               
            
        }
        
        Public Class AssetList{ 
            @auraenabled Public String Id {get;set;}
            @auraenabled Public String Name {get;set;} 
            @auraenabled Public String ProductId {get;set;}   
            @auraenabled Public String ProductRateGroup {get;set;}
            @auraenabled Public String ProductName {get;set;}        
            @auraenabled Public Decimal Quantity {get;set;}
            @auraenabled Public String BillToAccount {get;set;}
       
        }
    }