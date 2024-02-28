@RestResource(urlMapping='/GITAPIWebHook/*')
global with sharing class UTIL_GITAPIWebHook {
    
    @HttpPost
    global static void handlePost() {
        
            String webhookBody = RestContext.request.requestBody.toString();
            System.debug('webhookBody 1: ' + webhookBody);
           
            


          //  String authorizationHeader = 'Bearer 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' ;
            String authorizationHeader = 'Bearer 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' ;
            


        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.github.com/repos/seanparker60/IL_UAT/git/trees/b6b047d1f3ca008a4254dbb6b8f0b0cf719ba562');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setHeader('Authorization', authorizationHeader);
        
        // Send the request, and return a response
        HttpResponse res= h.send(req);// = h.send(req);

        system.debug(res.getBody());

        string Classes = res.getBody();

            SystemMonitor__c SystemMonitor = new SystemMonitor__c(Message__c = Classes ,ErrorMessage__c = webhookBody);
            insert SystemMonitor;
            
            /*
            HttpRequest req = new HttpRequest();
       String body = '{"new_name":"IL_Clone_Util"}';
    req.setEndpoint('https://api.github.com/repos/seanparker60/IL_UAT/branches/IL_Clone/rename');

        req.setMethod('POST');
            */
            
            
    }    
}