public with sharing class bg_AWSInvocableUtils {
    
    public static final String OPERATION_INSERT = 'created';
    public static final String OPERATION_UPDATE = 'updated';
    public static final String OPERATION_DELETE = 'deleted';
    public static final String DELETE_PARAMETER = ' Deleted : TRUE';
     

    /*
        Generic method to be called by After Insert / Update triggers for objects to participate in AWS integration
        If called for an update both newSObjectsToProcessMap and oldSObjectsToProcessMap are required.
    */
    public static void ProcessAWSCallout(String objectName, List<Id> RecordIds)
    {
        System.debug(LoggingLevel.ERROR,'bg_AWSTriggerUtils Updating fields Total amount of DML Statements' + Limits.getLimitDMLStatements());
        String errorMessage = '';
        if(bg_RESTCalloutUtil.processedIds==null)
        {
            bg_RESTCalloutUtil.processedIds = new Set<ID>();
        }
        //bg_RESTCalloutUtil.processedIds = new Set<ID>();
        
        //if (System.IsBatch() || System.IsFuture() || newSObjectsToProcessMap.isEmpty())
        
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

            System.debug('DEBUG: errorMessage'+errorMessage);
        }
        if (errorMessage == '' && !endPoint.integrationDisabled__c)
        {
            System.debug('DEBUG: Working with fields');
            //Map to pass DML OPERATION AND IDS
            Map<String,Set<ID>> mapId = new Map<String,Set<ID>>();
            Set<Id> DMLType = new Set<Id>();
            bg_CustomApiParameter apiParam = new bg_CustomApiParameter();
            
            System.debug(LoggingLevel.ERROR, 'DEBUG: Inserting fields');
                
                //Class Definintion to pass DML OPERATION AND IDS
             
                Set<Id> Set_RecordIds = new Set<Id>();

                for(Id ids:RecordIds){
                    Set_RecordIds.add(ids);
                }

                apiParam = new bg_CustomApiParameter();
                apiParam.ids = Set_RecordIds;
                apiParam.DMLOperation =  'Update';  
                if(!Test.isRunningTest()){
                    System.enqueueJob(new bg_RESTCalloutUtil(apiParam));
                }             
                
                
        }
        else
        {
            if ( errorMessage != '' )
            {
                // add the errors
              //  for(sObject objectToAddErrors : newSObjectsToProcessMap.values())
              //  {
             //       objectToAddErrors.addError(errorMessage);
             //   }
            }
        }
    }



}