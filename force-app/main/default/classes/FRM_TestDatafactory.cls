@IsTest
public class FRM_TestDatafactory {
    
    public static List<Product2> createProducts(Boolean doInsert) {
        List<Product2> products = new List<product2>();

        List<String> opcoList = new List<String>{'Plantyn','Noordhoff','Liber'};

        for (Integer i = 0; i < 10; i++) {
            
            for (String opco : opcoList) {
                Product2 prod = new Product2();
                prod.Subsidiary__c = opco;
                prod.Name = 'TestProduct ' + opco + ' ' + (i+1);
                prod.ISBN__c = '123456' + i;
                prod.Stocknumber__c = 10;
                prod.Type__c = 'Inventory Item';
                if (opco == 'Liber') {
                    prod.FirstPublicationDate__c = Date.today().addMonths(-1);
                } else {
                    prod.FirstPublicationDate__c = Date.today().addDays(-1);
                }

                products.add(prod);
            }
        }

        if (doInsert) {
            insert products;
        }

        return products;
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
            acc.Area__c = 'Dutch';
            acc.ConverseImport__c = 'Plantyn Converse migration';
            AccountList.Add(Acc);
        }
        // [0] Plantyn
        accountList[0].ExternalDatabase__c = 'Agodi';
        accountList[0].ExternalCustomerId__c = '123456';

        //[1] Noordhoff
        accountList[1].OperatingCompany__c = 'Noordhoff';
        accountList[1].ExternalDatabase__c = 'RIO';
        accountList[1].ExternalCustomerId__c = '654321';

        //[2] Liber
        accountList[2].OperatingCompany__c = 'Liber';
        accountList[2].ExternalCustomerId__c = '987654';

        if (doInsert) {
            insert accountList;
        }

        return accountList;
    }

    public static list<firstReleasePartner__c> createFirstReleasePartners(List<Account> accountList, Boolean doInsert) {
        List<firstReleasePartner__c> firstReleasePartners = new list<firstReleasePartner__c>();

        for (Account acc : accountList) {
            firstReleasePartner__c frp = new firstReleasePartner__c();
            //frp.Quantity__c = 2;
            frp.Account__c = acc.Id;

            firstReleasePartners.add(frp);
        }

        if (doInsert) {
            insert firstReleasePartners;
        }

        return firstReleasePartners;
    }

}