public class FRM_firstReleaseManagementHelper {

    @AuraEnabled(cacheable=true)
    public static List<firstReleasePartner__c> getFirstReleasePartners(){
        System.debug('FRM_firstReleaseManagementHelper.getFirstReleasePartners');

        Id curentUserId = UserInfo.getUserId();
        String Opco = [SELECT OperatingCompany__c FROM User WHERE Id = :curentUserId LIMIT 1].OperatingCompany__c;
        List<firstReleasePartner__c> frpList = [SELECT Id, Quantity__c, Account__c, Account__r.Name, (SELECT Id, Quantity__c, Product__c, Product__r.Name FROM FirstReleasePartnerProducts__r) FROM firstReleasePartner__c WHERE OperatingCompany__c = :OpCo];

        return frpList;
    }

    @AuraEnabled
    public static List<firstReleasePartner__c> createFirstReleasePartner(String accountId, Integer quantity) {
        System.debug('FRM_firstReleaseManagementHelper.createFirstReleasePartner');
        
        firstReleasePartner__c frp = new firstReleasePartner__c();
        frp.Account__c = accountId;
        frp.Quantity__c = quantity;
        insert frp;

        Id curentUserId = UserInfo.getUserId();
        String Opco = [SELECT OperatingCompany__c FROM User WHERE Id = :curentUserId LIMIT 1].OperatingCompany__c;
        List<firstReleasePartner__c> frpList = [SELECT Id, Quantity__c, Account__c, Account__r.Name, (SELECT Id, Quantity__c, Product__c, Product__r.Name FROM FirstReleasePartnerProducts__r) FROM firstReleasePartner__c WHERE OperatingCompany__c = :OpCo];

        return frpList;
    }

    @AuraEnabled
    public static List<firstReleasePartner__c> changeFirstReleasePartnerQuantity(String firstReleasePartnerId, Integer quantity){
        
        firstReleasePartner__c fp = New firstReleasePartner__c();
        fp.Id = firstReleasePartnerId;
        fp.Quantity__c = quantity;
        update fp;

        Id curentUserId = UserInfo.getUserId();
        String Opco = [SELECT OperatingCompany__c FROM User WHERE Id = :curentUserId LIMIT 1].OperatingCompany__c;
        List<firstReleasePartner__c> frpList = [SELECT Id, Quantity__c, Account__c, Account__r.Name, (SELECT Id, Quantity__c, Product__c, Product__r.Name FROM FirstReleasePartnerProducts__r) FROM firstReleasePartner__c WHERE OperatingCompany__c = :OpCo];

        return frpList;
    }

    @AuraEnabled
    public static List<firstReleasePartner__c> changeFirstReleasePartnerProductQuantity(String firstReleasePartnerProductId, Integer quantity){
        
        firstReleasePartnerProduct__c fpp = New firstReleasePartnerProduct__c();
        fpp.Id = firstReleasePartnerProductId;
        fpp.Quantity__c = quantity;
        update fpp;

        Id curentUserId = UserInfo.getUserId();
        String Opco = [SELECT OperatingCompany__c FROM User WHERE Id = :curentUserId LIMIT 1].OperatingCompany__c;
        List<firstReleasePartner__c> frpList = [SELECT Id, Quantity__c, Account__c, Account__r.Name, (SELECT Id, Quantity__c, Product__c, Product__r.Name FROM FirstReleasePartnerProducts__r) FROM firstReleasePartner__c WHERE OperatingCompany__c = :OpCo];

        return frpList;
    }

    @AuraEnabled
    public static List<firstReleasePartner__c> deleteFirstReleasePartner(String firstReleasePartnerId){
        
        firstReleasePartner__c fp = [SELECT Id FROM firstReleasePartner__c WHERE Id = :firstReleasePartnerId LIMIT 1];
        delete fp;

        Id curentUserId = UserInfo.getUserId();
        String Opco = [SELECT OperatingCompany__c FROM User WHERE Id = :curentUserId LIMIT 1].OperatingCompany__c;
        List<firstReleasePartner__c> frpList = [SELECT Id, Quantity__c, Account__c, Account__r.Name, (SELECT Id, Quantity__c, Product__c, Product__r.Name FROM FirstReleasePartnerProducts__r) FROM firstReleasePartner__c WHERE OperatingCompany__c = :OpCo];

        return frpList;

    }

    @AuraEnabled
    public static List<firstReleasePartner__c> addFirstReleasePartnerProduct(String firstReleasePartnerId, Integer quantity, String ProductId){
        
        firstReleasePartnerProduct__c frpp = New firstReleasePartnerProduct__c();
        frpp.FirstReleasePartner__c = firstReleasePartnerId;
        frpp.Product__c = ProductId;
        frpp.Quantity__c = quantity;
        insert frpp;

        Id curentUserId = UserInfo.getUserId();
        String Opco = [SELECT OperatingCompany__c FROM User WHERE Id = :curentUserId LIMIT 1].OperatingCompany__c;
        List<firstReleasePartner__c> frpList = [SELECT Id, Quantity__c, Account__c, Account__r.Name, (SELECT Id, Quantity__c, Product__c, Product__r.Name FROM FirstReleasePartnerProducts__r) FROM firstReleasePartner__c WHERE OperatingCompany__c = :OpCo];

        return frpList;
    }

    @AuraEnabled
    public static List<firstReleasePartner__c> deleteFirstReleasePartnerProduct(String firstReleasePartnerProductId){
        
        firstReleasePartnerProduct__c fpp = [SELECT Id FROM firstReleasePartnerProduct__c WHERE Id = :firstReleasePartnerProductId LIMIT 1];
        delete fpp;

        Id curentUserId = UserInfo.getUserId();
        String Opco = [SELECT OperatingCompany__c FROM User WHERE Id = :curentUserId LIMIT 1].OperatingCompany__c;
        List<firstReleasePartner__c> frpList = [SELECT Id, Quantity__c, Account__c, Account__r.Name, (SELECT Id, Quantity__c, Product__c, Product__r.Name FROM FirstReleasePartnerProducts__r) FROM firstReleasePartner__c WHERE OperatingCompany__c = :OpCo];

        return frpList;
    }
}