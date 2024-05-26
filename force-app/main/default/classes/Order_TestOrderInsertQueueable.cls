public with sharing class Order_TestOrderInsertQueueable implements Queueable {
    
   // Private List<Order_ProductSelectController.OrderLineItem> OrderItems;
   // Private List<OrderItem> lstOrderItem;
   //List<Order_ProductSelectController.OrderLineItem> OrderItems,
    Private String ContractId;
    Private String OrderId; 
    Private Decimal TotalNumberofStudents;
    Private Boolean AddShiptos;
    Private List<Account> AccountbyShipto;

    public Order_TestOrderInsertQueueable(String ContractId,String OrderId, Decimal TotalNumberofStudents,Boolean AddShiptos,List<Account> AccountbyShipto) {
      //  this.OrderItems = OrderItems;
        this.OrderId = OrderId;
        this.TotalNumberofStudents = TotalNumberofStudents;
        this.AccountbyShipto = AccountbyShipto;
        this.AddShiptos = AddShiptos;

    }

    public void execute(System.QueueableContext qc) {

        Contract[] Contract = [Select AccountId,NumberofUsers__c,SoldUsers__c,StartDate,Pricebook2Id,PaymentMethod__c,ShippingCostMethod__c,PricingMethod__c,defaultBilltoAccount__c from Contract where id =: ContractId];
        
        system.debug('**OrderItems 1**');

        //GET Subsidoaries
        if(Contract.size()>0){    
            /*
            if(Contract[0].SoldUsers__c == null){
              //  Contract[0].SoldUsers__c =TotalNumberofStudents;                
            }
            update Contract;
            */
        }

        Id NewOrderId = OrderId;
         

        Set<String> Set_Sub = new Set<String>();
        Map<String,String> Map_Sub = new Map<String,String>(); 
        Map<String,String> Map_Netsuite = new Map<String,String>(); 
        
        Order[] CurOrder = [Select AccountSubsidiary__c,Account.NetsuiteInternalId__c,OperatingCompany__c,InsertProductSelector__c,CustomerReference__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c from Order where id=: NewOrderId];
        
        List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
        if(Contract.size()>0){
            Set_Sub.add(Contract[0].defaultBilltoAccount__c);

            //lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);
        }
        else if(CurOrder.size()>0){
            Set_Sub.add(CurOrder[0].Billto__c);
            
            lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);
            if(CurOrder[0].ContractId != null){
                ContractId = CurOrder[0].ContractId;
            }
        }    
        
        

        Map_Sub = lst_AccSubMaps[0];
        Map_Netsuite = lst_AccSubMaps[1];

        
        Boolean varNewOrder=false;
        Order NewOrder;
        if(NewOrderId == null){ 
            NewOrder = new Order();
            if(ContractId != null){
                NewOrder.ContractId = ContractId;
                NewOrder.AccountId = Contract[0].AccountId;
                NewOrder.EffectiveDate = Contract[0].StartDate;
                NewOrder.Pricebook2Id = Contract[0].Pricebook2Id;
                NewOrder.Status = 'Draft';
                NewOrder.PaymentMethod__c = Contract[0].PaymentMethod__c;
                NewOrder.ShippingCostMethod__c = Contract[0].ShippingCostMethod__c;
                NewOrder.PricingMethod__c = Contract[0].PricingMethod__c;
                NewOrder.Billto__c = Contract[0].defaultBilltoAccount__c; 
                NewOrder.AccountSubsidiary__c =  Map_Sub.get(Contract[0].defaultBilltoAccount__c);
                NewOrder.NumberOfStudents__c = TotalNumberofStudents;
                NewOrder.ShipByDate__c = Contract[0].StartDate; //system.today(); 
                Insert NewOrder;
            }

            //Add Subsidoaries Bill to
            varNewOrder=true;
            NewOrderId = NewOrder.id;

            CurOrder= new Order[]{NewOrder};
         //   system.debug('**BILL TO 1**'+NewOrder.Account.NetsuiteInternalId__c);
         //   system.debug('**BILL TO 1: Contract[0].AccountId**'+Contract[0].AccountId);
        }
        else{
          //  CurOrder[0].InsertProductSelector__c = true;  
            CurOrder[0].AccountSubsidiary__c =  Map_Sub.get(CurOrder[0].Billto__c);  
            CurOrder[0].NetSuiteIdAccountSubsidiary__c = Map_Netsuite.get(CurOrder[0].Billto__c);         
            CurOrder[0].NumberOfStudents__c = TotalNumberofStudents;

         //   system.debug('**BILL TO 2**'+CurOrder[0].Account.NetsuiteInternalId__c);
            
            update CurOrder;
            try{
                
            }
            catch(exception e){
                HandleCustomException.LogException(e);
            }

        }


       /*      
        Id NewOrderId = OrderId;
        List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
        Map<String,String> Map_Sub = new Map<String,String>();
        Map<String,String> Map_Netsuite = new Map<String,String>();
        Set<String> Set_Sub = new Set<String>();
        Order[] CurOrder = [Select AccountSubsidiary__c,Account.NetsuiteInternalId__c,OperatingCompany__c,InsertProductSelector__c,ProductSelectorMessage__c,CustomerReference__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c from Order where id=: NewOrderId];
        


        List<OrderItem> lstOrderItem = new List<OrderItem>();
        List<OrderItem> lstOrderItemToDelete = new List<OrderItem>();

      //  system.debug('**OrderItems**'+OrderItems);

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
        for(Order_ProductSelectController.OrderLineItem item:OrderItems){
            Set_Sub.add(item.ShipToAccountId);
            Set_Products.add(item.ProductId);
        }  

        Product2[] lstProduct = [Select id,Type__c,FreeFromDate__c,IsRegularOrderPossible__c,IsInspectionCopyOrderPossible__c,IsUseCopyOrderPossible__c,FixedStartDate__c,StartDate__c,LicenseDuration__c,Renewable__c from Product2 where id in: Set_Products];

        Map<String,Date> Map_FreeFromDate = new Map<String,Date>();
        Map<String,Date> Map_FixedStartDate = new Map<String,Date>();
        Map<String,Date> Map_StartDate = new Map<String,Date>();
        Map<String,Decimal> Map_LicenseDuration = new Map<String,Decimal>();
        Map<String,Boolean> Map_Renewable = new Map<String,Boolean>();
        Map<String,String> Map_ProdType = new Map<String,String>();

        Map<String,Boolean> Map_InspectionCopyOrder = new Map<String,Boolean>();
        Map<String,Boolean> Map_RegularOrder = new Map<String,Boolean>();
        Map<String,Boolean> Map_UseCopyOrder = new Map<String,Boolean>();       
        
       
        Date FixedStartDate;
        for(Product2 prod:lstProduct){
            
            Map_InspectionCopyOrder.put(prod.id,prod.IsInspectionCopyOrderPossible__c);
            Map_RegularOrder.put(prod.id,prod.IsRegularOrderPossible__c);
            Map_UseCopyOrder.put(prod.id,prod.IsUseCopyOrderPossible__c);
            

            if(prod.FixedStartDate__c != null){
                FixedStartDate = date.newinstance(system.today().year(), prod.FixedStartDate__c.month(), prod.FixedStartDate__c.day());
                Map_FixedStartDate.put(prod.id,FixedStartDate);
            }
             
            Map_FreeFromDate.put(prod.id,prod.FreeFromDate__c );
            Map_StartDate.put(prod.id,prod.StartDate__c );
            if(prod.LicenseDuration__c != null){
                Map_LicenseDuration.put(prod.id,decimal.valueof(prod.LicenseDuration__c));
            }

            Map_Renewable.put(prod.id,prod.Renewable__c);
            Map_ProdType.put(prod.id, prod.Type__c);
            
        }

        
        lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);

       // Map_Sub = returnAccountSubsidiary(Set_Sub)[0];

       Map_Sub = lst_AccSubMaps[0];
       Map_Netsuite = lst_AccSubMaps[1];
 
       integer i = 0;
       List<Order_ProductSelectController.OrderLineItem> OrderItemSend = new List< Order_ProductSelectController.OrderLineItem>();

       String ShiptoAcc=null;
        for(Order_ProductSelectController.OrderLineItem item:OrderItems){
            system.debug('**item.IsEdited**'+item.IsEdited);
           if(item.IsEdited==true && (i < 500 || ShiptoAcc==item.ShipToAccountId)){ //Ensure that Item Group is not split during insert || item.ItemGroup!=null
            i++;
            ShiptoAcc=item.ShipToAccountId;
                        OrderItem OItem = new OrderItem();
                        OItem.OrderId = NewOrderId; 
                        
                        if(item.ItemGroup == null && item.ItemGroupComponent== true){
                            OItem.UnitPrice = 0;
                            OItem.NetSalesPriceItemGroup__c = item.UnitPrice.setScale(2);
                            OItem.DiscountedPriceItemGroup__c = item.STDPrice;
                            OItem.ListPriceItemGroup__c = Item.BasePrice;
                    
                        }
                        else{
                            OItem.UnitPrice = item.UnitPrice.setScale(2);
                        }

                        
                        if(item.ItemGroup == null && item.ItemGroupComponent != true){
                            OItem.Renewable__c= Map_Renewable.get(item.ProductId);
                        }
                        
                    


                        OItem.Quantity = item.Quantity;  

                        OItem.ComponentQuantity__c = item.ComponentQuantity;
                    // OItem.ItemGroup__c = item.ItemGroupProductId;
                        OItem.ListPriceDiscount__c =  item.listPriceRateId;  
                        OItem.Product2Id = item.ProductId;
                        
                        
                        OItem.PricebookEntryId = item.PricebookEntryId;
                        OItem.ShipToAccount__c  = item.ShipToAccountId; 
                        OItem.Account__c = CurOrder[0].Billto__c ;

                        OItem.AccountSubsidiary__c = Map_Sub.get(item.ShipToAccountId);
                        OItem.NetsuiteInternalId__c = Map_Netsuite.get(item.ShipToAccountId);
                        OItem.NetSuiteIdShiptoAccount__c = Map_Netsuite.get(item.ShipToAccountId);
                        Oitem.NetSuiteIdBilltoAccount__c = CurOrder[0].Account.NetsuiteInternalId__c;
                        Oitem.IsInspectionCopyOrderPossible__c = Map_InspectionCopyOrder.get(item.ProductId);
                        Oitem.IsRegularOrderPossible__c = Map_RegularOrder.get(item.ProductId);
                        Oitem.IsUseCopyOrderPossible__c = Map_UseCopyOrder.get(item.ProductId);
                        Oitem.ProductLicenseDuration__c = Map_LicenseDuration.get(item.ProductId);
                        OItem.ProductType__c = Map_ProdType.get(item.ProductId);
                        OItem.OrderLineItemType__c = item.PriceDiscount;
                        OItem.CustomerReference__c  =  CurOrder[0].CustomerReference__c;
                        OItem.OperatingCompany__c  = CurOrder[0].OperatingCompany__c;
                        OItem.StartDate__c = CurOrder[0].ShipByDate__c;
                        OItem.ServiceDate = CurOrder[0].ShipByDate__c;
                        
                    
                        Date EndDate=null;
                        
                        //No Fixed Start date
                        if (Map_FixedStartDate.get(OItem.Product2Id) != NULL && Map_LicenseDuration.get(OItem.Product2Id) != null && Map_FreeFromDate.get(OItem.Product2Id) < system.today() && Map_FreeFromDate.get(OItem.Product2Id) < Map_FixedStartDate.get(OItem.Product2Id)){

                            Date StartDate  = date.newinstance(system.today().year(), Map_FixedStartDate.get(OItem.Product2Id).month(), Map_FixedStartDate.get(OItem.Product2Id).day());      

                        // Integer add = Map_StartDate.get(OItem.Product2Id).month()+integer.valueof(Map_LicenseDuration.get(OItem.Product2Id));

                        // system.debug('***OnE**Mon*' +add);
                        //    system.debug('***OnE**Year*' +StartDate);

                            
                            EndDate = date.newinstance(StartDate.year()+1, StartDate.month(), StartDate.day());      
                        
                            OItem.StartDate__c = StartDate;
                            OItem.ServiceDate = StartDate;

                            OItem.OrderItemEndDate__c = EndDate-1;  
                            OItem.EndDate = EndDate-1;   
                            
                            
                            OItem.TrialStartDate__c = CurOrder[0].ShipByDate__c; 
                            OItem.TrialEndDate__c = StartDate - 1;
                        
                        } 
                        else if(Map_FixedStartDate.get(OItem.Product2Id) != NULL && (Map_FreeFromDate.get(OItem.Product2Id) == null ||  Map_FreeFromDate.get(OItem.Product2Id) > system.today()) ){ //&& Map_StartDate.get(OItem.Product2Id) != null
                            Date StartDate =  Map_FixedStartDate.get(OItem.Product2Id) - 1;
                            
                        //    system.debug('***TWO: FixedStartDate*'+StartDate +'***TWO: Order STart date*'+ CurOrder[0].EffectiveDate );

                            // Checking if the date is before the month in the current year then use current year else use next year

                            if(CurOrder[0].EffectiveDate < StartDate){
                                OItem.OrderItemEndDate__c = date.newinstance(StartDate.year(), StartDate.month(), StartDate.day());
                                OItem.EndDate = date.newinstance(StartDate.year(), StartDate.month(), StartDate.day());
                            }
                            else{
                                OItem.OrderItemEndDate__c = date.newinstance(StartDate.year()+1, StartDate.month(), StartDate.day());
                                OItem.EndDate = date.newinstance(StartDate.year()+1, StartDate.month(), StartDate.day());
                            }

                            
                        } 
                        else if(Map_FixedStartDate.get(OItem.Product2Id) == NULL && Map_LicenseDuration.get(OItem.Product2Id) != null){

                        
                            EndDate = date.newinstance(CurOrder[0].ShipByDate__c.year(), CurOrder[0].ShipByDate__c.month()+integer.valueof(Map_LicenseDuration.get(OItem.Product2Id)), CurOrder[0].ShipByDate__c.day());      
                                        
                            OItem.OrderItemEndDate__c = EndDate-1; 
                            OItem.EndDate = EndDate-1;  


                        
                        }
                        

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
                        
                        system.debug('**item.IsEdited: DiscountAmount**'+item.DiscountAmount);

                            if(item.ItemId != null && item.IsnewItem !='True'){
                                OItem.Id = item.IId;
                            } 
                           
                lstOrderItem.Add(OItem); 
            
            }
            else if(item.IsEdited==true){
                OrderItemSend.Add(item);                
            }
        }
        String Error=null;   
        try{
            system.debug('**Insert try **');
            upsert lstOrderItem id;
            
        }
        catch(exception e){
            system.debug('**Insert: '+e.getMessage());
            Error = 'Error:'+e.getMessage().left(247);
            
           HandleCustomException.LogException(e);
           CurOrder[0].ProductSelectorMessage__c = Error;
           CurOrder[0].InsertProductSelector__c = false;
            update CurOrder;

             
        }
        
        if(Error!=null){
            system.debug('**Insert:Error 1');
             
            system.debug('**Insert:Error 2');
        }
        else{

        

         
     // FUTURE + REST OPTION  
     try{
                
                Map<String,String> Map_itemGroup = new Map<String,String>();    
                String ShiptoProdGroup;
                for(OrderItem  item:lstOrderItem){
                    
                    ShiptoProdGroup = item.ShipToAccount__c;
                    ShiptoProdGroup += item.Product2Id;
                    Map_itemGroup.put(ShiptoProdGroup ,item.id );
                }    
                List<OrderItem> lstOrderItemComponent = new List<OrderItem>();

                for(Order_ProductSelectController.OrderLineItem Oitem:OrderItems){
                    
                    for(OrderItem  item:lstOrderItem){
                    //  system.debug('**OItem.ProductId**'+OItem.ProductId+'****'+item.Product2Id+ '****'+ OItem.ItemGroupProductId);
                        
                        if(OItem.ProductId == item.Product2Id && OItem.ItemGroup != null && item.ShipToAccount__c  == OItem.ShipToAccountId){
                            ShiptoProdGroup = item.ShipToAccount__c; 
                            ShiptoProdGroup += OItem.ItemGroupProductId;
                            
                            item.ItemGroup__c = Map_itemGroup.get(ShiptoProdGroup);
                            item.ProductComponent__c = OItem.ItemGroupId; //New line
                            item.ItemGroupId__c = Map_itemGroup.get(ShiptoProdGroup);
                            lstOrderItemComponent.add(item);
                        }
                    
                    } 
                }
        
            if(lstOrderItemComponent.size()>0){
               update  lstOrderItemComponent;
            }    
            
            system.debug('**Update try **');
        }
        catch(exception e){
          //  HandleCustomException.LogException(e);
            NewOrderId = e.getMessage();
            system.debug('**Update: '+e.getMessage());
            CurOrder[0].ProductSelectorMessage__c = Error;
            CurOrder[0].InsertProductSelector__c = false;
            update CurOrder;
        }
        
        
     if(AddShiptos){

       
        if(ContractId != null){
           
         //   system.debug('**Set_NewAccIdCon**'+Set_NewAccIdCon);
            list<ContractShipto__c> lstContractShiptoAdd = new  list<ContractShipto__c>();
            for(String str:Set_NewAccIdCon){
               // if(!Set_existing.contains(str)){
                   if(str != null){ 
                        ContractShipto__c ContractShipto = new  ContractShipto__c();
                        ContractShipto.ShiptoAccount__c = str;
                        ContractShipto.Contract__c = ContractId;
                        lstContractShiptoAdd.add(ContractShipto);
                    } 
               // }    
            }
            try{
                if(lstContractShiptoAdd.size()>0){
                    insert lstContractShiptoAdd;
                }
            }
            catch(exception e){
                HandleCustomException.LogException(e);
                NewOrderId = e.getMessage();
                 
            }
            
            
        }

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
                
            }
              
            
        }
    } 


    //Handle Delete
    
        
        try{
            Set<String> Set_DontDelete = new Set<String>();

            for(OrderItem item:lstOrderItem){
                Set_DontDelete.add(item.id);
            }
        
            lstOrderItemToDelete = [Select id from OrderItem where id not in:Set_DontDelete and OrderId =:NewOrderId];
        

         //   delete lstOrderItemToDelete;
          //  SetOrderItemsForFlow(Set_DontDelete);
        }
        catch(exception e){
            HandleCustomException.LogException(e);
            NewOrderId = e.getMessage();
            
        }
     

    // FUTURE + REST OPTION  
     
                system.debug('**Send AGain: '+OrderItemSend.size());
                if(OrderItemSend.size()>0){
                    System.enqueueJob(new Order_TestOrderInsertQueueable(OrderItemSend,ContractId,OrderId, TotalNumberofStudents,false,AccountbyShipto));
                }
                else{
                    CurOrder[0].InsertProductSelector__c = false;
                   update CurOrder;
                }
        }
       */  
}
 



}