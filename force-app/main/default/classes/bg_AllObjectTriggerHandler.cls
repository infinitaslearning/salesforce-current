/****************************************************************************
 *  bg_ProductTriggerHandler
 *
 * Called from  trigger
 * 
 *  Author: Ismail Basser - Brightgen
 *  Created: 06/08/2019
 * 
 *  Changes: 
 *  VERSION  AUTHOR            DATE              DETAIL    DESCRIPTION
 *  
***********************************************************************/
public class bg_AllObjectTriggerHandler {
    
    public static void afterObjectInsert(Map<Id, sObject> allProductsMap, String ObjectName) 
    {
        Boolean Process = true;

        system.debug('** AllObjectTriggerHandler: Insert 1** ');
/*
        if(ObjectName == 'Order'){
            Order[] Order = [Select id,Status from Order where id in:allProductsMap.keyset()];
            Process = false;
            for(Order ord:Order){
                  
                if(ord.Status=='Activated'){
                    Process = true;
                }
            }
        }
        else if(ObjectName == 'OrderItem'){
            system.debug('** AllObjectTriggerHandler: Error Check** ');
            for(Id i:allProductsMap.keyset()){
                system.debug('** AllObjectTriggerHandler: ** '+i);
            }

            
            OrderItem[] OrderItem = [Select id,Order.Status from OrderItem where id in:allProductsMap.keyset()];
            Process = false;
            for(OrderItem item:OrderItem){                  
                if(item.Order.Status=='Activated'){
                    Process = true;
                }
            }
        }
        else 
      */  
        if(ObjectName == 'Account'){

            Account[] lstAccount = [Select id,ValidateIntegrationerrors__c from Account where id in:allProductsMap.keyset()];

            for(Account acc:lstAccount){
                if(acc.ValidateIntegrationerrors__c == true){
                    Process = false;
                }
            }
            
        }

        else if(ObjectName == 'AccountSubsidiary__c') {
            AccountSubsidiary__c[] AccSubs = [SELECT Id, AgodiUpdateIsRunning__c FROM AccountSubsidiary__c WHERE Id IN :allProductsMap.keySet()];
            for (AccountSubsidiary__c accSub : AccSubs) {
                if (AccSub.AgodiUpdateIsRunning__c) {
                    Process = false;
                }
            }
        }

        if(!allProductsMap.isEmpty() && Process)
        {
            system.debug('** AllObjectTriggerHandler: Insert 2** ');
            bg_AWSTriggerUtils.ProcessAWSCallout(ObjectName, allProductsMap, null, bg_AWSTriggerUtils.OPERATION_INSERT);
        }                
    }
    
    public static void afterObjectUpdate(Map<Id, sObject> allNewProductsMap, Map<Id, sObject> allOldProductsMap, String ObjectName)
    {
        
        Boolean Process = true;
        system.debug('** AllObjectTriggerHandler: Update 1** ');
        /*
        if(ObjectName == 'Order'){
            Order[] Order = [Select id,Status from Order where  id in:allNewProductsMap.keyset()];
            Process = false;
            for(Order ord:Order){
                  
                if(ord.Status=='Activated'){
                    Process = true;
                }
            }
        }
        else if(ObjectName == 'OrderItem'){
            OrderItem[] OrderItem = [Select id,Order.Status from OrderItem where id in:allNewProductsMap.keyset()];
            Process = false;
            for(OrderItem item:OrderItem){                  
                if(item.Order.Status=='Activated'){
                    Process = true;
                }
            }
        }
        else 
        */
        
        if(ObjectName == 'Account'){

            Account[] lstAccount = [Select ValidateIntegrationerrors__c,id from Account where id in:allNewProductsMap.keyset()];

            for(Account acc:lstAccount){
                if(acc.ValidateIntegrationerrors__c == true){
                    Process = false;
                }
            }
            
        }

        if (!allNewProductsMap.isEmpty() && Process)
        {           
            system.debug('** AllObjectTriggerHandler: Update 2** ');
            bg_AWSTriggerUtils.ProcessAWSCallout(ObjectName, allNewProductsMap, allOldProductsMap, bg_AWSTriggerUtils.OPERATION_UPDATE);
        }                                       
    }
    
}