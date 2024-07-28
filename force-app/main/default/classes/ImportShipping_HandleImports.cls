public with sharing class ImportShipping_HandleImports {

    public class Request{ 
        @invocablevariable Public ImportShippingCosts__c ImportShippingCosts;
    }
    public class Response{
        @invocablevariable Public ImportOrder__c ImportShippingCostsr; 
    }    

    
@invocablemethod
Public static List<Response> ImportHandler(List<Request> req){

    List<Response> responses = new List<Response>();
    Response res = new Response();

    Map<String,Decimal> Map_ImpCount = new Map<String,Decimal>();

    List<ImportShippingCosts__c> lstImportShippingCosts = new List<ImportShippingCosts__c>();
    
    
    
    Set<String> Set_ImpId = new  Set<String>();

    for(Request r:req){       
        //lstImportShippingCosts.add(r.ImportShippingCosts); 
        
        Set_ImpId.add(r.ImportShippingCosts.id);
    }

    lstImportShippingCosts = [Select id,name__c,charge__c , CurrencyIsoCode,ImportExpectedCount__c , description__c, isActive__c, 
                        perItemRate__c, rangeValue__c,  subsidiary__c, weightQuantity__c,Error__c,externalId__c 
                    from ImportShippingCosts__c Where id in:Set_ImpId Order By rangeValue__c ASC];

    Map<Integer, Decimal> Map_RangeEnd = new Map<Integer, Decimal>();

    Integer count = 0;
    for(ImportShippingCosts__c imp:lstImportShippingCosts){
        Map_RangeEnd.put(count,imp.rangeValue__c);
        count++;
    }


    for(ImportShippingCosts__c imp:lstImportShippingCosts){       
        if(Map_ImpCount.get(imp.name__c) == null){
            Map_ImpCount.put(imp.name__c,1);
        }
        else{
            Map_ImpCount.put(imp.name__c,Map_ImpCount.get(imp.name__c)+1);
        }
    }

system.debug('**Import Handler: Size*'+lstImportShippingCosts.size());

    List<ShippingCost__c> lstShippingCost = new List<ShippingCost__c>();
    Set<String> Set_Import = new Set<String>();


    lstImportShippingCosts = HandleErrors(lstImportShippingCosts,Map_ImpCount);

    count = 1;
    for(ImportShippingCosts__c imp:lstImportShippingCosts){  

        if(imp.Error__c ==null){
            ShippingCost__c ShippingCost = new ShippingCost__c();
            ShippingCost.externalId__c = imp.externalId__c;
            ShippingCost.Name= imp.name__c;
            ShippingCost.charge__c= imp.charge__c ;      
            ShippingCost.CurrencyIsoCode= imp.CurrencyIsoCode;
            ShippingCost.description__c= imp.description__c;
            ShippingCost.isActive__c= imp.isActive__c;
            ShippingCost.perItemRate__c= imp.perItemRate__c;
            ShippingCost.StartRangeValue__c = imp.rangeValue__c;
            ShippingCost.rangeValue__c = Map_RangeEnd.get(count);
            ShippingCost.shippingRule__c= imp.name__c;// imp.shippingRule__c;
            ShippingCost.subsidiary__c= imp.subsidiary__c;
            ShippingCost.weightQuantity__c= imp.weightQuantity__c;

            Set_Import.add(imp.name__c);
            lstShippingCost.add(ShippingCost);
        }
        count++;
    }

    ShippingCost__c[] lstShippingCostdelete;
    try{

        update lstImportShippingCosts;

        if(lstShippingCost.size()>0){
            lstShippingCostdelete = [Select id from ShippingCost__c where Name in: Set_Import ];
            delete lstShippingCostdelete;
    
            system.debug('**Import Handler: Insert Size*'+lstShippingCost.size());

            insert lstShippingCost;
        }
         
    }
    catch(exception e){

        system.debug('**ShippingCost Error**'+ e.getMessage());

        if(lstShippingCostdelete.size()>0){
            HandleCustomException.LogException(e,lstShippingCostdelete[0].id);
        }
        if(lstShippingCost.size()>0){
            HandleCustomException.LogException(e,lstShippingCost[0].id);
        }
        
        
    }


    return responses;

}

Public static List<ImportShippingCosts__c> HandleErrors(List<ImportShippingCosts__c> lstImportShippingCosts,Map<String,Decimal> Map_ImpCount){    
    for(ImportShippingCosts__c imp:lstImportShippingCosts){

        system.debug('** HandleErrors*'+Map_ImpCount.get(imp.name__c)+ imp.ImportExpectedCount__c);
        
        if(Map_ImpCount.get(imp.name__c) != imp.ImportExpectedCount__c){
            imp.Error__c = 'Mismatch: Number expected vs number reveiced for: ' + imp.name__c;
        }

    }

    return lstImportShippingCosts;

}



}