({
	doInit : function(component, event, helper){
        
        helper.fetchAccountsUtil(component);
        helper.fetchOrderUtil(component);
        helper.fetchOrderItemsUtil(component);
        
        helper.fetchloadAssetsforRate(component);
        helper.fetchBilltoAccount(component);
        helper.fetchProductsUtil(component);
        var PricingMethod = component.get('v.PricingMethod');

        console.log("**PricingMethod XX**"+PricingMethod);
         
            helper.fetchListPriceDiscountUtil(component);
            helper.fetchListPriceBook(component);
            helper.fetchMaxOrderlineCount(component);
            helper.UserPermissionSets(component);

            
          
     var Assetlist = component.get('v.Assetlist');

     

        var availableActions = component.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "PAUSE") {
            component.set("v.canPause", true);
         } else if (availableActions[i] == "BACK") {
            component.set("v.canBack", true);
         } else if (availableActions[i] == "NEXT") {
            component.set("v.canNext", true);
         } else if (availableActions[i] == "FINISH") {
            component.set("v.canFinish", true);
         }
      }

        component.set("v.canNext",false);
        component.set("v.canFinish",true);

    },

    onButtonPressed: function(component, event, helper) {
      
      // Figure out which action was called
      var actionClicked = event.getSource().getLocalId();

    //  var accountsData =  component.get('v.accountsData');

     // component.set('v.accountsData',[]);


      // Fire that action
      var navigate = component.get('v.navigateFlow');
      navigate(actionClicked); 
    
    },
    CompleteOrder: function(component, event, helper) {
      
         
        var ContractId =  component.get("v.ContractId");
        var OrderId =  component.get("v.OrderId");

        if(OrderId == undefined || OrderId == null){
            OrderId =  component.get("v.recordId");
        }
 
        var OrderItems = component.get("v.OrderItemList");  
        
        var action = component.get("c.InsertOrderItems");
        
        var AccountbyShipto = component.get("v.accountsData");

       var TotalNumberofStudents =  component.get("v.TotalNumberofStudents");

       var IsOpportunity = component.get("v.IsOpportunity");
       var IsPricebookName =  component.get("v.PricebookName");
    
//OPPORTUNITY
    var errorrequired=false;   
    if((IsOpportunity == true && IsPricebookName == 'Zorg') || IsPricebookName == 'Zorg'){
       for(var key in OrderItems){
          //  console.log('**OrderItems[key]**: OppTerms'+OrderItems[key].OppTerms);
         //  console.log('**OrderItems[key]**: OppServiceDate'+OrderItems[key].OppServiceDate); 
         //  console.log('**OrderItems[key]**: ProductTYPE'+OrderItems[key].ProductTYPE); 

           if((OrderItems[key].OppTerms == undefined || OrderItems[key].OppServiceDate == undefined || OrderItems[key].OppServiceDate == '') && OrderItems[key].ProductTYPE !='Inventory Item'){
                alert('Terms and Start date required for Non Inventory items');
                errorrequired = true;
                break;
           }
           else if(OrderItems[key].OppTerms > 0 && (OrderItems[key].OppServiceDate == '' || OrderItems[key].OppServiceDate == undefined )){
                alert('If terms are entered please enter a date');
                errorrequired = true;
                break;
           }
                   
       }
    }
//OPPORTUNITY
    if(errorrequired==false){
 		 action.setParams({ 
            "ContractId": ContractId,
            "OrderId": OrderId,
             "OrderItems": OrderItems,
             "TotalNumberofStudents":TotalNumberofStudents,
             "AccountbyShipto":AccountbyShipto,
    	});
        
        component.set("v.isSpinner",true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var OrderId = response.getReturnValue();
       			//window.location.assign("/"+OrderId);
                
                var isPermissionSet = component.get("v.isPermissionSet");
                console.log('**UserPermissionSets Save**'+ isPermissionSet);

                if(isPermissionSet == false){
                    window.location.assign("/lightning/r/Order/"+OrderId+"/view");  
                }
                else{
                    component.set("v.canNext",true);
                    component.set("v.canFinish",false);
                    component.set("v.isSpinner",false);
                    var navigate = component.get('v.navigateFlow');
                    var actionClicked = 'NEXT';
                    navigate(actionClicked);
                }
                   
                   


            }
            else if (state === "INCOMPLETE") {
                
            }
                else if (state === "ERROR") {
                    component.set("v.isSpinner",false);
                    var errors = response.getError();
                    if (errors) {
                        alert("Error message: " + errors[0].message);
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            
                        }
                    } else {
                        alert("Something went wrong: Please contact System Administrator");
                    }
                }
                else{


                }
        });
        
        
            $A.enqueueAction(action);
        }
    },
    
    AddProductstoAccInd : function(component, event, helper) {
        console.log("AddProductstoAccInd");
    	 helper.AddProductstoAcc(component,event,'Individual');          
    },    
    AddProductstoAccGroup : function(component, event, helper) {
    	helper.AddProductstoAcc(component,event,'Group');
    },
    AddProductstoAccAll : function(component, event, helper) {
    	helper.AddProductstoAcc(component,event,'All');
    },

    
    Selectallschools : function(component, event, helper) {
      
        var AllCheck = event.getSource().get('v.checked');
        var schoollist = component.get("v.accountsData");
        console.log('**allschoolsselected: In**'+AllCheck);
        for(var key in schoollist){
            if(AllCheck == true){
                schoollist[key].IsSelected = true;
            }
            else{
                schoollist[key].IsSelected = false;
            }
        }
        component.set("v.accountsData",schoollist);
    },  

    QuantityChangeProduct : function(component, event, helper) {
        var ProductId = event.target.id;
        var newquantity = event.target.value;
       // var FullProductList = component.get("v.FullProductList");
       var FullProductList = component.get("v.SchoolProductList");
       

        for(var keyP in FullProductList){             
            
            if(FullProductList[keyP].ProductId == ProductId){
                FullProductList[keyP].Quantity = newquantity;
            }
        }        
        component.set("v.SchoolProductList",FullProductList);

    }, 
    
    AddProductsInd : function(component, event, helper) {
     
         
        var ProductId = event.target.id;
        var schoolOrder = component.get("v.ShoolOrderItemList"); 
        var OrderItems = component.get("v.OrderItemList");
        var SchoolProductList = component.get("v.SchoolProductList");
 
        var OrderProdMap = component.get("v.OrderProdMap");
        var CurrenShipto = component.get("v.CurrenShipto");
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay"); 
        var curOrder =  component.get("v.curOrder");
        var BillToAccount  = component.get("v.BillToAccount");
        var IsOpportunity  = component.get("v.IsOpportunity");
        var MaxOrderlineCount =  component.get("v.MaxOrderlineCount");
        var index=0;
       

        var IsMarketSegment;
        var RemoveFromSearch=false;
        
        var ItemGroupTotal=0; 
        var ItemGroupBasePrice=0;
        var ItemGroupUnitPrice=0;
        var ItemGroupSTDPrice=0;
        var ItemGroupQuantity=0;
        var  ComponentQuantityDisplay;

        var ItemId = [];
        var ItemIdCount=0;

        var t0 = performance.now();



     var ProductAlreadyExists = false;
    

     var OrderItemsLength = OrderItems.length;
     
     console.log('***AddProductsInd: OrderItemsLength**'+OrderItemsLength);


  if(ProductAlreadyExists == false){     
        for(var keyP in SchoolProductList){
             
            
         if(SchoolProductList[keyP].ProductId == ProductId){  // Commented out for TEST  
 			    
               var Amount;
               var STDPrice;
               var UnitPrice;
               var BasePrice;
                
               for(var keyS in CurrenShipto){ 
                 
                

                 
                var selectquantity; 
                
                
                if(SchoolProductList[keyP].QuantitySelectionType == 'Per number of students' && CurrenShipto[keyS].NoPupils>0){
                    
                    if(SchoolProductList[keyP].maxQuantity <= CurrenShipto[keyS].NoPupils){
                        selectquantity = SchoolProductList[keyP].maxQuantity;
                    }
                    else{
                        selectquantity = CurrenShipto[keyS].NoPupils;
                    }
                    
                }
                else if(SchoolProductList[keyP].Quantity>0) {
                    
                    if(SchoolProductList[keyP].maxQuantity <= SchoolProductList[keyP].Quantity){
                        selectquantity = SchoolProductList[keyP].maxQuantity;
                    }
                    else{
                        selectquantity = SchoolProductList[keyP].Quantity;
                    }
                }
                else{
                    selectquantity = 1;
                }
                
                
                
  //              if(IsMarketSegment == true){ 

                var STDPrice;
                var ProductItemId;
                var STPId;
                var STPRate;
                var listPriceSelected=false;
                var PriceDiscount;
                var PriceDiscountItemGrp = '--None--';
                        
                           STDPrice=SchoolProductList[keyP].BasePrice;
                           Amount = selectquantity * STDPrice;
                          
                           var TmpPriceDiscount=false;
                    if(IsOpportunity){
                        PriceDiscount = 'Regular';
                        for(var type in SchoolProductList[keyP].listPriceProductType){                    
                            if(SchoolProductList[keyP].listPriceProductType[type] == 'Regular'){
                               TmpPriceDiscount=true;
                           }
                        }   
                        if(TmpPriceDiscount==false){                     
                            alert('This product cant be sold as regular type. Please check the product and update: Regular Order possible');
                            break;
                        }
                   
                    }
                    else{                   
                           PriceDiscount = 'Service';
                           if(curOrder.Type == 'RegularOrder'){
                                PriceDiscount = 'Regular';
                           }
                           else if(curOrder.Type == 'FreeOrder'){
                                PriceDiscount = 'Free';
                           }
                           if(PriceDiscount != 'Free'){
                                for(var type in SchoolProductList[keyP].listPriceProductType){
                                
                                         if(SchoolProductList[keyP].listPriceProductType[type] == 'Regular'){
                                            TmpPriceDiscount=true;
                                        }
                                } 
                                if(PriceDiscount == 'Regular' && TmpPriceDiscount == false){                                        
                                        PriceDiscount = 'Service';
                                }
                           }
                    }     
                            
                            
                              
                             
                            ItemGroupTotal = 0;
                            ItemGroupBasePrice=0;
                            ItemGroupUnitPrice=0;
                            ItemGroupSTDPrice=0;
                            for(var igroup in SchoolProductList[keyP].listItemGroupComponent){
                                if(SchoolProductList[keyP].listItemGroupComponent[igroup].ProductId == ProductId || OrderProdMap[SchoolProductList[keyP].listItemGroupComponent[igroup].ProductId] == 1){
                                    ProductAlreadyExists = true;
                                    alert('Product Already exists in Order.');
                                    break;
                                }



                                //For Summing up the main product in the component pack
                                ItemGroupQuantity = SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity;

                                ItemGroupBasePrice = (SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice * ItemGroupQuantity) + ItemGroupBasePrice ;
                                itemSTDPrice = SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice * ItemGroupQuantity;
                             
                                ItemGroupUnitPrice = itemSTDPrice + ItemGroupUnitPrice;
                                ItemGroupSTDPrice =  itemSTDPrice + ItemGroupSTDPrice;

                                itemAmount = selectquantity * itemSTDPrice ;
                                ItemGroupTotal = itemAmount + ItemGroupTotal;

                                console.log('**AddProductsInd: ItemGroupQuantity**'+ItemGroupQuantity);
                                
                          
                            }    
            if(ProductAlreadyExists == true){  
                break;                 
            }    
                                
                             if(ItemGroupTotal>0 ){ 

                                
                                Amount=ItemGroupTotal;
                                console.log('**AddProductsInd: Amount: Before**'+Amount);
                                BasePrice= ItemGroupBasePrice; 
                                UnitPrice= ItemGroupUnitPrice; 
                                STDPrice= ItemGroupSTDPrice;
                                CurrenOrderDisplay.TotalAmount = CurrenOrderDisplay.TotalAmount + Amount;  
                            } 
                            else{
                               
                                BasePrice= SchoolProductList[keyP].BasePrice; 
                                UnitPrice= STDPrice; 
                                STDPrice= STDPrice;
                                CurrenOrderDisplay.TotalAmount = CurrenOrderDisplay.TotalAmount + Amount;  
                                
                            }
                            
                            console.log('**AddProductsInd: Amount: After**'+Amount);
                            console.log('****AddProductsInd: CustomPricingAllowed**'+SchoolProductList[keyP].CustomPricingAllowed);

                            RemoveFromSearch=true;
                            var today = new Date();
                            var RTime = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
                            ProductItemId = CurrenShipto[keyS].AccId+ProductId+RTime;

                            
                            OrderItemsLength++;
                            schoolOrder.push({
                            'sobjectType': 'OrderLineItem',
                            'ShipToAccountName': CurrenShipto[keyS].Name,     
                            'ProductName': SchoolProductList[keyP].ProductName,
                            'ProductId': ProductId,
                            'Subsidiary': BillToAccount.OperatingCompany__c,
                            'OppTerms': SchoolProductList[keyP].licenceduration,
                            'LicenceDuration': SchoolProductList[keyP].licenceduration,
                            'listPriceRateId':STPId,                                                    
                            'listPriceDiscountType':SchoolProductList[keyP].listPriceDiscountType, 
                            'listPriceProductType' :  SchoolProductList[keyP].listPriceProductType,
                            'ProductRateGroup': SchoolProductList[keyP].ProductRateGroup,
                            'listPriceDiscount':SchoolProductList[keyP].listPriceDiscount,
                            'PriceDiscount': PriceDiscount, // CHANGE TO ORDERLINE TYPE
                            'listAsset2Product':SchoolProductList[keyP].listAsset2Product,   
                            'listItemGroupComponent':SchoolProductList[keyP].listItemGroupComponent,
                            'ItemGroupComponent': SchoolProductList[keyP].ItemGroupComponent,
                            'ShipToAccountId': CurrenShipto[keyS].AccId,
                            'CustomerDiscountGroup': BillToAccount.CustomerDiscountGroup__c,  
                            'STDPrice' : STDPrice,           
                            'UnitPrice' : UnitPrice,
                            'BasePrice' : BasePrice,     
                            'Rate' :SchoolProductList[keyP].Rate, 
                            'Quantity':selectquantity,
                            'MarketSegment':SchoolProductList[keyP].MarketSegment,
                            'Amount':Amount,
                            'NoDiscAmount' :Amount,    
                            'ManualDiscount':SchoolProductList[keyP].ManualDiscount ,
                            'DiscountOption':'--None--',
                            'DiscountPercentShow':false, 
                            'DiscountValueShow':false,     
                            'DiscountAmount':0,
                            'maxQuantity':SchoolProductList[keyP].maxQuantity,     
                            'ItemId': ProductItemId, 
                            'PricebookEntryId': SchoolProductList[keyP].PricebookEntryId,                           
                            'IsnewItem':'True',            
                            'QuantitySelectionType':SchoolProductList[keyP].QuantitySelectionType,
                            'Stocknumber':SchoolProductList[keyP].Stocknumber,
                            'ProductTYPE':SchoolProductList[keyP].ProductTYPE,
                            'CustomPricingAllowed': SchoolProductList[keyP].CustomPricingAllowed,
                            'MasterOrder': false,
                            'ProRataRate': 1,
                            'IsEdited':true, 
                            'Count':OrderItemsLength   
                            });
                

                            ItemId[ItemIdCount] = ProductItemId; 
                             
                            var itemSTDPrice;
                            var itemSTPId;
                            var itemAmount; 

                            var ComponentQuantityDisplay;
                            var ComponentQuantityFinal;
                            var ComponentQuantityTitle;
                             

                            ItemGroupBasePrice=0;
                            ItemGroupUnitPrice=0;
                            ItemGroupSTDPrice=0;

                            for(var igroup in SchoolProductList[keyP].listItemGroupComponent){
                                   
                                PriceDiscountItemGrp = PriceDiscount; //'Service';                                     
                                listPriceSelected=false;
                                itemSTDPrice=SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice;
                                ItemGroupQuantity = SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity
                                itemAmount = selectquantity * itemSTDPrice * ItemGroupQuantity;
                                if(PricingMethod =='AccountStudents'){
                                    if(STPId != null){
                                    
                                        itemSTDPrice =  SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice-(SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice*(STPRate/100));
                                        itemAmount = selectquantity * itemSTDPrice;
                                        itemSTPId =  STPId;

                                    }
                                }
                              
                                
                                
                                //For Summing up the main product in the component pack

                                ItemGroupTotal = itemAmount + ItemGroupTotal;
                                ItemGroupBasePrice = SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice + ItemGroupBasePrice;
                                ItemGroupUnitPrice = itemSTDPrice + ItemGroupUnitPrice;
                                ItemGroupSTDPrice =  itemSTDPrice + ItemGroupSTDPrice;
                                ComponentQuantityFinal = (SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity * selectquantity);
                             
                                 
                                 OrderItemsLength++;
                                    schoolOrder.push({
                                        'sobjectType': 'OrderLineItem',
                                        'ShipToAccountName': CurrenShipto[keyS].Name,     
                                        'ProductName': SchoolProductList[keyP].listItemGroupComponent[igroup].ProductName,
                                        'ProductId': SchoolProductList[keyP].listItemGroupComponent[igroup].ProductId,
                                        'ItemGroupType': SchoolProductList[keyP].listItemGroupComponent[igroup].ItemGroupType,
                                        'ItemGroup': ProductItemId, 
                                        'ItemGroupProductId': ProductId,
                                        'ItemGroupId': SchoolProductList[keyP].listItemGroupComponent[igroup].ItemGroupId,                                       
                                        'listPriceRateId': itemSTPId,                  
                                        'listPriceDiscountType':SchoolProductList[keyP].listItemGroupComponent[igroup].listPriceDiscountType, 
                                        'listPriceProductType' :  SchoolProductList[keyP].listPriceProductType,
                                        'ProductRateGroup': SchoolProductList[keyP].ProductRateGroup,  
                                        'listPriceDiscount':SchoolProductList[keyP].listItemGroupComponent[igroup].listPriceDiscount,
                                        'MarketSegment':SchoolProductList[keyP].listItemGroupComponent[igroup].MarketSegment, 
                                        'listAsset2Product':SchoolProductList[keyP].listItemGroupComponent[igroup].listAsset2Product,
                                        'PriceDiscount': PriceDiscountItemGrp,      
                                        'ShipToAccountId': CurrenShipto[keyS].AccId,
                                        'CustomerDiscountGroup': BillToAccount.CustomerDiscountGroup__c,  
                                        'Subsidiary': BillToAccount.OperatingCompany__c,
                                        'STDPrice' :itemSTDPrice ,    
                                        'UnitPrice' : itemSTDPrice, 
                                        'BasePrice' :SchoolProductList[keyP].listItemGroupComponent[igroup].BasePrice,     
                                        'Rate' :SchoolProductList[keyP].listItemGroupComponent[igroup].Rate, 
                                        'Quantity':ComponentQuantityFinal, 
                                        
                                        'ComponentQuantityTitle': ComponentQuantityTitle, 
                                        'ComponentQuantity':SchoolProductList[keyP].listItemGroupComponent[igroup].ComponentQuantity,
                                        'ComponentQuantityFinal': ComponentQuantityFinal, 
                                        'ComponentQuantityDisplay':ComponentQuantityDisplay,

                                        'Amount':itemAmount,       
                                        'NoDiscAmount' :itemAmount,    
                                        'ManualDiscount':SchoolProductList[keyP].listItemGroupComponent[igroup].ManualDiscount ,
                                        'DiscountOption':'--None--',
                                        'DiscountPercentShow':false, 
                                        'DiscountValueShow':false,     
                                        'DiscountAmount':0,     
                                        'ItemId':CurrenShipto[keyS].AccId+SchoolProductList[keyP].listItemGroupComponent[igroup].ProductId,
                                        'PricebookEntryId': SchoolProductList[keyP].listItemGroupComponent[igroup].PricebookEntryId,                                           
                                        'CustomPricingAllowed': SchoolProductList[keyP].listItemGroupComponent[igroup].CustomPricingAllowed,
                                        'MasterOrder': false,
                                        'IsnewItem':'True',
                                        'ProRataRate': 1,
                                        'IsEdited':true,
                                        'Count':OrderItemsLength       
                                        });
                               

                             }
                             

               ItemIdCount++;                  
               }
                        
           break;        
         }              
                        
         index++;          
        
        if(ProductAlreadyExists == true){  
            break;                 
        }

       }
       if(OrderItemsLength > MaxOrderlineCount){
            alert('Order Cant be more than '+MaxOrderlineCount+' items');
        }
        else{

            if(ProductAlreadyExists == false){  
                
            var t1 = performance.now();
            console.log("ADD PRODUCT TOOK: " + (t1 - t0) + " milliseconds.");
        
            var t2 = performance.now();
            if(RemoveFromSearch == true){  
                    SchoolProductList.splice(index,1); 
                }                                      
      
        
                var t2 = performance.now();
                console.log("ITEM GROUP TOOK: " + (t2 - t1) + " milliseconds.");
             
                var PricingMethod = component.get('v.PricingMethod');
            
                var t3 = performance.now();
                console.log("ADD SET TOOK: " + (t3 - t2) + " milliseconds.");

                component.set("v.SchoolProductList",SchoolProductList); // Commented out for TEST 
                
                helper.UpdateListPriceDiscountNew(component,'AddProduct',ItemId,PricingMethod,schoolOrder);
                                
                }
            }        
    }
    
    component.set("v.OrderProdMap",[]);   
      
    },
   
   RemoveOrderItem : function(component, event, helper) {
       var OrderItemId = event.target.id;
       var fullOrderList = component.get("v.OrderItemList"); 
       
       var totalOrderAmounts = component.get( 'v.TotalOrder');
       
       var schoolOrder = component.get("v.ShoolOrderItemList");
       var SchoolProductList = component.get("v.SchoolProductList");
        var CurrenShipto = component.get("v.CurrenOrderDisplay");
    
       var index=0;
       var ProductId;

       var groupItem = [];
       for(var key in fullOrderList){
       	  
        
           if(fullOrderList[key].ItemId ==OrderItemId || fullOrderList[key].ItemGroup == OrderItemId){
               
               groupItem.push(index);
               
              // break;
           }

           if(fullOrderList[key].ItemId == OrderItemId){
            ProductId = fullOrderList[key].ProductId;
           }
           
           index++;
       }
 
       for(var i = groupItem.length -1; i >= 0; i--){
            console.log('**Splice: one**'+i);
            fullOrderList.splice(groupItem[i],1);
       }

       
       totalOrderAmounts.TotalAmount =0;
       for(var key in fullOrderList){
            if(fullOrderList[key].ItemGroup== undefined){
                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                fullOrderList[key].PriceDiscount = fullOrderList[key].PriceDiscount;
                
            }    
       }
        
       
      

  
       component.set("v.OrderItemList",fullOrderList); 

       var PricingMethod = component.get('v.PricingMethod');
        console.log('**OrderProductQuantity**'+PricingMethod);
        
            var varItemId = [];
            varItemId[0] = ProductId;          
           helper.UpdateListPriceDiscount(component,'Existing',varItemId,PricingMethod,fullOrderList);
     
   }, 


   RemoveOrderItemSelection : function(component, event, helper) {
    var OrderItemId = event.target.id;

    
    var schoolOrder = component.get("v.ShoolOrderItemList");
    var SchoolProductList = component.get("v.SchoolProductList");
     var CurrenShipto = component.get("v.CurrenOrderDisplay");
    
     var fullOrderList = component.get("v.OrderItemList"); 
     var totalOrderAmounts = component.get( 'v.TotalOrder');
     

    var index=0;
    console.log('**OrderItemId: Out**'+OrderItemId);
   
    index=0;
    var groupItem = [];
    for(var key in schoolOrder){
        console.log('**OrderItemId: School**');

        if(schoolOrder[key].ItemId ==OrderItemId && schoolOrder[key].ItemGroup == null){  
            SchoolProductList.push({
             'sobjectType': 'ProductListPrice',
             'ProductName': schoolOrder[key].ProductName,
            'UnitPrice': schoolOrder[key].UnitPrice,
               'STDPrice': schoolOrder[key].STDPrice,
             'BasePrice': schoolOrder[key].BasePrice,     
             'ProductId': schoolOrder[key].ProductId,     
               'Rate': schoolOrder[key].Rate,
              'PricebookEntryId': schoolOrder[key].PricebookEntryId,
              'listPriceDiscount':schoolOrder[key].listPriceDiscount,
              'listAsset2Product':schoolOrder[key].listAsset2Product,
              'listPriceRateId':schoolOrder[key].listPriceRateId,            
             'QuantitySelectionType':schoolOrder[key].QuantitySelectionType,
             'listItemGroupComponent':schoolOrder[key].listItemGroupComponent,
             'ItemGroupComponent': schoolOrder[key].ItemGroupComponent,
             'ProductTYPE':schoolOrder[key].ProductTYPE,
             'ManualDiscount':schoolOrder[key].ManualDiscount,
             'listPriceDiscountType':schoolOrder[key].listPriceDiscountType,
             'listPriceProductType' :  schoolOrder[key].listPriceProductType,
             'Stocknumber':schoolOrder[key].Stocknumber
         });                        


        }
        
        if(schoolOrder[key].ItemId ==OrderItemId || schoolOrder[key].ItemGroup == OrderItemId){
                 groupItem.push(index);
        }
        index++;
    }
    

    for(var i = groupItem.length -1; i >= 0; i--){
         schoolOrder.splice(groupItem[i],1);
     }
      
    CurrenShipto.TotalAmount = 0;
    for(var key in schoolOrder){
         if(schoolOrder[key].ItemGroup== undefined){
             CurrenShipto.TotalAmount = CurrenShipto.TotalAmount + schoolOrder[key].Amount;
             schoolOrder[key].PriceDiscount = schoolOrder[key].PriceDiscount;   
             
         }
     }    
    

 
	   component.set("v.ShoolOrderItemList",schoolOrder);
       component.set("v.SchoolProductList",SchoolProductList);

    
     
   }, 
    

