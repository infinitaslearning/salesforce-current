/*/
*  Brite created this class to convert lead  
*  Addition created by Jannes keerebezem to return the converted Account, Contact and Opportunity
/*/

public class IL_LeadConversion {
    
/*/
*  This method validate the exisitng data and decide 
*  if we have convert to existing data or create new data
*  label='Convert Lead' description='Convert the lead based on values .' category='lead'
/*/
    @InvocableMethod
    public static List<fieldWrapperRecords> fetchInvocableData (list<list<lead>> leadListCollection){

        System.debug('leadListCollection = ' + leadListCollection);

        List<fieldWrapperRecords> returnedFieldWrapper = new List<fieldWrapperRecords>();

        // Get Tasks and Events
        Set<Id> leadIdsForTasksAndEvents = new Set<Id>();
        for(list<lead> leadList : leadListCollection ){
            for (Lead l : leadList) {
                leadIdsForTasksAndEvents.add(l.Id);
            }
        }
        List<Task> tasks = [SELECT Id, WhoId FROM Task WHERE WhoId IN :leadIdsForTasksAndEvents];
        List<Event> events = [SELECT Id, WhoId FROM Event WHERE WhoId IN :leadIdsForTasksAndEvents];

        for(list<lead> leadList : leadListCollection ){
            List<Task> taskLst = new List<Task>();
            List<Event> eventLst = new List<Event>();
            for(Lead l : leadList) {
                for(Task t :tasks) {
                    if (t.WhoId == l.Id) {
                        taskLst.add(t);
                    }
                }
                for (Event e :events) {
                    if (e.WhoId == l.Id) {
                        eventLst.add(e);
                    }
                }
            }
            returnedFieldWrapper.add(checkData(leadList, taskLst, eventLst));
        }
        return returnedFieldWrapper;
    }
    
