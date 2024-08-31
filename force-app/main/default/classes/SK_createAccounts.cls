public class SK_createAccounts {

    public static Account createAccount(SK_SkolverketUpdateByAPI.schoolDetails sd, Map<String,Account> liberAccounts) {

        // set basic variables
        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        Date todaysDate = Date.today();

        // ALWAYS
        Account a = new Account();
        a.LegalName__c = sd.Namn;
        a.AgodiUpdateInProgress__c = true;

        // ONLY ON UPDATE
        if (liberAccounts.get(sd.Skolenhetskod) != null) {
            a.Id = liberAccounts.get(sd.Skolenhetskod).Id;
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
                System.debug('ORIGINAL PHONE ==> ' + sd.Telefon);
                a.Phone = sd.Telefon.replace('-','').replace('.','').replace('/','').replace(' ','');
                While(a.Phone.left(1) == '0') {
                    a.Phone = a.Phone.substring(1);
                }
                if (a.Phone.left(1) != '+') {
                    a.Phone = '+' + a.Phone;
                }
                System.debug('PHONE ==> ' + a.Phone);
                System.debug('Phone Regex Match ==> ' + Pattern.matches('^\\+[1-9]\\d{1,14}$', a.Phone));
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
            if (sd.Kommun != null) {
                if (sd.kommun.Kommunkod != null & sd.kommun.Kommunkod != '') {
                    a.MunicipalityCode__c = sd.Kommun.Kommunkod;
                }
                if (sd.kommun.Namn != null && sd.kommun.Namn != '') {
                    a.MunicipalityName__c = sd.Kommun.Namn;
                }
            }
            a.BillingCountry = 'Sweden';
            a.ShippingCountry = 'Sweden';
            a.ShippingCostMethod__c = 'Based on weight Domestic';
            if (sd.Webbadress != null && sd.Webbadress != '') {
                if (sd.Webbadress.left(4).toLowerCase() == 'http') {
                    a.Website = sd.Webbadress.toLowerCase();
                } else {
                    a.Website = 'http://' + sd.Webbadress.toLowerCase();
                }
                System.debug('Webadress ==> ' + a.Website);
            }
            a.CustomerCategory__c = 'Educational Institution';
            a.CustomerDiscountGroup__c = a.CustomerCategory__c;
            if (sd.Skolformer.size() > 0) {
                String schoolProgramString = createSchoolProgramString(sd.Skolformer);
                if (schoolProgramString.length() > 1) {
                    a.SchoolPrograms__c = schoolProgramString;
                }
                String classificationString = createClassificationString(sd.Skolformer);
                if (classificationString.length() > 1) {
                    a.Classification__c = classificationString;
                }
            }
        }
        return a;
    }

    public static String createClassificationString(List<SK_SkolverketUpdateByAPI.Skolformer> sfList) {
        
        List<String> classificationList = new List<String>();
        Boolean Gymnasieskola = false;
        Boolean Grundskola = false;
        Boolean Specialskola = false;
        Boolean Sameskola = false;

        for (SK_SkolverketUpdateByAPI.Skolformer sf : sfList) {
            switch on sf.SkolformKod {
                when '1' {
                    Gymnasieskola = true;
                }
                when '5' {
                    Grundskola = true;
                }
                when '12' {
                    Specialskola = true;
                }
                when '15' {
                    Sameskola = true;
                }
            }
        }

        if (Gymnasieskola) {
            classificationList.add('Gymnasium/Vuxenutbildning');
        }
        if (Grundskola) {
            classificationList.add('Primary');
        }
        if (Specialskola) {
            classificationList.add('Primary');
        }
        if (Sameskola) {
            classificationList.add('Primary'); 
        }

        return String.join(classificationList, ';');
    }

    public static String createSchoolProgramString(List<SK_SkolverketUpdateByAPI.Skolformer> sfList) {

        Map<String, String> skolformerCodeTranslations = new Map<String, String>{
            'BA'    =>  'Bygg- och anläggningsprogrammet',
            'BF'    =>  'Barn- och fritidsprogrammet',
            'EE'    =>  'El- och energiprogrammet',
            'EK'    =>  'Ekonomiprogrammet',
            'ES'    =>  'Estetiska programmet',
            'FS'    =>  'Försäljnings- och serviceprogrammet',
            'FT'    =>  'Fordons- och transportprogrammet',
            'FX'    =>  'Flygteknikutbildningen',
            'HA'    =>  'Handels- och administrationsprogrammet',
            'HT'    =>  'Hotell- och turismprogrammet',
            'HU'    =>  'Humanistiska programmet',
            'HV'    =>  'Hantverksprogrammet',
            'I_P'   =>  'Industritekniska programmet',
            'MX'    =>  'Marinteknikutbildningen',
            'NA'    =>  'Naturvetenskapsprogrammet',
            'NB'    =>  'Naturbruksprogrammet',
            'RL'    =>  'Restaurang- och livsmedelsprogrammet',
            'SA'    =>  'Samhällsvetenskapsprogrammet',
            'SX'    =>  'Sjöfartsutbildningen',
            'TE'    =>  'Teknikprogrammet',
            'TX'    =>  'Tågteknikutbildningen',
            'UX'    =>  'Utbildningen samiska näringar',
            'VF'    =>  'VVS- och fastighetsprogrammet',
            'VO'    =>  'Vård- och omsorgsprogrammet',
            'YX'    =>  'Yrkesdansarutbildningen'
        };

        List<String> schoolProgramList = new List<String>();
        for (SK_SkolverketUpdateByAPI.Skolformer sf : sfList) {
            if (sf.SkolformKod == '1') {

                if (sf.BA) {
                    schoolProgramList.add(skolformerCodeTranslations.get('BA'));
                }
                if (sf.BF) {
                    schoolProgramList.add(skolformerCodeTranslations.get('BF'));
                }
                if (sf.EE) {
                    schoolProgramList.add(skolformerCodeTranslations.get('EE'));
                }
                if (sf.EK) {
                    schoolProgramList.add(skolformerCodeTranslations.get('EK'));
                }
                if (sf.ES) {
                    schoolProgramList.add(skolformerCodeTranslations.get('ES'));
                }
                if (sf.FS) {
                    schoolProgramList.add(skolformerCodeTranslations.get('FS'));
                }
                if (sf.FT) {
                    schoolProgramList.add(skolformerCodeTranslations.get('FT'));
                }
                if (sf.FX) {
                    schoolProgramList.add(skolformerCodeTranslations.get('FX'));
                }
                if (sf.HA) {
                    schoolProgramList.add(skolformerCodeTranslations.get('HA'));
                }
                if (sf.HT) {
                    schoolProgramList.add(skolformerCodeTranslations.get('HT'));
                }
                if (sf.HU) {
                    schoolProgramList.add(skolformerCodeTranslations.get('HU'));
                }
                if (sf.HV) {
                    schoolProgramList.add(skolformerCodeTranslations.get('HV'));
                }
                if (sf.I_P) {
                    schoolProgramList.add(skolformerCodeTranslations.get('I_P'));
                }
                if (sf.MX) {
                    schoolProgramList.add(skolformerCodeTranslations.get('MX'));
                }
                if (sf.NA) {
                    schoolProgramList.add(skolformerCodeTranslations.get('NA'));
                }
                if (sf.NB) {
                    schoolProgramList.add(skolformerCodeTranslations.get('NB'));
                }
                if (sf.RL) {
                    schoolProgramList.add(skolformerCodeTranslations.get('RL'));
                }
                if (sf.SA) {
                    schoolProgramList.add(skolformerCodeTranslations.get('SA'));
                }
                if (sf.SX) {
                    schoolProgramList.add(skolformerCodeTranslations.get('SX'));
                }
                if (sf.TE) {
                    schoolProgramList.add(skolformerCodeTranslations.get('TE'));
                }
                if (sf.TX) {
                    schoolProgramList.add(skolformerCodeTranslations.get('TX'));
                }
                if (sf.UX) {
                    schoolProgramList.add(skolformerCodeTranslations.get('UX'));
                }
                if (sf.VF) {
                    schoolProgramList.add(skolformerCodeTranslations.get('VF'));
                }
                if (sf.VO) {
                    schoolProgramList.add(skolformerCodeTranslations.get('VO'));
                }
                if (sf.YX) {
                    schoolProgramList.add(skolformerCodeTranslations.get('YX'));
                }

            }
        }


        return String.join(schoolProgramList,';');
    }
}