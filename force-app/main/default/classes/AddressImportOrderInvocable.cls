public without sharing class AddressImportOrderInvocable {
    
    @InvocableMethod(label='Validate Import Order Address')
    public static void validateImportOrderAddress(List<AddressValidation.Request> requests){
        System.debug('***validateImportOrderAddress: ' + JSON.serialize(requests));
        //Serialize input to pass custom/complex data type to future method
        futureValidate(JSON.serialize(requests));
    }
    
    @future(callout=true)
    public static void futureValidate(String wrapper){
        //Deserialize the string input back to the custom/complex data type received by the invocable method
        List<AddressValidation.Request> requests = (List<AddressValidation.Request>)JSON.deserialize(wrapper, List<AddressValidation.Request>.class);
        System.debug('***futureValidate: ' + requests);
        
        //Call the address validation method
        List<AddressValidation.Response> responseWrapper = AddressValidation.validateAddress(requests);
        System.debug('***responseWrapper: ' + responseWrapper);
        
        //Assign response values from the responseWrapper into the flow validation result defined structure
        recordval.Rv2FlowValidationResult validation = new recordval.Rv2FlowValidationResult();
        validation.advice = responseWrapper[0].statusColour;
        validation.credit = responseWrapper[0].credit;
        validation.fieldName = 'Street__c';
        validation.statusCode = responseWrapper[0].statusCode;
        validation.statusMessage = responseWrapper[0].statusMessage;
        System.debug('***validation: ' + validation);
        
        List<recordval.Rv2FlowValidationResult> listValidationResult = new List<recordval.Rv2FlowValidationResult>();
        listValidationResult.add(validation);
        
        //Query the address to update with validation result
        List<ILAddress__c> addressRecordLs = [SELECT Id, rv2Status__c, rv2Validation__c
                                              FROM ILAddress__c
                                              WHERE HouseNumber__c =: requests[0].housenumber
                                              AND HouseNumberAddition__c =: requests[0].housenumberAddition
                                              AND PostalCode__c =: requests[0].postalcode
                                              AND Country__c =: requests[0].country];
        
        System.debug('***addressRecordLs: ' + addressRecordLs);
        
        /*Use the Rv2SaveValidationResultsFlowAction to save the validation result in APEX becuase currently no method available other than this is available to save validation results after calling the API from APEX.
          Only the flow APEX action method exits as a save methood to save validation results.
          The API response needs is converted into the type that the flow save action accepts which is not the same as the raw response from the API when validating*/
        recordval.Rv2SaveValidationResultsFlowAction.Rv2SaveValidationResultRequest saveValidationResultRequest = new recordval.Rv2SaveValidationResultsFlowAction.Rv2SaveValidationResultRequest();
        saveValidationResultRequest.recordId = addressRecordLs[0].Id;
        saveValidationResultRequest.validationResults = listValidationResult;
        System.debug('***saveValidationResultRequest: ' + saveValidationResultRequest);
        
        List<recordval.Rv2SaveValidationResultsFlowAction.Rv2SaveValidationResultRequest> listSaveValidationResultRequests = new List<recordval.Rv2SaveValidationResultsFlowAction.Rv2SaveValidationResultRequest>();
        listSaveValidationResultRequests.add(saveValidationResultRequest);
        
        if(!Test.isRunningTest()){
            //Save the validation result
            recordval.Rv2SaveValidationResultsFlowAction.saveValidationResults(listSaveValidationResultRequests);
        }
        
        //Update the Order/OrderItem address validation status
        Boolean isValid = validation.advice == 'GREEN' ? TRUE : FALSE;
        Boolean updatedOrderANDItems = AddressValidation.updateOrdersANDOrderItems(addressRecordLs[0].Id, isValid);
        System.debug('***UPDATED ORDERS AND ITEMS?: ' + updatedOrderANDItems);
    }
    
}