global without sharing class AddressValidation {
    
    public class Request {
        @InvocableVariable
        public string street;
        @InvocableVariable
        public string housenumber;
        @InvocableVariable
        public string housenumberAddition;
        @InvocableVariable(required=true)
        public string postalcode;
        @InvocableVariable(required=true)
        public string country;
        @InvocableVariable
        public string accountId;
        @InvocableVariable
        public boolean bCreateAddress;
        @InvocableVariable
        public string OperatingCompany;
    }
    
    public class Response {
        @InvocableVariable
        public string statusColour;
        @InvocableVariable
        public string statusCode;
        @InvocableVariable
        public string fullAddress;
        @InvocableVariable
        public string addressId;
        @InvocableVariable
        public boolean credit;
        @InvocableVariable
        public string statusMessage;
        public recordval.AddressValidationOutput_v1 addressValidationOutput;
    }
    
    @InvocableMethod(label='Validate Address')
    public static List<Response> validateAddress(List<Request> requests) {
        system.debug('REQUEST: ' + requests[0]);
        
        recordval.RecordValidationAPI_v1 api = new recordval.RecordValidationAPI_v1();
        recordval.AddressValidationInput_V1 input = new recordval.AddressValidationInput_V1();
        recordval.AddressOptions_v1 addressOptions = new recordval.AddressOptions_v1();
        
        input.street = requests[0].street;
        input.housenumber = requests[0].housenumber;
        input.housenumberAddition = requests[0].housenumberAddition;
        input.postalcode = requests[0].postalcode;
        input.country = requests[0].country;

        addressOptions.housenumber = true;
        addressOptions.housenumberAddition = true;
        input.addressOptions = addressOptions;
        //input.note = 'demo';
        
        system.debug('INPUT: ' + input);
        List<Response> responseWrapper = new List<Response>();
        Response result = new Response();
        
        if(!Test.isRunningTest()){
            recordval.AddressValidationOutput_v1 output = api.validateAddress(input);
            System.debug(LoggingLevel.DEBUG, '***validateAddress AddressValidationOutput_v1: ' + output);
            System.debug(LoggingLevel.DEBUG, output.advice);
            
            result.addressValidationOutput = output;
            result.statusColour = String.valueOf(output.advice);
            result.statusCode = String.valueOf(output.addresses.get(0).status.code);
            result.fullAddress = String.valueOf(output.addresses.get(0).fullAddress);
            result.credit = output.addresses.get(0).status.credit;
            result.statusMessage = String.valueOf(output.addresses.get(0).status.message); 
        } else {
            String testRes = '[addresses=(Address_v1:[advice=GREEN, city=ZEEWOLDE, country=Netherlands, countryCode=NL, fullAddress=Test  123, 3871 BK  ZEEWOLDE, housenumber=null, housenumberAddition=null, postalCode=3891 BK, state=Flevoland, stateCode=0012, status=Status_v1:[code=594, credit=true, message=Current address is verified up to Housenumber level.], street=Horlo  57]), advice=GREEN, status=Status_v1:[code=560, credit=true, message=Validation succeeded]]';
            String addressValidationOutputString = '{"addresses": [{"street": "Groenestraat","housenumber": "5","housenumberAddition": "","state": "Utrecht","city": "Utrecht","postalCode": "3512 PV","country": "Netherlands","countryCode": "NL","fullAddress": "Groenestraat  5, 3512 PV  UTRECHT","status": {"code": "594","message": "Current address is verified up to Housenumber level.","credit": true},"advice": "GREEN"}],"status": {"code": "560","message": "Validation succeeded","credit": true},"advice": "GREEN"}';

            result.statusColour = 'GREEN';
            result.statusCode = '594';
            result.fullAddress = 'DePijp 22, 1224AM  AMSTERDAM';
            result.credit = true;
            result.statusMessage = 'Current address is verified up to Housenumber level.';
            recordval.AddressValidationOutput_v1 addressValidationOutputType= new recordval.AddressValidationOutput_v1();
            recordval.Address_v1 addresses = new recordval.Address_v1();
            addresses.city = 'Amsterdam';
            addresses.country = 'Netherlands';
            addresses.countryCode = 'NL';
            addresses.housenumber = '22';
            addresses.postalCode = '1224AM';
            addresses.state = 'AM';
            addresses.street = 'DePijp';
            recordval.Status_v1 status = new recordval.Status_v1();
            status.code = '594';
            status.credit = true;
            status.message = 'Current address is verified up to Housenumber level.';
            addresses.status = status;
            List<recordval.Address_v1> addressesList = new List<recordval.Address_v1>();
            addressesList.add(addresses);
            addressValidationOutputType.addresses = addressesList;
            result.addressValidationOutput = addressValidationOutputType;
        }

        system.debug('RESPONSE: ' + result);
        
        responseWrapper.add(result);
        return responseWrapper;
    }
    
    public static Boolean updateOrdersANDOrderItems(String addressId, Boolean isValid){
        List<Order> orderLs = [SELECT Id, BillToAddress__c, ShipToAddress__c FROM Order WHERE (Status = 'Draft' OR Status = 'Under Review') AND (BillToAddress__c =: addressId OR ShipToAddress__c =: addressId)]; 
        List<OrderItem> orderItemLs = [Select Id, ShipToAddress__c FROM OrderItem WHERE (OrderStatus__c = 'Draft' OR OrderStatus__c = 'Under Review') AND ShipToAddress__c =: addressId];
        System.debug('Order list: ' + orderLs);
        system.debug('Order items: ' + orderItemLs);
        
        for(Order ord : orderLs){
            if(ord.BillToAddress__c == addressId && ord.ShipToAddress__c != addressId){
                System.debug('Billing valid: ' + isValid);
                ord.BillToAddressValidated__c = isValid;
            } else if (ord.BillToAddress__c == addressId && ord.ShipToAddress__c == addressId){
                // both must be validated
                ord.BillToAddressValidated__c = isValid;
                ord.ShipToAddressValidated__c = isValid;
            } else {
                // means shiptoaddress = addressId
                System.debug('Shipping valid: ' + isValid);
                ord.ShipToAddressValidated__c = isValid;
            }
        }
        
        for(OrderItem ordItem : orderItemLs){
            ordItem.ShipToAddressValidated__c = isValid;
        }
        
        try {
            update orderLs;
            update orderItemLs;
            
            return true;
        } catch(Exception exc){
            system.debug('EXCEPTION: ' + exc);
            
            return false;
        }
    }
    
}