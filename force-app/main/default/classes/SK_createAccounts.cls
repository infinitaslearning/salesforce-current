public class SK_createAccounts implements Queueable {
    
    public List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetails;
    public List<Account> accounts;
    public Map<String,Account> liberAccounts;

    public SK_createAccounts(List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList, Map<String,Account> liberAccountMap) {
        this.schoolDetails = schoolDetailList;
        this.accounts = new List<Account>();
        this.liberAccounts = liberAccountMap;
    }

    public SK_createAccounts(List<SK_SkolverketUpdateByAPI.schoolDetails> schoolDetailList, List<Account> accountList, Map<String,Account> liberAccountMap) {
        this.schoolDetails = schoolDetailList;
        this.accounts = accountList;
        this.liberAccounts = liberAccountMap;
    }

    public void execute(QueueableContext context) {

        if (schoolDetails.size() != 0) {

            // set basic variables
            Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;
            Date todaysDate = Date.today();

            for (SK_SkolverketUpdateByAPI.schoolDetails sd : schoolDetails) {

                // ALWAYS
                Account a = new Account();
                a.LegalName__c = sd.Namn;
                a.AgodiUpdateInProgress__c = true;

                // ONLY ON UPDATE
                if (this.liberAccounts.get(sd.Skolenhetskod) != null) {
                    a.Id = this.liberAccounts.get(sd.Skolenhetskod).Id;
                    a.DataMigrationHistory__c = 'Skolverket Update - ' + todaysDate;
                } 
                
                // ONLY ON INSERT
                else {
                    a.DataMigrationHistory__c = 'Skolverket Insert - ' + todaysDate;
                    a.RecordTypeId = recordTypeId;
                    a.AccountSource = 'Skolverket';
                    a.ExternalDatabase__c = 'Skolverket';
                    a.ExternalCustomerId__c = sd.Skolenhetskod;
                    a.Name = sd.Namn;
                    a.OperatingCompany__c = 'Liber';
                    a.PhoneCountry__c = 'Sweden';
                    a.CommunicationLanguage__c = 'sv_SE';
                    a.Courier__c = 'SCH | Schenker regelverk';
                    a.DeliveryRouting__c = 'LIBSCH';
                    if (sd.Telefon != null) {
                        a.Phone = sd.Telefon.replace('-','').replace('.','').replace('/','').replace(' ','');
                    }
                    if (sd.Epost != null) {
                        String emailAdres = sd.Epost;
                        a.InvoicingEmail__c = emailAdres;
                        a.OrderNotificationEmail__c = emailAdres;
                        a.BillingReminderEmail__c = emailAdres;
                        a.DigitalActivationEmail__c = emailAdres;
                    }
                    if (sd.Besoksadress?.Adress != null) {
                        a.BillingStreet = sd.Besoksadress?.Adress;
                        if (sd.Leveransadress?.Adress != null) {
                            a.ShippingStreet = sd.Leveransadress?.Adress;
                        } else {
                            a.ShippingStreet = sd.Besoksadress?.Adress;
                        }
                    }
                    if (sd.Besoksadress?.Postnr != null) {
                        a.BillingPostalCode = sd.Besoksadress?.Postnr;
                        if (sd.Leveransadress?.Postnr != null) {
                            a.ShippingPostalCode = sd.Leveransadress?.Postnr;
                        } else {
                            a.ShippingPostalCode = sd.Besoksadress?.Postnr;
                        }
                    }
                    if (sd.Besoksadress?.Ort != null) {
                        a.BillingCity = sd.Besoksadress?.Ort;
                        if (sd.Leveransadress?.Ort != null) {
                            a.ShippingCity = sd.Leveransadress?.Ort;
                        } else {
                            a.ShippingCity = sd.Besoksadress?.Ort;
                        }
                    }
                    a.BillingCountry = 'Sweden';
                    a.ShippingCountry = 'Sweden';
                    a.ShippingCostMethod__c = 'Based on weight Domestic';
                    if (sd.Webbadress != null && sd.Webbadress != '') {
                        if (sd.Webbadress.left(4) == 'http') {
                            a.Website = sd.Webbadress;
                        } else {
                            a.Website = 'Http://' + sd.Webbadress;
                        }
                    }
                    a.CustomerCategory__c = 'Educational Institution';
                    a.CustomerDiscountGroup__c = a.CustomerCategory__c;
                }
                accounts.add(a);
            }
        }

        System.debug('Starting SK_createAccounts_Batch for ' + accounts.size() + ' Accounts.');

        SK_createAccounts_Batch  createAccounts = new SK_createAccounts_Batch(accounts);
        Id batchprocessid = Database.executebatch(createAccounts, 5);
    }
}