/*
    SaveProduct : function(component, event, helper) {
        var schoolOrder = component.get("v.ShoolOrderItemList");
        var totalOrderAmounts = component.get( 'v.TotalOrder');

        var fullOrderList = component.get("v.OrderItemList");
        
        var t1 = performance.now();
        
        

        for(var key in schoolOrder){
            
            
                        fullOrderList.push({
                      'sobjectType': 'OrderLineItem',
                       'ShipToAccountName': schoolOrder[key].ShipToAccountName, 
                      'ProductName':schoolOrder[key].ProductName,
                      'ItemGroup': schoolOrder[key].ItemGroup,
                      'ItemGroupId': schoolOrder[key].ItemGroupId,                                  
                      'ProductId': schoolOrder[key].ProductId, 
                      'ShipToAccountId': schoolOrder[key].ShipToAccountId,
                      'CustomerDiscountGroup': schoolOrder[key].CustomerDiscountGroup, 
                      'Subsidiary':  schoolOrder[key].Subsidiary,
                      'Quantity':  schoolOrder[key].Quantity, 
                       
                      'UnitPrice' :schoolOrder[key].UnitPrice,
                       'BasePrice' :schoolOrder[key].BasePrice,
                       'STDPrice' :schoolOrder[key].STDPrice,
                       'listPriceRateId':schoolOrder[key].listPriceRateId,
                       'listPriceDiscountType':schoolOrder[key].listPriceDiscountType,
                       'ProductRateGroup': schoolOrder[key].ProductRateGroup, 
                       'PriceDiscount':schoolOrder[key].PriceDiscount,
                       'listPriceProductType' : schoolOrder[key].listPriceProductType,
                       'NoDiscAmount' :schoolOrder[key].NoDiscAmount,
                       'maxQuantity': schoolOrder[key].maxQuantity,
                      'Rate' :schoolOrder[key].Rate,                   
                      'Amount':schoolOrder[key].Amount,
                      'ManualDiscount':schoolOrder[key].ManualDiscount ,
                      'DiscountOption':schoolOrder[key].DiscountOption,  
                      'DiscountAmount':schoolOrder[key].DiscountAmount,
                        'DiscountPercent': schoolOrder[key].DiscountPercent,
                        'DiscountPercentShow': schoolOrder[key].DiscountPercentShow,
                        'DiscountValueShow': schoolOrder[key].DiscountValueShow,
                      'ItemId':schoolOrder[key].ItemId,
                      'PricebookEntryId': schoolOrder[key].PricebookEntryId,
                      'MarketSegment': schoolOrder[key].MarketSegment,
                      'listPriceDiscount':schoolOrder[key].listPriceDiscount,
                      'listAsset2Product':schoolOrder[key].listAsset2Product,
                      'ComponentQuantityTitle': schoolOrder[key].ComponentQuantityTitle,
                      'ComponentQuantity': schoolOrder[key].ComponentQuantity,   
                      'ComponentQuantityFinal': schoolOrder[key].ComponentQuantityFinal,
                      'ComponentQuantityDisplay': schoolOrder[key].ComponentQuantityDisplay,   
                      'ItemGroupComponent': schoolOrder[key].ItemGroupComponent,
                      'ItemGroupProductId': schoolOrder[key].ItemGroupProductId,
                      'ItemGroupType':schoolOrder[key].ItemGroupType,
                      'ItemGroup':schoolOrder[key].ItemGroup,
                      'ItemGroupId':schoolOrder[key].ItemGroupId, 
                      'IsEdited':schoolOrder[key].IsEdited,         
                                    
                       
                });
                 
        }
        var t2 = performance.now();     
        console.log("time 2 " + (t2 - t1) + " milliseconds.");
      
        totalOrderAmounts.TotalAmount =0;
        for(var key in fullOrderList){
            if(fullOrderList[key].ItemGroup== undefined){
                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
            } 
        }    

        var t3 = performance.now();
         console.log("time 3 " + (t3 - t2) + " milliseconds.");

        component.set( 'v.TotalOrder', totalOrderAmounts);
        
        component.set("v.OrderItemList",fullOrderList); 
        component.set("v.ShoolOrderItemList",[]);
        component.set("v.CurrenOrderDisplay",[]);

        var t4 = performance.now();
         console.log("time 3 " + (t4 - t3) + " milliseconds.");
        
      
        
    },
    */ 

   
    
    closeAccOrd : function(component, event, helper){
        component.set("v.isOpenAccOrd",false);
        component.set("v.ShoolOrderItemList",[]);
        component.set("v.SchoolProductList",[]);
        component.set("v.CurrenOrderDisplay",[]);
    },
    
    handleShowList : function(component, event, helper){
        component.set( 'v.newRec', false);
        component.set( 'v.showList', true);
        helper.fetchAccountsUtil(component);
    },

    ListPriceChangeProduct : function(component, event, helper) {
        
        
        var ItemId = event.target.id;
        var newListPrice = event.target.value;
       // var FullProductList = component.get("v.FullProductList");
       var fullOrderList = component.get("v.OrderItemList");
        var totalOrderAmounts = component.get( 'v.TotalOrder');
       var SETCHANGE = true;
        var varItemId = [];
       varItemId[0] = ItemId;


       
       console.log('**ListPriceChangeProduct: newListPrice **'+newListPrice);
       newListPrice = parseFloat(newListPrice); //.toFixed(2)
       if(newListPrice >= 0.01){
        
       
        totalOrderAmounts.TotalAmount = 0;
        var tmpSTD;
        var tmpUnit; 
        var tmpAmount;

       for(var key in fullOrderList){            
            
            if(fullOrderList[key].ItemId == ItemId){
                console.log('**ListPriceChangeProduct: Loop:STD 1**'+fullOrderList[key].STDPrice);
                   
               
                
                console.log('**ListPriceChangeProduct: DiscountAmount **'+fullOrderList[key].DiscountAmount);
                

                
                    
                    console.log('**ListPriceChangeProduct: Loop:STD 2**'+fullOrderList[key].STDPrice);
                    console.log('**ListPriceChangeProduct: Loop:Rate **'+fullOrderList[key].Rate);

                    if(fullOrderList[key].Rate != undefined){
                        tmpSTD = parseFloat((newListPrice - newListPrice * fullOrderList[key].Rate)).toFixed(2);
                    }
                    else{
                        tmpSTD = parseFloat(newListPrice).toFixed(2);
                    }

                    console.log('**ListPriceChangeProduct: Loop: tmpSTD**'+tmpSTD);

                    tmpUnit = tmpSTD;
                    
                    if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                        tmpUnit = (tmpSTD-fullOrderList[key].DiscountAmount).toFixed(2);
                        tmpAmount = fullOrderList[key].Quantity * (tmpUnit);  
                    }
                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                        tmpAmount = (fullOrderList[key].Quantity * tmpSTD)-fullOrderList[key].DiscountAmount;
                        tmpUnit = (fullOrderList[key].Amount/fullOrderList[key].Quantity).toFixed(2);
                    }
                    else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                        tmpUnit = (tmpSTD-(tmpSTD*(fullOrderList[key].DiscountPercent/100))).toFixed(2);
                        tmpAmount = fullOrderList[key].Quantity * tmpUnit;
                    }
                    else{
                        tmpAmount = fullOrderList[key].Quantity * tmpUnit;   
                    }

                 //   fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;
                 console.log('****ListPriceChangeProduct :UnitPrice **'+tmpUnit);
                 console.log('****ListPriceChangeProduct : Amount **'+tmpAmount);
                    if(fullOrderList[key].ProRataRate < 1 ){
                            
                        console.log('****ListPriceChangeProduct:ProRataRate:UnitPrice **'+tmpUnit);

                        tmpUnit =  (tmpUnit*(parseFloat(fullOrderList[key].ProRataRate))).toFixed(2);
                        console.log('****ListPriceChangeProduct:ProRataRate:UnitPrice **'+tmpUnit);
                        tmpAmount =  tmpUnit * fullOrderList[key].Quantity;
                    }

                    //Check after Manual discount
                    if((fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount') && tmpSTD  < fullOrderList[key].DiscountAmount){
                       // SETCHANGE = false;
                       totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                        break;
                    }
                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                        
                        if(fullOrderList[key].Quantity == 1 && tmpSTD  <  fullOrderList[key].DiscountAmount){
                           // SETCHANGE = false;
                           totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            break;
                        }
                        else if(tmpSTD  <  ((fullOrderList[key].DiscountAmount)/fullOrderList[key].Quantity)){
                          //  SETCHANGE = false;
                          totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            break;
                        }
                        
                    } 
                    // Only set new values if no errors
                    console.log('****ListPriceChangeProduct : no errors:tmpUnit **'+tmpUnit);
                    fullOrderList[key].IsEdited = true;
                    fullOrderList[key].BasePrice = newListPrice.toFixed(2);
                    fullOrderList[key].STDPrice = tmpSTD;
                    fullOrderList[key].Amount = tmpAmount;
                    fullOrderList[key].UnitPrice = tmpUnit;
                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;


                //add manual discounts

            }
            console.log('****ListPriceChangeProduct:ProRataRate:UnitPrice **'+fullOrderList[key].ItemGroup);
                    if(fullOrderList[key].ItemGroup== undefined){
                        totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                    }  
        }  
    }

         if(SETCHANGE == true){
            component.set("v.OrderItemList",fullOrderList);
            
         }    
         component.set( 'v.TotalOrder', totalOrderAmounts);
        
    },

    QuantityChangeforRate : function(component, event, helper){
        var ItemId = event.target.id;
        var newquantity = event.target.value;
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
        var PricingMethod = component.get('v.PricingMethod');
        var totalOrderAmounts = component.get( 'v.TotalOrder');
        
        var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        var MaxQuantity = null;
        var TotalShipto;
        var TotalOrder; 
        
        newquantity = parseFloat(newquantity).toFixed(0);
        
        
        if(newquantity>=1){
            
            CurrenOrderDisplay.TotalAmount =0;
        
            
                totalOrderAmounts.TotalAmount=0; 
                
                var ItemGroupTotalAmount=0;
                var ItemGroupUnitPrice=0;
                
                var NegativeNSPrice = false;

                for(var key in fullOrderList){            
                    
                   

                    if((fullOrderList[key].ItemId == ItemId || fullOrderList[key].ItemGroup == ItemId || PricingMethod=='OrderTotalAmount') ){
                   

                        if(fullOrderList[key].maxQuantity == null || fullOrderList[key].maxQuantity == undefined || newquantity <= fullOrderList[key].maxQuantity ){


                                    fullOrderList[key].UnitPrice = fullOrderList[key].BasePrice;
                                    fullOrderList[key].STDPrice = fullOrderList[key].BasePrice;
                                    fullOrderList[key].Amount = fullOrderList[key].STDPrice * fullOrderList[key].Quantity;
                                    fullOrderList[key].listPriceRateId = null;

                                if(fullOrderList[key].ItemId == ItemId || fullOrderList[key].ItemGroup == ItemId){
                                    var tmpQuantity;
                                    if(fullOrderList[key].ItemGroup == ItemId){
                                        tmpQuantity = newquantity * fullOrderList[key].ComponentQuantity;
                                    }
                                    else{
                                        tmpQuantity = newquantity;  
                                    }

                                    if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                                        
                                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-fullOrderList[key].DiscountAmount;
                                        fullOrderList[key].Amount = tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2);

                                        if(fullOrderList[key].Amount < 0){
                                            fullOrderList[key].DiscountAmount = 0;
                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice;
                                            fullOrderList[key].Amount = tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2);
                                            NegativeNSPrice = true;
                                        }
                                        
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                                        fullOrderList[key].Amount = parseFloat((tmpQuantity * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount).toFixed(2);
                                        console.log('**DiscountOption: **'+fullOrderList[key].Amount);
                                        
                                        fullOrderList[key].UnitPrice = fullOrderList[key].Amount/tmpQuantity;

                                        if(fullOrderList[key].Amount < 0){
                                            fullOrderList[key].DiscountAmount = 0;
                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice;
                                            fullOrderList[key].Amount = tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2);
                                            NegativeNSPrice = true;
                                        }
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                                        fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100))).toFixed(2);
                                        fullOrderList[key].Amount = tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2);
                                    }
                                    else{
                                        fullOrderList[key].Amount = parseFloat(tmpQuantity * parseFloat(fullOrderList[key].UnitPrice).toFixed(2)).toFixed(2);   
                                    }
                                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;
                                    console.log('**AFter Quantity change Amount **'+fullOrderList[key].Amount);
                                    
                                    fullOrderList[key].Quantity = newquantity;

                                    fullOrderList[key].ComponentQuantityFinal = (fullOrderList[key].ComponentQuantity * newquantity);

                                    if(fullOrderList[key].ItemGroup == ItemId){
                                        fullOrderList[key].Quantity = fullOrderList[key].ComponentQuantityFinal;
                                    }

                                    if(fullOrderList[key].ProRataRate < 1 ){
                        
                                        fullOrderList[key].UnitPrice =  (fullOrderList[key].UnitPrice*(parseFloat(fullOrderList[key].ProRataRate))).toFixed(2);
                                        console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);
                                        fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                                    }  

                                    
                                }

                                    fullOrderList[key].IsEdited=true;

                                }
                                else{

                                    MaxQuantity = fullOrderList[key].maxQuantity;
                                    break; 
                                } 

                                if(fullOrderList[key].ItemGroup== undefined){
                                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                                }   
                                
                                    
                                    if(fullOrderList[key].ItemGroup == ItemId){
                                    
                                        ItemGroupTotalAmount = parseFloat(ItemGroupTotalAmount) + parseFloat(fullOrderList[key].Amount);
                                        ItemGroupUnitPrice =  parseFloat(ItemGroupUnitPrice) + parseFloat(fullOrderList[key].UnitPrice);
                                
                                    }
                                    

                    }   
                            
                }
                if(MaxQuantity == null){
                          
                        console.log('**ItemGroupTotalAmount : **'+ItemGroupTotalAmount );
                        if(ItemGroupTotalAmount > 0){
                            totalOrderAmounts.TotalAmount=0;
                            for(var key in fullOrderList){ 

                                if((fullOrderList[key].ItemId == ItemId) ){
                                    fullOrderList[key].Amount = ItemGroupTotalAmount;
                                    fullOrderList[key].UnitPrice = ItemGroupUnitPrice;
                                }
                                if(fullOrderList[key].ItemGroup== undefined){
                                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                                }
                            }        
                        }


                        component.set( 'v.TotalOrder', totalOrderAmounts);
                        
                        console.log('**OrderProductQuantity**'+PricingMethod);
                        var varItemId = [];
                        varItemId[0] = ItemId;        
                        helper.UpdateListPriceDiscount(component,'Existing',varItemId,PricingMethod,fullOrderList);

                        if(NegativeNSPrice == true){
                            alert('Discount Amount was greater than Line Amount. Please enter a new discount');
                        }
                }   
                else{
                    component.set("v.ShoolOrderItemList",schoolOrder);
                    component.set("v.OrderItemList",fullOrderList);    
                    alert('This product has maximum quantity of: ' + MaxQuantity+': please select correct quantity');
                } 

            }
            else{
                component.set("v.ShoolOrderItemList",schoolOrder);
                component.set("v.OrderItemList",fullOrderList);
            }    
    },
     
    
    
    ManualDiscount : function(component, event, helper) {
        
        console.log('**Manual Discount 1***');

        var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        var ItemId = event.target.id;        
        var DiscountOption = event.target.value;       
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
        
        var totalOrderAmounts = component.get( 'v.TotalOrder');
         
        console.log('**Manual Discount 2***');

        totalOrderAmounts.TotalAmount=0; CurrenOrderDisplay.TotalAmount =0;
        

        var ItemGroupTotal=0;         
        var ItemGroupUnitPrice=0;
        var ItemGroup;

        for(var key in fullOrderList){            
             
            if(fullOrderList[key].ItemId == ItemId){
                if(fullOrderList[key].ItemGroup == undefined){
                    ItemGroup=ItemId;
                }   
                else{
                    ItemGroup = fullOrderList[key].ItemGroup;
                }
                
            }
        }       
        ItemGroupTotal=0;         
        ItemGroupUnitPrice=0;
        for(var key in fullOrderList){            
             
            if(fullOrderList[key].ItemId == ItemId){
                fullOrderList[key].IsEdited = true;
             
             if(DiscountOption == 'One-Off Percentage'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountPercentShow=true; 
                fullOrderList[key].DiscountValueShow=false;  
            }
            else if(DiscountOption== 'Recurring Percentage'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountPercentShow=true; 
                fullOrderList[key].DiscountValueShow=false;
            }
            else if(DiscountOption== 'One-Off Amount'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountValueShow=true;
                fullOrderList[key].DiscountPercentShow=false;
            }
            else if(DiscountOption== 'One-Off Amount (Subtotal)'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountValueShow=true;
                fullOrderList[key].DiscountPercentShow=false;
            }
            
            else if(DiscountOption== 'Recurring Amount'){
                fullOrderList[key].DiscountOption = DiscountOption;
                fullOrderList[key].DiscountValueShow=true;
                fullOrderList[key].DiscountPercentShow=false;
            }
           else{
               fullOrderList[key].DiscountOption = '--None--'; 
               fullOrderList[key].DiscountPercentShow=false;
               fullOrderList[key].DiscountValueShow=false;    
           }
               fullOrderList[key].PriceDiscount = fullOrderList[key].PriceDiscount;
               
               fullOrderList[key].DiscountAmount = 0;
               fullOrderList[key].DiscountPercent = 0; 
               fullOrderList[key].UnitPrice=   fullOrderList[key].STDPrice;
               
               console.log('**STDPrice**'+ fullOrderList[key].STDPrice);

               if(fullOrderList[key].ItemGroup != null){ 
                    fullOrderList[key].Amount = fullOrderList[key].STDPrice*(fullOrderList[key].Quantity/fullOrderList[key].ComponentQuantity);
               }
               else{
                    fullOrderList[key].Amount = fullOrderList[key].STDPrice*fullOrderList[key].Quantity;
               }    
               //
               console.log('**Amount**'+ fullOrderList[key].Amount);

               console.log('**ComponentQuantity**'+ fullOrderList[key].ComponentQuantity);
            }
            if(fullOrderList[key].ItemGroup == ItemGroup ){
                
                if(fullOrderList[key].ItemId == ItemId ){
                    fullOrderList[key].IsEdited = true;
                    console.log('**ComponentQuantity 2**'+ fullOrderList[key].ComponentQuantity);

                  if(fullOrderList[key].ItemGroup != null){ 
                        fullOrderList[key].Amount = fullOrderList[key].STDPrice*(fullOrderList[key].Quantity);
                   }
                   else{
                     fullOrderList[key].Amount = fullOrderList[key].STDPrice*fullOrderList[key].Quantity;
                   }   
                    
                    fullOrderList[key].UnitPrice=   fullOrderList[key].STDPrice;   
                }
                
                
                ItemGroupTotal = parseFloat(fullOrderList[key].Amount) + parseFloat(ItemGroupTotal);               
                ItemGroupUnitPrice = parseFloat(fullOrderList[key].UnitPrice * fullOrderList[key].ComponentQuantity) + parseFloat(ItemGroupUnitPrice);
                console.log('**ItemGroupTotal**'+ ItemGroupTotal);           
            }
            
           
        }
        for(var key in fullOrderList){

            if(ItemGroupTotal>0 && fullOrderList[key].ItemGroup== undefined && fullOrderList[key].ItemId == ItemGroup ){
                fullOrderList[key].IsEdited = true;
              fullOrderList[key].Amount=ItemGroupTotal;              
              fullOrderList[key].UnitPrice= ItemGroupUnitPrice;              
              totalOrderAmounts.TotalAmount = parseFloat(totalOrderAmounts.TotalAmount) + parseFloat(fullOrderList[key].Amount);
              console.log('**totalOrderAmounts.TotalAmount**'+ totalOrderAmounts.TotalAmount);
            }
            else if(fullOrderList[key].ItemGroup== undefined){
                

              totalOrderAmounts.TotalAmount = parseFloat(totalOrderAmounts.TotalAmount) + parseFloat(fullOrderList[key].Amount);
              
            } 
             
            if(fullOrderList[key].ProRataRate < 1 && fullOrderList[key].ItemId == ItemId){
                console.log('**ProRataRate**'+fullOrderList[key].ProRataRate);        
                fullOrderList[key].UnitPrice =  (fullOrderList[key].UnitPrice*(parseFloat(fullOrderList[key].ProRataRate))).toFixed(2);
                console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);
                fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
            }

        }
      
        

        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
        component.set( 'v.TotalOrder', totalOrderAmounts);
        component.set("v.ShoolOrderItemList",schoolOrder);
    	component.set("v.OrderItemList",fullOrderList); 
    },
    ManualDiscountPercent: function(component, event, helper) {
      
        var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        
        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
        var totalOrderAmounts = component.get( 'v.TotalOrder');
        
        var ItemId = event.target.id;
    	var DiscountPercent = event.target.value; 
        
        var ItemGroupTotal=0;         
        var ItemGroupUnitPrice=0;
        var ItemGroup;
        DiscountPercent = parseFloat(DiscountPercent).toFixed(2);
        if(DiscountPercent >= 0 && DiscountPercent <=100){ 
                        for(var key in fullOrderList){            
                            
                            if(fullOrderList[key].ItemId == ItemId){
                                ItemGroup = fullOrderList[key].ItemGroup;
                            }
                        }    

                        totalOrderAmounts.TotalAmount=0; CurrenOrderDisplay.TotalAmount =0;

                        for(var key in fullOrderList){
                            
                            if(fullOrderList[key].ItemId == ItemId){
                                
                                fullOrderList[key].IsEdited = true;

                                fullOrderList[key].DiscountPercent = DiscountPercent;
                                
                                fullOrderList[key].DiscountAmount = 0;
                                fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice - (fullOrderList[key].STDPrice *(DiscountPercent/100))).toFixed(2);
 
                                console.log('**Prod: Item Group**'+ fullOrderList[key].ItemGroup);
                                if(fullOrderList[key].ItemGroup != null){ 
                                    fullOrderList[key].Amount = fullOrderList[key].UnitPrice *(fullOrderList[key].Quantity);
                               }
                               else{
                                    fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                               }
                            }

 
                            if((fullOrderList[key].ItemGroup == ItemGroup && ItemGroup != undefined) || fullOrderList[key].ItemGroup == ItemId){                               
                                ItemGroupTotal = parseFloat(fullOrderList[key].Amount) + parseFloat(ItemGroupTotal);               
                                ItemGroupUnitPrice = parseFloat(fullOrderList[key].UnitPrice * fullOrderList[key].ComponentQuantity) + parseFloat(ItemGroupUnitPrice);  
                            }
                         
                        }

            
                        for(var key in fullOrderList){

                            if(ItemGroupTotal>0 && fullOrderList[key].ItemGroup== undefined && fullOrderList[key].ItemId == ItemGroup){

                                console.log('**Main: UnitPrice**'+ ItemGroupUnitPrice); 

                                fullOrderList[key].IsEdited = true;
                                fullOrderList[key].Amount=ItemGroupTotal;              
                                fullOrderList[key].UnitPrice= ItemGroupUnitPrice;              
                                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            }
                            else if(fullOrderList[key].ItemGroup== undefined){
                                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            } 
                            
                            if(fullOrderList[key].ProRataRate < 1 && fullOrderList[key].ItemId == ItemId){
                                console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);

                                fullOrderList[key].UnitPrice =  (fullOrderList[key].UnitPrice*(parseFloat(fullOrderList[key].ProRataRate))).toFixed(2);
                                console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);
                                fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                            }
                                      
                        }
        


                        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
                        component.set( 'v.TotalOrder', totalOrderAmounts);
                }                
                        component.set("v.ShoolOrderItemList",schoolOrder); 
                        component.set("v.OrderItemList",fullOrderList);
            

    },
    AllDiscountPercent: function(component, event, helper) {
      
         
        var fullOrderList = component.get("v.OrderItemList"); 
        
        var ItemGroupTotal = component.get("v.VarMap"); 
        
        var totalOrderAmounts = component.get( 'v.TotalOrder');
        
        
    	var DiscountPercent = component.find("AllDiscount").get("v.value");
        
        
        DiscountPercent = parseFloat(DiscountPercent).toFixed(2);
        
        if(DiscountPercent >= 0 && DiscountPercent <=100){ 
                        

                        totalOrderAmounts.TotalAmount=0;  
                        var HasItemGroups = false;

                        for(var key in fullOrderList){

                            console.log('*AllDiscountPercent: ItemGroup1**'+fullOrderList[key].ItemGroup);

                         fullOrderList[key].IsEdited = true;
                         
                            if(fullOrderList[key].ItemGroupComponent == false || fullOrderList[key].ItemGroupComponent == undefined){// && fullOrderList[key].ItemGroup==undefined ){
                                
                                fullOrderList[key].DiscountPercent = DiscountPercent;
                                fullOrderList[key].DiscountPercentShow=true; 
                                fullOrderList[key].DiscountValueShow=false; 
                                fullOrderList[key].DiscountAmount = 0;
                                fullOrderList[key].DiscountOption = 'One-Off Percentage';                                                        
                                
                                if(fullOrderList[key].ItemGroupComponent == false){
                                    fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice - (fullOrderList[key].STDPrice *(DiscountPercent/100))).toFixed(2);
                                    fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;                             
                                }
                                else if(fullOrderList[key].ItemGroupComponent == undefined){
                                    HasItemGroups = true;
                                    fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice - (fullOrderList[key].STDPrice *(DiscountPercent/100))).toFixed(2);
                                    fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].ComponentQuantityFinal;  
                                    
                                  //  console.log('*AllDiscountPercent: ItemGroup**'+fullOrderList[key].ItemGroup);
                                    
                                    if(ItemGroupTotal[fullOrderList[key].ItemGroup] == undefined){
                                        ItemGroupTotal[fullOrderList[key].ItemGroup] = parseFloat(fullOrderList[key].UnitPrice);
                                    }
                                    else{
                                        ItemGroupTotal[fullOrderList[key].ItemGroup] = parseFloat(ItemGroupTotal[fullOrderList[key].ItemGroup]) + parseFloat(fullOrderList[key].UnitPrice);
                                    }
                                    
                                }
                                
                                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            }
                            else if(fullOrderList[key].ItemGroup==undefined){

                                  
                               // fullOrderList[key].UnitPrice = parseFloat(fullOrderList[key].STDPrice - (fullOrderList[key].STDPrice *(DiscountPercent/100))).toFixed(2);
                               // fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;  
                                //totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            }

                            if(fullOrderList[key].ProRataRate < 1 ){
                        
                                fullOrderList[key].UnitPrice =  (fullOrderList[key].UnitPrice*(parseFloat(fullOrderList[key].ProRataRate))).toFixed(2);
                                console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);
                                fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                            }
                            
                        }   

                        if(HasItemGroups = true){

                            
                            for(var key in fullOrderList){
                             
                                console.log('*AllDiscountPercent: ItemGroup2**'+fullOrderList[key].ItemGroup);

                                if(fullOrderList[key].ItemGroup==undefined && ItemGroupTotal[fullOrderList[key].ItemId] != undefined){
                                    fullOrderList[key].UnitPrice = ItemGroupTotal[fullOrderList[key].ItemId];
                                    fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity; 
                                    fullOrderList[key].IsEdited = true; 
                                }

                            }  
                        }
                          

                        component.set("v.VarMap",[]); 
                        component.set( 'v.TotalOrder', totalOrderAmounts);
                        component.set("v.OrderItemList",fullOrderList);
        }                
                         
                        
            

    },
    
    ManualDiscountAmount: function(component, event, helper) {
    	var schoolOrder = component.get("v.ShoolOrderItemList");
        var fullOrderList = component.get("v.OrderItemList"); 
        var ItemId = event.target.id;
    	var DiscountAmount = event.target.value; 
        

        DiscountAmount = parseFloat(DiscountAmount).toFixed(2);
        console.log('**DiscountAmount **'+DiscountAmount);
        if(DiscountAmount>0){

        

                        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
                        var totalOrderAmounts = component.get( 'v.TotalOrder');
                        
                        var ItemGroupTotal=0;         
                        var ItemGroupUnitPrice=0;
                        var ItemGroup;

                        for(var key in fullOrderList){            
                            
                            if(fullOrderList[key].ItemId == ItemId){
                                ItemGroup = fullOrderList[key].ItemGroup;
                            }
                        } 

                        totalOrderAmounts.TotalAmount=0; CurrenOrderDisplay.TotalAmount =0;
                        
                        for(var key in fullOrderList){
                            
                          
                            if(fullOrderList[key].ItemId == ItemId){
                                fullOrderList[key].IsEdited = true;
                                var tmpval;
                                if(fullOrderList[key].DiscountOption == 'One-Off Amount (Subtotal)'){
 
                                    console.log('**ItemGroup**'+fullOrderList[key].ItemGroup);
                                    if(fullOrderList[key].ItemGroup == null){
                                        tmpval = (fullOrderList[key].STDPrice*fullOrderList[key].Quantity) ;
                                        if(tmpval >= DiscountAmount){
                                            console.log('**tmpval1 **'+tmpval);
                                            
                                            
                                            fullOrderList[key].Amount = (fullOrderList[key].STDPrice*fullOrderList[key].Quantity) - DiscountAmount;
                                            console.log('**Amount **'+ fullOrderList[key].Amount);
                                            fullOrderList[key].UnitPrice =  (fullOrderList[key].Amount / fullOrderList[key].Quantity).toFixed(2);
                                            console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);

                                            
                                            fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;

                                            fullOrderList[key].DiscountAmount = DiscountAmount;
                                        }
                                        
                                    }    
                                    else if(fullOrderList[key].ItemGroup != undefined){ 
                                        tmpval = (fullOrderList[key].STDPrice*(fullOrderList[key].Quantity)) ;
                                        if(tmpval >= DiscountAmount){
                                            fullOrderList[key].Amount = (fullOrderList[key].STDPrice*(fullOrderList[key].Quantity)) - DiscountAmount;
                                            fullOrderList[key].UnitPrice =  fullOrderList[key].Amount / (fullOrderList[key].Quantity);
                                            fullOrderList[key].DiscountAmount = DiscountAmount;    
                                        }    
                                    }
                                    
                                }
                                else{
                                    console.log('**ItemGroup**'+fullOrderList[key].ItemGroup);
                                    if(fullOrderList[key].ItemGroup == undefined){ 
                                        tmpval = parseFloat(fullOrderList[key].STDPrice);
                                     //   tmpval = fullOrderList[key].STDPrice;
                                        console.log('**tmpval2 **'+tmpval);

                                        if(tmpval >= DiscountAmount){
                                            console.log('**Discount Apply **');
                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice - DiscountAmount; 
                                            fullOrderList[key].Amount = fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                                            fullOrderList[key].DiscountAmount = DiscountAmount;
                                        }
                                    }
                                    else if(fullOrderList[key].ItemGroup != undefined){
                                        tmpval = parseFloat(fullOrderList[key].STDPrice);
                                        if(tmpval >= DiscountAmount){
                                            fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice - DiscountAmount; 
                                            fullOrderList[key].Amount = fullOrderList[key].UnitPrice * (fullOrderList[key].Quantity);
                                            fullOrderList[key].DiscountAmount = DiscountAmount;
                                        }
                                    }    
                                    
                                }
 
                                
                                fullOrderList[key].DiscountPercent = 0;

                            }
             

                            if((fullOrderList[key].ItemGroup == ItemGroup && ItemGroup != undefined) || fullOrderList[key].ItemGroup == ItemId){ //
 
                                
                                ItemGroupTotal = parseFloat(fullOrderList[key].Amount) + parseFloat(ItemGroupTotal);               
                                ItemGroupUnitPrice = parseFloat(fullOrderList[key].UnitPrice * fullOrderList[key].ComponentQuantity) + parseFloat(ItemGroupUnitPrice); 
                      
                            }

                        }
 
                        console.log('**ItemGroupTotal**'+ItemGroupTotal);
                        
                        
                        for(var key in fullOrderList){


                            if(ItemGroupTotal>0 && fullOrderList[key].ItemGroup== undefined && fullOrderList[key].ItemId == ItemGroup){

            
                                fullOrderList[key].IsEdited = true;    
                                fullOrderList[key].Amount=ItemGroupTotal;              
                                    fullOrderList[key].UnitPrice= ItemGroupUnitPrice;              
                                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            }
                            else if(fullOrderList[key].ItemGroup== undefined ){
                                    totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount;
                            } 

                            if(fullOrderList[key].ProRataRate < 1 && fullOrderList[key].ItemId == ItemId){
                                console.log('**Disc: UnitPrice 1**'+fullOrderList[key].UnitPrice);
                                console.log('**Disc: ProRata**'+fullOrderList[key].ProRataRate);
                                fullOrderList[key].UnitPrice =  (fullOrderList[key].UnitPrice*(parseFloat(fullOrderList[key].ProRataRate))).toFixed(2);
                                console.log('**Disc: UnitPrice 2**'+fullOrderList[key].UnitPrice);
                                fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                            }
                                       
                        }
                    

                


                        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
                        component.set( 'v.TotalOrder', totalOrderAmounts); 
                        
        }    
        component.set("v.ShoolOrderItemList",schoolOrder); 
        component.set("v.OrderItemList",fullOrderList);             
    },

    ChangeDate: function(component, event, helper) {
        
        var fullOrderList = component.get("v.OrderItemList");
        var target = event.getSource(); 
        var checkDate = target.get("v.value");

        var a = event.getSource();
        var Itemid = a.getLocalId();

      //  var selectedId = event.target.dataset.id; 

        var ProRataMonths;
        var ProRata;
        console.log('*ChangeDate: Itemid**'+Itemid );

        
        var enddate = new Date();
        var varCheckdate = new Date(checkDate);
        var TooEarly = false;


        for(var key in fullOrderList){
            fullOrderList[key].IsEdited = true;
            if(fullOrderList[key].ProductTYPE != 'Inventory Item'){
                fullOrderList[key].IsEdited = true;
                fullOrderList[key].OppServiceDate =  checkDate;
            }
            if(fullOrderList[key].OppServiceDate ==''){
                fullOrderList[key].OppServiceDate = null;
            }
            console.log('*ChangeDate: ItemId**'+fullOrderList[key].ItemId );
            console.log('*ChangeDate: ProRata**'+fullOrderList[key].ProRata );
            console.log('*ChangeDate: ItemEndDate**'+fullOrderList[key].ItemEndDate);
            console.log('*ChangeDate: ItemGroupComponent**'+fullOrderList[key].ItemGroupComponent);
            console.log('*ChangeDate: MasterOrder**'+fullOrderList[key].MasterOrder);

            if(fullOrderList[key].ProRata == true && fullOrderList[key].ItemEndDate != null && fullOrderList[key].ItemGroupComponent == false && fullOrderList[key].MasterOrder == true){
                
                console.log('*ChangeDate: ProRataMonths**'+ProRataMonths);
                console.log('*ChangeDate: licenceduration**'+fullOrderList[key].LicenceDuration);
                    enddate =  new Date(fullOrderList[key].ItemEndDate);
                    
                    console.log('*ChangeDate: enddate**'+enddate);
                    console.log('*ChangeDate: fullOrderList[key].EndDate**'+fullOrderList[key].ItemEndDate);
                    console.log('*ChangeDate: enddate.getFullYear()**'+enddate.getFullYear());             
                    console.log('*ChangeDate: ItemStartDate**'+fullOrderList[key].ItemStartDate);

              
                    if(fullOrderList[key].ItemStartDate === checkDate){ 
                        console.log('*selDate == Startdate**');
                        fullOrderList[key].ProRataRate = 1; 
                        fullOrderList[key].ProRataMonths =  fullOrderList[key].LicenceDuration;
                    }
                    else{
                        console.log('*ChangeDate: selDate != Startdate: NOT 1**');
                        ProRataMonths = (enddate.getFullYear() - varCheckdate.getFullYear()) * 12;
                        console.log('*ChangeDate: ProRataMonths 1**'+ProRataMonths);
                        console.log('*ChangeDate: selDate != Startdate: NOT 2: ProRataMonths**'+ProRataMonths);
                        ProRataMonths -= varCheckdate.getMonth();
                        console.log('*ChangeDate: ProRataMonths 2**'+ProRataMonths);
                        ProRataMonths += enddate.getMonth();
                        console.log('*ChangeDate: ProRataMonths 3**'+ProRataMonths);
                        if(varCheckdate.getMonth() !=  enddate.getMonth()){
                            ProRataMonths += 1;
                        }
                                
                        

                        fullOrderList[key].ProRataMonths = parseFloat(ProRataMonths);
                        fullOrderList[key].ProRataRate = (parseFloat(ProRataMonths) / fullOrderList[key].LicenceDuration);
                    }
 
                    console.log('*ChangeDate: ProRataRate**'+fullOrderList[key].ProRataRate);
                    
               
                    if(checkDate < fullOrderList[key].ItemStartDate || checkDate > fullOrderList[key].ItemEndDate){
                        console.log('*ChangeDate: ProRataRate > 1**');
                        fullOrderList[key].OppServiceDate = fullOrderList[key].ItemStartDate;
                        fullOrderList[key].ProRataRate = 1; 
                        fullOrderList[key].ProRataMonths =  fullOrderList[key].LicenceDuration;

                        if(TooEarly == false && checkDate < fullOrderList[key].ItemStartDate){
                            alert('New date cant be before current start date: '+ fullOrderList[key].ItemStartDate);
                            TooEarly = true;    
                        }
                        else if(TooEarly == false  && checkDate > fullOrderList[key].ItemEndDate){
                            alert('New date cant be greater than Item current End date: '+ fullOrderList[key].ItemEndDate);
                            TooEarly = true;
                        }
                       // break;
                    }


                    

                    ProRata = true;
                    fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice;

                    if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-fullOrderList[key].DiscountAmount;
                        fullOrderList[key].Amount = fullOrderList[key].Quantity * (fullOrderList[key].UnitPrice);  
                    }
                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                        fullOrderList[key].Amount = (fullOrderList[key].Quantity * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount;
                        fullOrderList[key].UnitPrice = fullOrderList[key].Amount/fullOrderList[key].Quantity;
                    }
                    else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100));
                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;
                    }
                    else{
                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;   
                    }

                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;


                   
                    if(fullOrderList[key].ProRataRate < 1 ){
                        
                        console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);

                        fullOrderList[key].UnitPrice =  (fullOrderList[key].UnitPrice*(parseFloat(fullOrderList[key].ProRataRate))).toFixed(2);
                        console.log('**UnitPrice **'+fullOrderList[key].UnitPrice);
                        fullOrderList[key].Amount =  fullOrderList[key].UnitPrice * fullOrderList[key].Quantity;
                    }
