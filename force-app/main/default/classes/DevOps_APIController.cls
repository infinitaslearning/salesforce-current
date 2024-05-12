@RestResource(urlMapping='/ApexClass/*')
global with sharing class DevOps_APIController {
	@HttpGet
    global static ApexClass getClass(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String className = req.requestURI.subString(req.requestURI.lastIndexOf('/')+1);
        ApexClass apxClsDetail = [Select Id, Name, Body From ApexClass WHERE Name =:className];
        return apxClsDetail;
    }
}