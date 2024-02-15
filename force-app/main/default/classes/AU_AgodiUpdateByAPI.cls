/*/
*
*   Created By: Jannes Kleerebezem
*
*   Use to start the queue for the Agodi Updates
*   System.enqueueJob(new AU_AgodiUpdateByAPI());
*
*   #############################################
*   #       MODIFICATION HISTORY                #
*   #############################################
*   Date        Initials    What was done
*   ---------------------------------------------
*   24-08-2022  JK          Created
*
/*/

public class AU_AgodiUpdateByAPI implements Queueable, Database.AllowsCallouts {

    Map<String,Account> CurrentPlantynAccounts;
    String inrichtendemachtenInstellingsType = '300';
    String scholengemeenschappenInstellingsType = '400';
    List<String> scholenInstellingsType = new List<String>();
    List<String> instellingHoofdstructuurList = new List<String>{'111','121','211','221','311','312','313','314','315','316','317','321','411','416','417','450','511','618','H00'};

    List<Instelling> inrichtendemachtenInstellingen, scholengemeenschappenInstellingen;
    List<Account> newAccountsIM, newAccountsSG, newAccountsS;

    Boolean InrichtendeMachtenAccountsCreated = false;
    Boolean scholengemeenschappenAccountsCreated = false;
    Boolean scholenPart1AccountsCreated = false;

    public AU_AgodiUpdateByAPI(Map<String,Account> agodiAccounts) {
        this.CurrentPlantynAccounts = agodiAccounts;
        
        scholenInstellingsType.add('1200');//	Consortium
        scholenInstellingsType.add('1100');//	Kinderdagverblijf
        scholenInstellingsType.add('1000');//	Huis van het Nederlands
        scholenInstellingsType.add('900'); //	Pedagogische begeleidingsdienst
        scholenInstellingsType.add('700'); //	Koepel
        scholenInstellingsType.add('600'); //	CLB
        scholenInstellingsType.add('500'); //	Associatie
        scholenInstellingsType.add('440'); //   Algemeen leersteuncentrum
        scholenInstellingsType.add('450'); //   Specifiek leersteuncentrum
        scholenInstellingsType.add('200'); //	Internaat
        scholenInstellingsType.add('151'); //	Instelling voor deeltijds kunstonderwijs
        scholenInstellingsType.add('142'); //	Centrum voor Volwassenenonderwijs
        scholenInstellingsType.add('141'); //	Centrum voor Basiseducatie
        scholenInstellingsType.add('135'); //	Niet-ambtshalve geregistreerde instelling
        scholenInstellingsType.add('134'); //	Ambtshalve geregistreerde instelling
        scholenInstellingsType.add('133'); //	Hoger kunstonderwijs
        scholenInstellingsType.add('132'); //	Hogeschool
        scholenInstellingsType.add('131'); //	Universiteit
        scholenInstellingsType.add('126'); //	School voor buitengewoon secundair onderwijs
        scholenInstellingsType.add('125'); //	Syntra
        scholenInstellingsType.add('124'); //	Centrum voor deeltijdse vorming
        scholenInstellingsType.add('123'); //	Centrum voor deeltijds onderwijs
        scholenInstellingsType.add('122'); //	School voor voltijds gewoon secundair onderwijs en deeltijds beroepsonderwijs
        scholenInstellingsType.add('121'); //	School voor voltijds gewoon secundair onderwijs
        scholenInstellingsType.add('116'); //	Autonome lagere school voor buitengewoon onderwijs
        scholenInstellingsType.add('115'); //	Autonome lagere school
        scholenInstellingsType.add('113'); //	Basisschool voor buitengewoon onderwijs
        scholenInstellingsType.add('112'); //	Basisschool
        scholenInstellingsType.add('111'); //	Autonome kleuterschool
    }
    
