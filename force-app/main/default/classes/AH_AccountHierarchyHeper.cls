public class AH_AccountHierarchyHeper {

    public class AccountWrapper {
        @AuraEnabled
        public Account record { get; set; }
        @AuraEnabled
        public List<Account> AccountList { get; set; }
    }
    
    @Auraenabled(cacheable=true)
    public static Account getMainAccount(String accountId) {
        System.debug(LoggingLevel.INFO, 'AH_AccountHierarchyHeper - getMainAccount(' + accountId + ')');

        Account acc = [SELECT Id, Name, PurchasingGroup__c, DefaultShipTo__c, DefaultBillto__c, ParentId FROM Account WHERE Id = :accountId LIMIT 1];
        System.debug('acc ==> ' + acc);
        return acc;
    }

    @Auraenabled(cacheable=true)
    public static Account getUltimateParent(String accountId) {

        Boolean getNewParents = true;
        Account pAccount = [SELECT Id, Name, ParentId FROM Account WHERE ParentId = :accountId];
        Account oldPaccount = new Account();
        while (getNewParents) {
            oldPaccount = pAccount;
            if (oldPaccount.ParentId != null) {
                pAccount = [SELECT Id, Name, PurchasingGroup__c, DefaultShipTo__c, DefaultBillto__c, ParentId FROM Account WHERE ParentId = :oldPaccount.ParentId];
            } else {
                getNewParents = false;
            }
        }
        return oldPaccount;

    }

    @Auraenabled(cacheable=true)
    public static List<Account> getLocations(String accountId) {
        System.debug(LoggingLevel.INFO, 'AH_AccountHierarchyHeper - getLocations(' + accountId + ')');

        List<Account> locLst = new List<Account>();
        locLst = [SELECT Id, Name FROM Account WHERE MainLocation__c = :accountId];

        System.debug('locLst ==> ' + locLst);
        return locLst;
    }

    @Auraenabled(cacheable=true)
    public static Boolean purchasingGroupCheck(String accountId) {
        System.debug(LoggingLevel.INFO, 'AH_AccountHierarchyHeper - purchasingGroupCheck(' + accountId + ')');

        Boolean isPurchasingGroup = false;
        List<Account> accLst = new List<Account>();
        accLst = [SELECT Id FROM Account WHERE PurchasingGroup__c = :accountId];

        isPurchasingGroup = accLst.size() > 0;
        System.debug('isPurchasingGroup ==> ' + isPurchasingGroup);

        return isPurchasingGroup;
    }

    @Auraenabled(cacheable=true)
    public static Account getAccountDetails(String accountId) {
        System.debug(LoggingLevel.INFO, 'AH_AccountHierarchyHeper - getAccountDetails(' + accountId + ')');
        Account acc = [SELECT 
                Id, 
                Name, 
                BillingStreet, 
                BillingPostalCode,
                BillingCity,
                BillingCountry,
                ShippingStreet, 
                ShippingPostalCode,
                ShippingCity,
                ShippingCountry,
                Email__c,
                Phone
                FROM Account
                WHERE Id = :accountId LIMIT 1];
        return acc;
    }

    // @Auraenabled(cacheable=true)
    // public static List<Account> getSchoolsFromSchoolGroupId(String accountId) {
    //     System.debug(LoggingLevel.INFO, 'AH_AccountHierarchyHeper - getSchoolsFromSchoolGroupId(' + accountId + ')');

    //     List<Account> accLst = new List<Account>();
    //     accLst = [SELECT Id, Name FROM Account WHERE ParentId = :accountId ORDER BY Name];

    //     return accLst;
    // }

    // @Auraenabled(cacheable=true)
    // public static Map<String,AccountWrapper> getSchoolsAndLocationsFromSchoolGroupId(String accountId) {
    //     System.debug(LoggingLevel.INFO, 'AH_AccountHierarchyHeper - getSchoolsAndLocationsFromSchoolGroupId(' + accountId + ')');

    //     Map<String,AccountWrapper> returnMap = new Map<String,AccountWrapper>();
        
    //     List<Account> schools = new List<Account>();
    //     schools = [SELECT Id, Name, PurchasingGroup__c, DefaultShipTo__c, DefaultBillto__c FROM Account WHERE ParentId = :accountId ORDER BY Name];

    //     List<Id> schoolIds = new List<Id>();
    //     for (Account acc : schools) {
    //         schoolIds.add(acc.Id);
    //     }
    //     List<Account> locations = [SELECT Id, Name, MainLocation__c, PurchasingGroup__c, DefaultShipTo__c, DefaultBillto__c FROM Account WHERE MainLocation__c IN :schoolIds];

    //     for (Account school : schools) {
    //         List<Account> tmpLocList = new List<Account>();
    //         for (Account loc : locations) {
    //             if (loc.MainLocation__c == school.Id) {
    //                 tmpLocList.add(loc);
    //             }
    //         }
    //         AccountWrapper awrapper = new AccountWrapper();
    //         awrapper.record = school;
    //         awrapper.AccountList = tmpLocList;
    //         returnMap.put(String.valueOf(school.Id), awrapper);
    //     }
    //     System.debug('returnMap.keySet().size() ==>' + returnMap.keySet().size());
    //     System.debug('returnMap ==> ' + returnMap);

    //     return returnMap;
    // }

    // @Auraenabled(cacheable=true)
    // public static Map<String,AccountWrapper> getSchoolsAndLocationsFromSchoolId(String accountId) {
    //     System.debug(LoggingLevel.INFO, 'AH_AccountHierarchyHeper - getSchoolsAndLocationsFromSchoolId(' + accountId + ')');

    //     Id SchoolGroupId = [SELECT ParentId FROM Account WHERE Id = :accountId LIMIT 1].ParentId;

    //     Map<String,AccountWrapper> returnMap = new Map<String,AccountWrapper>();
        
    //     List<Account> schools = new List<Account>();
    //     schools = [SELECT Id, Name FROM Account WHERE ParentId = :SchoolGroupId ORDER BY Name];

    //     List<Id> schoolIds = new List<Id>();
    //     for (Account acc : schools) {
    //         schoolIds.add(acc.Id);
    //     }
    //     List<Account> locations = [SELECT Id, Name, MainLocation__c FROM Account WHERE MainLocation__c IN :schoolIds];

    //     for (Account school : schools) {
    //         List<Account> tmpLocList = new List<Account>();
    //         for (Account loc : locations) {
    //             if (loc.MainLocation__c == school.Id) {
    //                 tmpLocList.add(loc);
    //             }
    //         }
    //         AccountWrapper awrapper = new AccountWrapper();
    //         awrapper.record = school;
    //         awrapper.AccountList = tmpLocList;
    //         returnMap.put(String.valueOf(school.Id), awrapper);
    //     }
    //     System.debug('returnMap.keySet().size() ==>' + returnMap.keySet().size());
    //     System.debug('returnMap ==> ' + returnMap);

    //     return returnMap;
    // }

}