/*
                    if(fullOrderList[key].ItemGroup !=){
                        var STDPrice = fullOrderList[key].ItemGroup+'STDPrice';
                        var unitPrice = fullOrderList[key].ItemGroup+'unit';
                        var AmountPrice = fullOrderList[key].ItemGroup+'amount';

                        if(ItemGrpMap[STDPrice] == undefined){
                            ItemGrpMap[STDPrice] = parseFloat(fullOrderList[key].STDPrice)*parseFloat(fullOrderList[key].ComponentQuantity);
                            ItemGrpMap[unitPrice] = parseFloat(fullOrderList[key].UnitPrice)*parseFloat(fullOrderList[key].ComponentQuantity);
                            ItemGrpMap[AmountPrice] = parseFloat(fullOrderList[key].Amount);
                        }
                        else{
                            ItemGrpMap[STDPrice] = parseFloat(ItemGrpMap[STDPrice]) + (parseFloat(fullOrderList[key].STDPrice) *parseFloat(fullOrderList[key].ComponentQuantity));
                            ItemGrpMap[unitPrice] = parseFloat(ItemGrpMap[unitPrice]) + (parseFloat(fullOrderList[key].UnitPrice)*parseFloat(fullOrderList[key].ComponentQuantity));
                            ItemGrpMap[AmountPrice] = parseFloat(ItemGrpMap[AmountPrice]) + parseFloat(fullOrderList[key].Amount);
                        }  
                    }
*/

            }

        }
        
        /*
        if(ITEMGROUP ProRata = true){
                for(var key in fullOrderList){

                    console.log('**Item group Update: Before**');
                    if(fullOrderList[key].ItemGroupComponent == true){
                        

                        var STDPrice = fullOrderList[key].ItemId+'STDPrice';
                        var unitPrice = fullOrderList[key].ItemId+'unit';
                        var AmountPrice = fullOrderList[key].ItemId+'amount';
                        
                        fullOrderList[key].IsEdited = true;
                        fullOrderList[key].STDPrice = ItemGrpMap[STDPrice] ;
                        fullOrderList[key].UnitPrice = ItemGrpMap[unitPrice] ;
                        fullOrderList[key].Amount = ItemGrpMap[AmountPrice] ;

                    }

                    if(fullOrderList[key].ItemGroup== undefined){
                        totalOrderAmounts.TotalAmount = parseFloat(totalOrderAmounts.TotalAmount) + parseFloat(fullOrderList[key].Amount);
                    }
                    fullOrderList[key].Count = OrderItemsLength;
                    OrderItemsLength++;

                }    
            } 
        */

        component.set("v.OrderItemList",fullOrderList);

    },    


    ChangeTerms: function(component, event, helper) {
        
        
        var fullOrderList = component.get("v.OrderItemList"); 
      
        var ItemId = event.target.id;
        var newquantity = event.target.value;

      var checkMultiple;
      var checkDate =null;
      var updateAllowed = true;

      

      

        for(var key in fullOrderList){

            if(fullOrderList[key].ItemId == ItemId){

                if(newquantity>0){
                    fullOrderList[key].IsEdited = true;
                    fullOrderList[key].OppTerms = newquantity;

                    if(parseFloat(fullOrderList[key].LicenceDuration)>0){
                        
                        checkMultiple = (parseFloat(fullOrderList[key].OppTerms)/parseFloat(fullOrderList[key].LicenceDuration)) % 1;
                 
                        if(checkMultiple>0){
                            updateAllowed = false;
                            fullOrderList[key].OppTerms = parseFloat(fullOrderList[key].LicenceDuration);
                            alert('Terms must in multiples of licence duration: '+ fullOrderList[key].LicenceDuration);
                        }
                    }
                }
                else if(parseFloat(fullOrderList[key].LicenceDuration)>0){
                    fullOrderList[key].OppTerms = parseFloat(fullOrderList[key].LicenceDuration);
                } 
                else{
                    fullOrderList[key].OppTerms = null;
                }   
            }      
        }
    
    
        console.log('**updateAllowed**'+updateAllowed);
        component.set("v.OrderItemList",fullOrderList);
       

    },

    ChangeOrderLineType: function(component, event, helper) {
        
        console.log('**ChangeOrderLineType**:One');
        
                        var schoolOrder = component.get("v.ShoolOrderItemList");
                        var fullOrderList = component.get("v.OrderItemList"); 
                        
                        var CurrenOrderDisplay = component.get("v.CurrenOrderDisplay");
                        var totalOrderAmounts = component.get( 'v.TotalOrder');
                        
                        var ItemId = event.target.id;
                        var OrderLineType = event.target.value; 
                        
                        var selected;

                        totalOrderAmounts.TotalAmount=0; CurrenOrderDisplay.TotalAmount =0;

        
                      var curOrder =  component.get("v.curOrder");
                      
                       var blockchange =false;
                    
                     if(curOrder.Type == 'RegularOrder' && (OrderLineType =='Service' || OrderLineType =='Free')){

                            blockchange=true;
                            alert('These order line types cannot be mixed, create a separate order');
                     }
                     else if(curOrder.Type == 'FreeOrder' || curOrder.Type == 'ServiceOrder'){
                            
                            if(OrderLineType !='Service' && OrderLineType !='Free'){
                                blockchange=true;
                                alert('These order line types cannot be mixed, create a separate order');
                            }
                     }
                     


                     if(blockchange==false){

                        var CurOrderLineType;
                        var CustomerDiscountGroup;
                        for(var key in fullOrderList){
                            
                            if(fullOrderList[key].ItemId == ItemId){
                                fullOrderList[key].IsEdited = true;
                            
                                for(var item in fullOrderList[key].listPriceDiscount){
                                    console.log('**CUS GRP**:'+fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup);

                                    if(OrderLineType == fullOrderList[key].listPriceDiscount[item].OrderLineType && fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup == fullOrderList[key].CustomerDiscountGroup && selected == false){
                                        CurOrderLineType = OrderLineType;
                                        CustomerDiscountGroup = fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup;
                                    }    
                                }    
        
                            }
                        }        
 
                        var NewRate;
                        var LPDID;
 

                        for(var key in fullOrderList){
                            
                            if(fullOrderList[key].ItemId == ItemId || fullOrderList[key].ItemGroup == ItemId){
                
                                fullOrderList[key].PriceDiscount = OrderLineType;
                                fullOrderList[key].IsEdited = true;
                                selected = false;

                                console.log('*selected == false: '+fullOrderList[key].BasePrice);  
                                fullOrderList[key].UnitPrice = fullOrderList[key].BasePrice;
                                fullOrderList[key].STDPrice = fullOrderList[key].BasePrice; 
                                fullOrderList[key].PriceDiscount = OrderLineType; 
                                fullOrderList[key].listPriceRateId = null;

                                if(fullOrderList[key].PriceDiscount == 'Free' || fullOrderList[key].PriceDiscount =='Service'){

                                    fullOrderList[key].DiscountOption='--None--';
                                    fullOrderList[key].DiscountAmount = 0;
                                    fullOrderList[key].DiscountPercent = 0; 
                                    fullOrderList[key].DiscountValueShow = false;
                                    fullOrderList[key].DiscountPercentShow = false;
    
                                }
                                else{
                                    for(var item in fullOrderList[key].listPriceDiscount){

                                        if(fullOrderList[key].ItemGroup == undefined && OrderLineType == fullOrderList[key].listPriceDiscount[item].OrderLineType && fullOrderList[key].listPriceDiscount[item].CustomerDiscountGroup == fullOrderList[key].CustomerDiscountGroup && selected == false){
                                            console.log('*selected == true: '+fullOrderList[key].BasePrice);     
                                            selected = true;                 
                                            fullOrderList[key].STDPrice=fullOrderList[key].BasePrice - ((fullOrderList[key].listPriceDiscount[item].Discount/100) * fullOrderList[key].BasePrice);
                                            fullOrderList[key].UnitPrice=fullOrderList[key].STDPrice;
                                            
                                            fullOrderList[key].PriceDiscount = OrderLineType;                                       
                                            fullOrderList[key].listPriceRateId = fullOrderList[key].listPriceDiscount[item].LPDId;

                                            LPDID = fullOrderList[key].listPriceDiscount[item].LPDId;
                                            NewRate = fullOrderList[key].listPriceDiscount[item].Discount;

                
                                        }
    
                                        else if(selected == false){
                                        
                                        }

                                    }
                              
                                    if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice - fullOrderList[key].DiscountAmount;
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * (fullOrderList[key].UnitPrice);  

                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                                        fullOrderList[key].Amount = (fullOrderList[key].Quantity * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount;
                                        fullOrderList[key].UnitPrice = fullOrderList[key].Amount/fullOrderList[key].Quantity;
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100));
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;
                                    }
                                    else{
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;   
                                    }
                                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;
                             //   }
                                
 
                                }
                            }
                            if(fullOrderList[key].ItemGroup == undefined){
                                totalOrderAmounts.TotalAmount = totalOrderAmounts.TotalAmount + fullOrderList[key].Amount; 
                            }    
                    }


                    for(var key in fullOrderList){
                            
                        if(fullOrderList[key].ItemGroup == ItemId){

                            if(fullOrderList[key].PriceDiscount == 'Free' || fullOrderList[key].PriceDiscount =='Service'){

                                fullOrderList[key].DiscountOption='--None--';
                                fullOrderList[key].DiscountAmount = 0;
                                fullOrderList[key].DiscountPercent = 0; 
                                fullOrderList[key].DiscountValueShow = false;
                                fullOrderList[key].DiscountPercentShow = false;

                            }
                            else if(NewRate != undefined){ 

                                    fullOrderList[key].STDPrice=fullOrderList[key].BasePrice - ((NewRate/100) * fullOrderList[key].BasePrice);
                                    fullOrderList[key].UnitPrice=fullOrderList[key].STDPrice;
     
                                    fullOrderList[key].PriceDiscount = OrderLineType;                                       
                                    fullOrderList[key].listPriceRateId = LPDID;
                                    fullOrderList[key].IsEdited = true;
  

                                    
                                    if(fullOrderList[key].DiscountOption=='One-Off Amount' || fullOrderList[key].DiscountOption=='Recurring Amount'){
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * (fullOrderList[key].UnitPrice);  
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Amount (Subtotal)'){
                                        fullOrderList[key].Amount = (fullOrderList[key].Quantity * fullOrderList[key].STDPrice)-fullOrderList[key].DiscountAmount;
                                        fullOrderList[key].UnitPrice = fullOrderList[key].Amount/fullOrderList[key].Quantity;
                                    }
                                    else if(fullOrderList[key].DiscountOption=='One-Off Percentage' || fullOrderList[key].DiscountOption=='Recurring Percentage'){
                                        fullOrderList[key].UnitPrice = fullOrderList[key].STDPrice-(fullOrderList[key].STDPrice*(fullOrderList[key].DiscountPercent/100));
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;
                                    }
                                    else{
                                        fullOrderList[key].Amount = fullOrderList[key].Quantity * fullOrderList[key].UnitPrice;   
                                    }
                                    fullOrderList[key].NoDiscAmount = fullOrderList[key].Quantity * fullOrderList[key].STDPrice;
                                    fullOrderList[key].PriceDiscount = OrderLineType;
                                        
                        }  
                        
                    }  
                }   
                        component.set("v.CurrenOrderDisplay",CurrenOrderDisplay);
                        component.set( 'v.TotalOrder', totalOrderAmounts);
                       
                        component.set("v.OrderItemList",fullOrderList);
        
                        var PricingMethod = component.get('v.PricingMethod');
                       
                            var varItemId = [];
                            varItemId[0] = ItemId;            
                            helper.UpdateListPriceDiscount(component,'Existing',varItemId,PricingMethod,fullOrderList);
                       
            }
            else{
                component.set("v.OrderItemList",fullOrderList);
            }

                               
    },
 
 
    DynamicSearchProductOnEnter : function(component, event, helper){
        
        var searchString = component.find("DynamicSearch").get("v.value");
        console.log('**searchString**'+searchString.length);
        if (event.which == 13 || searchString.length == 0){
            console.log('**Enter**');  
            
            //var action = component.get('c.DynamicSearchProduct');

            var action = component.get('c.DynamicSearchProductSOQL');
            $A.enqueueAction(action);
        }
        
    },    
    DynamicSearchProductSOQL : function(component, event, helper){
        
        var searchString = component.find("DynamicSearch").get("v.value");
        if(searchString.length > 2 || searchString.length == 0 ){
            var t0 = performance.now();
            
    
            component.set("v.isSpinner",true);


                console.log('**searchString**'+searchString);
            var action = component.get("c.loadProductsbySearch");
                var OrderId =  component.get("v.OrderId");
                var OrderItems = component.get("v.OrderItemList");
                var SelectedItems = component.get("v.ShoolOrderItemList");

                if(OrderItems[0] != undefined){
                    console.log('**OrderItems-ProductId**'+OrderItems[0].ProductId);
                }
                
                action.setParams({ 
                    "OrderItems" : OrderItems,
                    "SelectedItems":  SelectedItems,
                    "OrderId": OrderId,
                    "searchString": searchString
                });
                
                

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log(state);
                    if (state === "SUCCESS") {
                        var returnValue = response.getReturnValue();
                        
                        component.set("v.SchoolProductList",returnValue);
                        var t1 = performance.now();
                        console.log("SOQL SEARCH took " + (t1 - t0) + " milliseconds.");
                        component.set("v.isSpinner",false);
                    }
                    else if (state === "INCOMPLETE") {
                        
                    }
                        else if (state === "ERROR") {
                            component.set("v.isSpinner",false);
                            var errors = response.getError();
                            if (errors) {
                                alert("Error message: " + errors[0].message);
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " + errors[0].message);
                                    component.set("v.isSpinner",false);
                                }
                            } else {
                                component.set("v.isSpinner",false);
                                alert("Something went wrong: Please contact System Administrator");
                            }
                        }
                        else{


                        }
                });

                $A.enqueueAction(action);
        }        
        
       
    },



  
    
})