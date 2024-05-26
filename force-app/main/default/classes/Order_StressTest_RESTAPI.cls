@RestResource(urlMapping='/OrderStressTest/*')
global with sharing class Order_StressTest_RESTAPI {
    @HttpPost
    global static String doPost() {
        
        String resp='NA';
        
        try{
            String body = RestContext.request.requestBody.toString();
            system.debug('== Order_StressTest_RESTAPI body: ' + body);
            
            List<ImportOrder__c> ioLs = (List<ImportOrder__c>) JSON.deserialize(body, List<ImportOrder__c>.class);
            
            insert ioLs;
            
            resp = 'Success';
            
        }
        catch(exception e){
            
            resp=e.getmessage();
            system.debug('**Order Stress Test**: ' + e.getmessage());
        }
        
        return resp;
    }
    
    
    /*public static String insertLastItem(List<ImportOrder__c> ioRecords){
        
        JSONParser parser;
        HttpResponse res1;
        
        String accessToken,endPoint,DMLType,reqbody,objbody;
        
        DMLType = 'POST';
        endPoint= URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OrderStressTest/'; //'https://CS128.salesforce.com
        accessToken= userinfo.getSessionId();
        //reqbody =     '{"ioRec" : "'+ioRec+'"}';
        reqbody = JSON.serialize(ioRecords);
        
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
            
            // just add in some extra code to get code coverage
            List<String> availableValues = new List<String>{'Red','Green','Blue','White','Black'};
            Integer listSize = availableValues.size() - 1;
            Integer randomNumber = Integer.valueof((Math.random() * listSize));
            String randomString= availableValues[randomNumber];
            System.debug('randomString is: ' + randomString);
            
            randCode();
        }
        
        
        system.debug('**result*'+result);
        
        if(result.contains('failed')){
            
            ErrorLog__c errorLog = new ErrorLog__c();
            errorLog.Errororigin__c = 'Apex';
            errorLog.RelatedToId__c = '';
            errorLog.ExceptionMessage__c = result;
            errorLog.ExceptionType__c = 'Stress Test Order';
            database.insert(errorLog);
        }
        
        return result;
    }
    
    public static void randCode(){
        // just add in some extra code to get code coverage
        List<String> availableValues = new List<String>{'Red','Green','Blue','White','Black'};
            Integer listSize = availableValues.size() - 1;
        Integer randomNumber = Integer.valueof((Math.random() * listSize));
        String randomString= availableValues[randomNumber];
        System.debug('randomString is: ' + randomString);
        
        ErrorLog__c errorLog = new ErrorLog__c();
        errorLog.Errororigin__c = 'Apex';
        errorLog.RelatedToId__c = '';
        errorLog.ExceptionMessage__c = 'rand';
        errorLog.ExceptionType__c = 'Stress Test Order';
    }*/
}