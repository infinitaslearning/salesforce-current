@IsTest
public  class UTIL_CalculateBusinessHoursDiff_TEST {
    
    @isTest
    static void check_diffInMilliSeconds() 
    {
        Profile sysadminprofile = [select Id, name from profile where Name='System administrator' limit 1];
        User adminUser = [select Id,Name from user where profileId= :sysadminprofile.Id and isactive= True limit 1];
        BusinessHours bhoursId = [select Id from BusinessHours where Name='Default' limit 1];
        System.runAs(adminUser)
        {
            List<UTIL_CalculateBusinessHoursDiff.request> inputparams = new List<UTIL_CalculateBusinessHoursDiff.request>();
            UTIL_CalculateBusinessHoursDiff.request pf = new UTIL_CalculateBusinessHoursDiff.request();
            pf.startDate = Datetime.now();
            pf.endDate = Datetime.now().addDays(1);
            pf.businessHoursId = bhoursId.Id;
            inputparams.add(pf);
            Test.startTest();
            List<UTIL_CalculateBusinessHoursDiff.response> response = UTIL_CalculateBusinessHoursDiff.getMilliSecondDiff(inputparams);
            Integer total_duration_in_seconds = (response[0].diffResult/1000).intValue();
            Test.stopTest();
            System.assertEquals(86400,total_duration_in_seconds );
            
        }
    }

}