@IsTest
public class SK_TestDataFactory {

    public static List<Account> createAccounts(Integer amount, Boolean doInsert) {

        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

        List<Account> accountList = new List<Account>();
        for (Integer i=0; i < amount; i++) {
            Account Acc = new Account();
            Acc.RecordTypeId = recordTypeId;
            Acc.Name = 'School '+ (i+1);
            Acc.OperatingCompany__c = 'Liber';
            acc.CustomerCategory__c = 'Educational Institution';
            Acc.NetsuiteInternalId__c = '1234'+i;
            Acc.ShippingCity = 'Stockholm';
            Acc.ShippingCountry = 'Sweden';
            Acc.BillingCountry = 'Sweden';
            Acc.ShippingPostalCode = '83120';
            Acc.ShippingStreet = 'testStreet 01';
            Acc.invoicingEmail__c = 'test@test.se';
            Acc.Phone = '+123456789';
            Acc.Website = 'http://www.testwebsite.se';
            Acc.Type = 'Customer';
            Acc.ExternalDatabase__c = 'Skolverket';
            AccountList.Add(Acc);
        }
        accountList[0].ExternalCustomerId__c = '123456';
        accountList[1].ExternalCustomerId__c = '654321';
        accountList[2].ExternalCustomerId__c = '12345678';

        if (doInsert) {
            insert accountList;
        }

        return accountList;
    }

    public static SK_SkolverketUpdateByAPI.schoolDetails createSchoolDetail () {
           
            SK_SkolverketUpdateByAPI.Besoksadress ba = new SK_SkolverketUpdateByAPI.Besoksadress();
                ba.Adress = 'Test Billing Street 4';
                ba.Postnr = '12345';
                ba.Ort = 'Test City';
            
            SK_SkolverketUpdateByAPI.Leveransadress la = new SK_SkolverketUpdateByAPI.Leveransadress();
                la.Adress = 'Test Shipping Street 4';
                la.Postnr = '54321';
                la.Ort = 'Test City';

            SK_SkolverketUpdateByAPI.Kommun komm = new SK_SkolverketUpdateByAPI.Kommun();
            Komm.Kommunkod = '1800';
            Komm.Namn = 'Stockholm';

            List<SK_SkolverketUpdateByAPI.Skolformer> sfLst = new List<SK_SkolverketUpdateByAPI.Skolformer>();
            SK_SkolverketUpdateByAPI.Skolformer sf1 = new SK_SkolverketUpdateByAPI.Skolformer();
                sf1.SkolformKod = '1';
                sf1.BA = true;
                sf1.BF = true;
                sf1.EE = true;
                sf1.EK = true;
                sf1.ES = true;
                sf1.FS = true;
                sf1.FT = true;
                sf1.FX = true;
                sf1.HA = true;
                sf1.HT = true;
                sf1.HU = true;
                sf1.HV = true;
                sf1.I_P = true;
                sf1.MX = true;
                sf1.NA = true;
                sf1.NB = true;
                sf1.RL = true;
                sf1.SA = true;
                sf1.SX = true;
                sf1.TE = true;
                sf1.TX = true;
                sf1.UX = true;
                sf1.VF = true;
                sf1.VO = true;
                sf1.YX = true;
                sfLst.add(sf1);
            SK_SkolverketUpdateByAPI.Skolformer sf2 = new SK_SkolverketUpdateByAPI.Skolformer();
                sf2.SkolformKod = '5';
                sfLst.add(sf2);
            SK_SkolverketUpdateByAPI.Skolformer sf3 = new SK_SkolverketUpdateByAPI.Skolformer();
                sf3.SkolformKod = '12';
                sfLst.add(sf3);
            SK_SkolverketUpdateByAPI.Skolformer sf4 = new SK_SkolverketUpdateByAPI.Skolformer();
                sf4.SkolformKod = '15';
                sfLst.add(sf4);


            SK_SkolverketUpdateByAPI.schoolDetails sd = new SK_SkolverketUpdateByAPI.schoolDetails();
                sd.Namn = 'Test Name From API';
                sd.Skolenhetskod = '12345678';
                sd.Telefon = '123456789';
                sd.Webbadress = 'http://testwebaddress.com';
                sd.Epost = 'Test@testEmail.se';
                sd.Besoksadress = ba;
                sd.Leveransadress = la;
                sd.Skolformer = sfLst;
                sd.Kommun = komm;


        return sd;
    }
    
