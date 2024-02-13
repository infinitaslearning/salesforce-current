public with sharing class Order_OrderInsertQueueable implements Queueable {
    
    Private String ContractId;    
    Private String OrderId; 
    Private Decimal TotalNumberofStudents;
    Private Boolean AddShiptos;
    Private List<Account> AccountbyShipto;

    public Order_OrderInsertQueueable(String ContractId,String OrderId, Decimal TotalNumberofStudents,Boolean AddShiptos,List<Account> AccountbyShipto) {
      
        this.OrderId = OrderId;
        this.TotalNumberofStudents = TotalNumberofStudents;
        this.AccountbyShipto = AccountbyShipto;
        this.AddShiptos = AddShiptos;
        this.ContractId = ContractId;
    }

    public void execute(System.QueueableContext qc) {

                 Contract[] Contract = [Select AccountId,NumberofUsers__c,SoldUsers__c,StartDate,Pricebook2Id,PaymentMethod__c,ShippingCostMethod__c,PricingMethod__c,defaultBilltoAccount__c from Contract where id =: ContractId];
                
                system.debug('*Order_OrderInsertQueueable 1**');

               

                Id NewOrderId = OrderId;
                

                Set<String> Set_Sub = new Set<String>();
                Map<String,String> Map_Sub = new Map<String,String>(); 
                Map<String,String> Map_Netsuite = new Map<String,String>(); 
                
               // Order[] CurOrder = [Select Type,AccountSubsidiary__c,MultipleShippingLocations__c,Shipto__r.NetsuiteInternalId__c ,Account.NetsuiteInternalId__c,OperatingCompany__c,Source__c,InsertProductSelector__c,CustomerReference__c,NumberOfStudents__c,Billto__c,ContractId,EffectiveDate,ShipByDate__c from Order where id=: NewOrderId];
                
               List<Id> SetOrderId = new List<Id>();

               SetOrderId.add(OrderId);

                Order[] CurOrder = Order_SoqlFactory.returnQueryOrder(SetOrderId,null,null);
                system.debug('**Order_SoqlFactory.Order_OrderInsertQueueable.CurOrder :Size**'+CurOrder.size());
               
                List<Id> OrderId = new List<Id>();
                if(CurOrder.size()>0){
                    OrderId.add(CurOrder[0].Id);
                }
                
               
                //List<OrderItem>   lstOrderItem = Order_OrderandOrdeItemHandler.returnQueryOrderItems(null,OrderId);
                OrderItem[]   lstOrderItem =  Order_SoqlFactory.returnQueryOrderItems(null,SetOrderId,null,null);
                system.debug('**Order_SoqlFactory.Order_OrderInsertQueueable.lst_OrdItem :Size**'+lstOrderItem.size());

                Date FixedStartDate;
                Date FreeFromDate;
                Integer year;


                //------ Order Item Calculations: Moved here to get Date for Order before order is updated

                lstOrderItem = Order_ProductCalculationDates.UpdateOrderItemDate(lstOrderItem,CurOrder);

                List<Map<String,String>> lst_AccSubMaps = new List<Map<String,String>>();
                if(Contract.size()>0){
                    Set_Sub.add(Contract[0].defaultBilltoAccount__c);

                  //  lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);
                }
                else if(CurOrder.size()>0){
                    Set_Sub.add(CurOrder[0].Billto__c);
                    
                   // lst_AccSubMaps = Order_ProductSelectController.returnAccountSubsidiary(Set_Sub);
                    if(CurOrder[0].ContractId != null){
                        ContractId = CurOrder[0].ContractId;
                    }
                }    

                lst_AccSubMaps =  Order_SoqlFactory.returnAccountSubsidiary(Set_Sub);
                system.debug('**Order_SoqlFactory.Order_OrderInsertQueueable.lst_AccSubMaps :Size**'+lst_AccSubMaps.size());
                
                system.debug('**Order_OrderInsertQueueable: CurOrder**'+CurOrder);
                system.debug('**Order_OrderInsertQueueable: lst_AccSubMaps**'+lst_AccSubMaps);
                Map_Sub = lst_AccSubMaps[0];
                Map_Netsuite = lst_AccSubMaps[1];


                
                Boolean varNewOrder=false;
                Order NewOrder;
            //    List<Id> lstOrderId = new List<Id>();
                if(NewOrderId == null){ 
                    NewOrder = new Order();
                    if(ContractId != null){
                        NewOrder.ContractId = ContractId;
                        NewOrder.AccountId = Contract[0].AccountId;
                        NewOrder.EffectiveDate = Contract[0].StartDate;
                        NewOrder.Pricebook2Id = Contract[0].Pricebook2Id;
                        NewOrder.Status = 'Draft';
                        NewOrder.PaymentMethod__c = Contract[0].PaymentMethod__c;
                        NewOrder.PricingMethod__c = Contract[0].PricingMethod__c;
                        NewOrder.Billto__c = Contract[0].defaultBilltoAccount__c; 
                        NewOrder.AccountSubsidiary__c =  Map_Sub.get(Contract[0].defaultBilltoAccount__c);
                        NewOrder.NumberOfStudents__c = TotalNumberofStudents;
                        if(NewOrder.Source__c == null){
                            NewOrder.Source__c ='B2B Salesforce';
                        }
                        
                        NewOrder.ShipByDate__c = Contract[0].StartDate; 
                        NewOrder.PaymentStatus__c = 'payment_pending'; 
                        NewOrder.PaymentMethodType__c = 'Invoice'; 

                        if(Test.isRunningTest()){
                            NewOrder.OperatingCompany__c = 'Plantyn';
                        }
                                
                        Insert NewOrder;
                    }

                    //Add Subsidoaries Bill to
                    varNewOrder=true;
                    NewOrderId = NewOrder.id;

                    CurOrder= new Order[]{NewOrder};
                }
                else{
                
                    system.debug('**Order_OrderInsertQueueable: Map_Sub**'+Map_Sub.get(CurOrder[0].Billto__c));
                    CurOrder[0].AccountSubsidiary__c =  Map_Sub.get(CurOrder[0].Billto__c);  
                    CurOrder[0].NetSuiteIdAccountSubsidiary__c = Map_Netsuite.get(CurOrder[0].Billto__c); 
                    CurOrder[0].NetSuiteIdShiptoAccount__c = CurOrder[0].Shipto__r.NetsuiteInternalId__c;        
                    CurOrder[0].NumberOfStudents__c = TotalNumberofStudents;
                    if(CurOrder[0].Source__c == null){
                        CurOrder[0].Source__c ='B2B Salesforce';
                    }
                        CurOrder[0].PaymentStatus__c = 'payment_pending'; 
                        CurOrder[0].PaymentMethodType__c = 'Invoice'; 
                    

                    if(Order_ProductCalculationDates.Map_ShipByDate.size()>0){                             
                        date ShipbyDate = Order_ProductCalculationDates.Map_EffectiveDate.get(CurOrder[0].id);

                        if(ShipbyDate != CurOrder[0].EffectiveDate){

                            CurOrder[0].EffectiveDate = Order_ProductCalculationDates.Map_EffectiveDate.get(CurOrder[0].id);
                           
                        }

                        
                            system.debug('***Order_OrderInsertQueueable: Dates :ord.ShipByDate'+CurOrder[0].ShipByDate__c);
                            system.debug('***Order_OrderInsertQueueable:Dates :ord.EffectiveDate'+CurOrder[0].EffectiveDate);
                    }
                    

                    try{
                        update CurOrder;
                       
                        update lstOrderItem;

                        if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                            CalloutException e = new CalloutException();

                            system.debug('***Order_OrderInsertQueueable: Dates :ord.ShipByDate'+CurOrder[0].ShipByDate__c);

                            e.setMessage('Error');
                            throw e;        
                        }
                    }
                    catch(exception e){
                        HandleCustomException.LogException(e,CurOrder[0].id);
                    }

                }

                
}
 



}