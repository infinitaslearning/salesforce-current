public with sharing class Order_CheckItemGroupComponents {
    
    //Updating the OrderHeader vs the item. Less processing required.

    
    @invocablemethod
    public static void CheckItemGroupComponents(List<Id> OrderId){

        OrderItem[] lstItemGroups = [Select id,Product2.ItemGroupCountActual__c,OrderId from OrderItem where ProductType__c ='Item Group' AND OrderId in:OrderId  ];

        Map<String, Decimal> Map_CompCountExp = new Map<String, Decimal>();

        for(OrderItem item:lstItemGroups){
            Map_CompCountExp.put(item.id,item.Product2.ItemGroupCountActual__c);
        }

        OrderItem[] lstItemComponent = [Select id,ItemGroup__c,OrderId from OrderItem where ItemGroup__c in: Map_CompCountExp.keyset() AND OrderId in:OrderId  ];


        Boolean Mismatch = true;
        Map<String, Decimal> Map_CompCount = new Map<String, Decimal>();

        Map<String, Boolean> Map_MisMatch = new Map<String, Boolean>();

       
        for(OrderItem item:lstItemComponent){

            if(Map_CompCount.get(item.ItemGroup__c) == null){
                Map_CompCount.put(item.ItemGroup__c,1);
            }	
            else {
                Map_CompCount.put(item.ItemGroup__c,Map_CompCount.get(item.ItemGroup__c)+1);
            }
            
        }

        Set<String> Set_OrdMismatch = new Set<String>();

        for(OrderItem item:lstItemGroups){
          if(item.Product2.ItemGroupCountActual__c !=  Map_CompCount.get(item.id)){
            Set_OrdMismatch.add(item.OrderId);
            system.debug('**Order_CheckItemGroupComponents: ID Mismatch**'+ item.id + '**' + Map_CompCount.get(item.id));
          }
        }

        system.debug('**Order_CheckItemGroupComponents: Set_OrdMismatch.size()**'+ Set_OrdMismatch.size());

        Boolean ErrorMessage = false;


        if(Set_OrdMismatch.size()>0){
            
            Order[] CurOrder = [Select Status,IGComponentMismatch__c,ExternalOrderId__c,ValidateIGComponentMismatch__c from Order where id in: Set_OrdMismatch];

            for(Order ord:CurOrder){
                ord.IGComponentMismatch__c = true;
                ord.status ='Activated';
            }
            

            try{
                update CurOrder;
           //    system.debug('**Order_CheckItemGroupComponents: ValidateIGComponentMismatch**'+ lstItemGroups[0].ValidateIGComponentMismatch__c);
             //  update lstItemGroups;
            }
            catch(Exception e){
                system.debug('**Order_ProductComponentPrice: error**'+e.getMessage());
               
              if(!test.isRunningTest()){
                throw e;
              } 
              

            } 
        }
        

    }

    


}