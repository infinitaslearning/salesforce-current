/*
* Connor Huglin - 2022/11/04: This will be used to compare the code of Apex Classes across the different environments
* It uses the custom metadata "OrgLogin__mdt" to store and fetch the different environment details
* It then fetches the details for the passed Apex Class Name for each environment
* still need to do the front-end work for this to display and compare the code
*/
public class DevOps_ClassCompare {
    public String getAccessToken(OrgLogin__mdt orgLogin){
        String accessToken;
        String clientId = orgLogin.clientId__c;
        String clientSecret = orgLogin.clientSecret__c;
        String username = orgLogin.username__c;
        String password = orgLogin.password__c;
        
        // REGION GET TOKEN
        Http httpCls = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://test.salesforce.com/services/oauth2/token');
        request.setMethod('POST');
        
        request.setHeader('Content-Type','application/x-www-form-urlencoded');        
        request.setBody('grant_type=password' + 
                        '&client_id=' + clientId + 
                        '&client_secret=' + clientSecret + 
                        '&username=' + username + 
                        '&password=' + password);        
        
        httpResponse response = httpCls.send(request);
        
        if(response.getStatusCode() == 200){            
            system.debug('## Successfully retrieving access token'); 
            
            Map<string,Object> resultMap = (Map<string,Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('## resultMap: ' + resultMap);
            
            accesstoken = (String)resultMap.get('access_token'); 
			system.debug('## accesstoken: ' + accesstoken);
        } else {
            system.debug('## Could not retrieve the access token' ); 
            system.debug('## response status :' + response.getStatus()); 
            system.debug('## response message :' + response.getBody());
        }
        // END REGION
        
        return accessToken;
    }
    
    public List<ApexClass> getClassDetails(String className){
		List<ApexClass> classesToCompare = new List<ApexClass>();
        // fetch metadata login data (need to fetch class contents for each org)
        Map<String, OrgLogin__mdt> orgLogins = OrgLogin__mdt.getAll();
        system.debug('## orgLogins: ' + orgLogins);
        
        // get apex class details for current org
        ApexClass apexCls = [Select Id, Name, Body From ApexClass WHERE Name =: className];
        classesToCompare.add(apexCls);
        
        // get apex class details for other orgs
        for(String key : orgLogins.keySet()){
            OrgLogin__mdt orgLogin = orgLogins.get(key);
            String accessToken = getAccessToken(orgLogin);
            
            Http httpCls2 = new Http();
            HttpRequest classRequest = new HttpRequest();
            classRequest.setEndpoint('https://' + orgLogin.url__c + '/services/apexrest/ApexClass/' + className);
            classRequest.setMethod('GET');
            classRequest.setHeader('Authorization','Bearer ' + accessToken);
            system.debug('## classRequest: ' + classRequest);
            
            HttpResponse classResponse = new HttpResponse();
            classResponse = httpCls2.send(classRequest);
            system.debug('## classResponse: ' + classResponse);

            while (classResponse.getStatusCode() == 302) {
                classRequest.setEndpoint(classResponse.getHeader('Location'));
                classResponse = new Http().send(classRequest);
            }
            
            if(classResponse != null && classResponse.getBody() != null){                
                ApexClass apexClassRes = (ApexClass)JSON.deserialize(classResponse.getBody(), ApexClass.class);
                classesToCompare.add(apexClassRes);
            }
        }
        
        system.debug('## classesToCompare.size(): ' + classesToCompare.size());
        return classesToCompare;
    }
}