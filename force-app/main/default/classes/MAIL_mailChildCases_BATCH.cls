public class MAIL_mailChildCases_BATCH implements Database.Batchable<sObject> {
    
    public Map<Id, FlowInputs> idInputMap;

    public MAIL_mailChildCases_BATCH(Map<Id, FlowInputs> caseIdFlowInputMap) {
        this.idInputMap = caseIdFlowInputMap;
    }

    // INVOCABLE PARAMETER
    public class FlowInputs {
        @InvocableVariable (label='Parent Case' required = true)
        public Case parentCase;
        @InvocableVariable (label='Child Cases' required = true)
        public List<Case> childCases;
        @InvocableVariable (label='Title' required = true)
        public String title;
        @InvocableVariable (label='Body' required = true)
        public String body;
        @InvocableVariable (label='Also Mail parent Case' required = true)
        public Boolean doMailParentCase;
    }
    
    // INVOCABLE METHOD
    @invocablemethod (label='Send Email to Child Cases' description='Insert ParentCase to send emails to all clild Cases' iconName='slds:standard:list_email')
    public static void sendEmailToChildCases(List<FlowInputs> requests) {
        
        Map<Id, FlowInputs> caseIdFlowInputMap = new Map<Id, FlowInputs>();
        
        for (FlowInputs req : requests) {
            caseIdFlowInputMap.put(req.parentCase.Id, req);
        }

        Id jobId = Database.executeBatch(new MAIL_mailChildCases_BATCH(caseIdFlowInputMap));
    }

    
    // START METHOD
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        System.debug('this.idInputMap ==> ' + this.idInputMap);
        List<String> idList = new List<String>();
        for (Id idFromList : this.idInputMap.keySet())  {
            idList.add('\'' + idFromList  + '\'');
        }

        String query = 'SELECT Id, ContactEmail, ContactId, ContactFirstName__c, SuppliedName, SuppliedEmail, ParentId, OperatingCompany__c FROM Case WHERE Id IN ' + idList;
        System.debug('Query = ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> scope) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress noordhoffOWEA,plantynOWEA,liberOWEA,noordhoffProfessionalOWEA,fallBackOWEA,devSandboxOWEA;
        EmailTemplate template;
        Id currentUserId = UserInfo.getUserId();
        
        // Get emailsignature of current user
        User currentUser = [SELECT Id, EmailSignature__c FROM User WHERE Id = :currentUserId LIMIT 1];
        String userSignature = 'TeamServices<br>Noordhoff';                                                                 // Backup for when user emailsignature is empty
        if (currentUser.EmailSignature__c != null && currentUser.EmailSignature__c != '') {
            userSignature = currentUser.EmailSignature__c.replaceAll('\r\n|\n|\r','<br>');
        }
        
        // Get email Templates
        try {
            Organization ORG = [Select Id, Name, IsSandbox from Organization];
            
            if (ORG.IsSandbox && ORG.Name == 'DevCentral') {                                                          // For Developer sandboxes (no-reply e-mailaddress is not available there)
                devSandboxOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'bsc-support@infinitaslearning.com' LIMIT 1];
                noordhoffOWEA = devSandboxOWEA;
                plantynOWEA = devSandboxOWEA;
                liberOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@liber.se' LIMIT 1];   
                noordhoffProfessionalOWEA = devSandboxOWEA;
                fallBackOWEA = devSandboxOWEA;
            }
            else if ((ORG.IsSandbox && ORG.Name == 'UAT') || Test.isRunningTest()) {                           // FOR UAT Sandbox & test in Production
                noordhoffOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@noordhoff.nl' LIMIT 1];
                plantynOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1];                // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                liberOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@liber.se' LIMIT 1];                 
                noordhoffProfessionalOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1];  // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                fallBackOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1];               // FALLBACK
            }
            else { // FOR PRODUCTION
                noordhoffOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@noordhoff.nl' LIMIT 1];
                plantynOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1];                // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                liberOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@liber.se' LIMIT 1];                  
                noordhoffProfessionalOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1];  // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                fallBackOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1];               // FALLBACK
            }
            
        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }
        

        // Creation of emails
        for (Case parent : scope) {

            Id oweaId;
            Boolean mailCase = true;
            String templateName = '';

            // Check what template to use
            if (parent.OperatingCompany__c == 'Noordhoff') {
                oweaId = noordhoffOWEA.Id;
                templateName = CaseManagement__mdt.getInstance('Noordhoff').ChildCase_Template__c;
            } else if (parent.OperatingCompany__c == 'Plantyn') {
                oweaId = plantynOWEA.Id;
                templateName = CaseManagement__mdt.getInstance('Plantyn').ChildCase_Template__c;
            } else if (parent.OperatingCompany__c == 'Liber') {
                oweaId = liberOWEA.Id;
                templateName = CaseManagement__mdt.getInstance('Liber').ChildCase_Template__c;
            } else if (parent.OperatingCompany__c == 'Noordhoff Zorg') {
                oweaId = noordhoffProfessionalOWEA.Id;
                templateName = CaseManagement__mdt.getInstance('NoordhoffZorg').ChildCase_Template__c;
            } else {
                System.debug('Case has no OpperatingCompany');
            }

            if (Test.isRunningTest()) {
                templateName = 'NoordhoffChildCaseTemplate';
            }

            // Query Template
            template = [SELECT Id, htmlValue, Body, subject FROM EmailTemplate WHERE DeveloperName = :templateName];


            // Email variables
            String htmlBody = template.htmlValue;
            String name = 'Meneer/Mevrouw';
            String emailAddress;

            // Get Name
            if (parent.ContactId != null && parent.ContactFirstName__c != null && parent.ContactFirstName__c != '') {   // Get Name from Contact
                name = parent.ContactFirstName__c;
            } else if (parent.SuppliedName != null && parent.SuppliedName != '') {                                      // Else get Name from SuppliedName
                name = parent.SuppliedName;
            } else {
                System.debug('We dont have a contact and supplied Name for case with Id ' + parent.Id);
            }

            // Get Email
            if (parent.ContactId != null && parent.ContactEmail != '' && parent.ContactEmail != null) {                 // Get Name from Contact
                emailAddress = parent.ContactEmail;
            } else if (parent.SuppliedEmail != null && parent.SuppliedEmail != '') {                                    // Else get Email from SuppliedEmail
                emailAddress = parent.SuppliedEmail;
            } else {                                                                                                    // If we dont have an e-mail address don't create Mail
                mailCase = false;
                System.debug('We dont have a contact and supplied e-mail for case with Id ' + parent.Id);
            }

            if (this.idInputMap.get(parent.Id).doMailParentCase && mailCase) {                                          // Create mail for Parent Case if Mail Parent Case is checked and if we have an e-mailaddress

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(this.idInputMap.get(parent.Id).title);
                email.setHtmlBody(htmlBody.replace('### replace this text ###', idInputMap.get(parent.Id).body.replaceAll('\r\n|\n|\r','<br>')).replace('{!Case.Contact}', name).replace('### UserSignature ###', userSignature));
                email.setToAddresses(new String[] {(String) emailAddress});
                email.setSaveAsActivity(true);
                email.setWhatId(parent.Id);

                if (oweaId != null) {
                    email.setOrgWideEmailAddressId(oweaId);
                }
        
                emails.add(email);
                System.debug('Added EmailMessage: ' + email);
            }

            if (this.idInputMap.get(parent.Id).childCases != null && this.idInputMap.get(parent.Id).childCases.size() > 0) { // Check if we have childCases
                for (Case child : this.idInputMap.get(parent.Id).childCases) {
                    mailCase = true;
                    
                    // Get Name
                    if (child.ContactId != null && child.ContactFirstName__c != null && child.ContactFirstName__c != '') {  // Get Email and Name from Contact
                        name = child.ContactFirstName__c;
                    } else if (child.SuppliedName != null && child.SuppliedName != '') {                                    // Else get Email and Name from Supplies info (SuppliedEmail and SuppliedName fields)
                        name = child.suppliedName;
                    } else {
                        name = 'Mijnheer/Mevrouw';
                        System.debug('We dont have a contact and supplied Name for case with Id ' + child.Id);
                    }

                    // Get Email
                    if (child.ContactId != null && child.ContactEmail != '' && child.ContactEmail != null) {                // Get Email from Contact
                        emailAddress = child.ContactEmail;
                    } else if (child.SuppliedEmail != null && child.SuppliedEmail != '') {                                  // Else get Email from SuppliedEmail
                        emailAddress = child.SuppliedEmail;
                    } else {                                                                                                // If we dont have an e-mail address don't create Mail
                        mailCase = false;
                        System.debug('We dont have a contact and supplied e-mail for case with Id ' + child.Id);
                    }

                    // Create mail for Child Cases if we have an e-mailaddress
                    if (mailCase) { 

                        System.debug('CaseId = ' + child.Id + ' // Name = ' + name + ' // Usersignature = '  + userSignature);

                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setSubject(this.idInputMap.get(parent.Id).title);
                        email.setHtmlBody(htmlBody.replace('### replace this text ###', idInputMap.get(parent.Id).body.replaceAll('\r\n|\n|\r','<br>')).replace('{!Case.Contact}', name).replace('### UserSignature ###', userSignature));
                        email.setToAddresses(new String[] {(String) emailAddress});
                        email.setSaveAsActivity(true);
                        email.setWhatId(child.Id);

                        if (oweaId != null) {
                            email.setOrgWideEmailAddressId(oweaId);
                        }
                
                        emails.add(email);
                        System.debug('Added EmailMessage: ' + email);
                    } else {
                        System.debug('We do not have a ContactEmail on case with Id ' + child.Id);
                    }
                }
            } else {
                System.debug('Parent Case has no child cases.');
            }


        }
    
        // Send emails
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
    
        // check result of sending of the e-mails
        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess()) {
                // Email sent successfully
                System.debug('Email sent successfully');
            } else {
                // Handle any errors or exceptions
                System.debug('Error sending email: ' + result.getErrors()[0].getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        
    }
}