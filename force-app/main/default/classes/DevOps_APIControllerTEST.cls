@isTest
public class DevOps_APIControllerTEST {
    public static testMethod void testDevOps_APIController(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ApexClass/DevOps_APIController'; 
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        ApexClass apxCls = DevOps_APIController.getClass();
        test.stopTest();
    }
}