    public void execute(QueueableContext context) {

        try {
            Map<String,List<Integer>> hfdStrInstellingNrMap = new Map<String,List<Integer>>();
            List<Instelling> instellingenForAccountsIM = new List<Instelling>();
            List<Instelling> instellingenForAccountsSG = new List<Instelling>();

            for (String instHfdStr : instellingHoofdstructuurList) {
                hfdStrInstellingNrMap.put(instHfdStr, getInstellingenByHoofdstructuur(instHfdStr));
            }

            // Create Accounts
            if (!InrichtendeMachtenAccountsCreated) {
                // ########## Create Instellingen from Agodi API
                System.debug('Get inrichtende machten');
                inrichtendemachtenInstellingen = createInstellingenList(this.inrichtendemachtenInstellingsType);

                // Get Instelling with with no endDate or endDate later than today
                for (Instelling inst : inrichtendemachtenInstellingen) {
                    if (inst.instelling_einddatum == null || Date.valueOf(inst.instelling_einddatum) > Date.today()) {
                        instellingenForAccountsIM.add(inst);
                    } else {
                        System.debug('should not be added to the list, End Date ===> ' + inst.instelling_einddatum);
                    }
                }

                System.debug('Starting => createAccounts(instellingenForAccountsIM)');
                newAccountsIM = createAccounts(instellingenForAccountsIM, hfdStrInstellingNrMap);
                InrichtendeMachtenAccountsCreated = true;
                System.enqueueJob(this);
            } else if (!scholengemeenschappenAccountsCreated) {
                // ########## Create Instellingen from Agodi API
                System.debug('Get scholengemeenschappen');
                scholengemeenschappenInstellingen = createInstellingenList(this.scholengemeenschappenInstellingsType);

                // Get Instelling with with no endDate or endDate later than today
                for (Instelling inst : scholengemeenschappenInstellingen) {
                    if (inst.instelling_einddatum == null || Date.valueOf(inst.instelling_einddatum) > Date.today()) {
                        instellingenForAccountsSG.add(inst);
                    } else {
                        System.debug('should not be added to the list, End Date ===> ' + inst.instelling_einddatum);
                    }
                }

                System.debug('Starting => createAccounts(instellingenForAccountsSG)');
                newAccountsSG = createAccounts(instellingenForAccountsSG, hfdStrInstellingNrMap);
                scholengemeenschappenAccountsCreated = true;
                System.enqueueJob(this);
            } else {
                
                // ########## Create Instellingen from Agodi API
                while (!scholenInstellingsType.isEmpty()) {

                    List<Instelling> instellingenForAccountsS = new List<Instelling>();
                    List<Instelling> scholenInstellingen = new List<Instelling>();

                    String instellingsType = scholenInstellingsType.remove(0);
                    scholenInstellingen.addAll(createInstellingenList(instellingsType));

                    // Get Instelling with with no endDate or endDate later than today
                    System.debug('Get Scholen with with no endDate or endDate later than today');
                    for (Instelling inst : scholenInstellingen) {
                        if (inst.instelling_einddatum == null || Date.valueOf(inst.instelling_einddatum) > Date.today()) {
                            instellingenForAccountsS.add(inst);
                        } else {
                            System.debug('should not be added to the list, End Date ===> ' + inst.instelling_einddatum);
                        }
                    }
                    
                    System.debug('Starting => createAccounts(instellingenForAccountsS)');
                    if (newAccountsS == null) {
                        newAccountsS = createAccounts(instellingenForAccountsS, hfdStrInstellingNrMap);
                    } else {
                        newAccountsS.addAll(createAccounts(instellingenForAccountsS, hfdStrInstellingNrMap));
                    }
                }

                if (!scholenInstellingsType.isEmpty()) {
                    System.enqueueJob(this);
                } else {
                    if (!Test.isRunningTest()) {
                        System.debug('newAccountsS size = ' + newAccountsS.size());
                        System.enqueueJob(new AU_accountHelper(newAccountsIM, newAccountsSG, newAccountsS)); // handles the upsert of accounts before queueing the structure update
                    }
                }
            }
        } catch (Exception e) {
            System.debug('An error occured: ' + e.getMessage());
            HandleCustomException.LogException(e);
        }
        

    }

