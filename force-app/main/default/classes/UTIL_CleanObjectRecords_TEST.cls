@isTest
public class UTIL_CleanObjectRecords_TEST {
    @testSetup
    public static void makeData(){
        ErrorLog__c errLog = new ErrorLog__c();
        errLog.ClassName__c = 'Test';
        errLog.ExceptionMessage__c = 'Test';
        errLog.ExceptionType__c = 'Test';
        errLog.MethodName__c = 'Test';
        errLog.RelatedToId__c = 'Test';
        insert errLog;
        
        Test.setCreatedDate(errLog.Id, Date.newInstance(2020, 01, 31));
        
        List<SystemMonitor__c> sysMonLs = new List<SystemMonitor__c>();
        
        SystemMonitor__c sysMon1 = new SystemMonitor__c();
        sysMon1.Object__c = 'Account';
        sysMon1.Type__c = 'Integration';
        sysMon1.OperatingCompany__c = 'Plantyn';
        sysMonLs.add(sysMon1);
        
        SystemMonitor__c sysMon2 = new SystemMonitor__c();
        sysMon2.Object__c = 'Order';
        sysMon2.Type__c = 'Integration';
        sysMon2.OperatingCompany__c = 'Liber';
        sysMonLs.add(sysMon2);
        
        SystemMonitor__c sysMon3 = new SystemMonitor__c();
        sysMon3.Object__c = 'Account';
        sysMon3.Type__c = 'Integration';
        sysMon3.OperatingCompany__c = 'Plantyn';
        sysMonLs.add(sysMon3);
        
        insert sysMonLs;
        
        Test.setCreatedDate(sysMon1.Id, Date.newInstance(2020, 01, 31));
        Test.setCreatedDate(sysMon2.Id, Date.newInstance(2020, 01, 31));
        Test.setCreatedDate(sysMon3.Id, Date.newInstance(2020, 01, 31));
    }
    
    public static testMethod void testUTIL_CleanObjectRecords(){
        test.startTest();
        UTIL_CleanObjectRecordsScheduleable ctrl = new UTIL_CleanObjectRecordsScheduleable();
        ctrl.execute(null);
        test.stoptest();
    }
}