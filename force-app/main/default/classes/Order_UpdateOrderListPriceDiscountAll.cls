public with sharing class Order_UpdateOrderListPriceDiscountAll {



    /*
    Public static void UpdateOrdeItemswithListPriceDiscount(Decimal NoStudents, List<String> lstOrderId , String PricebookId){
        
        

        try {
            OrderItem[] lstOrderItem = ProcessUpdate(NoStudents, lstOrderId , PricebookId,null,null);
            update lstOrderItem;

            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True)
      {

                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
      }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            
            HandleCustomException.LogException(e);
            system.debug('**Error Msg:**'+e.getMessage());
        }
        
     }
*/
    
    Public static List<OrderItem>  ProcessUpdate(Decimal NoStudents, List<String> lstOrderId , String PricebookId,OrderItem[] lstOrderItem, ListPriceDiscount__c[] lst_ListPriceDiscountRegular){


        system.debug('**Order_UpdateOrderListPrice 1**'+lstOrderId);

      Order[] curOrder = [Select Pricebook2Id,Billto__r.OperatingCompany__c,Billto__r.CustomerDiscountGroup__c,Type,PricingMethod__c,Billto__c from Order where id in: lstOrderId];
    
      /* OrderLineItemType__c, */
    /*  
    if(lstOrderItem == null){
        lstOrderItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,lstOrderId);
     
    }         

    Date CurDate = system.today();

    if(lst_ListPriceDiscountRegular == null){
        lst_ListPriceDiscountRegular = [Select Id,DiscountType__c,ProductDiscountGroup__c,StartAmount__c,Subsidiary__c,CustomerDiscountGroup__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c From ListPriceDiscount__c  
                                                                                        where  EndDate__c >=:CurDate 
                                                                                        AND StartDate__c  <=:CurDate  
                                                                                        ORDER BY StartQuantity__c DESC];
    }
    */


        system.debug('**Order_UpdateOrderListPrice 2: lstOrderItem**'+lstOrderItem);
        Set<String> Set_BillTo = new Set<String>();

        String OrderType='Order';
        String PricingMethod ='';
        for(Order ord:curOrder){
            Set_BillTo.add(ord.Billto__c);
            if(ord.Type =='RenewalOrder'){
                OrderType='Renewal';
            }
            
            PricingMethod = ord.PricingMethod__c;
        }

    Set<String> Set_ProdAccId = new Set<String>();   
    
    //To avoid double counting of Assets which have future renewal date and products in current order which are actually the same.

    if(OrderType=='Renewal'){
        for(OrderItem Item:lstOrderItem){
            String ProdAcc=item.Product2Id;
            ProdAcc += item.ShipToAccount__c;
            Set_ProdAccId.add(ProdAcc);
        }    
    }

    Date CurrrentDay = system.today();
    
    
    
    Map<String,Decimal> Map_OrderProdMap = new Map<String,Decimal>(); 

    Map<String,List<String>> Map_PriceProductType = new Map<String,List<String>>();
    String ProdGroup;
      

    

  //  if(PricingMethod.contains('UsageBased')){
/*
        asset[] loadAssetsListGroupRate  = [Select id,Name,Product2.Name,Product2.OrderLineType__c,PriceBook__c,PriceBook__r.FollowUpPriceBook__c,RenewalDate__c,Account.DigitalActivationEmail__c ,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,RenewalTerm__c,IsUpForRenewal__c,AccountId,PricingMethod__c,BillToAccount__r.ShippingCostMethod__c,BillToAccount__r.PaymentMethod__c,Price,Quantity, BillToAccount__c,Product2Id 
                                                from asset 
                                                where (CancellationDate__c >: CurrrentDay OR CancellationDate__c =:null)
                                                AND RenewalDate__c  >=: CurrrentDay
                                                AND (ActivationDate__c <=: CurrrentDay OR ActivationDate__c =: null)
                                                AND IsActive__c =: true
                                                AND BillToAccount__c in:Set_BillTo
                                                ]; 
                                                //AND Contract__c =:null

        system.debug('**Order_UpdateOrderListPrice: loadAssetsListGroupRate**'+loadAssetsListGroupRate.size());
*/

Date CurrentDay = system.today();
Date RenewalDay = system.today();
asset[] loadAssetsListGroupRate  = Database.query(Order_SoqlFactory.returnasset('ListPriceDiscount',Set_BillTo,null));
system.debug('**Order_SoqlFactory.Order_UpdateOrderListPriceDiscountAll.loadAssetsListGroupRate :Size**'+loadAssetsListGroupRate.size());

        for(asset ass:loadAssetsListGroupRate){
            String ProdAcc=ass.Product2Id;
            ProdAcc += ass.AccountId;

            if(!Set_ProdAccId.contains(ProdAcc)){

            
                    //'ProductDiscountGroupUsageBased
                   // system.debug('**LPD: ass.Quantity**'+ass.Quantity);         
                    //'ProductUsageBased
                    
                    ProdGroup = ass.BillToAccount__c;
                    //ProdGroup =+ ass.Product2Id;

                    if(ass.Quantity != null){ 

                     //   if(ass.PricingMethod__c=='ProductDiscountGroupUsageBased'){

                            if(ass.Product2.ProductRateGroup__c != null){
                                ProdGroup = ass.BillToAccount__c + ass.Product2.ProductRateGroup__c;
                            } 
                            else{
                                ProdGroup = ass.BillToAccount__c;
                            }  

                            if(Map_OrderProdMap.get(ProdGroup)== null){
                                Map_OrderProdMap.put(ProdGroup,ass.Quantity);               
                            }
                            else{
                                Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+ass.Quantity);         
                            }
                   
                            ProdGroup = ass.BillToAccount__c;
                            ProdGroup += ass.Product2Id;
                      
                        
                        if(Map_OrderProdMap.get(ProdGroup)== null){
                            Map_OrderProdMap.put(ProdGroup,ass.Quantity);               
                        }
                        else{
                            Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+ass.Quantity);         
                        }
                        
                    }
                    
                

                    if(Map_PriceProductType.get(ass.Product2Id) == null){
                        List<String> PriceProductType = new List<String>();
                        PriceProductType.AddAll(ass.Product2.OrderLineType__c.Split(';'));
                        Map_PriceProductType.put(ass.Product2Id,PriceProductType);
                        
                    }

            }
        }    
   // }
        system.debug('**Order_UpdateOrderListPrice:Map_OrderProdMap ***'+Map_OrderProdMap);
       
        
        Set<String> Set_AccountStudents = new Set<String>(); 
        String AccountStudents;
        for(OrderItem Item:lstOrderItem){
    
                if(Item.Order.PricingMethod__c =='OrderProductQuantity'){
                     
                    ProdGroup = Item.OrderId + Item.Product2.Name;
                    if(Map_OrderProdMap.get(ProdGroup)== null){
                        Map_OrderProdMap.put(ProdGroup,Item.Quantity);               
                    }
                    else{
                        Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+Item.Quantity);         
                    }
                
                }
                if(Item.Order.PricingMethod__c =='OrderTotalAmount'){
                      
                     ProdGroup = Item.OrderId;
                     if(Map_OrderProdMap.get(ProdGroup)== null){
                         Map_OrderProdMap.put(ProdGroup,Item.ListPrice*Item.Quantity);               
                     }
                     else{
                         Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+(Item.ListPrice * Item.Quantity));         
                     }
                 
                 }
                else if(Item.Order.PricingMethod__c=='AccountStudents'){
                    ProdGroup = Item.OrderId;
                    
                    AccountStudents = Item.OrderId;
                    AccountStudents += Item.ShipToAccount__c;

                    if(Map_OrderProdMap.get(ProdGroup)== null && !Set_AccountStudents.contains(AccountStudents)){                       
                        Set_AccountStudents.add(AccountStudents);
                        Map_OrderProdMap.put(ProdGroup,Item.ShipToAccount__r.NumberOfStudents__c);               
                    }
                    else if(!Set_AccountStudents.contains(AccountStudents)){
                        Set_AccountStudents.add(AccountStudents);
                        Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+Item.ShipToAccount__r.NumberOfStudents__c);         
                    }
                }
                else if(Item.Order.PricingMethod__c=='ProductUsageBased'){
                    
                
                    ProdGroup = Item.Order.Billto__c;
                    ProdGroup += Item.Product2Id;  

                    if(Map_OrderProdMap.get(ProdGroup)== null){
                        Map_OrderProdMap.put(ProdGroup,Item.Quantity);               
                    }
                    else{
                        Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+Item.Quantity);         
                    }
                   

                }
                else if(Item.Order.PricingMethod__c=='ProductDiscountGroupUsageBased'){
                    
                    
                    if(Item.Product2.ProductRateGroup__c != null && OrderType=='Renewal'){
                        ProdGroup = Item.Order.Billto__c + Item.Product2.ProductRateGroup__c;
                    }  
                    else if(OrderType=='Renewal'){
                        ProdGroup = Item.Order.Billto__c;
                    }
                    else{
                        ProdGroup = Item.Product2Id;    
                    }
                    
                    if(Map_OrderProdMap.get(ProdGroup)== null){
                        Map_OrderProdMap.put(ProdGroup,Item.Quantity);               
                    }
                    else{
                        Map_OrderProdMap.put(ProdGroup ,Map_OrderProdMap.get(ProdGroup)+Item.Quantity);         
                    }
                    
                }

                /*
                No need to check Prodct type: Match Order line type with LDP?
                List<String> PriceProductType = new List<String>();
                PriceProductType.AddAll(Item.Product2.OrderLineType__c.Split(';'));                
                Map_PriceProductType.put(Item.Product2Id,PriceProductType);
                */
                
    }

    system.debug('**Order_UpdateOrderListPrice: Map_OrderProdMap Final'+Map_OrderProdMap);

    lstOrderItem = returnItemswithListpriceId(OrderType,lstOrderItem,lst_ListPriceDiscountRegular,Map_OrderProdMap); //,Map_PriceProductType

    return lstOrderItem;
}    