    public static List<Instelling> createInstellingenList(String instellingType) {

        List<Instelling> instellingenList = new List<Instelling>();

        String body = getFile(instellingType);
        if (body == '') {
            return null;
        }
        JSONParser parser = JSON.createParser(body);
        
        // Create List of Instellingen from returned JSON
        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY && parser.getCurrentName() == 'content') {
                while (parser.nextToken() != null && parser.getCurrentName() != 'links') {
                    Instelling inst = (Instelling)parser.readValueAs(Instelling.class);
                    if (inst == null) {
                        break;
                    }
                    parser.skipChildren();
                    instellingenList.add(inst);
                }
            }
        }

        return instellingenList;
    }

    public static List<Integer> getInstellingenByHoofdstructuur(String HoofdstructuurCode) {
        List<Integer> returnList = new List<Integer>();
        List<Instelling> instellingenList = new List<Instelling>();

        String endpoint = 'https://onderwijs.api.vlaanderen.be/instellingsgegevens/instelling/v2/instelling';
        String key = 'eBVx7fy6T3iEaZMLjGjUUPiKaSDT9rSG';
        String completeEndPoint = endpoint + '?filter_instelling_hoofdstructuur=' + HoofdstructuurCode + '&size=9999999&apikey=' + key;

        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(completeEndPoint);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/json');

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        String body = res.getBody();

        Integer statusCode = res.getStatusCode();

        if (statusCode == 200) {
        } else if (statusCode == 503) {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode + ' (failure from Agodi server)');
            System.debug('Server Message ==> ' + body.substringBetween('"diagnose":"','","type"'));
        } else if (statusCode > 499) {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode + ' (failure from Agodi server)');
            body = '';
        } else {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode);
            body = '';
        }

        if (body == '') {
            return returnList;
        }
        JSONParser parser = JSON.createParser(body);
        
        // Create List of Instellingen from returned JSON
        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY && parser.getCurrentName() == 'content') {
                while (parser.nextToken() != null && parser.getCurrentName() != 'links') {
                    Instelling inst = (Instelling)parser.readValueAs(Instelling.class);
                    if (inst == null) {
                        break;
                    }
                    parser.skipChildren();
                    returnList.add(inst.instelling_nummer);
                }
            }
        }
        return returnList;
    }

    public static String getFile(String instellingType) {

        String endpoint = 'https://onderwijs.api.vlaanderen.be/instellingsgegevens/instelling/v2/instelling';
        String key = 'eBVx7fy6T3iEaZMLjGjUUPiKaSDT9rSG';
        String completeEndPoint = endpoint + '?filter_instelling_type=' + instellingType + '&size=9999999&apikey=' + key;

        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(completeEndPoint);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/json');

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        String body = res.getBody();

        Integer statusCode = res.getStatusCode();

        if (statusCode == 200) {
        } else if (statusCode == 503) {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode + ' (failure from Agodi server)');
            System.debug('Server Message ==> ' + body.substringBetween('"diagnose":"','","type"'));
        }  else if (statusCode > 499) {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode + ' (failure from Agodi server)');
            body = '';
        } else {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode);
            body = '';
        }

        return body;
    }

    public List<Account> createAccounts(List<Instelling> instellingList, Map<String,List<Integer>> hfdStrInstellingNrMap) {

        Map<String, Account> instellingNrAccountMap = new Map<String, Account>();
        List<Account> accounts = new List<Account>();
        Date todaysDate = Date.today();
        Id ownerId;
        Id recordTypeIdInrichtendeMachten = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Purchasing Groups' LIMIT 1].Id;
        Id recordTypeIdScholenGemeenschappen = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        Id recordTypeIdScholen = [SELECT Id FROM Recordtype WHERE sObjectType = 'Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        List<String> hfdStrLst = new List<String>{'111','121','211','221','311','312','313','314','315','316','317','321','411','416','417','511','618'};

        List<String> higherCodes = new List<String>{'411','416','417','511'};
        List<String> preSchoolCodes = new List<String>{'111','121'};
        List<String> primaryCodes = new List<String>{'211','221','618'};
        List<String> secondaryCodes = new List<String>{'311','317','321'};
        List<String> vocationalCodes = new List<String>{'312','313','314','315','316'};

        if (!Test.isRunningTest()) {
            ownerId = Id.valueOf(ApexIds__mdt.getInstance('AU_AgodiUpdateByAPI').PlantynId__c);
        }

        for (Instelling instelling : instellingList) {

            Boolean addToList = true;
            Account currentPlantynAccount = this.CurrentPlantynAccounts.get(String.valueOf(instelling.instelling_nummer));
            
            // create new Account for upsert
            Account a = new Account();
            a.LastAgodiUpdate__c = todaysDate;
            a.AgodiUpdateInProgress__c = true;
            a.ExternalCustomerId__c = String.ValueOf(instelling.instelling_nummer);
            
            // ONLY ON UPDATE
            if (currentPlantynAccount != null) {

                a.Id = currentPlantynAccount.Id;
                a.DataMigrationHistory__c = 'Agodi Update - ' + todaysDate;

                // Update full legalName if this is changed
                if (a.FullLegalName__c != instelling.instelling_naam_volledig) {
                    a.FullLegalName__c = instelling.instelling_naam_volledig;
                }

                // fill fields if empty in original Account
                if (currentPlantynAccount.NumberofStudents__c == null) {
                    a.NumberofStudents__c = 0;
                }
                if (currentPlantynAccount.PhoneCountry__c == '') {
                    a.PhoneCountry__c = 'Belgium';
                }
                if ( currentPlantynAccount.CustomerDiscountGroup__c == '') {
                    a.CustomerDiscountGroup__c = currentPlantynAccount.CustomerCategory__c;
                }
                if (a.Hfdstructuur__c != null && a.Hfdstructuur__c != '') {
                    for (String hfdStr : hfdStrLst) {
                        if (hfdStrInstellingNrMap.get(hfdStr).contains(instelling.instelling_nummer) && !a.Hfdstructuur__c.contains(hfdStr)) {
                            a.Hfdstructuur__c += ';' + hfdStr;
                        }
                    }
                } else {
                    String hfdStrString = '';
                    for (String hfdStr : hfdStrInstellingNrMap.keySet()) {
                        // System.debug('TMP Debug==> hfdStrInstellingNrMap.get(hfdStr) ==> ' + hfdStrInstellingNrMap.get(hfdStr));
                        // System.debug('TMP Debug==> instelling.instelling_nummer ==> ' + instelling.instelling_nummer);
                        if (hfdStrInstellingNrMap.get(hfdStr).contains(instelling.instelling_nummer)) {
                            if (hfdStrString.length() > 1) {
                                hfdStrString += ';';
                            }
                            hfdStrString += hfdStr;
                        }
                    }
                    a.Hfdstructuur__c = hfdStrString;

                    if (hfdStrString.length() > 1) {
                        Set<String> classificationList = new Set<String>();
                        // Check Classifications
                        String classificationString = '';
                        List<String> currentClassificationList = new List<String>();
                        if (currentPlantynAccount.Classification__c != null) {
                            currentClassificationList = currentPlantynAccount.Classification__c.split(';');
                        }
                        for (String code : hfdStrString.split(';')) {
                            
                            System.debug('Code ==> ' + code);
                            String cls = '';
    
                            if (higherCodes.contains(code)) {
                                cls = 'Higher';
                            }
                            if (preSchoolCodes.contains(code)) {
                                cls = 'Pre-School';
                            }
                            if (primaryCodes.contains(code)) {
                                cls = 'Primary';
                            }
                            if (secondaryCodes.contains(code)) {
                                cls = 'Secondary';
                            }
                            if (vocationalCodes.contains(code)) {
                                cls = 'Vocational';
                            }
    
                            if (!currentClassificationList.contains(cls) && cls != '') {
                                classificationList.add(cls);
                            }
                        }
                        classificationString = currentPlantynAccount.Classification__c;
                        classificationString += String.join(new List<String>(classificationList), ';');
                        System.debug('ClassificationString ==> ' + classificationString);
    
                        a.Classification__c = classificationString;
                    }
                }
            }

            //ONLY ON INSERT
            else {
                if (!Test.isRunningTest() && System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName() == null) {
                    a.OwnerId = ownerId;
                }
                a.OperatingCompany__c = 'Plantyn';
                a.DataMigrationHistory__c = 'Agodi Insert - ' + todaysDate;
                a.ConverseImport__c = 'Agodi import';
                a.Name = instelling.instelling_naam.length() < 46 ? instelling.instelling_naam : instelling.instelling_naam.left(instelling.instelling_naam.left(45).lastIndexOf(' '));
                a.FullLegalName__c = instelling.instelling_naam_volledig;
                a.TypeOfAccount__c = 'Sales and Order';
                a.PhoneCountry__c = 'Belgium';
                if (instelling.instelling_telefoon != null) {
                    a.Phone = instelling.instelling_telefoon.replace('-','').replace('.','').replace('/','').replace(' ','');
                }
                if (instelling.instelling_website != null && instelling.instelling_website != '') {
                    if (instelling.instelling_website.left(4) == 'http') {
                        a.Website = instelling.instelling_website;
                    } else {
                        a.Website = 'http://' + instelling.instelling_website;
                    }
                }

                if (String.ValueOf(instelling.instelling_type.code) == this.inrichtendemachtenInstellingsType) {
                    a.RecordTypeId = recordTypeIdInrichtendeMachten;
                    a.CustomerCategory__c = 'Government Agency';
                } else if (String.ValueOf(instelling.instelling_type.code) == this.scholengemeenschappenInstellingsType) {
                    a.RecordTypeId = recordTypeIdScholenGemeenschappen;
                    a.CustomerCategory__c = 'School Group';
                    a.SchoolType__c = 'School Group';
                } else {
                    a.RecordTypeId = recordTypeIdScholen;
                    a.CustomerCategory__c = 'Educational Institution';
                }

                a.CustomerDiscountGroup__c = a.CustomerCategory__c;
                a.ShippingCostMethod__c = 'Based on weight Domestic';
                a.AccountSource = 'Agodi';

                if (instelling.instelling_email != null && instelling.instelling_email!= '') {
                    String emailAdres = instelling.instelling_email;
                    a.InvoicingEmail__c = emailAdres;
                    a.OrderNotificationEmail__c = emailAdres;
                    a.BillingReminderEmail__c = emailAdres;
                    a.DigitalActivationEmail__c = emailAdres;
                }
                
                a.ShippingStreet = instelling.instelling_straatnaam + ' ' + instelling.instelling_huisnummer;
                a.ShippingPostalCode = instelling.instelling_postcode;
                a.ShippingCity = instelling.instelling_gemeente;
                a.ShippingCountry = 'Belgium';

                a.BillingStreet = instelling.instelling_straatnaam + ' ' + instelling.instelling_huisnummer;
                a.BillingPostalCode = instelling.instelling_postcode;
                a.BillingCity = instelling.instelling_gemeente;
                a.BillingCountry = 'Belgium';

                a.CommunicationLanguage__c = 'nl_NL'; // UPDATED
                if (instelling.instelling_kbo_vestigingseenheidsnummer != null) {
                    if (instelling.instelling_kbo_vestigingseenheidsnummer.length() == 10 && instelling.instelling_kbo_vestigingseenheidsnummer.left(1) == '0') {
                        a.VATNumber__c = instelling.instelling_kbo_vestigingseenheidsnummer;
                    } else if (instelling.instelling_kbo_vestigingseenheidsnummer.length() == 9) {
                        a.VATNumber__c = '0' + instelling.instelling_kbo_vestigingseenheidsnummer;
                    } else {
                        a.VATNumber__c = instelling.instelling_kbo_vestigingseenheidsnummer;
                    }
                }
                a.Area__c = 'Dutch';
                a.NumberofStudents__c = 0;
                a.ExternalDatabase__c = 'Agodi';

                String hfdStrString = '';
                for (String hfdStr : hfdStrLst) {
                    if (hfdStrInstellingNrMap.get(hfdStr).contains(instelling.instelling_nummer)) {
                        if (hfdStr.length() > 2) {
                            hfdStrString += ';';
                        }
                        hfdStrString += hfdStr;
                    }
                }
                a.Hfdstructuur__c = hfdStrString;

                if (hfdStrString.length() > 1) {
                    Set<String> classificationList = new Set<String>();
                    // Check Classifications
                    String classificationString = '';

                    for (String code : hfdStrString.split(';')) {
                        
                        System.debug('Code ==> ' + code);
                        String cls = '';

                        if (higherCodes.contains(code)) {
                            cls = 'Higher';
                        }
                        if (preSchoolCodes.contains(code)) {
                            cls = 'Pre-School';
                        }
                        if (primaryCodes.contains(code)) {
                            cls = 'Primary';
                        }
                        if (secondaryCodes.contains(code)) {
                            cls = 'Secondary';
                        }
                        if (vocationalCodes.contains(code)) {
                            cls = 'Vocational';
                        }

                        if (cls != '') {
                            classificationList.add(cls);
                        }
                    }

                    classificationString = String.join(new List<String>(classificationList), ';');
                    System.debug('ClassificationString ==> ' + classificationString);

                    a.Classification__c = classificationString;
                }
            }
            
            instellingNrAccountMap.put(a.ExternalCustomerId__c, a);
        }

        accounts = instellingNrAccountMap.values();

        return accounts;
    }

    // ########## WRAPPER CLASS INSTELLINGEN ##########
    public class Instelling {
        public String instelling_naam;
        public String instelling_naam_volledig;
        public Integer instelling_nummer;
        public String instelling_begindatum;
        public String instelling_einddatum;
        instelling_niveau instelling_niveau;
        instelling_type instelling_type;
        public String instelling_postcode;
        public String instelling_gemeente;
        public String instelling_datum_laatste_wijziging;
        public String instelling_straatnaam;
        public String instelling_huisnummer;
        public String instelling_busnummer;
        public String instelling_provincie;
        public String instelling_telefoon;
        public String instelling_email;
        public String instelling_website;
        public Boolean instelling_buitengewoon; 
        public String instelling_gemeente_nis;
        public Boolean instelling_biedt_deeltijds_aan;
        public String instelling_crab_code;
        public Boolean instelling_biedt_voltijds_aan;
        public String instelling_kbo_ondernemingsnummer;
        public String instelling_kbo_vestigingseenheidsnummer;
        instelling_net instelling_net;
        instelling_levensbeschouwing instelling_levensbeschouwing;
        instelling_status_erkenning instelling_status_erkenning;
        instelling_taalstelsel instelling_taalstelsel;
        instelling_pedagogische_methode instelling_pedagogische_methode;
        instelling_soort_bestuur instelling_soort_bestuur;

        public Instelling(String naam, 
                            String naamVolledig, 
                            Integer nummer, 
                            String beginDatum, 
                            String eindDatum, 
                            instelling_niveau instellingNiveau, 
                            instelling_type instellingType, 
                            String postcode, 
                            String gemeente, 
                            String laatsteWijziging, 
                            String straat, 
                            String huisNr, 
                            String busNr, 
                            String provincie, 
                            String tel, 
                            String email, 
                            String website, 
                            Boolean buitengewoon, 
                            String gemeenteNis, 
                            Boolean deeltijd, 
                            String crabCode, 
                            Boolean voltijd, 
                            String kboOndernemingsNummer, 
                            String kboVertigingsEenheidsNummer, 
                            instelling_net net, 
                            instelling_levensbeschouwing levensbeschouwing, 
                            instelling_status_erkenning statusErkenning, 
                            instelling_taalstelsel taalStelsel, 
                            instelling_pedagogische_methode pedagogoscheMethode, 
                            instelling_soort_bestuur soortBestuur) 
        {
        instelling_naam = naam;
        instelling_naam_volledig = naamVolledig;
        instelling_nummer = nummer;
        instelling_begindatum = beginDatum;
        instelling_einddatum = eindDatum;
        instelling_niveau = instellingNiveau.clone();
        instelling_type = instellingType.clone();
        instelling_postcode = postcode;
        instelling_gemeente = gemeente;
        instelling_datum_laatste_wijziging = laatsteWijziging;
        instelling_straatnaam = straat;
        instelling_huisnummer = huisNr;
        instelling_busnummer = busNr;
        instelling_provincie = provincie;
        instelling_telefoon = tel;
        instelling_email = email;
        instelling_website = website;
        instelling_buitengewoon = buitengewoon;
        instelling_gemeente_nis = gemeenteNis;
        instelling_biedt_deeltijds_aan = deeltijd;
        instelling_crab_code = crabCode;
        instelling_biedt_voltijds_aan = voltijd;
        instelling_kbo_ondernemingsnummer = kboOndernemingsNummer;
        instelling_kbo_vestigingseenheidsnummer = kboVertigingsEenheidsNummer;
        instelling_net = net;
        instelling_levensbeschouwing = levensbeschouwing;
        instelling_status_erkenning = statusErkenning;
        instelling_taalstelsel = taalStelsel;
        instelling_pedagogische_methode = pedagogoscheMethode;
        instelling_soort_bestuur = soortBestuur;
        }
    }
    public class instelling_niveau { public String code,omschrijving; }
    public class instelling_type { public String code,omschrijving; }
    public class instelling_net { public String code,omschrijving; }
    public class instelling_levensbeschouwing { public String code,omschrijving; }
    public class instelling_status_erkenning { public String code,omschrijving; }
    public class instelling_taalstelsel { public String code,omschrijving; }
    public class instelling_pedagogische_methode { public String code,omschrijving; }
    public class instelling_soort_bestuur { public String code,omschrijving; }
    // ########## END WRAPPER CLASS INSTELLINGEN ##########

}