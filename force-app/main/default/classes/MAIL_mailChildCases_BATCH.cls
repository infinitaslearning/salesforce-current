public class MAIL_mailChildCases_BATCH implements Database.Batchable<sObject> {
    
    public Map<Id,EmailMessage> parentIdEmailMessageMap;
    public List<Id> parentCaseIdList;

    // CLASS PARAMETERS
    public MAIL_mailChildCases_BATCH(List<Id> caseIdList, Map<Id,EmailMessage> parentCaseIdEmailMessageMap) {
        this.parentCaseIdList = caseIdList;
        this.parentIdEmailMessageMap = parentCaseIdEmailMessageMap;
    }

    
    // START METHOD
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id  FROM Case WHERE ParentId IN (' + this.parentCaseIdList + ')';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> scope) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
        for (Case c : scope) {

            if (c.ContactEmail != '' && c.ContactEmail != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(this.parentIdEmailMessageMap.get(c.ParentId).Subject);
                email.setHtmlBody(this.parentIdEmailMessageMap.get(c.ParentId).HtmlBody);
                email.setToAddresses(new String[] {(String) c.ContactEmail});
        
                emails.add(email);
            } else {
                System.debug('Case with Id ' + c.Id + ' does not have a ContactMail.');
            }
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