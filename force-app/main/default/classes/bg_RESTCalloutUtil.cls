/*******************************************************
 * bg_RESTCalloutUtil
 *
 *  Class prepares RESTful Callouts and then carries them out
 *  Test Class - bg_RESTCalloutUtilTest
 *
 * Author: Joseph Gallagher
 * Created: 02-12-2015
 * Changes: 12-01-2016  Andy White - Code Review Changes
 *          28-07-2016  IB - make methods generic for SOW009
 *          16-11-2017  Audo V - make future method queueable
******************************************************/
public without sharing class bg_RESTCalloutUtil implements Queueable, Database.AllowsCallouts
{
    // This variable is used in Tests to ensure that the time of the callout can be consistent through the test - as it is a DateTime it would be potentially be inaccurate otherwise 
    @TestVisible public static DateTime testNow;
    // This will prevent the execution of the old/new deletion functionality at the same time.
    public static Boolean restCallOutDone = false;
    // Set of IDs that have already been processed - will avoid sending the same record more than once in a single transaction
    public static Set<ID> processedIds;
    public Set<ID>ids;

    public Set<ID> ids_full;
    
    Public String OPERATION;


   /*
        Prepare JSON payload for AWSEndpoint__c
        New single generic method in SOW009
    */

    public bg_RESTCalloutUtil (bg_CustomApiParameter apiParam)
    {
       //Map to pass DML OPERATION AND IDS

        this.ids_full = new Set<id>(apiParam.ids);

       // this.ids = new Set<id>(apiParam.ids);
       System.debug('DEBUG: bg_RESTCalloutUtil: Constructor');
        this.OPERATION = apiParam.DMLOperation; 
    }
    
    public void execute (QueueableContext context)
    {
        // Determine the object type that we are dealing with

        /*Paging: */
         
        ids = new Set<ID>();
        if(ids_full.size()>200){
            Integer i=0;
            for(Id recId:ids_full){
                if(i < 200){
                    ids.add(recId);
                    i++;
                }
                else{
                    break;
                }
                
            }             
        }
        else{
           ids.addAll(ids_full);
        }
        

        
        System.debug('DEBUG: bg_RESTCalloutUtil: execute'+ids.size());   

if(ids.size()>0){

        ID firstID = (new list<ID>(ids))[0];        
        Schema.SObjectType soType = firstID.getSObjectType();
        //Generate JSON
        String json = bg_AWSJSONGenerationUtil.GenerateJSONStringForAWSCallout(soType.getDescribe().getName(), ids);
        System.debug('DEBUG: json insert: ' + json);
        // Populate the General Integration Settings for use in this method
        
        //CHANGE DONE -- NEEDS TO BE REPLACED  //= GeneralIntegrationSettings__c.getOrgDefaults();
        GeneralIntegrationSettings__mdt GENERAL_INTEGRATION_SETTINGS =[Select AWSCalloutUsername__c,AWSCalloutPassword__c from GeneralIntegrationSettings__mdt limit 1];  
        
         
        
        // Get endpoint URL from Custom Setting

        //CHANGE DONE ----- NEEDS TO CHANGE // = AWSEndpoint__mdt.getInstance(soType.getDescribe().getName());
        
        Organization[] Organization = [SELECT InstanceName,Name,OrganizationType, Issandbox FROM Organization];


        AWSEndpoint__mdt endPoint;
        

        if(!Organization[0].Issandbox){
            endPoint = [Select endPoint__c,integrationDisabled__c,Test_AWS_Integration__c from AWSEndpoint__mdt limit 1 ];
        }
        else if(Organization[0].Name == 'UAT' || Organization[0].Name == 'DevCentral'){
            endPoint = [Select endPoint__c,integrationDisabled__c,Test_AWS_Integration__c from AWSEndpoint__mdt limit 1];
        }
        
        
                  
        
        AWSCalloutObject__mdt[] CalloutObject = [Select DestinationObject__c,SourceObject__c from AWSCalloutObject__mdt where SourceObject__c =: string.valueof(soType)]; 
        
        String endPointURL;
        if(OPERATION =='Insert'){
            endPointURL = endPoint.endPoint__c+CalloutObject[0].DestinationObject__c+'/batch';
        }
        else if(OPERATION =='Update'){
            endPointURL = endPoint.endPoint__c+CalloutObject[0].DestinationObject__c+'/batch';
        }
        System.debug('DEBUG: OPERATION: ' + OPERATION);
         

        // Set the Authorization Type
        String authorizationType = 'basicAuth';
        // Get username and password
        String calloutUsername = GENERAL_INTEGRATION_SETTINGS.AWSCalloutUsername__c;
        String calloutPassword = GENERAL_INTEGRATION_SETTINGS.AWSCalloutPassword__c;        
        // Set Success Status of Callout
        String successStatus = 'Success';
        // Set Error Message for AWS Update as blank - if success leave it as such though overwrite with a failure
        String errorMessage = '';        
        // Call callout to AWS method
        if(endPointURL!=null && calloutUsername!=null && calloutPassword!=null)
        {
            HttpResponse response = CalloutToEndpoint(calloutUsername, calloutPassword, authorizationType, endPointURL, bg_Constants.HTTP_CALLOUT_POST, json);
            system.debug('AWS Callout status code = ' + response.getStatusCode());
            // We leave this here in case we need to find the transaction ID returned from the POST
            system.debug(response.getBody());
            restCallOutDone = true;
            // If callout fails update error message and success status as appropriate
            if(!(response.getStatusCode()==202 || response.getStatusCode()==200))
            {
                system.debug('**response.getStatusCode()*'+response.getStatusCode());
                successStatus = 'Failure';
                errorMessage = response.getBody().left(254);

            }
            
            bg_LogResponse.logresponse(response.getBody(),ids);

        }
        else
        {
            successStatus = 'Failure';
            errorMessage = Label.GeneralIntegrationSettingNotDefined;

            bg_LogResponse.logresponse(errorMessage +'*** Json: ' + json,ids);
        }
        if (errorMessage != null)
        {
            errorMessage = errorMessage.unescapeHtml4();//.subString(0, 254);
        }
        List<ID> idList = new List<ID>(ids);
        String objectName = String.valueOf(soType.newSObject(idList[0]).getSobjectType());
        // Update success status as success of last callout on all associated sObjects
        String queryString = 'select id, Deleted__c from ' + objectName + ' where id in :idList';
        List<sObject> theObjects = Database.query(queryString);
        // Set the time of last update - this will be now unless running as a test
        DateTime lastUpdate = datetime.now();
        if(test.isRunningTest() && testNow!=null)
        {
            lastUpdate = testNow;
        }
        List<sObject> updateList = new List<sObject>();
        List<sObject> deleteList = new List<sObject>();
        for(ID accIDLi : ids)
        {
            sObject so = soType.newSObject(accIDLi);
            so.put('ID',accIDLi);
            so.put('SuccessStatusOfLastAWSUpdate__c',successStatus);
            so.put('ErrorMessageForAWSUpdate__c',errorMessage);
            so.put('LastUpdateToAWS__c', lastUpdate);
            so.put('IntegrationFactorySend__c', false);
            
            // If the logical delete flag is set and the message has been accepted then perform the physical delete

            try{
                if (theObjects[0].get('Deleted__c') == true && successStatus == 'Success')
                {
                    deleteList.add(so);
                }
                else
                {
                    updateList.add(so);
                }
            }
            catch(exception e){
                system.debug('**B2BOrderInv**: error: '+e.getmessage());
                 HandleCustomException.LogException(e,accIDLi);
            }    
        }
        try
        {
            if (deleteList.size() > 0)
            {
               // delete deleteList;
            }
            if (updateList.size() > 0)
            {
                update updateList;
            }
        }
        catch (Exception e)
        {
            
            system.debug('*****LIST SIZE***'+updateList.size());
            system.debug('*****LIST SIZE: ID***'+updateList[0].id);
            HandleCustomException.LogException(e,updateList[0].id);
            

        }

        /* */
            ids_full.removeAll(ids);
            if(ids_full.size()>0){
                
                
                bg_CustomApiParameter apiParam = new bg_CustomApiParameter();
                apiParam.ids = ids_full;
                apiParam.DMLOperation =  OPERATION ;
                System.enqueueJob(new bg_RESTCalloutUtil(apiParam));
            }
            else{ //Only for renewals
               
                system.debug('**objectName**'+objectName);
                
               if(objectName == 'OrderItem'){
                    OrderItem[] CurOrderItem = [ Select  Order.ActivateforBatchProcessing__c, OrderId from OrderItem Where id in: ids limit 1];
                    if(CurOrderItem[0].Order.ActivateforBatchProcessing__c == true){ 
                        Set<String> Set_checked = new Set<String>();
                        Order_OrderActivateQueueHandler.checknextOrder(CurOrderItem[0].OrderId,Set_checked);
                    }    
               }
               if(objectName == 'Order'){
                    OrderItem[] lst_OrdItem = [ Select  Order.ActivateforBatchProcessing__c, OrderId from OrderItem Where Orderid in: ids Order BY ItemAndItemGroupIntegration__c asc];

                    List<Id> lst_ItemId = new List<Id>();
                    List<Id> Set_OrdId = new List<Id>();
                    for(OrderItem item:lst_OrdItem){
                        lst_ItemId.add(item.id);
                        Set_OrdId.add(item.Orderid);
                        //item.IntegrationFactorySend__c = true;            
                    }
                   
                   //MAKE A QUEUEUABLE CALL
                   Set<Id> Set_ItemId = new Set<Id>();
                   Set_ItemId.addAll(lst_ItemId);
                   // Order_AssetsCreateOnOrderActivation.processAssetsFromOrder(lst_ItemId,Set_ItemId);
                   if(!Test.isRunningTest()){
                    System.enqueueJob(new Order_AssetsCreateOnOrderActivation(lst_ItemId,Set_ItemId));
                   }
                    
                   // bg_AllObjectInvocableHandler.AllObjectInvocableHandler(Set_ItemId);
                    
               }
            }
        
        }


    }   
    // Shared method for a RESTful callout to an endpoint
    public static HttpResponse CalloutToEndpoint(String calloutUsername, String calloutPassword, String authorizationType, String endpointUrl, String httpVerb, String json)
    {
        // Populate the General Integration Settings for use in this method
       // GeneralIntegrationSettings__mdt[] GENERAL_INTEGRATION_SETTINGS =[Select id from limit 1]; // = GeneralIntegrationSettings__mdt.getOrgDefaults();
        
       
        system.debug('**calloutUsername*'+calloutUsername+'**calloutPassword**'+calloutPassword+'**endpointUrl**'+endpointUrl+'**httpVerb**'+httpVerb);
        system.debug('**json*'+json);
        
        //NEEDS TO BE CHANGED        
        
        // Set authorization Value is required
        String authorizationValue;  
         
        if(authorizationType == 'basicAuth')
        {           
            // Generate User Name and Password String for Authentication             
            authorizationValue = BuildBasicAuthorizationHeader(calloutUsername, calloutPassword);           
        } 
                        
        // Instantiate a new http object
        authorizationValue = BuildBasicAuthorizationHeader(calloutUsername, calloutPassword);
        system.debug('**authorizationValue*'+authorizationValue);

        Http h = new Http();
        // Instantiate a new http request - takes the verb as well as endpoint and JSON string
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod(httpVerb);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setBody(json);
         
        
        if(authorizationType == 'basicAuth')
        {  
            req.setHeader('Authorization', authorizationValue);
        }
        
        // Send the request, and return a response
        HttpResponse res;// = h.send(req);

        if(!Test.isRunningTest()) {
              
               res = h.send(req);           
           
        } 
        else{    
                 
                String body = '{"success":true}';
                res = new HttpResponse();
                res.setBody(body);
                res.setStatusCode(200);
        } 



        system.debug(res.getBody());
        return res;
    }
    // Method to build the Basic Authorisation header with the Username and Password 
    public static String BuildBasicAuthorizationHeader(String Username, String Password)
    {
        // Form authorization header with password and username 
        Blob authValues = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(authValues);
        return authorizationHeader;
    }
}