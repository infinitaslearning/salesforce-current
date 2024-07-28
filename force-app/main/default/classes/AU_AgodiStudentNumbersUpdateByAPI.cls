/*/
*
*   Created By: Jannes Kleerebezem
*
*   Use to start the queue for the Agodi Studentnumbers Update
*   System.enqueueJob(new AU_AgodiStudentNumbersUpdateByAPI());
*
*   #############################################
*   #       MODIFICATION HISTORY                #
*   #############################################
*   Date        Initials    What was done
*   ---------------------------------------------
*   11-10-2023  JK          Created
*
/*/

public class AU_AgodiStudentNumbersUpdateByAPI implements Queueable, Database.AllowsCallouts {
    
    public List<Account> agodiAccountList;
    public List<Account> updateList;
    public Boolean doUpdate;
    public Integer batchSize = 1000;

    public AU_AgodiStudentNumbersUpdateByAPI(List<Account> agodiAccounts) {
        this.agodiAccountList = agodiAccounts;
        this.doUpdate = false;
    }

    public AU_AgodiStudentNumbersUpdateByAPI(List<Account> accountsToUpdate, Boolean updatePlease) {
        this.updateList = accountsToUpdate;
        this.doUpdate = updatePlease;
    }

    public void execute(QueueableContext context) {


        if (!this.doUpdate) {
            List<Account> accountUpdateList = new List<Account>();

            // Get Details list of Primary Education
            Map<Integer, Map<String, Integer>> PEMap = createBaoDetails(getStudentNumbers('https://onderwijs.api.vlaanderen.be/instellingsgegevens/inschrijvingsaantal_bao/v1/inschrijvingsaantal'));
            System.debug('PEMap size ==> ' + PEMap.keySet().size());

            // Get Details list of Secondary Education
            Map<Integer, Details> SEMap = createDetailsMap(getStudentNumbers('https://onderwijs.api.vlaanderen.be/instellingsgegevens/inschrijvingsaantal_so/v1/inschrijvingsaantalperinstelling'));
            System.debug('SEMap size ==> ' + SEMap.keySet().size());

            // Get Details list of Higher Education ---> Nu Deeltijds Kunstonderwijs
            Map<Integer, Details> DKOMap = createDetailsMap(getStudentNumbers('https://onderwijs.api.vlaanderen.be/instellingsgegevens/inschrijvingsaantal_dko/v1/inschrijvingsaantalperinstelling'));
            System.debug('DKOMap size ==> ' + DKOMap.keySet().size());

            // Get Details list of Vocational Education
            Map<Integer, Details> VEMap = createDetailsMap(getStudentNumbers('https://onderwijs.api.vlaanderen.be/instellingsgegevens/inschrijvingsaantal_vwo/v1/inschrijvingsaantalperinstelling'));
            System.debug('VEMap size ==> ' + VEMap.keySet().size());


            for (Account acc : this.agodiAccountList) {
                Boolean addAcc = false;
                
                if (acc.ExternalCustomerId__c.isNumeric()) {
                    Integer extCustId = Integer.ValueOf(acc.ExternalCustomerId__c);

                    Boolean hasPE = PEMap.containsKey(extCustId);
                    Boolean hasSE = SEMap.containsKey(extCustId);
                    Boolean hasDKO = DKOMap.containsKey(extCustId);
                    Boolean hasVE = VEMap.containsKey(extCustId);
                    Decimal numberOfStudents = 0;

                    if (hasPE || hasSE || hasDKO || hasVE) {
                        // Reset Studentnumbers
                        acc.KGStudents__c = null;
                        acc.PEStudents__c = null;
                        acc.SEStudents__c = null;
                        acc.HEStudents__c = null;
                        acc.VEStudents__c = null;
                        acc.NumberofStudents__c = null;
                    }
                    
                    // Handle KG & PE StudentNumbers
                    if (hasPE) {
                        Map<String, Integer> KgPeMap = PEMap.get(extCustId);

                        // Handle KG
                        if (KgPeMap.containsKey('KG')) {
                            acc.KGStudents__c = KgPeMap.get('KG');
                            numberOfStudents += acc.KGStudents__c;
                            addAcc = true;
                        }
                        if (KgPeMap.containsKey('PE')) {
                            acc.PEStudents__c = KgPeMap.get('PE');
                            numberOfStudents += acc.PEStudents__c;
                            addAcc = true;
                        }
                    }

                    // Handle SE StudentNumbers
                    if (hasSE) {
                        Details det = SEMap.get(extCustId);
                        acc.SEStudents__c = det.aantal_inschrijvingen;
                        numberOfStudents += det.aantal_inschrijvingen;
                        addAcc = true;
                    }

                    // Handle Deeltijd Kunst Opleiding StudentNumbers (should go to SE Students)
                    if (hasDKO) {
                        Details det = DKOMap.get(extCustId);
                        if (acc.SEStudents__c != null) {
                            acc.SEStudents__c += det.aantal_inschrijvingen;
                        } else{
                            acc.SEStudents__c = det.aantal_inschrijvingen;
                        }
                        numberOfStudents += det.aantal_inschrijvingen;
                        addAcc = true;
                    }

                    // Handle VE StudentNumbers
                    if (hasVE) {
                        Details det = VEMap.get(extCustId);
                        acc.VEStudents__c = det.aantal_inschrijvingen;
                        numberOfStudents += det.aantal_inschrijvingen;
                        addAcc = true;
                    }

                    // Any Update to do on Account? If so, add to the Update List
                    if (addAcc) {
                        acc.NumberofStudents__c = numberOfStudents;
                        accountUpdateList.add(acc);
                    }
                }
            }

            System.debug('accountUpdateList.size() ==> ' + accountUpdateList.size());
            System.debug('Accounts :\n' + JSON.serializePretty(accountUpdateList));
            if (!Test.isRunningTest()) {
                System.enqueueJob(new AU_AgodiStudentNumbersUpdateByAPI(accountUpdateList, true));
            }
        }
        
        if (this.doUpdate) {

            System.debug('updateList.size() ==> ' + this.updateList.size());

            Integer originalUpdatelistSize = this.updateList.size();
            Integer calculatedBatchSize = math.min(this.updateList.size(), this.batchSize);

            List<Account> updateNow = new List<Account>();
            for (Integer i = 0 ; i < calculatedBatchSize ; i ++) {
                updateNow.add(this.updateList.remove(0));
            }

            //update accountUpdateList;
            List<Database.SaveResult> srLst = Database.update(updateNow,false);
            System.debug('We have updated ' + updateNow.size() + ' Accounts with the StudenNumber information.');

            for (Database.SaveResult sr : srLst) {
                if (!sr.success) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('The following Error occured when updating Account:');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that ate affected by this Error: ' + err.getFields());
                    }
                }
            }

