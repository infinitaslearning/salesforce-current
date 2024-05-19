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
        System.debug('***responseWrapper1: ' + responseWrapper);
        System.debug('***responseWrapper2: ' + responseWrapper[0].addressValidationOutput);
        System.debug('***responseWrapper3: ' + responseWrapper[0].addressValidationOutput.addresses[0]);
        System.debug('***responseWrapper4: ' + responseWrapper[0].addressValidationOutput.addresses[0].status);
        System.debug('***responseWrapper5: ' + responseWrapper[0].addressValidationOutput.status);
        System.debug('***responseWrapper6: ' + responseWrapper[0].addressValidationOutput.advice);

        //Query the address to update with validation result
        List<ILAddress__c> addressRecordLs = [SELECT Id, rv2Status__c, rv2Validation__c
                                              FROM ILAddress__c
                                              WHERE HouseNumber__c =: requests[0].housenumber
                                              AND HouseNumberAdditionFormatted__c =: requests[0].housenumberAddition
                                              AND PostalCodeFormatted__c =: requests[0].postalcode
                                              AND Country__c =: requests[0].country];
        
        System.debug('***addressRecordLs: ' + addressRecordLs);
        
        // define record validation API        
        recordval.RecordValidationAPI_v1 api = new recordval.RecordValidationAPI_v1();

        // Create a new rv2SaveResultsInputObject
        recordval.rv2SaveValidationResultInput_v1 saveResults = new recordval.rv2SaveValidationResultInput_v1();
        // Set the recordId in which the result needs to be stored
        saveResults.setRecordId(addressRecordLs[0].Id);
        // Pass the fieldName that needs to be validated and the result from the validation
        saveResults.setValidationResult('Street__c', responseWrapper[0].addressValidationOutput);
        recordval.rv2SaveValidationResultOutput_v1 result = api.saveValidationResult(saveResults);

        System.debug(LoggingLevel.debug, result.recordId);
        System.debug(LoggingLevel.debug, result.success);

        //Update the Order/OrderItem address validation status
        Boolean isValid = responseWrapper[0].statusColour == 'GREEN' ? TRUE : FALSE;
        Boolean updatedOrderANDItems = AddressValidation.updateOrdersANDOrderItems(addressRecordLs[0].Id, isValid);
        System.debug('***UPDATED ORDERS AND ITEMS?: ' + updatedOrderANDItems);
    }
    
}