@isTest
public class UTIL_TestDatafactory {
    
    public static List<Account> createAccounts(integer count, Boolean doinsert) {
        
        List<Account> Accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            Account a = new Account();
            a.Name = 'Test Account ' + (i + 1);
            a.NumberofStudents__c = 1;
            a.OperatingCompany__c = 'Plantyn';
            a.Area__c = 'Dutch';
            accounts.add(a);
        }
        if (doinsert) {
            insert accounts;
        }

        return accounts;
    }

    public static List<Contact> createContacts(integer numberOfContactsPerAccount, List<Account> accounts, Boolean doInsert) {
        
        List<Contact> contacts = new List<Contact>();
        for (Account account : accounts) {
            for (Integer i = 0; i < numberOfContactsPerAccount; i++) {
                Contact c = new Contact();
                c.FirstName = 'Test';
                c.LastName = 'Contact ' + (i + 1);
                c.Email = 'email' + i + '@test.com';
                c.Accountid = account.Id;
                contacts.add(c);
            }
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static List<Contact> createContactsForEmailMatchingOnTeacherSchoolNumber(integer numberOfContactsPerAccount, List<Account> accounts, Boolean doInsert) {
        
        List<Contact> contacts = new List<Contact>();
        for (Account account : accounts) {
            for (Integer i = 0; i < numberOfContactsPerAccount; i++) {
                Contact c = new Contact();
                c.FirstName = 'Test';
                c.LastName = 'Contact ' + (i + 1);
                c.Email = 'email@test.com';
                c.TeacherSchoolNumber__c = '123456789';
                c.Accountid = account.Id;
                contacts.add(c);
            }
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static List<Contact> createContactsForEmailMatchingOnAccount(integer count, Account account, Boolean doInsert) {

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            Contact c = new Contact();
            c.FirstName = 'Test2';
            c.LastName = 'Contact2 ' + (i + 1);
            c.Email = 'email2@test.com';
            c.AccountId = account.Id;
            contacts.add(c);
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

    public static List<Contact> createContactsDorTeacherNumberMatching(Integer count, List<Account> accounts, Boolean doInsert) {

        List<Contact> contacts = new List<Contact>();
        for (Account account : accounts) {
            for (Integer i = 0; i < count; i++) {
                Contact c = new Contact();
                c.FirstName = 'Test3';
                c.LastName = 'Test3 ' + (i + 1);
                c.Email = 'email3@test.com';
                c.TeacherNumber__c = '987654321';
                c.AccountId = account.Id;
                contacts.add(c);
            }
        }
        if (doInsert) {
            insert contacts;
        }
        return contacts;
    }

}