    public class Mock implements HttpCalloutMock {
        
        public HttpResponse respond (HttpRequest req) {

            String endpoint = req.getEndpoint();
            String body = '';

            if (endpoint == 'https://api.skolverket.se/skolenhetsregistret/v1/skolenhet') {
                body = '{"Uttagsdatum": "2023-07-21T00:00:00.1579653+02:00","Fotnot": null,"Skolenheter": [{"Skolenhetskod": "12345678","Kommunkod": "0581","PeOrgNr": "5567026454","Skolenhetsnamn": "Prolympia, Norrköping","Status": "Aktiv"},{"Skolenhetskod": "33468088","Kommunkod": "2510","PeOrgNr": "5567857262","Skolenhetsnamn": "Vuollerims Friskola","Status": "Aktiv"},{"Skolenhetskod": "52152242","Kommunkod": "1494","PeOrgNr": "2120001694","Skolenhetsnamn": "Rudenschöldskolan","Status": "Aktiv"}]}';
            } else {
                body = '{"Uttagsdatum": "2023-07-21T00:30:11.9666933+02:00","Fotnot": null,"SkolenhetInfo": {"Namn": "TestName","Rektorsnamn": "Test Name","Skolenhetskod": "12345678","Epost": "test@test.com","Telefon": "0157-123456","Webbadress": "http://www.test.com","Besoksadress": {"Adress": "testStraat 1A","Postnr": "12345","Ort": "Flen","GeoData": {"Koordinat_SweRef_E": "590513,793","Koordinat_SweRef_N": "6547551,337","Koordinat_WGS84_Lat": "59.05774559999999","Koordinat_WGS84_Lng": "16.578196700000035","Punkttyp": null}},"Leveransadress": {"Adress": null,"Postnr": null,"Ort": null},"Utdelningsadress": {"Adress": "testStraat 1A","Postnr": "12345","Ort": "Flen"},"Inriktningstyp": "Ej relevant","Skolenhetstyp": "Skolenhet","SkolaNamn": null,"Skolformer": [{"type": "Grundskola","Benamning": "Grundskola","SkolformID": 5,"SkolformKod": "11","Ak1": false,"Ak2": false,"Ak3": false,"Ak4": true,"Ak5": true,"Ak6": true,"Ak7": false,"Ak8": false,"Ak9": false,"Resursskola": false,"Sjukhusskola": false}],"Kommun": {"Kommunkod": "0482","Namn": "Flen"},"Huvudman": {"PeOrgNr": "2120000332","Namn": "FLENS KOMMUN","Typ": "Kommun"},"Skolenhet_ValidFrom": "2022-12-01T00:00:00","Status": "Aktiv","Startdatum": "2018-07-01","Nedlaggningsdatum": "2023-06-30"}}';
            }

            HttpResponse res = new HttpResponse();
            res.setBody(body);
            res.setStatusCode(200);

            return res;
        }
    }

    public class badMock01 implements HttpCalloutMock {
        
