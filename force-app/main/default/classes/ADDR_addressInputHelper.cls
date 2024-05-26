public class ADDR_addressInputHelper {
    
    @AuraEnabled(cacheable = true)
    public static Account getAddressDetails(String accountId){
        System.debug(LoggingLevel.INFO, 'ADDR_addressInputHelper - getAddressDetails ('+ accountId + ')');
        
        Account acc = [SELECT 
            BillingStreet, 
            BillingCity, 
            BillingPostalCode, 
            BillingCountry, 
            BillingState, 
            ShippingStreet, 
            ShippingCity, 
            ShippingPostalCode, 
            ShippingCountry,
            ShippingState 
            FROM Account WHERE Id = :accountId];

        return acc;
    }

    @AuraEnabled
    public static String saveBillingAddress(String accountId, String billingStreet, String billingPostalCode, String billingCity, String billingState, String billingCountry) {
    System.debug(LoggingLevel.INFO, 'ADDR_addressInputHelper - saveBillingAddress ('+ accountId + ', ' + billingStreet + ', ' + billingPostalCode +', ' + billingCity + ', ' + billingState + ', ' + billingCountry + ')');

        String result = '';

        Account acc = new Account();
        acc.Id = accountId;
        acc.BillingStreet = billingStreet;
        acc.BillingPostalCode = billingPostalCode;
        acc.BillingCity = billingCity;
        if (billingState != null) {
            acc.BillingState = billingState;
        }
        acc.BillingCountry = billingCountry;

        Database.SaveResult sr = Database.update(acc, false);

        if (sr.isSuccess()) {
            result = 'success';
        } else {
            for (Database.Error err : sr.getErrors()) {
                result += 'Error: ' + err.getMessage();
            }
        }

        System.debug('Results ==> ' + result);

        return result;
    }

    @AuraEnabled
    public static String saveShippingAddress(String accountId, String shippingStreet, String shippingPostalCode, String shippingCity, String shippingState, String shippingCountry) {
    System.debug(LoggingLevel.INFO, 'ADDR_addressInputHelper - saveShippingAddress ('+ accountId + ', ' + shippingStreet + ', ' + shippingPostalCode +', ' + shippingCity + ', ' + shippingState + ', ' + shippingCountry + ')');

        String result = '';

        Account acc = new Account();
        acc.Id = accountId;
        acc.ShippingStreet = shippingStreet;
        acc.ShippingPostalCode = shippingPostalCode;
        acc.ShippingCity = shippingCity;
        if (shippingState != null) {
            acc.ShippingState = shippingState;
        }
        acc.ShippingCountry = shippingCountry;

        Database.SaveResult sr = Database.update(acc, false);

        if (sr.isSuccess()) {
            result = 'success';
        } else {
            for (Database.Error err : sr.getErrors()) {
                result += 'Error: ' + err.getMessage();
            }
        }

        System.debug('Results ==> ' + result);

        return result;
    }

}