    //this method can be used for trigger or in the normal apex context
    public static fieldWrapperRecords checkData (list<lead> leadList, List<Task> tasks, List<Event> events){
        
        
        //varaibles with lead id as key to determine the existing data
        map<id,id> accMap = new map<id,id> ();
        map<id,id> conMap = new map<id,id> ();
        map<id,id> oppMap = new map<id,id> ();
        map<id,boolean> DcreateOppMap = new map<id,boolean> ();
        Map<String,String> convertResults = new Map<String,String>();
        string stats = getConversionStatus() ;
        
        fieldWrapper fw = new fieldWrapper();

        Set<Id> leadIds = new Set<Id>();

        for(lead ld : leadList) { 
            leadIds.add(ld.Id);
        }

        for(lead ld : leadList) {
            
            if(ld.ReadytoConvert__c){
                
                if(String.isNotBlank(ld.Account__c)){
                    accMap.put(ld.id,ld.Account__c);
                }
                
                if(String.isNotBlank(ld.Contact__c)){
                    conMap.put(ld.id,ld.Contact__c);
                }
                
                if(String.isNotBlank(ld.Opportunity__c)){
                    oppMap.put(ld.id,ld.Opportunity__c);
                } else {
                    oppMap.put(ld.id,ld.id);
                }
                
                if(ld.AutoConvertCreateOpportunity__c){
                    DcreateOppMap.put(ld.id,false);
                }else {
                    DcreateOppMap.put(ld.id,true);
                }

                System.debug('IL_LeadConversion - Convert Lead Varables:\n### ld.id: ' + ld.id + 
                '\nIL_LeadConversion - ### stats: ' + stats +
                '\nIL_LeadConversion - ### accMap.get(ld.id): ' + accMap.get(ld.id) +
                '\nIL_LeadConversion - ### conMap.get(ld.id): ' + conMap.get(ld.id) +
                '\nIL_LeadConversion - ### oppMap.get(ld.id): ' + oppMap.get(ld.id) + 
                '\nIL_LeadConversion - ### DcreateOppMap.get(ld.id): ' + DcreateOppMap.get(ld.id));
                

                convertResults = convertLead(ld.id,stats,accMap.get(ld.id),conMap.get(ld.id),oppMap.get(ld.id),DcreateOppMap.get(ld.id));
                System.debug('IL_LeadConversion - convertResults = ' + convertResults);
                
                System.debug('IL_LeadConversion - convertResults.get(\'AccountId\') = ' + convertResults.get('AccountId') );
                System.debug('IL_LeadConversion - convertResults.get(\'ContactId\') = ' + convertResults.get('ContactId'));
                System.debug('IL_LeadConversion - convertResults.get(\'OpportunityId\') = ' + convertResults.get('OpportunityId'));

                if(convertResults != null && !convertResults.isEmpty()) {
                    Id AccountId = convertResults.get('AccountId');
                    Id ContactId = convertResults.get('ContactId');
                    String OpportunityId = convertResults.get('OpportunityId');
                    fw.AccountIds.add(AccountId);
                    fw.ContactIds.add(ContactId);
                    fw.OpportunityIds.add(OpportunityId);
                    Date closeDate;
                    if (ld.Sales_season__c != null && ld.Sales_season__c != '') {
                        closeDate = Date.newInstance(Integer.ValueOf(ld.Sales_season__c.right(4)), 7, 31);
                     } else if(Date.today().month() < 7 || (Date.today().month() == 7 && Date.today().day() < 31)) {
                        closeDate = Date.newInstance(Date.today().year(), 7, 31);
                     } else {
                        closeDate = closeDate = Date.newInstance(Date.today().year()+1, 7, 31);
                     }
                     fw.closeDates.add(closeDate);

                }

            }

        }

        List<Opportunity> oppUpdateLst = new List<Opportunity>();
        for (Integer i = 0; i < fw.OpportunityIds.size(); i++) {
            if (fw.OpportunityIds[i] != null && fw.OpportunityIds[i] != '') {
                Opportunity opp = new Opportunity();
                opp.Id = fw.OpportunityIds[i];
                opp.CloseDate = fw.closeDates[i];
                oppUpdateLst.add(opp);
            }
        }

        update oppUpdateLst;

        Map<Id,Id> taskIdWhoIds = new Map<Id,Id>();
        for (Task t : tasks) {
            System.debug('Task Id: ' + t.Id + ' // Task WhoId: ' + t.WhoId);
            taskIdWhoIds.put(t.Id,t.WhoId);
        }

        Map<Id,Id> eventIdWhoIds = new Map<Id,Id>();
        for (Event e : events) {
            System.debug('Event Id: ' + e.Id + ' // Event WhoId: ' + e.WhoId);
            eventIdWhoIds.put(e.Id,e.WhoId);
        }

        System.debug('oppMap.size() ==> ' + oppMap.size());
        if(oppMap.size() > 0) {
            addTasksToOpportunities(oppMap, taskIdWhoIds, eventIdWhoIds);
        }
       
        Map<Id,Account> convertedAccs = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :fw.AccountIds]);
        Map<Id,Contact> convertedCons = new Map<Id,Contact>([SELECT Id, Name, IsInactive__c FROM Contact WHERE Id IN :fw.ContactIds]);
        Map<Id,Opportunity> convertedopps = new Map<Id,Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN :fw.OpportunityIds]);

        fieldWrapperRecords fwr = new fieldWrapperRecords();
        for (Integer i = 0; i < fw.AccountIds.size(); i++) {
            fwr.Accounts.add(convertedAccs.get(fw.AccountIds[i]));
            fwr.Contacts.add(convertedCons.get(fw.ContactIds[i]));
            fwr.Opportunities.add(convertedOpps.get(fw.OpportunityIds[i]));
        }
       
        return fwr;
    }
    
    //this method is used to set the Lead conversion status 
    public static string getConversionStatus () {
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        
        if(String.isNotBlank(string.valueOf(convertStatus.MasterLabel))){
            return string.valueOf(convertStatus.MasterLabel);
        }else {
            return 'Converted';
        }
    }
    
    //this method converts the lead by taking different parameters 
    public static Map<String,String> convertLead(id leadId,string status,string AccountId,
                                      string ContactId,string OpportunityId,Boolean createOpp)
    {
        
        Database.LeadConvert lc = new Database.LeadConvert();
        Database.LeadConvertResult lcr ;
        lc.setLeadId(leadId);
        lc.setConvertedStatus(status);
        lc.setDoNotCreateOpportunity (createOpp);
        
        if(String.isNotBlank(AccountId)){
            lc.setAccountId(accountId);
        }
        
        if(String.isNotBlank(contactId)){
            lc.setContactId(contactId);
        }
        
        if(String.isNotBlank(OpportunityId) && leadId != OpportunityId){
            lc.setOpportunityId(OpportunityId);
        }
        
        try{
            lcr = Database.convertLead(lc);
        }catch (Exception e) {
            list<lead> ldList = new  list<lead>  ();
            lead ld = new lead (id =leadId);
            ld.AutoConvertError__c = e.getMessage();
            System.debug('ERROR: ' + e.getMessage());
            ld.AutoConvert__c = false;
            ldList.add(ld);
            database.update(ldList,false);
        }

        System.debug('lcr = ' + lcr);

        Map<String,String> returnMap = new Map<String,String>();
        if(lcr != null) {
            System.debug('Successfull leadConverse? ' + lcr.isSuccess());
            returnMap.put('ContactId',lcr.getContactId());
            returnMap.put('AccountId',lcr.getAccountId());
            if (!createOpp) {
                returnMap.put('OpportunityId',lcr.getOpportunityId());
                System.debug('IL_LeadConversion - oppId - v1');
            } else {
                if (OpportunityId == leadId) {
                    returnMap.put('OpportunityId',lcr.getOpportunityId());
                    System.debug('IL_LeadConversion - oppId - v2');
                } else {
                    returnMap.put('OpportunityId', OpportunityId);
                    System.debug('IL_LeadConversion - oppId - v3');
                }
            }
        }

        return returnMap ;
        
    }

    @future
    public static void addTasksToOpportunities(Map<Id,Id> leadOpportunityIdMap, Map<Id,Id> taskIdWhoIds, Map<Id,Id> eventIdWhoIds) {
        System.debug('IL_LeadConversion.addTasksToOpportunities');

        // ######################### HANDLE TASKS #########################
        List<Task> taskUpdateList = new List<Task>();
        Set<Id> taskIds = taskIdWhoIds.keySet();
        System.debug('We have ' + taskIds.size() + ' Task Ids');

        List<Task> tasks = [SELECT Id, WhoId FROM Task WHERE Id IN :taskIds];

        // Create OpportunityTask
        for(Task t : tasks) {
            t.WhatId = leadOpportunityIdMap.get(taskIdWhoIds.get(t.Id));
            taskUpdateList.add(t);
            System.debug('Updated Task for Object ==> ' + t.WhatId.getSObjectType().getDescribe().getName());
        }

        try {
            update taskUpdateList;            
        } catch (Exception e) {
            HandleCustomException.LogException(e);
            System.debug('An error occured updating the Task List ==> ' + e.getMessage());
        } 

        // ######################### HANDLE EVENTS #########################

        List<Event> eventUpdateList = new List<Event>();
        Set<Id> eventIds = eventIdWhoIds.keySet();
        System.debug('We have ' + eventIds.size() + ' Event Ids');

        List<Event> events = [SELECT Id, WhoId FROM Event WHERE Id IN :eventIds];

        // Create OpportunityEvent
        for(Event e : events) {
            e.WhatId = leadOpportunityIdMap.get(eventIdWhoIds.get(e.Id));
            eventUpdateList.add(e);
            System.debug('Updated Event for Object ==> ' + e.WhatId.getSObjectType().getDescribe().getName());
        }

        try {
            update eventUpdateList;            
        } catch (Exception e) {
            HandleCustomException.LogException(e);
            System.debug('An error occured updating the Event List ==> ' + e.getMessage());
        } 
    }

    public class fieldWrapper {

        @InvocableVariable(label = 'Account Ids')
        public List<String> AccountIds = new List<Id>();
        
        @InvocableVariable(label = 'Contact Ids')
        public List<String> ContactIds = new List<Id>();
        
        @InvocableVariable(label = 'Opportunity Ids')
        public List<String> OpportunityIds = new List<Id>();

        @InvocableVariable(label = 'close Date')
        public List<Date> closeDates = new List<Date>();
    }

    public class fieldWrapperRecords {

        @InvocableVariable(label = 'Account Ids')
        public List<Account> Accounts = new List<Account>();
        
        @InvocableVariable(label = 'Contact Ids')
        public List<Contact> Contacts = new List<Contact>();
        
        @InvocableVariable(label = 'Opportunity Ids')
        public List<Opportunity> Opportunities = new List<Opportunity>();
    }

}