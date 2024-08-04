public class SK_SkolverketUpdateByAPI implements Queueable, Database.AllowsCallouts {

    public List<schoolDetails> schoolDetails;
    public List<school> schoolList;
    public Integer maxApiCalls = 75;    // TO PREVENT TIME OUTS
    public List<Integer> schoolFormsToSync = new List<Integer>{1,5,12,15};
        
    public SK_SkolverketUpdateByAPI() {
        schoolDetails = new List<schoolDetails>();
        schoolList = getSchools();
    }

    public SK_SkolverketUpdateByAPI(List<school> schools, List<schoolDetails> schoolDetailList) {
        schoolList = schools;
        schoolDetails = schoolDetailList;
    }

    public void execute(QueueableContext context) {
        
        Integer split = Math.min(schoolList.size(), maxApiCalls);

        List<school> tempSchoolList = new List<school>();
        for (Integer i = 0; i < split; i++) {
            tempSchoolList.add(schoolList.remove(0));
        }

        System.debug('schoolList.size() ==> ' + schoolList.size());

        schoolDetails.addAll(getSchoolDetails(tempSchoolList));
        
        if (!Test.isRunningTest()) {
            if (schoolList.size() != 0) {
                System.enqueueJob(new SK_SkolverketUpdateByAPI(schoolList, schoolDetails));
            } else {
                System.enqueueJob(new SK_getLiberAccountsQueueable(schoolDetails));
            }
        }
    }

    public List<school> getSchools() {
        List<school> returnList = new List<school>();

        String endpoint = 'https://api.skolverket.se/skolenhetsregistret/v1/skolenhet';

        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000); //sets maximum timeout
        req.setMethod('GET');

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        String body = res.getBody();

        Integer statusCode = res.getStatusCode();

        if (statusCode != 200) {
            System.debug('Incorrect Response from API, Statuscode: ' + statusCode);
            body = '';
        }

        if (body == '') {
            return returnList;
        }
        JSONParser parser = JSON.createParser(body);
        
        // Create List of schools from returned JSON
        while (parser.nextToken() != null) {

            if (parser.getCurrentToken() == JSONToken.START_ARRAY && parser.getCurrentName() == 'Skolenheter') {
                while (parser.nextToken() != null) {
                    school school = (school)parser.readValueAs(school.class);
                    if (school == null) {
                        break;
                    }
                    parser.skipChildren();
                    if (school.Status == 'Aktiv') {
                        returnList.add(school);
                    }
                    
                }
            }
        }
        return returnList;
    }

    public List<schoolDetails> getSchoolDetails(List<School> schools) {
        List<schoolDetails> schoolDetailList = new List<schoolDetails>();

        String baseEndpoint = 'https://api.skolverket.se/skolenhetsregistret/v1/skolenhet';

        for (school s : schools) {
            String endpoint = baseEndpoint + '/' + s.Skolenhetskod;
            System.debug('endpoint ==> ' + endpoint);

            // Instantiate a new http object
            Http h = new Http();
            
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setTimeout(60000); //sets maximum timeout
            req.setMethod('GET');

            // Send the request, and return a response
            HttpResponse res = h.send(req);
            String body = res.getBody();

            Integer statusCode = res.getStatusCode();

            if (statusCode != 200) {
                System.debug('Incorrect Response from API, Statuscode: ' + statusCode);
                body = '';
            }

            System.debug('Body ==> ' + body);

            if (body == '') {
                return schoolDetailList;
            }
            JSONParser parser = JSON.createParser(body.replaceAll('"IN":', '"I_P":'));
            
            // Create List of schools from returned JSON
            while (parser.nextToken() != null) {

                System.debug('parser.getCurrentToken() ==> ' + parser.getCurrentToken());
                System.debug('parser.getCurrentName() ==> ' + parser.getCurrentName());

                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'SkolenhetInfo') {

                    System.debug('parser.nextToken() ==> ' + parser.nextToken());
                    System.debug('parser.getText() ==> ' + parser.getText());

                    schoolDetails schoolDetail = (schoolDetails)parser.readValueAs(schoolDetails.class);
                    System.debug('schoolDetail.Status ==> ' + schoolDetail.Status);
                    
                    if (schoolDetail == null) {
                        break;
                    }
                    parser.skipChildren();
                    if (schoolDetail.Status == 'Aktiv' && schoolDetail.Skolformer != null && schoolDetail.Skolformer.size() > 0) {
                        Boolean addSchool = false;
                        for (Skolformer sf : schoolDetail.Skolformer) {
                            if (schoolFormsToSync.contains(sf.SkolformID)) {
                                addSchool = true;
                            }
                        }
                        if (addSchool) {
                            schoolDetailList.add(schoolDetail);
                        }
                    }
                }
            }
        }
        return schoolDetailList;
    }

    public class school {
        public String Skolenhetskod;
        public String Kommunkod;
        public String PeOrgNr;
        public String Skolenhetsnamn;
        public String Status;
    }

    public class schoolDetails {
        public String Namn;
		public String Rektorsnamn;
		public String Skolenhetskod;
		public String Epost;
		public String Telefon;
		public String Webbadress;
		public Besoksadress Besoksadress;
		public Leveransadress Leveransadress;
		public Leveransadress Utdelningsadress;
		public String Inriktningstyp;
		public String Skolenhetstyp;
		public String SkolaNamn;
		public List<Skolformer> Skolformer;
		public Kommun Kommun;
		public Huvudman Huvudman;
		public String Skolenhet_ValidFrom;
		public String Status;
		public String Startdatum;
		public String Nedlaggningsdatum;
    }

    public class Besoksadress {
		public String Adress;
		public String Postnr;
		public String Ort;
		public GeoData GeoData;
	}

    public class Leveransadress {
		public String Adress;
		public String Postnr;
		public String Ort;
	}

    public class Kommun {
		public String Kommunkod;
		public String Namn;
	}

    public class Huvudman {
		public String PeOrgNr;
		public String Namn;
		public String Typ;
	}

    public class GeoData {
		public String Koordinat_SweRef_E;
		public String Koordinat_SweRef_N;
		public String Koordinat_WGS84_Lat;
		public String Koordinat_WGS84_Lng;
		public String Punkttyp;
	}

    public class Skolformer {
		public String type;
		public String Benamning;
		public Integer SkolformID;
		public String SkolformKod;
        public String CSNKod;
        public Boolean BA;
        public Boolean BF;
        public Boolean EE;
        public Boolean EK;
        public Boolean ES;
        public Boolean FS;
        public Boolean FT;
        public Boolean FX;
        public Boolean HA;
        public Boolean HT;
        public Boolean HU;
        public Boolean HV;
        public Boolean I_P;
        public Boolean MX;
        public Boolean NA;
        public Boolean NB;
        public Boolean RL;
        public Boolean SA;
        public Boolean SX;
        public Boolean TE;
        public Boolean TX;
        public Boolean UX;
        public Boolean VF;
        public Boolean VO;
        public Boolean YX;
	}
}