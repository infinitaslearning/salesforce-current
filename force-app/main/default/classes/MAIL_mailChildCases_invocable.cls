public class MAIL_mailChildCases_invocable {

    // INVOCABLE PARAMETER
    public class FlowInputs {
        @InvocableVariable (label='EmailMessage Record' required = true)
        public EmailMessage emailMessage;
    }
    
    // INVOCABLE METHOD
    @invocablemethod (label='Send Email to Child Cases' description='Insert EmailMessage to send emails to all clild Cases of the Parent case from the Emailmessage' iconName='slds:standard:list_email')
    public static void sendEmailToChildCases(List<FlowInputs> requests) {
        
        List<Id> caseIdList = new List<Id>();
        Map<Id,EmailMessage> parentCaseIdEmailMessageMap = new Map<Id,EmailMessage>();
        for (FlowInputs req : requests) {
            caseIdList.add(req.emailMessage.ParentId);
            parentCaseIdEmailMessageMap.put(req.emailMessage.ParentId, req.emailMessage);
        }

        Id jobId = Database.executeBatch(new MAIL_mailChildCases_BATCH(caseIdList, parentCaseIdEmailMessageMap));
    }

}