            if (this.updateList.size() != 0) {
                System.debug('Starting new Batch with ' + this.updateList.size() + ' Accounts.');
                if (!Test.isRunningTest()) {
                    System.enqueueJob(new AU_AgodiStudentNumbersUpdateByAPI(this.updateList, true));
                }
            }

            System.debug('Original updateListSize ==> ' + originalUpdatelistSize);
            System.debug('Current updateListSize ===> ' + this.updateList.size());
            System.debug('CalculatedBatchSize ======> ' + calculatedBatchSize);

        }

    }

    public static String getStudentNumbers(String endpoint) {

        String key = 'eBVx7fy6T3iEaZMLjGjUUPiKaSDT9rSG';
        String completeEndpoint = endpoint + '?size=9999999&apikey=' + key;

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

        if (body == '') {
            return null;
        }
        return body;
    }

    public static Map<Integer,Details> createDetailsMap(String body) {

        Map<Integer, Details> detailMap = new Map<Integer, Details>();


        System.debug('BODY ==> \n' + body);
        if (body == null || body == '') {
            return detailMap;
        }

        JSONParser parser = JSON.createParser(body);

        // create List of Details from returned JSON
        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY && parser.getCurrentName() == 'content') {
                while (parser.nextToken() != null && parser.getCurrentName() != 'links') {
                    Details det = (Details)parser.readValueAs(Details.class);
                    if (det == null) {
                        break;
                    }
                    parser.skipChildren();
                    detailMap.put(det.instelling_nummer, det);
                }
            }
        }

        return detailMap;
    }

    public static Map<Integer, Map<String, Integer>> createBaoDetails(String body) {
        JSONParser parser = JSON.createParser(body);

        // create List of Details from returned JSON
        Map<Integer, Map<String, Integer>> detailsPeKg = new Map<Integer, Map<String, Integer>>();
        
        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY && parser.getCurrentName() == 'content') {
                while (parser.nextToken() != null && parser.getCurrentName() != 'links') {
                    baoDetails det = (baoDetails)parser.readValueAs(baoDetails.class);
                    if (det == null) {
                        break;
                    }
                    parser.skipChildren();
                    
                    if (detailsPeKg.containsKey(det.instelling_nummer)) {

                        if (det.administratievegroep_omschrijving == 'Kleuterklas') {
                            // Add to KG students
                            if (detailsPeKg.get(det.instelling_nummer).containsKey('KG')) { // Add
                                detailsPeKg.get(det.instelling_nummer).put('KG',detailsPeKg.get(det.instelling_nummer).get('KG') + det.aantal_inschrijvingen.totaal);
                            } else { // Create
                                detailsPeKg.get(det.instelling_nummer).put('KG',det.aantal_inschrijvingen.totaal);
                            }
                        } else {
                            // Add to PE students
                            if (detailsPeKg.get(det.instelling_nummer).containsKey('PE')) { // Add
                                detailsPeKg.get(det.instelling_nummer).put('PE',detailsPeKg.get(det.instelling_nummer).get('PE') + det.aantal_inschrijvingen.totaal);
                            } else { // Create
                                detailsPeKg.get(det.instelling_nummer).put('PE',det.aantal_inschrijvingen.totaal);
                            }
                        }
                    } else {

                        Map<String, Integer> tempMap = new Map<String, Integer>();

                        if (det.administratievegroep_omschrijving == 'Kleuterklas') {
                            // Add to KG students
                            tempMap.put('KG',det.aantal_inschrijvingen.totaal);
                        } else {
                            // Add to PE students
                            tempMap.put('PE',det.aantal_inschrijvingen.totaal);
                        }
                        detailsPeKg.put(det.instelling_nummer,tempMap);
                    }
                }
            }
        }

        return detailsPeKg;
    }

    // public static Map<Integer, Map<String, Integer>> createPeKgMap(Map<Integer, baoDetails> baoDetailMap) {
    //     for (Integer externalCustumerNumber : baoDetailMap.keySet()) {

    //     }
    // }

    public class baoDetails {
        public Integer schooljaar;
        public Integer instelling_nummer;
        public String instelling_naam;
        public Integer instellingslocatie_vestigingsnummer;
        public String instellingslocatie_postcode;
        public String instellingslocatie_gemeente;
        public Integer administratievegroep_code;
        public String administratievegroep_omschrijving;
        public aantal_inschrijvingen aantal_inschrijvingen;
    }

    public class aantal_inschrijvingen {
        public Integer totaal;
        public Integer man;
        public Integer vrouw;
    }

    public class Details {
        public Integer schooljaar;
        public Integer instelling_nummer;
        public String instelling_naam;
        public String instellingslocatie_postcode;
        public String instellingslocatie_gemeente;
        public Integer aantal_inschrijvingen;
    }
}