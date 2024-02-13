public with sharing class Order_ImportOrderSuccessorUpdate {
    public class Request{ 
        @invocablevariable Public OrderItem SingleOrderItems;
        @invocablevariable Public ImportOrder__c ImportOrder;
        
    }
    public class Response{ 
        @invocablevariable Public OrderItem SingleOrderItems; 
    }


   
    @invocablemethod
    public static List<Response> OrderSuccessorUpdate(List<Request> req){

        system.debug('**OrderSuccessorUpdate: GO**'+req.size());


        List<Response> responses = new List<Response>();
        Response res = new Response();
        List<OrderItem> ListOfOrderItems = new List<OrderItem>();
        List<ImportOrder__c> ListOfImportOrders = new List<ImportOrder__c>();


        for(Request r:req){
            ListOfOrderItems.add(r.SingleOrderItems);
            ListOfImportOrders.add(r.ImportOrder);
            system.debug('==> r.SingleOrderItems: ' + r.SingleOrderItems);
            system.debug('==> r.ImportOrder: ' + r.ImportOrder);
            system.debug('**Order_ImportOrderSuccessorUpdate: Go 1**'+r.SingleOrderItems.PricebookEntryId);
           /*
            
            system.debug('**Order_ImportOrderSuccessorUpdate: Go 1**'+r.SingleOrderItems.Product2Id);
            res = new Response();
            res.SingleOrderItems = r.SingleOrderItems;
            responses.add( res);
            */
        }
        
        ListOfOrderItems = OrderSuccessorUpdate(ListOfOrderItems, ListOfImportOrders);
       
        
        for(OrderItem item:ListOfOrderItems){
            res = new Response();
            res.SingleOrderItems = item;
           
            system.debug('**Order_ImportOrderSuccessorUpdate: 11**'+res.SingleOrderItems.PricebookEntryId);
            system.debug('**Order_ImportOrderSuccessorUpdate: 11BB**'+res.SingleOrderItems.Product2Id);
            responses.add(res);
        }

        
        return responses;
    }    


    public static List<OrderItem> OrderSuccessorUpdate(List<OrderItem> ListOfOrderItems, List<ImportOrder__c> ListOfImportOrders){    
        
        Map<String,String> Map_Prod = new Map<String,String>();
        Map<String,String> Map_ProdType = new Map<String,String>();//added by Danie
        Map<String,Decimal> Map_SuccessorPBE = new Map<String,Decimal>(); // added by connor
        Map<String,Decimal> Map_ImportOrderNetSalesPrice = new Map<String,Decimal>(); // added by connor
        Map<String,String> Map_ProductIdByEAN = new Map<String,String>(); // added by connor
        Set<String> Set_ProdId = new Set<String> ();
        Set<String> Set_OrdId = new Set<String>();

        for(OrderItem item: ListOfOrderItems){
            Set_ProdId.add(item.Product2Id);
            Set_OrdId.add(item.OrderId); 
            system.debug('**Order_ImportOrderSuccessorUpdate: item.OrderId**'+item.OrderId);
        }

        List<Product2> productsWithEAN = [SELECT Id, EAN__c FROM Product2 WHERE Id IN: Set_ProdId];

        for(Product2 prod : productsWithEAN){
            system.debug('prod.EAN__c: ' + prod.EAN__c);
            system.debug('prod.Id: ' + prod.Id);
            
            Map_ProductIdByEAN.put(prod.EAN__c, prod.Id);
        }

        
        for(ImportOrder__c io : ListOfImportOrders){         
                Map_ImportOrderNetSalesPrice.put(Map_ProductIdByEAN.get(io.ProductId__c), io.NetSalesPrice__c);
        }
        

        Order[] lstOrder = [Select id,Pricebook2Id from Order where id in:Set_OrdId ];

        Set<String> Set_PB = new Set<String>();

        for(Order ord:lstOrder){
            Set_PB.add(ord.Pricebook2Id);
        }

        system.debug('**Order_ImportOrderSuccessorUpdate: 1**'+Set_ProdId);

       // Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

        PricebookEntry[] lstPricebookEntryExist;
        
        if(Set_PB.size()>0){
            //   lstPricebookEntryExist = [Select id,Product2Id, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c from PricebookEntry where Product2Id in:Set_ProdId AND Pricebook2Id !=:standardPB.id AND Pricebook2Id in: Set_PB]; // 
            lstPricebookEntryExist = Order_SoqlFactory.returnPricebookEntry('SuccessorPricebookentrycreate_1', null, Set_ProdId,Set_PB,null,null,null,null,null);
            system.debug('**Order_SoqlFactory.Order_ImportOrderSuccessorUpdate1.lstPricebookEntryExist :Size**'+lstPricebookEntryExist.size());
                 
        }
        else{
           // lstPricebookEntryExist = [Select id,Product2Id, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.SuccessorItem__r.IsActive,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c from PricebookEntry where Product2Id in:Set_ProdId AND Pricebook2Id !=:standardPB.id]; //       
            lstPricebookEntryExist = Order_SoqlFactory.returnPricebookEntry('SuccessorPricebookentrycreate_2', null, Set_ProdId,null,null,null,null,null,null);
            system.debug('**Order_SoqlFactory.Order_ImportOrderItemGroupCreate2.lstPricebookEntryExist :Size**'+lstPricebookEntryExist.size());
     
        }
        
        Date ReprintDateCheck = system.today();

        Set<String> Set_Successor = new Set<String>();
        
        system.debug('**Order_ImportOrderSuccessorUpdate: 1**'+lstPricebookEntryExist);
        for(PricebookEntry pbe:lstPricebookEntryExist){
            system.debug('**Order_ImportOrderSuccessorUpdate: 2**'+pbe.Product2.SuccessorItem__c );
            system.debug('**Order_ImportOrderSuccessorUpdate: 3**'+pbe.Product2.IsSuccessorItemActive__c );

            if(pbe.Product2.SuccessorItem__c != null && pbe.Product2.IsSuccessorItemActive__c == true && pbe.Product2.SuccessorItem__r.IsActive == true){
                //Successor item active = true & Successor item != NULL -> Pick Successor Item Id
                system.debug('**Order_ImportOrderSuccessorUpdate: 4**');
                Map_Prod.put(pbe.Product2Id, pbe.Product2.SuccessorItem__c);
                Set_Successor.add(pbe.Product2.SuccessorItem__c);

            }
            else if(pbe.Product2.SuccessorItem__c != null && (pbe.Product2.IsSuccessorItemActive__c == false || pbe.Product2.SuccessorItem__r.IsActive == false) && pbe.Product2.Stocknumber__c > 0){
                system.debug('**Order_ImportOrderSuccessorUpdate: 5**');
                //Successor item active = false & Successor item != NULL & available stock > 0 for ordered product -> Backorder ordered product
                //Product stays the same
            }
            else if(pbe.Product2.SuccessorItem__c != null && (pbe.Product2.IsSuccessorItemActive__c == false || pbe.Product2.SuccessorItem__r.IsActive == false) && (pbe.Product2.Stocknumber__c == 0 || pbe.Product2.Stocknumber__c == null) && (pbe.Product2.PlannedPrintDate__c < ReprintDateCheck || pbe.Product2.PlannedPrintDate__c ==null)){
                //Successor item switch = false & available stock = 0 for regular product & no reprint planned & Successor item != NULL -> Pick successor item Id
                Map_Prod.put(pbe.Product2Id, pbe.Product2.SuccessorItem__c);
                Set_Successor.add(pbe.Product2.SuccessorItem__c);

                system.debug('**Order_ImportOrderSuccessorUpdate: 6**');
            
            }
        }

        String Pricebook2Id;
        if(lstPricebookEntryExist.size()>0){
            Pricebook2Id = lstPricebookEntryExist[0].Pricebook2Id;
        }
        else{
            Pricebook2Id = null;
        }
        //PricebookEntry[] lstPricebookSuccessor = [Select id,Product2Id, UnitPrice, Pricebook2Id,Product2.IsSuccessorItemActive__c,Product2.SuccessorItem__c,Product2.Stocknumber__c,Product2.StockLevel__c, Product2.PlannedPrintDate__c, Product2.Type__c from PricebookEntry where Product2Id in:Set_Successor AND Pricebook2Id =:lstPricebookEntryExist[0].Pricebook2Id ]; // 
        PricebookEntry[] lstPricebookSuccessor = Order_SoqlFactory.returnPricebookEntry('SuccessorPricebookentrycreate_3', null, null,null,Pricebook2Id,null,Set_Successor,null,null);
        system.debug('**Order_SoqlFactory.Order_ImportOrderItemGroupCreate2.lstPricebookEntryExist :Size**'+lstPricebookEntryExist.size());
 


        Map<String,String> Map_PBE = new Map<String,String>();
        
        system.debug('**Order_ImportOrderSuccessorUpdate: 7**'+lstPricebookSuccessor);

        for(PricebookEntry pbe:lstPricebookSuccessor){
            Map_PBE.put(pbe.Product2Id,pbe.Id);  
            Map_SuccessorPBE.put(pbe.Product2Id, pbe.UnitPrice); // added by connor to have PBE price for successor item product
           
            Map_ProdType.put(pbe.Product2Id, pbe.Product2.Type__c);
        }

        system.debug('**Order_ImportOrderSuccessorUpdate: 8**'+Map_PBE);
        for(OrderItem item: ListOfOrderItems){
            system.debug('**Order_ImportOrderSuccessorUpdate: 9: item.Product2Id: ' + item.Product2Id);
            String originalProductId = item.Product2Id; // added by connor
           
            if(Map_PBE.get(Map_Prod.get(item.Product2Id)) != null){
                system.debug('**Order_ImportOrderSuccessorUpdate: 9B**'+Map_PBE.get(Map_Prod.get(item.Product2Id)));
                system.debug('**Order_ImportOrderSuccessorUpdate: 10**'+item.PricebookEntryId);
                    item.PricebookEntryId = Map_PBE.get(Map_Prod.get(item.Product2Id));
                    
                    item.Product2Id = Map_Prod.get(item.Product2Id);
                    item.ProductType__c = Map_ProdType.get(item.Product2Id);
                    // new logic for successor price
                    //system.debug('Map_ImportOrderNetSalesPrice: ' + Map_ImportOrderNetSalesPrice);
                    system.debug('**Order_ImportOrderSuccessorUpdate: 10B: Map_ImportOrderNetSalesPrice.get(originalProductId): ' + Map_ImportOrderNetSalesPrice.get(originalProductId));

                    if(Map_ImportOrderNetSalesPrice.get(originalProductId) == null){
                        system.debug('**Order_ImportOrderSuccessorUpdate: 10C :  CON - SUCCESSOR: NO NET SALES PRICE ON IO. USE: ' + Map_SuccessorPBE.get(item.Product2Id));
                        item.ComponentListPrice__c = Map_SuccessorPBE.get(item.Product2Id);
                        item.unitPrice = Map_SuccessorPBE.get(item.Product2Id);
                    } else {
                        system.debug('**Order_ImportOrderSuccessorUpdate: 10D :  CON - SUCCESSOR: NET SALES PRICE EXISTS ON IO. USE: ' + Map_ImportOrderNetSalesPrice.get(originalProductId));
                        item.ComponentListPrice__c = Map_ImportOrderNetSalesPrice.get(originalProductId);
                        item.UnitPrice = Map_ImportOrderNetSalesPrice.get(originalProductId);
                    }
                
                
                
                system.debug('**Order_ImportOrderSuccessorUpdate: 10E**'+item.PricebookEntryId);
            }

            
        }

        return ListOfOrderItems;

    }    
}