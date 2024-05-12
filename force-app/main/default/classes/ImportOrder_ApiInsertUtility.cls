@RestResource(urlMapping='/ImportOrder/*')
global with sharing class ImportOrder_ApiInsertUtility {
    
    @HttpPost
    global static String doPost(){
        
        String resp='Success';
        try{
            Integer randomNumber = Integer.valueof((Math.random() * 10000));
            ImportOrder__c ioHeader = new ImportOrder__c();
            ioHeader.ExternalOrderId__c = 'BatchIndvTest' + randomNumber;
            ioHeader.customerNo__c = '0';
            ioHeader.orderDate__c = '01/06/2022';
            ioHeader.LineCount__c = 1;
            ioHeader.Source__c = 'eCommerce B2C';
            ioHeader.addressLine1__c = 'Lange Nieuwstraat 125';
            ioHeader.City__c = 'Utrecht';
            ioHeader.Country__c = 'Netherlands';
            ioHeader.Postalcode__c = '3512 PG';
            ioHeader.BillingStreet__c = 'Lange Nieuwstraat 125';
            ioHeader.BillingCity__c = 'Utrecht';
            ioHeader.BillingCountry__c = 'Netherlands';
            ioHeader.BillingPostalCode__c = '3512 PG';
            ioHeader.OperatingCompany__c = 'Plantyn';
            ioHeader.FirstName__c = 'Trail';
            ioHeader.LastName__c = 'Blazer' + randomNumber;
            ioHeader.UserEmail__c = ioHeader.FirstName__c + ioHeader.LastName__c + randomNumber + '@example.nl';
            ioHeader.CommunicationLanguage__c = 'nl-NL';
            ioHeader.customerOrderType__c = 'private';
            ioHeader.deliveryIdLocation__c = '0';
            ioHeader.invoiceIdLocation__c = '0';
            
            List<ImportOrder__c> importOrderList = new List<ImportOrder__c>();
            
            for(Integer i = 0; i < 1; i++){
                ImportOrder__c ioLine = new ImportOrder__c();
                ioLine.ProductId__c = '9789633493410';
                ioLine.quantity__c = 1;
                ioLine.ExternalOrderId__c = 'BatchIndvTest' + randomNumber;
                ioLine.customerNo__c = '0';
                ioLine.orderDate__c = '01/06/2022';
                ioLine.Source__c = 'eCommerce B2C';
                ioLine.addressLine1__c = 'Lange Nieuwstraat 125';
                ioLine.City__c = 'Utrecht';
                ioLine.Country__c = 'Netherlands';
                ioLine.Postalcode__c = '3512 PG';
                ioLine.BillingStreet__c = 'Lange Nieuwstraat 125';
                ioLine.BillingCity__c = 'Utrecht';
                ioLine.BillingCountry__c = 'Netherlands';
                ioLine.BillingPostalCode__c = '3512 PG';
                ioLine.OperatingCompany__c = 'Plantyn';
                ioLine.TriggerBusinessLogic__c = false;
                ioLine.customerOrderType__c = 'private';
                importOrderList.add(ioLine);
                
                /*ImportOrder__c ioLine2 = new ImportOrder__c();
                ioLine2.ProductId__c = '9782801003596';
                ioLine2.quantity__c = 1;
                ioLine2.ExternalOrderId__c = 'BatchIndvTest' + randomNumber;
                ioLine2.customerNo__c = '0';
                ioLine2.orderDate__c = '14/04/2022';
                ioLine2.Source__c = 'eCommerce B2B';
                ioLine2.addressLine1__c = 'Lange Nieuwstraat 125';
                ioLine2.City__c = 'Utrecht';
                ioLine2.Country__c = 'Netherlands';
                ioLine2.Postalcode__c = '3512 PG';
                ioLine2.BillingStreet__c = 'Lange Nieuwstraat 125';
                ioLine2.BillingCity__c = 'Utrecht';
                ioLine2.BillingCountry__c = 'Netherlands';
                ioLine2.BillingPostalCode__c = '3512 PG';
                ioLine2.OperatingCompany__c = 'Plantyn';
                ioLine2.TriggerBusinessLogic__c = false;
                ioLine2.customerOrderType__c = 'private';
                importOrderList.add(ioLine2);*/
            }
            System.debug('importOrderList size: ' + importOrderList.size());
            importOrderList.get(importOrderList.size() - 1).TriggerBusinessLogic__c = true;
            insert ioHeader;
            insert importOrderList;
        }
        catch(exception e){
            resp=e.getmessage();
        }
        
        return resp;
    }
    
    public static String dummyInsertImportOrders(){
        
        JSONParser parser;
        HttpResponse res1;
        
        String accessToken,endPoint,DMLType,reqbody,objbody;
        
        DMLType = 'POST';
        endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/ImportOrder/';
        accessToken = userinfo.getSessionId();
        reqbody = '{}';
        
        
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
        
        /*if(result.contains('failed')){
            
            ErrorLog__c errorLog = new ErrorLog__c();
            errorLog.Errororigin__c = 'Apex';
            errorLog.RelatedToId__c = OrderId;
            errorLog.ExceptionMessage__c = result;
            errorLog.ExceptionType__c = 'API Order Activation';
            database.insert(errorLog);
		}*/
        
        return result;
    }
    
}