public with sharing class Order_RemoveAccounts_OrderContract {
    
    public class Request{ 
        @invocablevariable Public String RecordId;
        @invocablevariable Public String ContractId;   
        @invocablevariable Public Account BilltoAccount; 
        @invocablevariable Public String PricebookId; 
        @invocablevariable Public String RequestType;
        
        @invocablevariable Public String ExistingContract ;   
        @invocablevariable Public String ContractRenewal;  
        @invocablevariable Public String PricingMethod;  
        @invocablevariable Public String ContractRequired;

        @invocablevariable Public List<Id> ListOfAccountIds; 

    }
    public class Response{ 
          @invocablevariable Public List<Account> ListOfAccounts;  
    }



    @invocablemethod
    public static List<Response> ContractAccounts(List<Request> req){

        List<Response> responses;

        try {
            responses = processContractAccounts(req);
            
            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
            }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            HandleCustomException.LogException(e);
            
        }
        finally {
            // Something executed whether there was an error or not
        }
        
        return responses;

    }    
    public static List<Response> processContractAccounts(List<Request> req){    

         
        Account[] lstContractAccounts;
        
        Account[] lstShiptoAccounts;

        List<string> recordIdStrings = new List<string>();
        system.debug('**req[0].RecordId**'+req[0].RecordId);
        
        recordIdStrings.Add(req[0].RecordId);
        List<String> ObjectName = UTIL_getObjectName.returnObjectName(recordIdStrings);
        
        
        if(ObjectName[0] == 'Order'){
            
            OrderShipto__c[] lstOrderShiptoDelete = [Select id,ShiptoAccount__c from OrderShipto__c where ShiptoAccount__c in: req[0].ListOfAccountIds AND Order__c =:req[0].RecordId];
            OrderShipto__c[] lstOrderShipto = [Select id,ShiptoAccount__c from OrderShipto__c where ShiptoAccount__c not in: req[0].ListOfAccountIds AND Order__c =:req[0].RecordId];
           
            OrderItem[] lstOrderItem = [Select id,ShipToAccount__c   From OrderItem where OrderId =:req[0].RecordId AND ShipToAccount__c in:req[0].ListOfAccountIds]; 

            system.debug('**lstOrderShipto**'+lstOrderShipto);
            system.debug('**lstOrderItem**'+lstOrderItem);
            system.debug('**ListOfAccountIds**'+req[0].ListOfAccountIds);
            

            try{
                
                delete lstOrderShiptoDelete;
                delete lstOrderItem; 

                //Add remaining Set of Ids 
                req[0].ListOfAccountIds = new  List<Id>();

                for(OrderShipto__c ship:lstOrderShipto){
                    req[0].ListOfAccountIds.add(ship.ShiptoAccount__c);
                }

               List<Order_StructurediscountCalculation.Response> Response = recalculateListPriceDiscount(req); 
                            
                system.debug('**totalnumbers**'+Response[0].totalnumbers);
                List<String> OrderId = new List<String>();
                OrderId.add(req[0].RecordId);

             //   Order_UpdateOrderListPriceDiscountAll.UpdateOrdeItemswithListPriceDiscount(Response[0].totalnumbers,OrderId,req[0].PricebookId);
                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
                }
              //  UpdateOrdeItemswithListPriceDiscount(Response[0].totalnumbers,, req[0].PricebookId);
            }
            catch (exception e){
                HandleCustomException.LogException(e,req[0].RecordId);
            }
        }

        lstContractAccounts = lstShiptoAccounts;

        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.ListOfAccounts = lstContractAccounts; 
        responses.add(res);
        return responses;

    }    


Public static List<Order_StructurediscountCalculation.Response> recalculateListPriceDiscount(List<Request> req){

    List<Order_StructurediscountCalculation.Request> lst_request = new List<Order_StructurediscountCalculation.Request>();
    Order_StructurediscountCalculation.Request newreq = new Order_StructurediscountCalculation.Request();

    
    newreq.OrderId = req[0].RecordId;
    newreq.ContractId= req[0].ContractId;
    
    newreq.ExistingContract = req[0].ExistingContract;
    newreq.ContractRenewal = req[0].ContractRenewal;
    newreq.PricingMethod =  req[0].PricingMethod;
    newreq.ContractRequired = req[0].ContractRequired; 
     
    
    newreq.ListOfAccountIds = req[0].ListOfAccountIds;
    lst_request.add(newreq);

    List<Order_StructurediscountCalculation.Response> Response = Order_StructurediscountCalculation.start(lst_request);

    return Response;

}    




}