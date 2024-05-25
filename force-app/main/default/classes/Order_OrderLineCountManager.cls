public with sharing class Order_OrderLineCountManager implements Queueable {
    
    public static Decimal FIXEDLINECOUNT;

    
    Private String load;
    Private Order CurOrder ;
    Private List<Order> MaxOrder;

    public Order_OrderLineCountManager(List<Order> MaxOrder,String load) {
        
        
        

        system.debug('**Order_OrderLineCountManager: FIXEDLINECOUNT**'+FIXEDLINECOUNT);
        //Handles bulkification of big orders. One at a time in the recursive queueable.

        if(load == 'Start'){           
            this.MaxOrder = MaxOrder;
            this.CurOrder = MaxOrder[0];
        }
        else {
          
          MaxOrder.remove(0);
          this.MaxOrder = MaxOrder;
          if(MaxOrder.size()>0){
            this.CurOrder= MaxOrder[0];
          }
          
          
        }   

        system.debug('**Order_OrderLineCountManager: Cur**'+CurOrder);
          system.debug('**Order_OrderLineCountManager: Max**'+MaxOrder);

    }
    public void execute(System.QueueableContext qc) {
         system.debug('**Order_OrderLineCountManager: CurOrder Order size exe**'+CurOrder);
        if(CurOrder != null){

        
                List<Id> OrderId = new List<Id>();
                OrderId.add(CurOrder.id);

                //OrderItem[] lst_OrdItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);

                OrderItem[]   lst_OrdItem =  Order_SoqlFactory.returnQueryOrderItems(null,OrderId,null,null);
                system.debug('**Order_SoqlFactory.Order_OrderLineCountManager.lst_OrdItem :Size**'+lst_OrdItem.size());

                

                try{
                    ItemGroupSync(lst_OrdItem,CurOrder);
                }
                catch(exception e){
                    HandleCustomException.LogException(e,CurOrder.id);
                }

                if(!test.isrunningtest()){
                    System.enqueueJob(new Order_OrderLineCountManager(MaxOrder,'Next'));
                }
        }
    }
    Public static void ItemGroupSync(OrderItem[] lst_OrdItem,Order CurOrder){

        Map<String, List<OrderItem>> Map_ItemGrpId = new  Map<String, List<OrderItem>>();
        Map<OrderItem, List<OrderItem>> Map_ItemGrp = new  Map<OrderItem, List<OrderItem>>();
        Map<String, OrderItem> Map_ItemGrpHead = new  Map<String, OrderItem>();

        List<OrderItem> lst_ItemGroup = new List<OrderItem>();
        List<OrderItem> lst_RemoveItemGroup = new List<OrderItem>(); 

        List<Integer> lstItemremoveIndex = new List<Integer>();

        system.debug('**Order_OrderLineCountManager**: ItemGroupSync1');


        Integer index = 0;
        
        List<id> lstRemove = new List<id>();

        //Create Map of all Item Groups with Components. Order of loop is not certain. therefore use ItemGroupId with ItemGroup record
        // Item group item record is included in the list and the key in the map

        for(OrderItem item:lst_OrdItem){

            if(item.ItemGroup__c != null){

                    //Add item Group component to the Map
                    if(Map_ItemGrpHead.get(item.ItemGroup__c) !=null){
                            Map_ItemGrp.get(Map_ItemGrpHead.get(item.ItemGroup__c)).add(item); 
                    }
                    else if(Map_ItemGrpId.get(item.ItemGroup__c) != null){
                        Map_ItemGrpId.get(item.ItemGroup__c).add(item);
                     }
                    else{
                        lst_ItemGroup = new List<OrderItem>();
                        lst_ItemGroup.add(item);
                        Map_ItemGrpId.put(item.ItemGroup__c,lst_ItemGroup);
                    }
                  index++;                    
            }
            else if(item.ProductType__c == 'Item Group'){                 

                Map_ItemGrpHead.put(item.id,item);

                if(Map_ItemGrp.get(item) == null && Map_ItemGrpId.get(item.id) ==null){
                    lst_ItemGroup = new List<OrderItem>();
                    lst_ItemGroup.add(item);
                    Map_ItemGrp.put(item,lst_ItemGroup);
                }
                else if(Map_ItemGrp.get(item) == null && Map_ItemGrpId.get(item.id) !=null){
                    Map_ItemGrpId.get(item.id).add(item);
                    Map_ItemGrp.put(item,Map_ItemGrpId.get(item.id));

                }
                else{
                    Map_ItemGrpId.get(item.id).add(item);
                    Map_ItemGrp.put(item,Map_ItemGrpId.get(item.id));
               }
              
                index++;
            }
            

        }
                                               
        Integer listsize = lst_OrdItem.size();
        
        //Changed i > 0 to i>=0 to ensure list is completely empty if need be

        //NB TEST THIS PROPERLY
        //Remove item Groups from list.  

        for(Integer i=listsize-1; i>=0; i-- ){                                                
               if(lst_OrdItem.get(i).ProductType__c == 'Item Group' || lst_OrdItem.get(i).ItemGroup__c != null){
                    lst_OrdItem.remove(i);
               }    
        }

        creatlists(lst_OrdItem,Map_ItemGrp,CurOrder);

    }

    Public static void creatlists(OrderItem[] lst_OrdItem,Map<OrderItem, List<OrderItem>> Map_ItemGroup,Order CurOrder){


        OrderLineItemMaxCount__mdt[] OrderLineItemMaxCount;
       
        if(test.isrunningtest()){
            OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='TestCount'];
        }
        else{
            OrderLineItemMaxCount = [Select Count__c from OrderLineItemMaxCount__mdt where MasterLabel='LiveCount'];
        }
        
        FIXEDLINECOUNT =  OrderLineItemMaxCount[0].Count__c;

        Decimal fullistsize = lst_OrdItem.size();
        Decimal NoChunks = (fullistsize/FIXEDLINECOUNT);
        Map<Integer,List<OrderItem>> Map_Itemlist = new Map<Integer,List<OrderItem>>();
        Map<String, String> Map_IGLookup = new Map<String, String>();
        
        Map<Integer, Integer> Map_ImpLineCount = new Map<Integer, Integer>();
        Map<Integer, Decimal> Map_ImpLineCountQuantity = new Map<Integer, Decimal>();

        List<OrderItem> lstNewOrderitems;
                system.debug('**Order_OrderLineCountManager: ProcessLineCount**: NI fullistsize'+ fullistsize);
                system.debug('**Order_OrderLineCountManager: ProcessLineCount**: NI NoChunks'+ NoChunks);

       

        Integer count = 0;
        Integer LoopChunks=0;

        //If list size larger than max after item groups removed
        if(NoChunks>1){
            
            lstNewOrderitems = new List<OrderItem>(); 
            count = 1;
            LoopChunks = 1;
             for(OrderItem item:lst_OrdItem){

           //Only create a new Order Header if the line count is greater than FIXEDLINECOUNT      
                if(count>FIXEDLINECOUNT){

                    if(Map_Itemlist.get(LoopChunks)== null){
                        Map_Itemlist.put(LoopChunks,lstNewOrderitems);
                    }

                    Map_Itemlist.get(LoopChunks).add(item);

                    if(item.orderImportNumber__c != null){
                        if(Map_ImpLineCount.get(LoopChunks)==null){
                            Map_ImpLineCount.put(LoopChunks,1);
                            Map_ImpLineCountQuantity.put(LoopChunks,item.Quantity);
                        }
                        else{
                            Map_ImpLineCount.put(LoopChunks,Map_ImpLineCount.get(LoopChunks)+1);
                            Map_ImpLineCountQuantity.put(LoopChunks,Map_ImpLineCountQuantity.get(LoopChunks)+item.Quantity);
                        }    
                    }

                    //Creates the next Order Item list. Maxline for current is reached
                    if(Map_Itemlist.get(LoopChunks).size() == FIXEDLINECOUNT){
                        LoopChunks++;
                        lstNewOrderitems = new List<OrderItem>();
                    }
                 }
                 else{

                    //Line count sent for Master Order
                    //Calculate Main line count now in Non Item group list and later in Item Group list
                    if(item.orderImportNumber__c != null){
                        if(Map_ImpLineCount.get(99999999)==null){
                            Map_ImpLineCount.put(99999999,1);
                            Map_ImpLineCountQuantity.put(99999999,item.Quantity);
                        }
                        else{
                            Map_ImpLineCount.put(99999999,Map_ImpLineCount.get(99999999)+1);
                            
                            Map_ImpLineCountQuantity.put(99999999,Map_ImpLineCountQuantity.get(99999999)+item.Quantity);

                        }    
                    }

                 }

                

                count++;
            }
        }
        else{
            Map_ImpLineCount.put(99999999,lst_OrdItem.size()); 
            for(OrderItem item:lst_OrdItem){
                if(Map_ImpLineCountQuantity.get(99999999)==null){
                    Map_ImpLineCountQuantity.put(99999999,item.Quantity);
                }
                else{
                    Map_ImpLineCountQuantity.put(99999999,Map_ImpLineCountQuantity.get(99999999)+item.Quantity);
                }    
            }    

        }

        

        if(Map_ItemGroup.size()>0){
             lstNewOrderitems = new List<OrderItem>();
            if(LoopChunks== 0){
                LoopChunks=1;
            }
            else{
                LoopChunks++;
            }
       
            count = 1;
            Map_Itemlist.put(LoopChunks,lstNewOrderitems);
            Integer CurrentChunkSize;

            //Splitting Item groups into their Set of orders per FIXEDLINE SIZE
            //Add Item Groups into full Map List of all items based on their chunks

            //Loop per Item group
            for(OrderItem item: Map_ItemGroup.keyset()){
                
                Integer CurListSize = count + Map_ItemGroup.get(item).size();
                
                

                if(CurListSize  < FIXEDLINECOUNT){
                    CurrentChunkSize = Map_Itemlist.get(LoopChunks).size();

                    //Loop per items in Group
                     for(OrderItem itemComp:Map_ItemGroup.get(item)){
                      
                        //add Components to the list
                        Map_Itemlist.get(LoopChunks).add(itemComp);
                        Map_IGLookup.put(itemComp.ImportItemGroupEAN__c, item.id);
                        count++;

                        if(itemComp.orderImportNumber__c != null){
                            if(Map_ImpLineCount.get(LoopChunks)==null){
                                Map_ImpLineCount.put(LoopChunks,1);
                                Map_ImpLineCountQuantity.put(LoopChunks,item.Quantity);
                            }
                            else{
                                Map_ImpLineCount.put(LoopChunks,Map_ImpLineCount.get(LoopChunks)+1);      
                                Map_ImpLineCountQuantity.put(LoopChunks,Map_ImpLineCountQuantity.get(LoopChunks)+item.Quantity);
                            }    
                        }
                    }
                    
                    CurrentChunkSize = Map_Itemlist.get(LoopChunks).size();

                    

                 } 
                else{
                    lstNewOrderitems = new List<OrderItem>();
                  
                    CurrentChunkSize = Map_Itemlist.get(LoopChunks).size() + Map_ItemGroup.get(item).size();

                    //Instantiate new list per chunk size that will add items below

                    if( CurrentChunkSize > FIXEDLINECOUNT){
                        LoopChunks++;
                        lstNewOrderitems = new List<OrderItem>();
                    }
                    if(Map_Itemlist.get(LoopChunks)== null){
                                                                //LoopChunks++;
                        Map_Itemlist.put(LoopChunks,lstNewOrderitems);
                        
                    }
                    
                    //add items below


                    for(OrderItem itemComp:Map_ItemGroup.get(item)){
                        
                        Map_IGLookup.put(itemComp.ImportItemGroupEAN__c, item.id);
                        //add Components to the list
                        Map_Itemlist.get(LoopChunks).add(itemComp);
                        count++;
                        if(itemComp.orderImportNumber__c != null){
                            if(Map_ImpLineCount.get(LoopChunks)==null){
                                Map_ImpLineCount.put(LoopChunks,1);
                                Map_ImpLineCountQuantity.put(LoopChunks,item.Quantity);
                            }
                            else{
                                Map_ImpLineCount.put(LoopChunks,Map_ImpLineCount.get(LoopChunks)+1);
                                Map_ImpLineCountQuantity.put(LoopChunks,Map_ImpLineCountQuantity.get(LoopChunks)+item.Quantity);
                            }    
                        }
                    }
                }
                
                
            }
        }

       

        if(count>0){
            ReparentItems(CurOrder, Map_Itemlist,lst_OrdItem,Map_IGLookup,Map_ImpLineCount,Map_ImpLineCountQuantity);
        }
   

    }

    Public static void ReparentItems(Order CurOrder, Map<Integer,List<OrderItem>> Map_Itemlist,OrderItem[] lst_OrdItem, Map<String, String> Map_IGLookup, Map<Integer, Integer> Map_ImpLineCount,Map<Integer, Decimal> Map_ImpLineCountQuantity ){
       
       
        Order newOrder;
        List<OrderItem> lst_InsertItemGroup = new List<OrderItem>(); 
        List<OrderItem> lst_Insert= new List<OrderItem>(); 
        List<OrderItem> lst_Delete= new List<OrderItem>(); 

       
        
        MaxOrderLine__c MaxOrderLine = new MaxOrderLine__c();
        MaxOrderline.OperatingCompany__c = CurOrder.OperatingCompany__c;
        Insert MaxOrderLine;
        Integer lineCount = Integer.valueof(CurOrder.LineCount__c);

        Set<Id> Set_OrdId = new Set<Id>();
        Set_OrdId.add(CurOrder.id);


        //Non Item Groups list == 0
        Integer ItemGroupListsize = lst_OrdItem.size();
        system.debug('**Order_OrderLineCountManager: ProcessLineCount**: NI ItemGroupListsize'+ ItemGroupListsize);
        OrderActivationRules__mdt[] OrderActivationRules;
        
        
            if(CurOrder.Type == 'RenewalOrder'){
                OrderActivationRules = [Select Source__c, Status__c,OperatingCompany__c from OrderActivationRules__mdt where Source__c =:'B2B Salesforce Renewal' AND OperatingCompany__c =:CurOrder.OperatingCompany__c];
            }
            else{
                OrderActivationRules = [Select Source__c, Status__c,OperatingCompany__c from OrderActivationRules__mdt where Source__c =: CurOrder.Source__c AND OperatingCompany__c =:CurOrder.OperatingCompany__c];
            }
               
        Map<String,String> Map_ActiveStatus = new Map<String,String>();

        String OpcoSource;
        
        OpcoSource = CurOrder.OperatingCompany__c;
        OpcoSource += CurOrder.Source__c;
        
        try{             
            Map_ActiveStatus.put(OpcoSource,OrderActivationRules[0].Status__c);
        }
        catch(exception e){
            Map_ActiveStatus.put(OpcoSource,'Inactive');
        }     

        Boolean ActivateforBatchProcessing;

        if(OrderActivationRules.size()>0 && Map_ActiveStatus.get(OpcoSource) == 'Active'){
            ActivateforBatchProcessing=true;
        } 
        else{
            ActivateforBatchProcessing=false;
        }     


        for(Integer LoopChunks: Map_Itemlist.keyset()){

            //Added to check if Master order has zero items then repopulate with new Item Group list
            if(ItemGroupListsize > 0){
                newOrder = new Order();
                newOrder = CurOrder.clone(false, false, false, false); 
                NewOrder.id=null;
                NewOrder.MasterOrder__c = CurOrder.id;
                NewOrder.MaxOrderLine__c = MaxOrderLine.id; 
                NewOrder.CurrencyIsoCode = CurOrder.CurrencyIsoCode;               
                NewOrder.RelatedOrderActivationBlock__c = true;
                NewOrder.OrderImportLineCountSent__c = Map_ImpLineCount.get(LoopChunks);
                NewOrder.OrderImportTotalLineQuantities__c = Map_ImpLineCountQuantity.get(LoopChunks);
                NewOrder.ActivateforBatchProcessing__c = ActivateforBatchProcessing;
                

                Insert newOrder;
                 Set_OrdId.add(newOrder.id);
            }
            else{
                newOrder = new Order();
                newOrder = CurOrder;
                CurOrder.OrderImportLineCountSent__c = Map_ImpLineCount.get(LoopChunks);
                CurOrder.OrderImportTotalLineQuantities__c = Map_ImpLineCountQuantity.get(LoopChunks);
                ItemGroupListsize++;
            }
                                                                             
          

            for(OrderItem item:Map_Itemlist.get(LoopChunks)){
                
                OrderItem newItem = new OrderItem();
                newItem = item.clone(false, false, false, false);
                newItem.id = null;
                if(ItemGroupListsize > 0){
                    newItem.OrderId = newOrder.id;
                }
                else{
                    newItem.OrderId = CurOrder.id;
                    if(Item.orderImportNumber__c != null){
                        newItem.orderImportNumber__c = Item.orderImportNumber__c;
                        
                        //Line count sent for Master Order if Item Group the only order and main. Due to split lists above
                        if(Map_ImpLineCount.get(99999999)==null){
                            Map_ImpLineCount.put(99999999,1);
                            Map_ImpLineCountQuantity.put(99999999,item.Quantity);
                        }
                        else{
                            Map_ImpLineCount.put(99999999,Map_ImpLineCount.get(99999999)+1);
                            Map_ImpLineCountQuantity.put(99999999,Map_ImpLineCountQuantity.get(99999999)+item.Quantity);
                        }   
                    }
                    else{
                       // newItem.orderImportNumber__c = CurOrder.OrderNumber;
                    }                   
                }
                
                newItem.UnitPrice = item.UnitPrice;

                if(item.ComponentListPrice__c != null){
                    newItem.ComponentListPrice__c = item.ComponentListPrice__c;
                }

                if(item.ListPriceDiscount__c != null){
                    newItem.ListPriceDiscount__c = item.ListPriceDiscount__c;
                }                                                

                if(item.ProductType__c == 'Item Group'){  
                    newItem.UnitPrice = 0;
                    newItem.ImportItemGroupEAN__c = item.id;                                                                 
                    lst_InsertItemGroup.add(newItem);  
                }   
                else if(item.ItemGroup__c != null){ 
                     newItem.ProductComponent__c = item.ProductComponent__c;                   
                    lst_InsertItemGroup.add(newItem);
                }
                else{
                   lst_Insert.add(newItem);
                }    

                lst_Delete.add(item);
            }
            ItemGroupListsize++;
        }


        
        
        try{
            insert lst_InsertItemGroup;
            
            //Add look ups for new Item Groups

            Map<String, String> Map_IGLookup2 = new Map<String, String>();
            for(OrderItem item: lst_InsertItemGroup){
                if(item.ProductType__c == 'Item Group'){                  
                   // Map_IGLookup2.put(item.ProductEAN__c,Item.id);
                   Map_IGLookup2.put(item.ImportItemGroupEAN__c,Item.id);
                }
            }
            system.debug('**Order_OrderLineCountManager: ProcessLineCount**: ItemGroup Populate Size:**' +lst_InsertItemGroup.size());
                
            for(OrderItem item: lst_InsertItemGroup){ 
                
                if(item.ProductType__c != 'Item Group'){
                    system.debug('**Order_OrderLineCountManager: ProcessLineCount**: ItemGroup Populate 1_:' + Map_IGLookup.get(item.ImportItemGroupEAN__c));
                    system.debug('**Order_OrderLineCountManager: ProcessLineCount**: ItemGroup Populate 1a:' +Map_IGLookup2.get(Map_IGLookup.get(item.ImportItemGroupEAN__c)));
                    system.debug('**Order_OrderLineCountManager: ProcessLineCount**: ItemGroup Populate 1b:' +item.ProductType__c);
                    system.debug('**Order_OrderLineCountManager: ProcessLineCount**: ItemGroup Populate 1c:' +item.ItemGroup__c);    
                }
                
                if(Map_IGLookup2.get(Map_IGLookup.get(item.ImportItemGroupEAN__c)) != null && item.ProductType__c != 'Item Group' ){ //&& item.ItemGroup__c == null
                    //item.ItemGroup__c =    Map_IGLookup2.get(Map_IGLookup.get(item.ProductEAN__c));
                    system.debug('**Order_OrderLineCountManager: ProcessLineCount**: ItemGroup Populate 2');
                    item.ItemGroup__c =    Map_IGLookup2.get(Map_IGLookup.get(item.ImportItemGroupEAN__c));
                    
                }
            }


            update lst_InsertItemGroup;
        }
        catch(exception e){
            system.debug('**Order_OrderLineCountManager: ProcessLineCount**: IG Update Final Grp 2 : Error:'+ e.getMessage());
        
            HandleCustomException.LogException(e,newOrder.id);
        }


        try{

            system.debug('**Order_OrderLineCountManager: lst_Delete**'+lst_Delete.size());
 
            delete lst_Delete;
 
            insert lst_Insert;

            MaxOrderLine.LineCount__c = lineCount;
            MaxOrderLine.OrderTotal__c = CurOrder.TotalAmount;
            
            Order[] CurOrderGET = [Select id,LineCount__c from Order where id =:CurOrder.id];                                                                                                
            
            if(Map_ImpLineCount.get(99999999) != null){
                CurOrder.OrderImportLineCountSent__c = Map_ImpLineCount.get(99999999); //CurOrderGET[0].LineCount__c;
                CurOrder.OrderImportTotalLineQuantities__c = Map_ImpLineCountQuantity.get(99999999);
            }
            
            CurOrder.MaxOrderLine__c = MaxOrderLine.id;
            CurOrder.ActivateforBatchProcessing__c= ActivateforBatchProcessing;
            CurOrder.RelatedOrderActivationBlock__c = true; 
            
            Update CurOrder;
            
            List<Order> lstInsertedOrd = [Select ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c,TotalLineItemQuantity__c,OrderImportTotalLineQuantities__c from Order where id in: Set_OrdId];
            
            Integer Count=0, ActiveReady=0;
            for(Order ord:lstInsertedOrd){
                
                if(ord.ValidationErrorsOrder__c==0 && ord.ValidationErrorsOrderProducts__c==0){
                    ActiveReady++;
                }
                
                Count++;
            }
            MaxOrderLine.ActivationReadyCount__c = ActiveReady;
            MaxOrderLine.ExpectedActivationCount__c = Count;
            Update MaxOrderLine;
            
            //Trigger business logic on all Orders
            List<Id> MaxOrderLineId = new List<Id>();
            MaxOrderLineId.add(MaxOrderLine.id);
            Order_RelatedOrderProcess.RelatedOrderProcessIvocable(MaxOrderLineId);
            
        }
        catch(exception e){
            system.debug('**Error**'+e.getMessage());
            HandleCustomException.LogException(e,CurOrder.id);
        }

    }


}