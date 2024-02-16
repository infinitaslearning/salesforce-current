public with sharing class Order_TestProdHandler {



@auraenabled (cacheable=true)
Public static List<ProductListPrice>  loadProductsbySearch(String searchString){        
    
    String OrderId = '8013N000001mETXQA2';
    system.debug('** OrderId**'+ OrderId); 
    
            List<ProductListPrice> lstProductListPrice;
            Order[] Order = [Select PriceBook2Id from Order where id=:OrderId];
                 
            lstProductListPrice = loadProductsbyPriceBook(Order[0].Pricebook2Id,null,null,null,null,null,searchString);

        try {
            
                     
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException('Something went wrong: '
                + e.getMessage() + ' - Please contact system administator');    
        }
        finally {
            // Something executed whether there was an error or not
        }
        return  lstProductListPrice;
    
}



Public static List<ProductListPrice>  loadProductsbyPriceBook(String Pricebook2Id,Decimal NoStudents, List<String> ShiptoId,String ExistingContract,String ContractRenewal,String PricingMethod, String SearchString){     
    List<PricebookEntry> ProductsbyPriceBook;
        if(SearchString == null){
            ProductsbyPriceBook = new List <PricebookEntry>([Select Product2.Stocknumber__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id from PricebookEntry //,
            where Pricebook2Id =:Pricebook2Id AND IsActive =: true Order by Product2.Name ASC limit 100 ]); //AND IsActive =:true

        }
        else{
            String Search = '%'+SearchString+'%';
            ProductsbyPriceBook = new List <PricebookEntry>([Select Product2.Stocknumber__c,Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id from PricebookEntry //,
            where Pricebook2Id =:Pricebook2Id 
            AND IsActive =: true
            AND (Product2.Name  like:Search 
            OR Product2.ISBNArticleNumber__c like:Search
            OR Product2.Type__c like: Search) Order by Product2.Name ASC limit 100]);
        }
          
        system.debug('****'+NoStudents);
    
        Set<String> Set_ItemGroup = new Set<String>();
        for(PricebookEntry pbe:ProductsbyPriceBook){
            
            Set_ItemGroup.add(pbe.Product2Id);
        }    

        Pricing__c[] lstPrice = [Select ListRate__c,Product__c,EndDate__c,IsActive__c,ProductComponent__r.Quantity__c,ProductComponent__r.Type__c,ProductComponent__r.MainProduct__c,ProductComponent__r.Product__c from Pricing__c 
        Where   (ProductComponent__r.MainProduct__c in: Set_ItemGroup OR Product__c in: Set_ItemGroup )
        AND StartDate__c <=: system.today()
        AND EndDate__c >=: system.today()];

        //AND IsActive__c =: true 

        Map<String,Decimal> Map_ProductPrice  =  new Map<String,Decimal>();
        Map<String,Decimal> Map_ProductQuantity  =  new Map<String,Decimal>();
        

        Map<String,Decimal> Map_ItemGroupBasePrice =  new Map<String,Decimal>();            
        Map<String,String> Map_ItemGroup =  new Map<String,String>();
        Map<String,String> Map_ItemGroupId =  new Map<String,String>();
        Map<String,Decimal> Map_ItemGroupPrice  =  new Map<String,Decimal>();
        Map<String,Decimal> Map_ComponentQuantity  =  new Map<String,Decimal>();
        

        Set_ItemGroup = new Set<String>();

                    
        ProductComponent__c[] lstItemGroupComponent = [Select Product__c,MainProduct__c,Type__c from ProductComponent__c where MainProduct__c in: Set_ItemGroup];
        


    for(Pricing__c item:lstPrice){    
            if(item.ProductComponent__r.Type__c=='Item Group Component'){
                Map_ItemGroup.put(item.ProductComponent__r.Product__c,item.ProductComponent__r.MainProduct__c);
                Map_ItemGroupId.put(item.ProductComponent__r.Product__c,item.ProductComponent__c); //item.id
                Map_ItemGroupPrice.put(item.ProductComponent__r.Product__c,item.ListRate__c);
                Map_ComponentQuantity.put(item.ProductComponent__r.Product__c,item.ProductComponent__r.Quantity__c);
                Set_ItemGroup.add(item.ProductComponent__r.MainProduct__c);
                system.debug('**Item Group Component**'+item.id);
            }

           if(item.Product__c != null){
                Map_ProductPrice.put(item.Product__c,item.ListRate__c);
           }                    
    }        
 
      


        List<ProductListPrice> lstProductListPrice = new List<ProductListPrice>();
        //Used for Item Group Components
        Map<String,List<ProductListPrice>> Map_ProductListPrice = new Map<String,List<ProductListPrice>>();
        //Full List of LPD for picklist
        Map<String,List<ListPriceDiscount>> Map_PriceDiscount = listPriceDiscount(Pricebook2Id,NoStudents);

        Set<String> Set_ProductId = new Set<String>();

        
       List<String> ManualDiscount  = new List<String>();
       ManualDiscount.add('--None--');
        //ManualDiscount.add('Percent');
       // ManualDiscount.add('Value');

        //Populate Item Group map
        List<PricebookEntry> ProductsbyItemGroup;
        if(Map_ItemGroup.size()>0){
            ProductsbyItemGroup = new List <PricebookEntry>([Select Product2.Renewable__c,Product2.OrderLineType__c,Product2.ISBNArticleNumber__c,Product2.MarketSegment__c,Product2.name,Product2.SoldInSegment__c, Product2.QuantitySelectionType__c,Product2.ProductDiscountGroup__c,Product2.ProductRateGroup__c,Product2.Type__c,productcode,unitprice,Product2Id from PricebookEntry //,
            where Pricebook2Id =:Pricebook2Id AND Product2Id in:Map_ItemGroup.keyset() ]); //AND IsActive =:true
        
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
                            
                            if(Map_ItemGroupBasePrice.get(Map_ItemGroup.get(pbe.Product2Id))==null){
                                Map_ItemGroupBasePrice.put(Map_ItemGroup.get(pbe.Product2Id),prodlp.BasePrice);
                            }
                            else{
                                Map_ItemGroupBasePrice.put(Map_ItemGroup.get(pbe.Product2Id),Map_ItemGroupBasePrice.get(Map_ItemGroup.get(pbe.Product2Id))+prodlp.BasePrice);
                            }
            
                            prodlp.UnitPrice  = pbe.UnitPrice; // - (pbe.UnitPrice* (Map_Rate.get(pbe.Product2.ProductDiscountGroup__c)/100));
                            prodlp.STDPrice = prodlp.BasePrice;
                            
                            prodlp.ProductTYPE = pbe.Product2.Type__c; // pbe.productcode; replacing SKU
                            prodlp.ProductEAN = pbe.Product2.ISBNArticleNumber__c;
                            
                            system.debug('**pbe.Product2.name **'+pbe.Product2.name);
                            prodlp.QuantitySelectionType =  pbe.Product2.QuantitySelectionType__c;
                    
                            prodlp.PricebookEntryId = pbe.Id;
                            
                            
                            Set<String> Set_SoldInSegment = new Set<String>();
                            
                            prodlp.lstMarketSegment = new List<String>();
                            if(pbe.Product2.SoldInSegment__c != null){
                                
                                prodlp.lstMarketSegment.AddAll(pbe.Product2.SoldInSegment__c.Split(';'));

                                Set_SoldInSegment.AddAll(pbe.Product2.SoldInSegment__c.Split(';'));  
                            }
                        
                            //Only link LPD for that ProductDiscountGroup

                            List<ListPriceDiscount> AddlistPriceDiscount;
                            if(Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c) != null){
                                AddlistPriceDiscount = AddlistPriceDiscount(pbe.Product2.MarketSegment__c,Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c));
                            }

                            prodlp.listPriceDiscount = AddlistPriceDiscount;
                            Set_ProductId.add(prodlp.ProductId);
                            
                            List<String> PriceProductType = new List<String>();
                        

                        //Possible OrderLine type from the Product - needs to match with listPriceDiscount for a discount to be applied

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
    system.debug('**ITEM GROUP SET**'+Set_ItemGroup);
    system.debug('**ITEM GROUP MAP**'+Map_ProductListPrice);

        lstProductListPrice = new List<ProductListPrice>();
    for(PricebookEntry pbe:ProductsbyPriceBook){
        system.debug('**Product2.Name**'+pbe.Product2.name);
        if(Map_ProductPrice.get(pbe.Product2Id) != null){           
                ProductListPrice prodlp = new ProductListPrice();                  
                prodlp.ProductName =  pbe.Product2.name;
           
             
                prodlp.listPriceDiscountType = pbe.Product2.ProductDiscountGroup__c;
                prodlp.ProductRateGroup = pbe.Product2.ProductRateGroup__c;

                 
                prodlp.ProductId = pbe.Product2Id;
                prodlp.BasePrice  = Map_ProductPrice.get(pbe.Product2Id); // pbe.UnitPrice;
                prodlp.UnitPrice  = Map_ProductPrice.get(pbe.Product2Id);  // pbe.UnitPrice; //
                prodlp.STDPrice = prodlp.UnitPrice;

                prodlp.ProductTYPE = pbe.Product2.Type__c; // pbe.productcode; replacing SKU
                prodlp.ProductEAN = pbe.Product2.ISBNArticleNumber__c;
                prodlp.Stocknumber = pbe.Product2.Stocknumber__c;

                    Set<String> Set_SoldInSegment = new Set<String>();
                    prodlp.lstMarketSegment = new List<String>();
                    if(pbe.Product2.SoldInSegment__c != null){

                        //used for search
                        prodlp.lstMarketSegment.AddAll(pbe.Product2.SoldInSegment__c.Split(';'));
                        Set_SoldInSegment.AddAll(pbe.Product2.SoldInSegment__c.Split(';'));  

                    }
                    system.debug('**pbe.Product2Id**'+pbe.Product2Id); 
                            
                    
                    system.debug('**Map_PriceDiscount**'+ pbe.Product2.name);
                    system.debug('**Map_PriceDiscount**'+Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c));

                    List<ListPriceDiscount> AddlistPriceDiscount = new List<ListPriceDiscount>();
                    
                    if(Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c) != null){
                            AddlistPriceDiscount = AddlistPriceDiscount(pbe.Product2.MarketSegment__c,Map_PriceDiscount.get(pbe.Product2.ProductDiscountGroup__c));
                    }
                    prodlp.MarketSegment =  pbe.Product2.MarketSegment__c;
                    system.debug('**AddlistPriceDiscount**'+AddlistPriceDiscount);

                    prodlp.listPriceDiscount = AddlistPriceDiscount;

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
                
                        
                        if(Set_ItemGroup.contains(pbe.Product2Id)){
                            system.debug('**ITEM GROUP**'+prodlp.ProductName);

                            
                            prodlp.BasePrice  = Map_ItemGroupBasePrice.get(pbe.Product2Id);
                            prodlp.UnitPrice  = prodlp.BasePrice;  
                            prodlp.STDPrice = prodlp.BasePrice;
                            
                            system.debug('**ITEM LIST GROUYP**'+prodlp.listItemGroupComponent);
                        }
                        

                        if(Map_ProductListPrice.get(pbe.Product2Id) != null){
                            system.debug('**Map_ProductListPrice**'+Map_ProductListPrice.get(pbe.Product2Id) + '****'+ pbe.Product2Id);
                            prodlp.listItemGroupComponent  = Map_ProductListPrice.get(pbe.Product2Id);
                            prodlp.ItemGroupComponent = true;
                        }
                        else{
                            prodlp.ItemGroupComponent = false;   
                        }

                    // system.debug('**prodlp.STDPrice**'+prodlp.STDPrice);

                        Set_ProductId.add(prodlp.ProductId);
                        lstProductListPrice.add(prodlp);
            }
            
        }
        
        
        // USED TO LIMIT visibility of Products that are not in Customer Group -- Possible deprecation
        //  lstProductListPrice = AssettoAccountMap( Set_ProductId,ShiptoId, lstProductListPrice,ExistingContract,ContractRenewal,PricingMethod);
        
        system.debug('**lstProductListPrice**'+lstProductListPrice.size());
          
        Return lstProductListPrice;
       
       
        
    }

    public static Map<String,List<ListPriceDiscount>> listPriceDiscount(String Pricebook2Id, Decimal NoStudents){

        Map<String,List<ListPriceDiscount>> Map_PriceDiscount = new Map<String,List<ListPriceDiscount>>();
         
        Date CurDate = system.today();

        ListPriceDiscount__c[] lst_ListPriceDiscountRegular = [Select ProductDiscountGroup__c,DiscountType__c,OrderLineType__c, MarketSegment__c,Rate__c,StartQuantity__c,CustomerDiscountGroup__c From ListPriceDiscount__c  
        where  StartQuantity__c <=: NoStudents   
        AND  EndDate__c >=:CurDate 
        AND StartDate__c  <=:CurDate ORDER BY StartQuantity__c DESC];
        
        Map<String,Decimal> Map_Rate = new Map<String,Decimal>();
        List<ListPriceDiscount> ListPriceDiscount = new List<ListPriceDiscount>();
        
        for(ListPriceDiscount__c lpr:lst_ListPriceDiscountRegular){
           
            ListPriceDiscount PriceDiscount = new ListPriceDiscount();
            if(Map_Rate.get(lpr.ProductDiscountGroup__c) == null && lpr.OrderLineType__c=='Regular'){
                Map_Rate.put(lpr.ProductDiscountGroup__c,lpr.Rate__c);

                PriceDiscount.MarketSegment = lpr.MarketSegment__c;  
                PriceDiscount.OrderLineType = lpr.OrderLineType__c;
                PriceDiscount.DiscountType = lpr.DiscountType__c;
                PriceDiscount.Discount = lpr.Rate__c;
                PriceDiscount.ProductGroup = lpr.ProductDiscountGroup__c;
                PriceDiscount.CustomerDiscountGroup = lpr.CustomerDiscountGroup__c;
                PriceDiscount.LPDId = lpr.id;
            }
            else if(lpr.OrderLineType__c != 'Regular'){
                        PriceDiscount = new ListPriceDiscount();
                        PriceDiscount.DiscountType = lpr.DiscountType__c;
                        PriceDiscount.MarketSegment = lpr.MarketSegment__c;
                        PriceDiscount.CustomerDiscountGroup = lpr.CustomerDiscountGroup__c;   
                        PriceDiscount.OrderLineType = lpr.OrderLineType__c;
                        PriceDiscount.Discount = lpr.Rate__c;
                        PriceDiscount.ProductGroup = lpr.ProductDiscountGroup__c;
                        PriceDiscount.LPDId = lpr.id;
                         
            }  

            if(Map_PriceDiscount.get(lpr.ProductDiscountGroup__c) == null){
                ListPriceDiscount = new List<ListPriceDiscount>();
                ListPriceDiscount.add(PriceDiscount);
                Map_PriceDiscount.put(lpr.ProductDiscountGroup__c,ListPriceDiscount);
            }
            else{
                Map_PriceDiscount.get(lpr.ProductDiscountGroup__c).add(PriceDiscount); 
            }
        }      
        return Map_PriceDiscount;

    }


    Public static List<ListPriceDiscount> AddlistPriceDiscount(String ProdMarketSegment, List<ListPriceDiscount> ListPriceDiscountType){


        List<ListPriceDiscount> AddlistPriceDiscount = new List<ListPriceDiscount>();
        system.debug('**ProdMarketSegment**'+ProdMarketSegment);

                    for(ListPriceDiscount   lpdiscount:ListPriceDiscountType){
                            
                            ListPriceDiscount PriceDiscount = new ListPriceDiscount();

                            
                            if(lpdiscount.OrderLineType == 'Inspection Copy' && lpdiscount.DiscountType != 'Normal'){
                                
                                if(ProdMarketSegment  == lpdiscount.MarketSegment && ProdMarketSegment != null){

                                    PriceDiscount.MarketSegment = lpdiscount.MarketSegment;
                                    PriceDiscount.CustomerDiscountGroup = lpdiscount.CustomerDiscountGroup;
                                      
                                    PriceDiscount.OrderLineType = lpdiscount.OrderLineType; // + '-' +lpdiscount.MarketSegment;
                                    PriceDiscount.Discount = lpdiscount.Discount;
                                    PriceDiscount.LPDId = lpdiscount.LPDId ;
                                    PriceDiscount.ProductGroup = lpdiscount.ProductGroup;
                                    AddlistPriceDiscount.add(PriceDiscount);
                                }
                                
                            }   
                            else{
                                    PriceDiscount.MarketSegment = lpdiscount.MarketSegment;  
                                    PriceDiscount.CustomerDiscountGroup = lpdiscount.CustomerDiscountGroup; 
                                    PriceDiscount.OrderLineType = lpdiscount.OrderLineType;
                                    PriceDiscount.Discount = lpdiscount.Discount;
                                    PriceDiscount.LPDId = lpdiscount.LPDId ;
                                    PriceDiscount.ProductGroup = lpdiscount.ProductGroup;
                                    AddlistPriceDiscount.add(PriceDiscount);
                            }
                        
                    }

        return AddlistPriceDiscount;

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
        
    
        @auraenabled Public Decimal UnitPrice {get;set;}  
        @auraenabled Public Decimal Quantity {get;set;}
        @auraenabled Public Decimal BasePrice {get;set;}  
        @auraenabled Public Decimal STDPrice {get;set;}
        @auraenabled Public Decimal ComponentQuantity {get;set;}
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

}