@IsTest
public class AU_TestDataFactory {
    
    public static List<Account> createAccounts(Boolean doInsert) {

        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

        List<Account> accountList = new List<Account>();
        for (Integer i=0; i < 3; i++) {
            Account Acc = new Account();
            Acc.RecordTypeId = recordTypeId;
            Acc.Name = 'School '+ (i+1);
            Acc.OperatingCompany__c = 'Plantyn';
            acc.CustomerCategory__c = 'Educational Institution';
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

    public static List<Account> createMultipleAccounts(Integer amount, Boolean doInsert) {

        Id recordTypeId = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;

        List<Account> accountList = new List<Account>();
        for (Integer i=0; i < amount; i++) {
            Account Acc = new Account();
            Acc.RecordTypeId = recordTypeId;
            Acc.Name = 'School '+ (i+1);
            Acc.OperatingCompany__c = 'Plantyn';
            acc.CustomerCategory__c = 'Educational Institution';
            Acc.NetsuiteInternalId__c = String.valueOf(12345+i);
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.BillingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22';
            Acc.invoicingEmail__c = 'test' + (i+1) + '@test.be';
            Acc.Phone = '+123456789';
            Acc.Website = 'http://www.testwebsite.be';
            Acc.Type = 'Customer';
            Acc.ExternalDatabase__c = 'Agodi';
            acc.ExternalCustomerId__c = String.valueOf(12345+i);
            acc.Area__c = 'Dutch';
            acc.ConverseImport__c = 'Plantyn Converse migration';
            AccountList.Add(Acc);
        }

        if (doInsert) {
            insert accountList;
        }

        return accountList;
    }

    public class Mock implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest req) {

            String baseEndpoint = 'https://onderwijs.api.vlaanderen.be/instellingsgegevens/instelling/v2/instelling';
            String key = 'eBVx7fy6T3iEaZMLjGjUUPiKaSDT9rSG';

            String inrichtendemachtenInstellingsType = '300';
            String scholengemeenschappenInstellingsType = '400';
            List<String> scholenInstellingsType = new List<String>{'1200','1100','1000','900','700','600','500','200','151','142','141','135','134','133','132','131','126','125','124','123','122','121','116','115','113','112','111'};
            
            String body = '';

            String endPoint = req.getEndpoint();
            String typeFromEndpoint = endPoint.SubString(endPoint.IndexOf('=')+1,endPoint.IndexOf('&'));

            if(typeFromEndpoint == inrichtendemachtenInstellingsType) {
                body = '{"meta": {"total_elements": 948,"total_pages": 316,"number": 1,"number_of_elements": 3,"size": 3,"first": true,"last": false},"content": [{"instelling_naam": "IM01","instelling_naam_volledig": "Inrichtende Macht 01","instelling_nummer": 123456,"instelling_begindatum": "2018-12-14","instelling_niveau": {"code": "SB","omschrijving": "Schoolbestuur"},"instelling_type": {"code": "300","omschrijving": "Bestuur"},"instelling_postcode": "8200","instelling_gemeente": "SINT-ANDRIES","instelling_straatnaam": "Zevenkerken","instelling_huisnummer": "4","instelling_datum_laatste_wijziging": "2022-09-20","instelling_provincie": "Provincie West-Vlaanderen","instelling_telefoon": "+ 050 12 34 56","instelling_email": "im01@test.be","instelling_website": "https://www.im01Test.be","instelling_gemeente_nis": "31005","instelling_crab_code": "46263","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false,"instelling_kbo_ondernemingsnummer": "0123456789","instelling_net": {"code": "2","omschrijving": "Vrij gesubsidieerd onderwijs"},"instelling_soort_bestuur": {"code": "2","omschrijving": "Vrij"}},{"instelling_naam": "IM02","instelling_naam_volledig": "Inrichtende Macht 02","instelling_nummer": 122408,"instelling_begindatum": "2003-09-01","instelling_niveau": {"code": "SB","omschrijving": "Schoolbestuur"},"instelling_type": {"code": "300","omschrijving": "Bestuur"},"instelling_postcode": "2387","instelling_gemeente": "BAARLE-HERTOG","instelling_straatnaam": "Pastoor de Katerstraat","instelling_huisnummer": "5","instelling_datum_laatste_wijziging": "2022-09-20","instelling_provincie": "Provincie Antwerpen","instelling_gemeente_nis": "13002","instelling_crab_code": "12579","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false,"instelling_kbo_ondernemingsnummer": "0987654321","instelling_net": {"code": "3","omschrijving": "Officieel gesubsidieerd onderwijs"},"instelling_soort_bestuur": {"code": "4","omschrijving": "Gemeente"}},{"instelling_naam": "IM03","instelling_naam_volledig": "Inrichtende Macht 03","instelling_nummer": 61739,"instelling_niveau": {"code": "SB","omschrijving": "Schoolbestuur"},"instelling_type": {"code": "300","omschrijving": "Bestuur"},"instelling_postcode": "1000","instelling_gemeente": "BRUSSEL","instelling_straatnaam": ".","instelling_datum_laatste_wijziging": "2021-04-01","instelling_provincie": "Brussels Hoofdstedelijk Gewest","instelling_gemeente_nis": "21004","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false,"instelling_net": {"code": "4","omschrijving": "Andere"},"instelling_soort_bestuur": {"code": "9","omschrijving": "Andere"}}],"links": []}';
            } else if (typeFromEndpoint == scholengemeenschappenInstellingsType) {
                body = '{"meta": {"total_elements": 443,"total_pages": 148,"number": 1,"number_of_elements": 3,"size": 3,"first": true,"last": false},"content": [{"instelling_naam": "SG01","instelling_naam_volledig": "School Group 01","instelling_nummer": 654321,"instelling_begindatum": "2003-09-01","instelling_niveau": {"code": "ANDERE","omschrijving": "Andere"},"instelling_type": {"code": "400","omschrijving": "Scholengemeenschap"},"instelling_postcode": "1080","instelling_gemeente": "SINT-JANS-MOLENBEEK","instelling_straatnaam": "Jean-Baptiste Decockstraat","instelling_huisnummer": "54","instelling_datum_laatste_wijziging": "2022-10-15","instelling_provincie": "Brussels Hoofdstedelijk Gewest","instelling_telefoon": "+ 02 123 45 67","instelling_email": "sg01@test.be","instelling_gemeente_nis": "21012","instelling_crab_code": "22206","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false},{"instelling_naam": "SG02","instelling_naam_volledig": "School Group 02","instelling_nummer": 120741,"instelling_begindatum": "2003-09-01","instelling_niveau": {"code": "ANDERE","omschrijving": "Andere"},"instelling_type": {"code": "400","omschrijving": "Scholengemeenschap"},"instelling_postcode": "8400","instelling_gemeente": "OOSTENDE","instelling_straatnaam": "Prof. Mac Leodstraat","instelling_huisnummer": "11","instelling_datum_laatste_wijziging": "2022-10-15","instelling_provincie": "Provincie West-Vlaanderen","instelling_gemeente_nis": "35013","instelling_crab_code": "56095","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false},{"instelling_naam": "SG03","instelling_naam_volledig": "School Group 03","instelling_nummer": 120147,"instelling_begindatum": "2003-09-01","instelling_niveau": {"code": "ANDERE","omschrijving": "Andere"},"instelling_type": {"code": "400","omschrijving": "Scholengemeenschap"},"instelling_postcode": "3500","instelling_gemeente": "HASSELT","instelling_straatnaam": "Armand Hertzstraat","instelling_huisnummer": "2","instelling_datum_laatste_wijziging": "2022-10-15","instelling_provincie": "Provincie Limburg","instelling_telefoon": "+11 85 57 59","instelling_email": "sg03@test.be","instelling_website": "www.sg02test.be","instelling_gemeente_nis": "71022","instelling_crab_code": "114533","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false}],"links": []}';
            } else if (scholenInstellingsType.contains(typeFromEndpoint)) {
                body = '{"meta": {"total_elements": 6,"total_pages": 2,"number": 1,"number_of_elements": 3,"size": 3,"first": true,"last": false},"content": [{"instelling_naam": "S01","instelling_naam_volledig": "School 01","instelling_nummer": 987654,"instelling_begindatum": "1900-01-01","instelling_niveau": {"code": "HO","omschrijving": "Hoger onderwijs"},"instelling_type": {"code": "131","omschrijving": "Universiteit"},"instelling_postcode": "3000","instelling_gemeente": "LEUVEN","instelling_straatnaam": "Oude Markt","instelling_huisnummer": "13","instelling_busnummer": "5005","instelling_datum_laatste_wijziging": "2022-08-22","instelling_provincie": "Provincie Vlaams-Brabant","instelling_telefoon": "+3212345678","instelling_website": "http://www.s01test.be","instelling_gemeente_nis": "24062","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false,"instelling_kbo_ondernemingsnummer": "4567891230"},{"instelling_naam": "s02","instelling_naam_volledig": "School 02","instelling_nummer": 116772,"instelling_begindatum": "2001-10-01","instelling_niveau": {"code": "HO","omschrijving": "Hoger onderwijs"},"instelling_type": {"code": "131","omschrijving": "Universiteit"},"instelling_postcode": "3500","instelling_gemeente": "HASSELT","instelling_straatnaam": "Martelarenlaan","instelling_huisnummer": "42","instelling_datum_laatste_wijziging": "2022-08-22","instelling_provincie": "Provincie Limburg","instelling_telefoon": "003212345678","instelling_email": "test@s02.be","instelling_website": "http://www.s02test.edu","instelling_gemeente_nis": "71022","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false,"instelling_kbo_ondernemingsnummer": "4567891230"},{"instelling_naam": "s03","instelling_naam_volledig": "School 03","instelling_nummer": 115791,"instelling_begindatum": "1999-10-01","instelling_niveau": {"code": "HO","omschrijving": "Hoger onderwijs"},"instelling_type": {"code": "131","omschrijving": "Universiteit"},"instelling_postcode": "2000","instelling_gemeente": "ANTWERPEN","instelling_straatnaam": "Prinsstraat","instelling_huisnummer": "13","instelling_datum_laatste_wijziging": "2022-08-22","instelling_provincie": "Provincie Antwerpen","instelling_telefoon": "+3278945612","instelling_email": "test@s03.be","instelling_website": "http://www.s03test.be","instelling_gemeente_nis": "11002","instelling_buitengewoon": false,"instelling_biedt_deeltijds_aan": false,"instelling_biedt_voltijds_aan": false,"instelling_kbo_ondernemingsnummer": "1237894560"}],"links": []}';
            } else {
                System.debug('==> Unknown Endpoint found: ' + endPoint);
            }

            HttpResponse res = new HttpResponse();

            res.setBody(body);
            res.setStatusCode(200);
            return Res;
        }
    }

