/*******************************************************
 * bg_AWSTriggerUtils
 *
 *  
 * 
 * 
 *  Test Class - bg_AWSTriggerUtils_Test
 *
 * Author: Ian Bowman
 * Created: 15-08-2016
 * Changes: 16-11-2016 IB Allow unit tests that have not set up the Custom Setting to bypass this code
 *          22-11-2016 JA Added support for Test_AWS_Integration value to prevent tests that use SeeAllData
                          from falling over because of the Custom Setting
 *          29-06-2017 BP Added check for future method before calling another future method
 *          05-10-2017 AV Prevent to execute ProcessAWSCallout when the there is not records to process.
 *          16-11-2017 AV Use queueable job instead of future method
********************************************************/
public with sharing class bg_AWSTriggerUtils {
    public static final String OPERATION_INSERT = 'created';
    public static final String OPERATION_UPDATE = 'updated';
    public static final String OPERATION_DELETE = 'deleted';
    public static final String DELETE_PARAMETER = ' Deleted : TRUE';
     

    /*
        Generic method to be called by After Insert / Update triggers for objects to participate in AWS integration
        If called for an update both newSObjectsToProcessMap and oldSObjectsToProcessMap are required.
    */
    public static void ProcessAWSCallout(String objectName, map<Id, sObject> newSObjectsToProcessMap, map<Id, sObject> oldSObjectsToProcessMap, String operation)
    {
        System.debug(LoggingLevel.ERROR,'bg_AWSTriggerUtils Updating fields Total amount of DML Statements' + Limits.getLimitDMLStatements());
        String errorMessage = '';
        if(bg_RESTCalloutUtil.processedIds==null)
        {
            bg_RESTCalloutUtil.processedIds = new Set<ID>();
        }
        //bg_RESTCalloutUtil.processedIds = new Set<ID>();
        newSObjectsToProcessMap.keySet().removeAll(bg_RESTCalloutUtil.processedIds);
        //if (System.IsBatch() || System.IsFuture() || newSObjectsToProcessMap.isEmpty())
        if ( newSObjectsToProcessMap.isEmpty())
        {
            System.debug(LoggingLevel.ERROR, 'bg_AWSTriggerUtils list of records is empty');
            return;
        }
        System.debug(LoggingLevel.ERROR, 'bg_AWSTriggerUtils list of records is NOT empty');

        //CHANGE DONE ----- NEEDS TO CHANGE // = AWSEndpoint__mdt.getInstance(objectName);
        AWSEndpoint__mdt endPoint = [Select endPoint__c,integrationDisabled__c,Test_AWS_Integration__c from AWSEndpoint__mdt limit 1 ]; 

        
        
        System.debug(LoggingLevel.ERROR, 'bg_AWSTriggerUtils ProcessAWSCallout endPoint: ' + endPoint);
        if (Test.isRunningTest())
        {
            if (endPoint == null)
            {
                return;
            }
            else if (!endPoint.Test_AWS_Integration__c)
            {
                return;
            }
        }
        if ( endPoint == null )
        {
            errorMessage += Label.AWSIntegrationNotDefined + ' ' + objectName;
        }
        else if (!endPoint.integrationDisabled__c)
        {
            // carry out additional custom setting validation
            bg_CustomSettingValidity AWSIntegrationSetting = bg_CustomSettingUtils.ValidateCalloutCustomSettingsForObject(objectName);
            System.debug(LoggingLevel.ERROR, 'bg_AWSTriggerUtils: endPoint.integrationDisabled__c');
            String intErrorMessage = AWSIntegrationSetting.errorMessage;
            if(!AWSIntegrationSetting.isValid)
            {
                errorMessage += intErrorMessage + ' - invalid Settings';
            }
            if (!bg_CustomSettingUtils.validateGeneralIntegrationSettings())
            {
                errorMessage += Label.GeneralIntegrationSettingNotDefined + ' - invalid Notdefined';
            }
        }
        if (errorMessage == '' && !endPoint.integrationDisabled__c)
        {
            System.debug('DEBUG: Working with fields');
            //Map to pass DML OPERATION AND IDS
            Map<String,Set<ID>> mapId = new Map<String,Set<ID>>();
            Set<Id> DMLType = new Set<Id>();
            bg_CustomApiParameter apiParam = new bg_CustomApiParameter();

            if (operation == OPERATION_INSERT)
            {
                
                System.debug(LoggingLevel.ERROR, 'DEBUG: Inserting fields');
                
                //Class Definintion to pass DML OPERATION AND IDS
             

                apiParam = new bg_CustomApiParameter();
                apiParam.ids = newSObjectsToProcessMap.keySet();
                apiParam.DMLOperation =  'Insert';               
                System.enqueueJob(new bg_RESTCalloutUtil(apiParam));

                

                //REPLACES THIS CAll
                //System.enqueueJob(new bg_RESTCalloutUtil(newSObjectsToProcessMap.keySet()));
                bg_RESTCalloutUtil.processedIds.addAll(newSObjectsToProcessMap.keySet());
                
            }
            else if (operation == OPERATION_UPDATE)
            {
                 
                Set<Id> calloutIds = new Set<Id>();
                // evaluate if any of the fields that require integration have been updated
                Map<String, AWSCalloutFields__mdt> fieldsForCalloutMap = bg_CustomSettingUtils.GetObjectCustomSettingFieldsMap(objectName);
                System.debug('bg_AWSTriggerUtils fieldsForCalloutMap: ' + fieldsForCalloutMap);
                // Look through each record to check if any updates
                for(sObject newObject : newSObjectsToProcessMap.values())
                {
                    // Get the appropriate object from the old map to compare it to
                    sObject oldObject = oldSObjectsToProcessMap.get(newObject.Id);
                    // Check if any of the fields we are using for the integration have changed
                    for(String fieldName : fieldsForCalloutMap.keySet())
                    {
                        
                      //  System.debug('**IntegrationFactorySend__c**' + newObject.get(fieldName));

                        if(fieldName == 'IntegrationFactorySend__c' && newObject.get(fieldName)==true)
                        {
                            calloutIds.add(newObject.Id);
                            break;
                        }
                        else if(newObject.get(fieldName) != oldObject.get(fieldName) && fieldName != 'IntegrationFactorySend__c' && fieldName !='LastModifiedDate' && fieldName != 'Createddate')
                        {
                            calloutIds.add(newObject.Id);
                            break;
                        }
                    }
                }
                System.debug('bg_AWSTriggerUtils: calloutIds: ' + calloutIds);
                if(calloutIds != null && !calloutIds.isEmpty())
                {
                    System.debug(LoggingLevel.ERROR,'DEBUG: Updating fields');
                   
                    //Class Definintion to pass DML OPERATION AND IDS
                    apiParam = new bg_CustomApiParameter();
                    apiParam.ids = calloutIds;
                    apiParam.DMLOperation =  'Update';               
                    System.enqueueJob(new bg_RESTCalloutUtil(apiParam));
                    
                   //REPLACES THIS CAll
                    //System.enqueueJob(new bg_RESTCalloutUtil(calloutIds));
                    bg_RESTCalloutUtil.processedIds.addAll(calloutIds);
                }
            }
        }
        else
        {
            if ( errorMessage != '' )
            {
                // add the errors
                for(sObject objectToAddErrors : newSObjectsToProcessMap.values())
                {
                    objectToAddErrors.addError(errorMessage);
                }
            }
        }
    }
}