global with sharing class Order_BatchUpdateOrdersOnMerge implements Database.Batchable<sObject>,Schedulable {
    
    Public Set<String> Set_Accid; 

    global Order_BatchUpdateOrdersOnMerge() {
        
    } 

    global Order_BatchUpdateOrdersOnMerge(Set<String> Set_Accid) {
        this.Set_Accid = Set_Accid;
        system.Debug('**Merge: Contructor**'+this.Set_Accid);
    }   
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        system.Debug('**Merge: Set_Accid**'+Set_Accid);
        return Database.getQueryLocator([SELECT Id,NetsuiteInternalId__c  FROM Account where id in : Set_Accid]  ); 
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){

        Set<String> Set_Accid = new Set<String>();
        Set<String> Set_BillToNS = new Set<String>();
        
        
        for(Account acc:scope){
            Set_Accid.add(acc.id);
            Set_BillToNS.add(acc.NetsuiteInternalId__c);
            system.Debug('**Merge: Set_Accid in Execute**'+acc.NetsuiteInternalId__c);
        }
        system.Debug('**Merge: Set_Accid **'+Set_Accid);

        Order[] lstOrders = [Select id,NetSuiteIdShiptoAccount__c,NetSuiteIdAccountSubsidiary__c,TriggerBusinessRules__c from Order where  status!=:'Activated' AND ((Shipto__c in:Set_Accid AND NetSuiteIdShiptoAccount__c not in: Set_BillToNS)  OR (Billto__c in:Set_Accid AND NetSuiteIdAccountSubsidiary__c not in: Set_BillToNS))];
        system.Debug('**Merge: Orders**'+lstOrders);

        Set_Accid = new Set<String>();
        for(Order ord:lstOrders){
            ord.TriggerBusinessRules__c = true;
        }

        update lstOrders;
    }

    global void finish(Database.BatchableContext BC){

    }    

    global void execute(SchedulableContext sc)
    {
        Set<String> Set_Accid;
        Order_BatchUpdateOrdersOnMerge  OrdersOnMerge = new Order_BatchUpdateOrdersOnMerge(Set_Accid);
        database.executebatch(OrdersOnMerge ,1);
    }

}