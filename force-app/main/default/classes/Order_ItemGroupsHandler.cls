public with sharing class Order_ItemGroupsHandler {
    

    //Possible delete used for updating group items on Asset renewal

    public static List<OrderItem> ProcessItemGroups(List<OrderItem> lst_AssetItems,Map<String,Decimal> Map_Quantity,Map<String,String> Map_ItemGroupId ,Map<String,String> Map_ItemGroupProdMapId){


        Map<String,Decimal> Map_NetSalesPrice = new Map<String,Decimal>();
        

        for(OrderItem item: lst_AssetItems){

            system.debug('**ItemGroupsHandler: 2 before**'+Map_ItemGroupId);
            if(Map_ItemGroupId.get(Map_ItemGroupProdMapId.get(item.Product2Id)) != null){

               

                String ItemGroupId = Map_ItemGroupId.get(Map_ItemGroupProdMapId.get(item.Product2Id));

               // Set_GroupId.add(ItemGroupId);

                item.ItemGroup__c = ItemGroupId;
                item.ProductType__c = 'Inventory Item';
                system.debug('**ItemGroupsHandler: 2 Prod**'+item.Product2Id);
                system.debug('**ItemGroupsHandler: 2 Map**'+Map_Quantity);

                system.debug('**ItemGroupsHandler: ItemGroupId**'+ItemGroupId);

                if(Map_Quantity.get(item.Product2Id) != null){
                    item.NetsuiteQuantity__c = Map_Quantity.get(item.Product2Id) * item.Quantity;
                }
                else{
                    //item.NetsuiteQuantity__c = item.Quantity; 
                    item.NetsuiteQuantity__c = Map_Quantity.get(item.Product2Id) * item.Quantity;
                }
   
                
                if(Map_NetSalesPrice.get(ItemGroupId)==null){
                    Map_NetSalesPrice.put(ItemGroupId,item.UnitPrice);
                }
                else{
                    Map_NetSalesPrice.put(ItemGroupId,Map_NetSalesPrice.get(ItemGroupId)+item.UnitPrice);
                }

            }

            
        }

       
        for(OrderItem item:lst_AssetItems){
                    
            if(Map_ItemGroupId.get(item.Product2Id) != null){
                    item.UnitPrice = 0;
                    item.ProductType__c = 'Item Group';
                    item.NetSalesPriceItemGroup__c = Map_NetSalesPrice.get(item.id);
                    item.DiscountedPriceItemGroup__c = Map_NetSalesPrice.get(item.id);
                    item.ListPriceItemGroup__c = Map_NetSalesPrice.get(item.id);
                    system.debug('**OrderSuccessorUpdate:Item Group**');
            }
        }


        return lst_AssetItems;

    }




}