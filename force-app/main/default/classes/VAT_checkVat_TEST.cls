@IsTest
public class VAT_checkVat_TEST {

    @IsTest
    static void testInsert(){

        Account[] accounts = createAccounts(false);
        for (Integer i = 0; i < accounts.size(); i++) {
            accounts[i].VATNumber__c = 'NL12345678B0' + (i+1);
        }
        

        Test.startTest();
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            insert accounts;
        Test.stopTest();
        
    }
    
    @IsTest
    static void testUpdate(){
        
        Account[] accounts = createAccounts(true);
        for (Integer i = 0; i < accounts.size(); i++) {
            accounts[i].VATNumber__c = 'NL12345678B0' + (i+1);
        }

        Test.startTest();
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            update accounts;
        Test.stopTest();
        
    }

    public static List<Account> createAccounts(Boolean doInsert) {

        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

        List<Account> accountList = new List<Account>();
        for (Integer i=0; i < 3; i++) {
            Account Acc = new Account();
            Acc.RecordTypeId = recordTypeId;
            Acc.Name = 'School '+ (i+1);
            Acc.OperatingCompany__c = 'Plantyn';
            acc.CustomerCategory__c = 'Educational Institution';
            //Acc.CustomerDiscountGroup__c = acc.CustomerCategory__c;
            Acc.NetsuiteInternalId__c = '1234'+i;
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.BillingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22';
            Acc.invoicingEmail__c = 'test@test.be';
            Acc.Phone = '+123456789';
            Acc.Website = 'http://www.testwebsite.be';
            Acc.Type = 'Customer';
            Acc.ExternalDatabase__c = 'Agodi';
            acc.Area__c = 'Dutch';
            acc.ConverseImport__c = 'Plantyn Converse migration';
            AccountList.Add(Acc);
        }
        accountList[0].ExternalCustomerId__c = '123456';
        accountList[1].ExternalCustomerId__c = '654321';
        accountList[2].ExternalCustomerId__c = '987654';

        if (doInsert) {
            insert accountList;
        }

        return accountList;
    }

    public class WebServiceMockImpl implements WebServiceMock {

        public void doInvoke (
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

            //Map<String, VAT_Vies_WDSL.checkVatResponse_element> response_map_x = new Map<String, VAT_Vies_WDSL.checkVatResponse_element>();
            VAT_Vies_WDSL.checkVatResponse_element resp = new VAT_Vies_WDSL.checkVatResponse_element();

            resp.countryCode = 'BE';
            resp.vatNumber = 'NL12345678B0';
            resp.requestDate = Date.today();
            resp.valid = true;
            resp.name = 'School';
            resp.address = 'DePijp22\n1224AM Amsterdam';

            response.put('response_x', resp);
            
        }
    }
}