Public static List<OrderItem> returnItemswithListpriceId(String Type, List<OrderItem> lstOrderItem, List<ListPriceDiscount__c> lst_ListPriceDiscountRegular,Map<String,Decimal> Map_OrderProdMap){ //, Map<String,List<String>> Map_PriceProductType

    Boolean listPriceSelected;
    String ProdGroup;


    Map<String,Decimal> Map_ItemGroupLP = new Map<String,Decimal>(); 
    Map<String,Decimal> Map_ItemGroupDP = new Map<String,Decimal>();
    Map<String,Decimal> Map_ItemGroupNSP = new Map<String,Decimal>();
    Map<String,Decimal> Map_LPDRate = new Map<String,Decimal>();


Boolean UpdateItemGroup = false;
    for(OrderItem Item:lstOrderItem){
      // system.debug('**List Price Discount 1:**');
        listPriceSelected=false;


        if(item.OrderLineType__c == 'Free' || item.OrderLineType__c =='Service'){
            item.ListPriceDiscount__c = null;
            item.UnitPrice = 0;
            item.ManualDiscountValue__c = null;
            item.ManualDiscountPercent__c = null;
            item.ManualDiscount__c = null;
        } 
        else{       
            if(item.ListPriceItemGroup__c == null){


                        //Get Unit price without manual discount. Determines List Price
                       // system.debug('**List Price Discount 2:**');
                        item.ListPriceDiscount__c = null;
                        
                        if(item.ManualDiscount__c != null && (!item.ManualDiscount__c.contains('Percentage'))){
                            if(item.ComponentListPrice__c != null && item.ComponentListPrice__c >= 0 ){
                                item.UnitPrice = item.ComponentListPrice__c-item.ManualDiscountValue__c;
                                UpdateItemGroup = true;
                            }
                            else{
                                item.UnitPrice = item.ListPrice-item.ManualDiscountValue__c;
                            }
                            item.UnitPrice = item.UnitPrice.setScale(2);
                            
                        }
                        else if(item.ManualDiscount__c != null && (item.ManualDiscount__c.contains('Percentage'))){
                            
                            if(item.ComponentListPrice__c != null && item.ComponentListPrice__c >=0 ){
                                item.UnitPrice = item.ComponentListPrice__c-(item.ComponentListPrice__c*(Item.ManualDiscountPercent__c/100));
                                UpdateItemGroup = true;
                            }
                            else{
                                item.UnitPrice = item.ListPrice-(item.ListPrice*(Item.ManualDiscountPercent__c/100));
                            }
                            item.UnitPrice = item.UnitPrice.setScale(2);
                            
                        }
                        else{
                            

                            if(item.ComponentListPrice__c != null && item.ComponentListPrice__c >= 0 ){
                                item.UnitPrice = item.ComponentListPrice__c.setScale(2);
                            }
                            else{
                                item.UnitPrice = item.ListPrice.setScale(2);
                            }
                        }
                        
                        if(Item.Order.PricingMethod__c=='ProductDiscountGroupUsageBased'){
                                                                
                            if(Item.Product2.ProductRateGroup__c != null){
                                ProdGroup = Item.Order.Billto__c + Item.Product2.ProductRateGroup__c;
                            } 
                            else{
                                ProdGroup = Item.Order.Billto__c;   
                            }

                            //Add Asset usage to current Product Quantity summ for order
                            // Like Product Selector uses ItemId 

                            if(Map_OrderProdMap.get(ProdGroup) != null && Map_OrderProdMap.get(Item.Product2Id) != null){
                                    Map_OrderProdMap.put(Item.Id,Map_OrderProdMap.get(Item.Product2Id)+Map_OrderProdMap.get(ProdGroup));                                                   
                            }
                            else if(Map_OrderProdMap.get(Item.Product2Id) != null){
                                    Map_OrderProdMap.put(Item.Id,Map_OrderProdMap.get(Item.Product2Id)); 
                            }
                            else if(Map_OrderProdMap.get(ProdGroup) != null){
                                   Map_OrderProdMap.put(Item.Id,Map_OrderProdMap.get(ProdGroup)); 
                            }

                            ProdGroup = Item.Id;

                        }
                        else if(Item.Order.PricingMethod__c=='ProductUsageBased'){
                            
                            ProdGroup = Item.Order.Billto__c;
                            ProdGroup += Item.Product2Id;
                            
                           
                        }
                        else if(Item.Order.PricingMethod__c =='OrderProductQuantity'){
                            
                            ProdGroup = Item.OrderId + Item.Product2.Name;
                            

                        }
                        else if(Item.Order.PricingMethod__c =='OrderTotalAmount'){
                            
                            ProdGroup = Item.OrderId;

                        }
                        else if(Item.Order.PricingMethod__c=='AccountStudents'){
                            ProdGroup = Item.OrderId;
                        } 

                        system.debug('**Order_UpdateOrderListPrice: lst_ListPriceDiscountRegular.size**'+lst_ListPriceDiscountRegular.size());
                        for(ListPriceDiscount__c lpr:lst_ListPriceDiscountRegular){      
                            
                            
                      
                        if(lpr.CustomerDiscountGroup__c == Item.Order.Billto__r.CustomerDiscountGroup__c && lpr.Subsidiary__c == Item.Order.Billto__r.OperatingCompany__c && listPriceSelected==false){
                             
                             
                              system.debug('**Order_UpdateOrderListPrice: IN LPD 1**');
                               if(Item.Order.PricingMethod__c !='OrderTotalAmount' && Map_OrderProdMap.get(ProdGroup) >= lpr.StartQuantity__c
                               || Item.Order.PricingMethod__c =='OrderTotalAmount' && Map_OrderProdMap.get(ProdGroup) >= lpr.StartAmount__c){
                                                            
                                system.debug('**Order_UpdateOrderListPrice: IN LPD 2**');
                                        if(lpr.ProductDiscountGroup__c == item.Product2.ProductDiscountGroup__c){ 
                                                /*
                                                if(Map_PriceProductType.get(Item.Product2Id) != null){

                                                
                                                    //Can this for be removed: Match Order line type with LDP?
                                                        
                                                    for(String ProductType:Map_PriceProductType.get(Item.Product2Id)){
                                                        system.debug('**Order_UpdateOrderListPrice: IN LPD 3**');
                                                        (lpr.OrderLineType__c == ProductType) &&
                                                      */                                                                    
                                                        if( (lpr.OrderLineType__c == Item.OrderLineType__c  ) && listPriceSelected==false){
                                                            if(lpr.DiscountType__c!='Market Segment' || (lpr.DiscountType__c=='Market Segment' && lpr.MarketSegment__c == item.Product2.MarketSegment__c)){
                                                                        
                                                                system.debug('**Order_UpdateOrderListPrice: IN LPD 4**'+(lpr.Rate__c/100));
                                                                system.debug('**Order_UpdateOrderListPrice: IN LPD 4 ID**'+item.id);
                                                                    
                                                                    listPriceSelected=true;

                                                                    if(item.ComponentListPrice__c != null && item.ComponentListPrice__c >=0 ){
                                                                        UpdateItemGroup = true;
                                                                    }
                                                                   

                                                                    
                                                                    item.ListPriceDiscount__c =  lpr.Id;

                                                                    Map_LPDRate.put(item.id,lpr.Rate__c);

                                                                    if(item.ComponentListPrice__c != null && item.ComponentListPrice__c >= 0 ){
                                                                        item.UnitPrice = item.ComponentListPrice__c - (item.ComponentListPrice__c * (lpr.Rate__c/100));
                                                                        UpdateItemGroup = true;
                                                                    }
                                                                    else{
                                                                        item.UnitPrice = item.ListPrice - (item.ListPrice * (lpr.Rate__c/100));
                                                                    }
                                                                    
                                                                    item.UnitPrice = item.UnitPrice.setScale(2);
                                                                    
                                                                    if(item.ManualDiscount__c != null && (item.ManualDiscount__c.contains('Amount'))){
                                                                        item.UnitPrice = item.UnitPrice-item.ManualDiscountValue__c;  
                                                                    }
                                                                    else if(item.ManualDiscount__c != null && (item.ManualDiscount__c.contains('Percentage'))){
                                                                        item.UnitPrice = item.UnitPrice-(item.UnitPrice*(Item.ManualDiscountPercent__c/100));
                                                                    }

                                                                    item.UnitPrice = item.UnitPrice.setScale(2);
                                                                   

                                                                }
                                                                    
                                                        }
                                                    //}
                                                   // }  
                                                }     
                                    }      
                            }  
                        }

                    }      
        
     
                if(item.ComponentListPrice__c != null && item.ComponentListPrice__c >= 0 && item.ItemGroup__c != null ){
                    

                    Decimal fullUnitPrice = item.UnitPrice*item.ProductComponent__r.Quantity__c;
                    Decimal fullComponentListPrice = item.ComponentListPrice__c*item.ProductComponent__r.Quantity__c;
                    Decimal fullDiscountedPrice;// = item.DiscountedPrice__c*item.Quantity;
                    
                    if(item.ComponentListPrice__c != null && item.ComponentListPrice__c >= 0 && Map_LPDRate.get(item.id) != null){
                        fullDiscountedPrice = item.ComponentListPrice__c - (item.ComponentListPrice__c * (Map_LPDRate.get(item.id)/100));
                        UpdateItemGroup = true;
                    }
                    else if(Map_LPDRate.get(item.id) != null){
                        fullDiscountedPrice = item.ListPrice - (item.ListPrice * (Map_LPDRate.get(item.id)/100));
                    }
                    else{
                        fullDiscountedPrice = item.ListPrice;  
                    }

                    fullDiscountedPrice = fullDiscountedPrice *item.ProductComponent__r.Quantity__c;
                    

                    if(Map_ItemGroupLP.get(item.ItemGroup__c)==null){
                        Map_ItemGroupLP.put(item.ItemGroup__c,fullComponentListPrice);
                        Map_ItemGroupDP.put(item.ItemGroup__c,fullDiscountedPrice); 
                        Map_ItemGroupNSP.put(item.ItemGroup__c,fullUnitPrice);
                    }
                    else{
                        Map_ItemGroupLP.put(item.ItemGroup__c, Map_ItemGroupLP.get(item.ItemGroup__c)+fullComponentListPrice); 
                        Map_ItemGroupDP.put(item.ItemGroup__c, Map_ItemGroupDP.get(item.ItemGroup__c)+fullDiscountedPrice);  
                        Map_ItemGroupNSP.put(item.ItemGroup__c, Map_ItemGroupNSP.get(item.ItemGroup__c)+fullUnitPrice); 
                    }
                    system.debug('**Order_UpdateOrderListPrice: Item Group ID in LPD1**'+Map_ItemGroupLP);
                    system.debug('**Order_UpdateOrderListPrice: Item Group ID in LPD2**'+Map_ItemGroupDP);
                    system.debug('**Order_UpdateOrderListPrice: Item Group ID in LPD3**'+Map_ItemGroupNSP);
                }
        }
    }
   // update lstOrderItem;


   if(UpdateItemGroup == true){
    

        for(OrderItem item:lstOrderItem){
            if(item.ListPriceItemGroup__c != null){
                item.ListPriceItemGroup__c =  Map_ItemGroupLP.get(item.id);
                item.DiscountedPriceItemGroup__c =  Map_ItemGroupDP.get(item.id);
                item.NetSalesPriceItemGroup__c =  Map_ItemGroupNSP.get(item.id);
            }    
        }    
   }


   return lstOrderItem;
     
   // update   curOrder; 

   
        

    }

}