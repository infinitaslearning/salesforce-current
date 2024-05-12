global with sharing class ImportOrder_BatchInsertUtility implements Database.Batchable<sObject>,Schedulable {
    global ImportOrder_BatchInsertUtility() {
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([SELECT Id  FROM Account LIMIT 50]  ); // Dummy Query yo just get 200 records for the count to execute 200 times for batch
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        
        String response = ImportOrder_ApiInsertUtility.dummyInsertImportOrders();
    System.debug('response: ' + response);
    
        /*
        List<ImportOrder__c> importOrderList = new List<ImportOrder__c>();
        
        for(Account dummyAccount : scope){
            
            Integer randomNumber = Integer.valueof((Math.random() * 1000));
            ImportOrder__c ioHeader = new ImportOrder__c();
            ioHeader.ExternalOrderId__c = 'BatchIndvTest' + randomNumber;
            ioHeader.customerNo__c = '0';
            ioHeader.orderDate__c = '14/04/2022';
            ioHeader.LineCount__c = 1;
            ioHeader.Source__c = 'eCommerce B2B';
            ioHeader.addressLine1__c = 'Lange Nieuwstraat 125';
            ioHeader.City__c = 'Utrecht';
            ioHeader.Country__c = 'Netherlands';
            ioHeader.Postalcode__c = '3512 PG';
            ioHeader.BillingStreet__c = 'Lange Nieuwstraat 125';
            ioHeader.BillingCity__c = 'Utrecht';
            ioHeader.BillingCountry__c = 'Netherlands';
            ioHeader.BillingPostalCode__c = '3512 PG';
            ioHeader.OperatingCompany__c = 'Plantyn';
            ioHeader.FirstName__c = 'Trail';
            ioHeader.LastName__c = 'Blazer';
            ioHeader.UserEmail__c = ioHeader.FirstName__c + ioHeader.LastName__c + randomNumber + '@example.nl';
            ioHeader.CommunicationLanguage__c = 'nl-NL';
            ioHeader.customerOrderType__c = 'private';
            ioHeader.deliveryIdLocation__c = '0';
            ioHeader.invoiceIdLocation__c = '0';
            importOrderList.add(ioHeader);
            
            ImportOrder__c ioLine = new ImportOrder__c();
            ioLine.ProductId__c = '9789633493410';
            ioLine.quantity__c = 1;
            ioLine.ExternalOrderId__c = 'BatchIndvTest' + randomNumber;
            ioLine.customerNo__c = '0';
            ioLine.orderDate__c = '14/04/2022';
            ioLine.Source__c = 'eCommerce B2B';
            ioLine.addressLine1__c = 'Lange Nieuwstraat 125';
            ioLine.City__c = 'Utrecht';
            ioLine.Country__c = 'Netherlands';
            ioLine.Postalcode__c = '3512 PG';
            ioLine.BillingStreet__c = 'Lange Nieuwstraat 125';
            ioLine.BillingCity__c = 'Utrecht';
            ioLine.BillingCountry__c = 'Netherlands';
            ioLine.BillingPostalCode__c = '3512 PG';
            ioLine.OperatingCompany__c = 'Plantyn';
            ioLine.TriggerBusinessLogic__c = false;
            ioLine.customerOrderType__c = 'private';
            importOrderList.add(ioLine);
        }
        
        try{
            insert importOrderList;
        }
        catch(exception e){
            HandleCustomException.LogException(e,importOrderList[0].id);
        }
        */
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
    global void execute(SchedulableContext sc){
        
        ImportOrder_BatchInsertUtility  InsertUtility = new ImportOrder_BatchInsertUtility();
        database.executebatch(InsertUtility ,1);
    }
    
}