    public class MockInstellingDetails implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest req) {

            String fullEndpoint = req.getEndpoint();
            System.debug('fullEndpoint ==> ' + fullEndpoint);

            Integer Schoolnumber = Integer.valueOf(fullEndpoint.mid(fullEndpoint.indexOf('v2/instelling/')+14, fullEndpoint.indexOf('?apikey=') - (fullEndpoint.indexOf('v2/instelling/')+14)));

            System.debug('Schoolnumber from Endpoint: ' + Schoolnumber);

            String body = instellingDetailsMessage(schoolNumber);

            HttpResponse res = new HttpResponse();

            res.setBody(body);
            res.setStatusCode(200);
            return Res;
        }
    }

    public class MockStudentNumbers implements HttpCalloutMock {

        public HttpResponse respond (HttpRequest req) {

            String baseEndpointBAO = 'https://onderwijs.api.vlaanderen.be/instellingsgegevens/inschrijvingsaantal_bao/v1/inschrijvingsaantal';
            String baseEndpointSO = 'https://onderwijs.api.vlaanderen.be/instellingsgegevens/inschrijvingsaantal_so/v1/inschrijvingsaantalperinstelling';
            String baseEndpointDKO = 'https://onderwijs.api.vlaanderen.be/instellingsgegevens/inschrijvingsaantal_dko/v1/inschrijvingsaantalperinstelling';
            String baseEndpointVWO = 'https://onderwijs.api.vlaanderen.be/instellingsgegevens/inschrijvingsaantal_vwo/v1/inschrijvingsaantalperinstelling';

            String fullEndpoint = req.getEndpoint();
            String endPoint = fullEndpoint.left(fullEndpoint.indexOf('?'));

            String baoBody = '';
            String soBody = '';
            String dkoBody = '';
            String vwoBody = '';

            for (Integer i = 0; i < 20; i++) {
                if (i < 5) {
                    // Add Kindergarten studentnumbers
                    baoBody += inschrijvingsaantalMessage(i);
                    if (i < 4) {
                        baoBody += ',';
                    }
                } else if (i < 10) {
                    soBody += inschrijvingsaantalperinstellingMessage(i);
                    if (i < 9) {
                        soBody += ',';
                    }
                } else if (i < 15) {
                    dkoBody += inschrijvingsaantalperinstellingMessage(i);
                    if (i < 14) {
                        dkoBody += ',';
                    }
                } else {
                    vwoBody += inschrijvingsaantalperinstellingMessage(i);
                    if (i < 19) {
                        vwoBody += ',';
                    }
                }
            }

            String body = '{"meta": {"total_elements": 20,"total_pages": 1,"number": 1,"number_of_elements": 20,"size": 20,"first": true,"last": true},"content": [';

            if (endpoint == baseEndpointBAO) {
                System.debug('BAO endpoint found.');
                body += baoBody;
            } 
            else if (endpoint == baseEndpointSO) {
                System.debug('SO endpoint found.');
                body += soBody;
            }
            else if (endpoint == baseEndpointDKO) {
                System.debug('DKO endpoint found.');
                body += dkoBody;
            }
            else if (endPoint == baseEndpointVWO) {
                System.debug('VWO endpoint found.');
                body += vwoBody;
            }
            else {
                System.debug('==> Unknown Endpoint found: ' + endPoint);
            }

            body += '],"links": []}';

            HttpResponse res = new HttpResponse();

            res.setBody(body);
            res.setStatusCode(200);
            return Res;
        }
    }

    public static String instellingDetailsMessage(Integer i) {
        String body = '';

        body += '{';
        body += '    "instelling_naam": "TestSchool",';
        body += '    "instelling_naam_volledig": "Test School Volledige Naam",';
        body += '    "instelling_volledige_naam": "Test School Volledige Naam",';
        body += '    "instelling_nummer": ' + i + ',';
        body += '    "instelling_hoofdzetel_vestigingsnr": 1,';
        body += '    "instelling_postcode": "1000",';
        body += '    "instelling_gemeente": "BRUSSEL",';
        body += '    "instelling_straatnaam": "Teststraat",';
        body += '    "instelling_huisnummer": "1",';
        body += '    "instelling_provincie": "Brussels Hoofdstedelijk Gewest",';
        body += '    "instelling_niveau": {';
        body += '      "code": "BAO",';
        body += '      "omschrijving": "Basisonderwijs"';
        body += '    },';
        body += '    "instelling_buitengewoon": false,';
        body += '    "instelling_net": {';
        body += '      "code": "1",';
        body += '      "omschrijving": "Gemeenschapsonderwijs"';
        body += '    },';
        body += '    "instelling_taalstelsel": {';
        body += '      "code": "1",';
        body += '      "omschrijving": "Nederlandstalig"';
        body += '    },';
        body += '    "instelling_telefoon": "123456789",';
        body += '    "instelling_email": "info@test.test",';
        body += '    "instelling_website": "www.test.test",';
        body += '    "instelling_gemeente_nis": "21004",';
        body += '    "instelling_crab_code": "20244",';
        body += '    "instelling_directeur": {';
        body += '      "naam": "Contact",';
        body += '      "voornaam": "Test"';
        body += '    },';
        body += '    "instelling_bestuur": {';
        body += '      "naam": "GO! scholengroep Brussel",';
        body += '      "instellingsnummer": 123456';
        body += '    },';
        body += '    "instelling_clb": {';
        body += '      "naam": "GO! CLB Brussel",';
        body += '      "instellingsnummer": 654321';
        body += '    },';
        body += '    "instelling_koepel": {';
        body += '      "naam": "GO! onderwijs van de Vlaamse Gemeenschap",';
        body += '      "instellingsnummer": 987654';
        body += '    },';
        body += '    "instelling_scholengemeenschap": {';
        body += '      "naam": "SGE BRUSSELIAI",';
        body += '      "instellingsnummer": 987654';
        body += '    },';
        body += '    "instelling_leersteuncentrum": {';
        body += '      "naam": "LSC Kasterlinden",';
        body += '      "instellingsnummer": 654321';
        body += '    },';
        body += '    "instelling_status_erkenning": {';
        body += '      "code": "S",';
        body += '      "omschrijving": "Subsidieerbaar/Financierbaar en erkend"';
        body += '    },';
        body += '    "instelling_type": {';
        body += '      "code": "112",';
        body += '      "omschrijving": "Basisschool"';
        body += '    },';
        body += '    "instelling_hoofdstructuur": [';
        body += '      {';
        body += '        "code": "111",';
        body += '        "omschrijving": "Gewoon kleuteronderwijs"';
        body += '      },';
        body += '      {';
        body += '        "code": "211",';
        body += '        "omschrijving": "Gewoon lager onderwijs"';
        body += '      }';
        body += '    ],';
        body += '    "instelling_datum_laatste_wijziging": "2023-09-20",';
        body += '    "best_address_id": "215369",';
        body += '    "lambert72_x_coordinaat": 148310.739,';
        body += '    "lambert72_y_coordinaat": 171089.189,';
        body += '    "gps_lengtegraad": 4.34476,';
        body += '    "gps_breedtegraad": 50.8502,';
        body += '    "situatiedatum": "2023-11-29"';
        body += '}';

        return body;
    }

    public static String inschrijvingsaantalMessage(Integer i) {
        String baoBody = '';

        // Add Kindergarten studentnumbers
        baoBody += '{';
        baoBody += '    "schooljaar": ' + Date.today().year() + ',';
        baoBody += '    "instelling_nummer": ' + (12345+i) + ',';
        baoBody += '    "instelling_naam": "TestSchool' + (i+1) + '",';
        baoBody += '    "instellingslocatie_vestigingsnummer": 1,';
        baoBody += '    "instellingslocatie_postcode": "1000",';
        baoBody += '    "instellingslocatie_gemeente": "BRUSSEL",';
        baoBody += '    "administratievegroep_code": 14904,';
        baoBody += '    "administratievegroep_omschrijving": "Kleuterklas",';
        baoBody += '    "aantal_inschrijvingen": {';
        baoBody += '      "totaal": ' + (i+10) + ',';
        baoBody += '      "man": ' + (i/2) + ',';
        baoBody += '      "vrouw": ' + (i/2);
        baoBody += '    }';
        baoBody += '},';

        baoBody += '{';
        baoBody += '    "schooljaar": ' + Date.today().year() + ',';
        baoBody += '    "instelling_nummer": ' + (12345+i) + ',';
        baoBody += '    "instelling_naam": "TestSchool' + (i+1) + '",';
        baoBody += '    "instellingslocatie_vestigingsnummer": 2,';
        baoBody += '    "instellingslocatie_postcode": "1000",';
        baoBody += '    "instellingslocatie_gemeente": "BRUSSEL",';
        baoBody += '    "administratievegroep_code": 14904,';
        baoBody += '    "administratievegroep_omschrijving": "Kleuterklas",';
        baoBody += '    "aantal_inschrijvingen": {';
        baoBody += '      "totaal": ' + (i+10) + ',';
        baoBody += '      "man": ' + (i/2) + ',';
        baoBody += '      "vrouw": ' + (i/2);
        baoBody += '    }';
        baoBody += '},';

        // Add PE studentnumbers
        baoBody += '{';
        baoBody += '    "schooljaar": ' + Date.today().year() + ',';
        baoBody += '    "instelling_nummer": ' + (12345+i) + ',';
        baoBody += '    "instelling_naam": "TestSchool' + (i+1) + '",';
        baoBody += '    "instellingslocatie_vestigingsnummer": 1,';
        baoBody += '    "instellingslocatie_postcode": "1000",';
        baoBody += '    "instellingslocatie_gemeente": "BRUSSEL",';
        baoBody += '    "administratievegroep_code": 14904,';
        baoBody += '    "administratievegroep_omschrijving": "1ste leerjaar",';
        baoBody += '    "aantal_inschrijvingen": {';
        baoBody += '      "totaal": ' + (i+10) + ',';
        baoBody += '      "man": ' + (i/2) +',';
        baoBody += '      "vrouw": ' + (i/2);
        baoBody += '    }';
        baoBody += '},';

        baoBody += '{';
        baoBody += '    "schooljaar": ' + Date.today().year() + ',';
        baoBody += '    "instelling_nummer": ' + (12345+i) + ',';
        baoBody += '    "instelling_naam": "TestSchool' + (i+1) + '",';
        baoBody += '    "instellingslocatie_vestigingsnummer": 2,';
        baoBody += '    "instellingslocatie_postcode": "1000",';
        baoBody += '    "instellingslocatie_gemeente": "BRUSSEL",';
        baoBody += '    "administratievegroep_code": 14904,';
        baoBody += '    "administratievegroep_omschrijving": "2de leerjaar",';
        baoBody += '    "aantal_inschrijvingen": {';
        baoBody += '      "totaal": ' + (i+10) + ',';
        baoBody += '      "man": ' + (i/2) + ',';
        baoBody += '      "vrouw": ' + (i/2);
        baoBody += '    }';
        baoBody += '}';

        return baoBody;
    }

    public static String inschrijvingsaantalperinstellingMessage(Integer i) {
        String soBody = '';

        soBody += '{';
        soBody += '"schooljaar": ' + Date.today().year() + ',';
        soBody += '"instelling_nummer": ' + (12345+i) + ',';
        soBody += '"instelling_naam": "TestSchool' + (i+1) + '",';
        soBody += '"instelling_postcode": "3001",';
        soBody += '"instelling_gemeente": "HEVERLEE",';
        soBody += '"aantal_inschrijvingen": 424';
        soBody += '}';

        return soBody;
    }
}