        public HttpResponse respond (HttpRequest req) {

            String endpoint = req.getEndpoint();
            String body = '';

            if (endpoint == 'https://api.skolverket.se/skolenhetsregistret/v1/skolenhet') {
                body = '{"Uttagsdatum": "2023-07-21T00:00:00.1579653+02:00","Fotnot": null,"Skolenheter": [{"Skolenhetskod": "12345678","Kommunkod": "0581","PeOrgNr": "5567026454","Skolenhetsnamn": "Prolympia, Norrköping","Status": "Aktiv"},{"Skolenhetskod": "33468088","Kommunkod": "2510","PeOrgNr": "5567857262","Skolenhetsnamn": "Vuollerims Friskola","Status": "Aktiv"},{"Skolenhetskod": "52152242","Kommunkod": "1494","PeOrgNr": "2120001694","Skolenhetsnamn": "Rudenschöldskolan","Status": "Aktiv"}]}';
            } else {
                body = '{"Uttagsdatum": "2023-07-21T00:30:11.9666933+02:00","Fotnot": null,"SkolenhetInfo": {"Namn": "TestName","Rektorsnamn": "Test Name","Skolenhetskod": "12345678","Epost": "test@test.com","Telefon": "0157-123456","Webbadress": "http://www.test.com","Besoksadress": {"Adress": "testStraat 1A","Postnr": "12345","Ort": "Flen","GeoData": {"Koordinat_SweRef_E": "590513,793","Koordinat_SweRef_N": "6547551,337","Koordinat_WGS84_Lat": "59.05774559999999","Koordinat_WGS84_Lng": "16.578196700000035","Punkttyp": null}},"Leveransadress": {"Adress": null,"Postnr": null,"Ort": null},"Utdelningsadress": {"Adress": "testStraat 1A","Postnr": "12345","Ort": "Flen"},"Inriktningstyp": "Ej relevant","Skolenhetstyp": "Skolenhet","SkolaNamn": null,"Skolformer": [{"type": "Grundskola","Benamning": "Grundskola","SkolformID": 5,"SkolformKod": "11","Ak1": false,"Ak2": false,"Ak3": false,"Ak4": true,"Ak5": true,"Ak6": true,"Ak7": false,"Ak8": false,"Ak9": false,"Resursskola": false,"Sjukhusskola": false}],"Kommun": {"Kommunkod": "0482","Namn": "Flen"},"Huvudman": {"PeOrgNr": "2120000332","Namn": "FLENS KOMMUN","Typ": "Kommun"},"Skolenhet_ValidFrom": "2022-12-01T00:00:00","Status": "Aktiv","Startdatum": "2018-07-01","Nedlaggningsdatum": "2023-06-30"}}';
            }

            HttpResponse res = new HttpResponse();
            res.setBody(body);
            res.setStatusCode(400);

            return res;
        }
    }

    public class badMock02 implements HttpCalloutMock {
        
        public HttpResponse respond (HttpRequest req) {

            String endpoint = req.getEndpoint();
            String body = '';

            HttpResponse res = new HttpResponse();
            if (endpoint == 'https://api.skolverket.se/skolenhetsregistret/v1/skolenhet') {
                body = '{"Uttagsdatum": "2023-07-21T00:00:00.1579653+02:00","Fotnot": null,"Skolenheter": [{"Skolenhetskod": "12345678","Kommunkod": "0581","PeOrgNr": "5567026454","Skolenhetsnamn": "Prolympia, Norrköping","Status": "Aktiv"},{"Skolenhetskod": "33468088","Kommunkod": "2510","PeOrgNr": "5567857262","Skolenhetsnamn": "Vuollerims Friskola","Status": "Aktiv"},{"Skolenhetskod": "52152242","Kommunkod": "1494","PeOrgNr": "2120001694","Skolenhetsnamn": "Rudenschöldskolan","Status": "Aktiv"}]}';
                res.setStatusCode(200);
            } else {
                body = '{"Uttagsdatum": "2023-07-21T00:30:11.9666933+02:00","Fotnot": null,"SkolenhetInfo": {"Namn": "TestName","Rektorsnamn": "Test Name","Skolenhetskod": "12345678","Epost": "test@test.com","Telefon": "0157-123456","Webbadress": "http://www.test.com","Besoksadress": {"Adress": "testStraat 1A","Postnr": "12345","Ort": "Flen","GeoData": {"Koordinat_SweRef_E": "590513,793","Koordinat_SweRef_N": "6547551,337","Koordinat_WGS84_Lat": "59.05774559999999","Koordinat_WGS84_Lng": "16.578196700000035","Punkttyp": null}},"Leveransadress": {"Adress": null,"Postnr": null,"Ort": null},"Utdelningsadress": {"Adress": "testStraat 1A","Postnr": "12345","Ort": "Flen"},"Inriktningstyp": "Ej relevant","Skolenhetstyp": "Skolenhet","SkolaNamn": null,"Skolformer": [{"type": "Grundskola","Benamning": "Grundskola","SkolformID": 5,"SkolformKod": "11","Ak1": false,"Ak2": false,"Ak3": false,"Ak4": true,"Ak5": true,"Ak6": true,"Ak7": false,"Ak8": false,"Ak9": false,"Resursskola": false,"Sjukhusskola": false}],"Kommun": {"Kommunkod": "0482","Namn": "Flen"},"Huvudman": {"PeOrgNr": "2120000332","Namn": "FLENS KOMMUN","Typ": "Kommun"},"Skolenhet_ValidFrom": "2022-12-01T00:00:00","Status": "Aktiv","Startdatum": "2018-07-01","Nedlaggningsdatum": "2023-06-30"}}';
                res.setStatusCode(400);
            }

            res.setBody(body);

            return res;
        }
    }
}