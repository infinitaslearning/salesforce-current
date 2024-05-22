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
        OrgWideEmailAddress noordhoffOWEA,plantynOWEA,liberOWEA,noordhoffZorgOWEA,fallBackOWEA,devSandboxOWEA;
        EmailTemplate template;
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, EmailSignature__c FROM User WHERE Id = :currentUserId LIMIT 1];
        String userSignature = 'TeamServices<br>Noordhoff';
        if (currentUser.EmailSignature__c != null && currentUser.EmailSignature__c != '') {
            userSignature = currentUser.EmailSignature__c.replaceAll('\r\n|\n|\r','<br>');
        }
        
        try {
            Organization ORG = [Select Id, Name, IsSandbox from Organization];
            
            if (ORG.IsSandbox && ORG.Id != '00D0E000000E6pgUAC') { // For Developer sandboxes (no-reply e-mailaddress is not available there)
                devSandboxOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'bsc-support@infinitaslearning.com' LIMIT 1];
                noordhoffOWEA = devSandboxOWEA;
                plantynOWEA = devSandboxOWEA;
                liberOWEA = devSandboxOWEA;
                noordhoffZorgOWEA = devSandboxOWEA;
                fallBackOWEA = devSandboxOWEA;
            }
            else if ((ORG.IsSandbox && ORG.Id == '00D0E000000E6pgUAC') || Test.isRunningTest()) { // FOR UAT Sandbox & test in Production
                noordhoffOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@noordhoff.nl' LIMIT 1];
                plantynOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1]; // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                liberOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1]; // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                noordhoffZorgOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1];  // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                fallBackOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1]; // FALLBACK
            }
            else { // FOR PRODUCTION
                noordhoffOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@noordhoff.nl' LIMIT 1];
                plantynOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1]; // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                liberOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1]; // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                noordhoffZorgOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1];  // TO BE DECIDED -- NEEDS TO BE IN Organization-Wide Email Addresses
                fallBackOWEA = [SELECT Id FROM OrgWideEmailAddress WHERE Purpose = 'DefaultNoreply' LIMIT 1]; // FALLBACK
            }
            
        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }
        

        for (Case parent : scope) {

            Id oweaId;
            Boolean mailCase = true;
            String templateName = '';

            if (parent.OperatingCompany__c == 'Noordhoff') {
                oweaId = noordhoffOWEA.Id;
                templateName = 'NoordhoffChildCaseTemplate';
            } else if (parent.OperatingCompany__c == 'Plantyn') {
                oweaId = plantynOWEA.Id;
                templateName = 'plantynChildCaseTemplate';
            } else if (parent.OperatingCompany__c == 'Liber') {
                oweaId = liberOWEA.Id;
                templateName = 'liberChildCaseTemplate';
            } else if (parent.OperatingCompany__c == 'Noordhoff Zorg') {
                oweaId = noordhoffZorgOWEA.Id;
                templateName = 'noordhoffProfessinoalChildCaseTemplate';
            } else {
                System.debug('Case has no OpperatingCompany');
            }

            if (Test.isRunningTest()) {
                templateName = 'NoordhoffChildCaseTemplate';
            }

            template = [SELECT Id, htmlValue, Body, subject FROM EmailTemplate WHERE DeveloperName = :templateName];

            String htmlBody = template.htmlValue;
            String name = 'Meneer/Mevrouw';
            String emailAddress;

            if (parent.ContactId != null && parent.ContactFirstName__c != '') {
                name = parent.ContactFirstName__c;
                emailAddress = parent.ContactEmail;
            } else if (parent.SuppliedName != null && parent.SuppliedName != '') {
                name = parent.SuppliedName;
                emailAddress = parent.SuppliedEmail;
            } else {
                mailCase = false;
                System.debug('We dont have a contact and supplied e-mail for case with Id ' + parent.Id);
            }

            System.debug('Name = ' + name);

            if (this.idInputMap.get(parent.Id).doMailParentCase && mailCase) {
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

            if (this.idInputMap.get(parent.Id).childCases != null && this.idInputMap.get(parent.Id).childCases.size() > 0) {
                for (Case child : this.idInputMap.get(parent.Id).childCases) {
                    mailCase = true;
                    if (child.ContactId != null && parent.ContactFirstName__c != '') {
                        name = child.ContactFirstName__c;
                        emailAddress = child.ContactEmail;
                    } else if (child.SuppliedName != null && child.SuppliedName != '') {
                        name = child.suppliedName;
                        emailAddress = child.SuppliedEmail;
                    } else {
                        name = 'Mijnheer/Mevrouw';
                        mailCase = false;
                        System.debug('We dont have a contact and supplied e-mail for case with Id ' + child.Id);
                    }

                    System.debug('Name = ' + name);
                    if (mailCase) {
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



            /** OLD 
            if (parent.Cases != null && parent.Cases.size() > 0) {
                for (Case child : parent.Cases) {
                    mailCase = true;
                    if (child.ContactId != null) {
                        name = child.contact.FirstName + ' ' + child.Contact.LastName;
                        emailAddress = child.ContactEmail;
                    } else if (child.SuppliedName != null && child.SuppliedName != '') {
                        name = child.suppliedName;
                        emailAddress = child.SuppliedEmail;
                    } else {
                        name = 'Mijnheer/Mevrouw';
                        mailCase = false;
                        System.debug('We dont have a contact and supplied e-mail for case with Id ' + child.Id);
                    }
                    if (mailCase) {
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
            */

        }
    
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
    
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