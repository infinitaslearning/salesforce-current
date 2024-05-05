public with sharing class UTIL_GetContactIds {

    @InvocableMethod(label = 'Get Contacts by OpCo and Email' description = 'Returns a list of Contacts corresponding to the input OpCo + Email (Searches in Email and Private Email).' category = 'Contact')
    public static List<returnWrapper> getContactsByOpcoAndEmail(List<fieldwrapper> fieldwrappers) {
        

        List<returnWrapper> returnList = new List<returnWrapper>();
        for (fieldwrapper fw : fieldwrappers) {

            String Email = fw.Email;

            String query = 'SELECT Id FROM Contact WHERE (Email = \'' + Email + '\' OR PrivateEmail__c = \'' + Email + '\')';
            if (fw.OpCo != null) {
                string OpCo = fw.OpCo;
                query += ' AND OperatingCompany__c = \'' + OpCo + '\'';
            } else {
                query += ' AND OperatingCompany__c = null';
            }

            System.debug(LoggingLevel.INFO, 'query = ' + query);

            returnWrapper rw = new returnWrapper();
            rw.ContactList = Database.query(query);

            returnList.add(rw);
        }
        
        return returnList;
    }

    public class fieldwrapper {
        
        @InvocableVariable(label = 'OperatingCompany')
        public String OpCo;

        @InvocableVariable(label = 'Email')
        public String Email;

    }

    public class returnWrapper {

        @InvocableVariable(label = 'Contact List')
        public List<Contact> ContactList;
    }

}