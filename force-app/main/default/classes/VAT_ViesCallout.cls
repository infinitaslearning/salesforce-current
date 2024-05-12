public class VAT_ViesCallout {

    @future(callout=true)
    public static void MakeCallout(List<String> paramList) {

        List<Account> accountsForUpdate = new List<Account>();

        for (String param : paramList) {

            List<String> params = param.split(';');

            Id accountId = Id.valueOf(params[0]);
            String countryCode = params[1];
            String vatNumber = params[2];

            System.debug('VAT_ViesCallout - MakeCallout (accountId: ' + accountId + ', countryCode: ' + countryCode + ', vatNumber: ' + vatNumber + ')');

            Boolean isRsinNumber = false;

            if (countryCode == 'NL' && vatNumber.length() == 9) {
                isRsinNumber = true;
            }

            String vatNumberForCheck = '';
            // Clean up VAT number
            if (vatNumber.left(countryCode.length()).capitalize() == countryCode) {
                if (vatNumber.right(vatNumber.length() - countryCode.length()).left(1) == ' ') {
                    System.debug('vatNumber.right(vatNumber.length() - (countryCode.length() + 1)).replace(\'.\', \'\').replace(\' \', \'\') = ' + vatNumber.right(vatNumber.length() - (countryCode.length() + 1)).replace('.', '').replace(' ', ''));
                    vatNumberForCheck = vatNumber.right(vatNumber.length() - (countryCode.length() + 1)).replace('.', '').replace(' ', '');
                } else {
                    System.debug('vatNumber.right(vatNumber.length() - countryCode.length()) = ' + vatNumber.right(vatNumber.length() - countryCode.length()));
                    System.debug('vatNumber.right(vatNumber.length() - countryCode.length()).replace(\'.\', \'\').replace(\' \', \'\') = ' + vatNumber.right(vatNumber.length() - countryCode.length()).replace('.', '').replace(' ', ''));
                    vatNumberForCheck = vatNumber.right(vatNumber.length() - countryCode.length()).replace('.', '').replace(' ', '');
                }
                
            } else {
                vatNumberForCheck = vatNumber.replace('.', '').replace(' ', '');
            }

            System.debug('VAT variables for callout:');
            System.debug('countryCode: ' + countryCode);
            System.debug('vatNumberForCheck: ' + vatNumberForCheck);

            VAT_Vies_WDSL.checkVatResponse_element resp = new VAT_Vies_WDSL.checkVatResponse_element();

            if (isRsinNumber) {
                vatNumberForCheck += 'B01';
            }

            String err = '';
            // make callout to VIES for VAT Check
            try {
                VAT_Vies_WDSL.checkVatPort vatCheck = new VAT_Vies_WDSL.checkVatPort ();
                resp = vatCheck.checkVat(countryCode,vatNumberForCheck);
            } catch (Exception e) {
                err = e.getMessage();
            } 
            
            // TEMP
            System.debug('FULL RESPONSE: ' + resp);
            // END TEMP
            
            System.debug('Response:');
            System.debug('countryCode: ' + resp.countryCode);
            System.debug('vatNumber: ' + resp.vatNumber);
            System.debug('requestDate: ' + resp.requestDate);
            System.debug('valid: ' + resp.valid);
            System.debug('name: ' + resp.name);
            System.debug('address: ' + resp.address);

            Account accountForUpdate = new Account();
            accountForUpdate.id = accountId;

            if(err.length() > 1) {
                accountForUpdate.VATStatus__c = 'Error';
                accountForUpdate.VATErrorMessage__c = err;
            } else if (resp.valid) {
                accountForUpdate.VATStatus__c = 'Correct';
                if (isRsinNumber) {
                    accountForUpdate.VATNumber__c = resp.vatNumber;
                }
            } else {
                accountForUpdate.VATStatus__c = 'Incorrect';
            }
            accountsForUpdate.add(accountForUpdate);
        }
        
        update accountsForUpdate;
    }
}