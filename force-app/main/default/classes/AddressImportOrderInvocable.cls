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

        //Query the address to update with validation result
        List<ILAddress__c> addressRecordLs = [SELECT Id, rv2Status__c, rv2Validation__c
                                              FROM ILAddress__c
                                              WHERE HouseNumber__c =: requests[0].housenumber
                                              AND HouseNumberAdditionFormatted__c =: requests[0].housenumberAddition
                                              AND PostalCodeFormatted__c =: requests[0].postalcode
                                              AND Country__c =: requests[0].country
                                              AND OperatingCompany__c =: requests[0].OperatingCompany];
        System.debug('***addressRecordLs: ' + addressRecordLs);
        

        //assign address values with returned results from RV Validate API response
        addressRecordLs[0].Street__c = responseWrapper[0].addressValidationOutput.addresses[0].street;
        addressRecordLs[0].HouseNumber__c = responseWrapper[0].addressValidationOutput.addresses[0].housenumber;
        addressRecordLs[0].HouseNumberAddition__c = responseWrapper[0].addressValidationOutput.addresses[0].housenumberAddition;
        addressRecordLs[0].PostalCode__c = responseWrapper[0].addressValidationOutput.addresses[0].postalCode;
        addressRecordLs[0].City__c = responseWrapper[0].addressValidationOutput.addresses[0].city;
        addressRecordLs[0].Country__c = responseWrapper[0].addressValidationOutput.addresses[0].country;
        addressRecordLs[0].CountryCode__c = responseWrapper[0].addressValidationOutput.addresses[0].countryCode;
        //assign rv2 validate fields
        addressRecordLs[0].rv2Status__c = String.valueOf(responseWrapper[0].addressValidationOutput.addresses[0].advice);
        addressRecordLs[0].rv2StatusCode__c = responseWrapper[0].addressValidationOutput.addresses[0].status.code;
        addressRecordLs[0].rv2StatusMessage__c = responseWrapper[0].addressValidationOutput.addresses[0].status.message;
        addressRecordLs[0].rv2ValidationDate__c = system.now();
        //create a blob from for RV Validation text area field from the response values in the addressValidationOutput
        Blob base64ValidationBlob = Blob.valueOf('{"fieldStatus":{"Street__c":{"validatedOn":"'+ String.valueOf(System.now()) +'","status":{"message":"'+ responseWrapper[0].addressValidationOutput.addresses[0].status.message +
                                        '","credit":true,"code":"'+ responseWrapper[0].addressValidationOutput.addresses[0].status.code +
                                        '","addressValid":null},"isEntry":false,"isChanged":false,"geoStatus":null,"customData":{},"advice":"'+ String.valueOf(responseWrapper[0].addressValidationOutput.addresses[0].advice) +'"}}}');
        System.debug('***base64: ' + EncodingUtil.base64Encode(base64ValidationBlob));
        //encode the blob to base64 string and save to replicate the RV Validate save method saving the results as a base64
        addressRecordLs[0].rv2Validation__c = EncodingUtil.base64Encode(base64ValidationBlob);

        //Update queried address record
        update addressRecordLs[0];

        //Update the Order/OrderItem address validation status
        Boolean isValid = responseWrapper[0].statusColour == 'GREEN' ? TRUE : FALSE;
        Boolean updatedOrderANDItems = AddressValidation.updateOrdersANDOrderItems(addressRecordLs[0].Id, isValid);
        System.debug('***UPDATED ORDERS AND ITEMS?: ' + updatedOrderANDItems);
    }
    
}