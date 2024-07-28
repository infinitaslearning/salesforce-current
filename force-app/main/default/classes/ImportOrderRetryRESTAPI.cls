@RestResource(urlMapping='/ImportOrder_Retry/*')
global with sharing class ImportOrderRetryRESTAPI {
    @HttpPost
    global static String doPost(String externalOrderId) {
        
        // get header
        ImportOrder__c importOrder = [Select Id, ExternalOrderId__c from ImportOrder__c where ExternalOrderId__c =: externalOrderId AND ProductId__c = null AND Status__c = 'Error' LIMIT 1];
        String resp='NA';
        
        try{
            
            ImportOrder__c[] lst_ImportOrderLines = [Select Id from ImportOrder__c where ExternalOrderId__c =: externalOrderId AND ProductId__c != null AND Status__c = 'Error'];
            
            system.debug('**importOrder**: ' + importOrder);
            
            importOrder.Status__c = 'Pending';
            update importOrder;
            
            for(ImportOrder__c io : lst_ImportOrderLines){
                io.Status__c = 'Pending';
            }
            
            update lst_ImportOrderLines;
			
			resp = 'Success';
           
        }
        catch(exception e){
            
            resp=e.getmessage();
            system.debug('**Import Order Retry Error**: ' + e.getmessage());
        }
        
        return resp;
    }
    
    
    public static String retryImportOrder(String externalOrderId){
        
        JSONParser parser;
        HttpResponse res1;
        
        String accessToken,endPoint,DMLType,reqbody,objbody;
        
        DMLType = 'POST';
        endPoint= URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/ImportOrder_Retry/'; //'https://CS128.salesforce.com
        accessToken= userinfo.getSessionId();
        reqbody =     '{"externalOrderId" : "'+externalOrderId+'"}';
        
        
        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer ' + accessToken);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setTimeout(120000);   
        
        system.debug('**reqbody**'+reqbody);
        system.debug('**DMLType**'+DMLType);
        system.debug('**endPoint**'+endPoint);
        
        req1.setEndpoint(endPoint);
        req1.setBody(reqbody);
        req1.setMethod(DMLType);
        
        string result;
        if(!Test.isRunningTest()){
            res1 = h2.send(req1);
            result = res1.getbody();
        }
        else{
            result = 'failed';
        }
        
        
        system.debug('**result*'+result);
        
        if(result.contains('failed')){
            
            ErrorLog__c errorLog = new ErrorLog__c();
            errorLog.Errororigin__c = 'Apex';
            errorLog.RelatedToId__c = externalOrderId;
            errorLog.ExceptionMessage__c = result;
            errorLog.ExceptionType__c = 'Import Order Retry';
            database.insert(errorLog);
        }
        
        return result;
    }
}