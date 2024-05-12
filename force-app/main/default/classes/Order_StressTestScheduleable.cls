global class Order_StressTestScheduleable implements Schedulable {
    global void execute(SchedulableContext sc){
        runJob();
    }
    
    public static string getCronExpression(Integer specifedMinutes){
        String strSchedule;
        
        String day = string.valueOf(system.now().day());
        
        String month = string.valueOf(system.now().month());
        
        String hour = string.valueOf(system.now().hour());
        
        String minute = string.valueOf(system.now().minute() + specifedMinutes);
        
        String second = string.valueOf(system.now().second());
        
        String year = string.valueOf(system.now().year());
        
        strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        
        if(Integer.valueOf(minute) > 59){
            if(hour != '23'){
                // set minute to 0 and add 1 to the hour, so that it's not like 61 minutes past 10 for example
                strSchedule = '0 ' + '0' + ' ' + String.valueOf((Integer.valueOf(hour)+1)) + ' ' + day + ' ' + month + ' ?' + ' ' + year;
            } else {
                // set schedule to beginning of next day
                strSchedule = '0 ' + '0' + ' ' + '0' + ' ' + String.valueOf((Integer.valueOf(day)+1)) + ' ' + month + ' ?' + ' ' + year;
            }
        }
        
        system.debug('strSchedule: ' + strSchedule);
        return strSchedule;
    }
    
    
    public static Boolean abortScheduledJob(){
        Boolean retVal = false;
        
        String cronJobName = '%Order_StressTestScheduleable-%';
        //system.debug('=== cronJobName to abort: ' + cronJobName);
        
        CronTrigger[] cronJob = [SELECT Id, StartTime from CronTrigger WHERE CronJobDetail.Name LIKE :cronJobName AND StartTime != null];
        system.debug('=== cronJob: ' + cronJob);
        
        if(cronJob.size() == 0){
            retVal = true;
        }
        
        for(CronTrigger cron : cronJob){
            try {
                System.abortJob(cron.Id);
                retVal = true;
            } catch(Exception exc){
                System.debug('Order_StressTestScheduleable EXCEPTION: ' + exc.getMessage());
            }
        }
        
        return retVal;
    }
    
    public static void runJob(){
        // get the info that orders need to be created for
        List<OrderStressTest__c> orderStressTestRecords = [SELECT Id, Name, OperatingCompany__c, NumberofOrderstoCreate__c, IntervalMinutes__c, 
                                                          IncludeItemGroups__c, LastRun__c, NextRunTime__c, NumberofProductsPerOrder__c, RunAutomationUntil__c
                                                          FROM OrderStressTest__c];
        
        // if the size of this list is same as size of orderStressTestRecords, then we can abort the job
        List<Integer> canCancelJob = new List<Integer>();
        
        for(OrderStressTest__c orderStressTestRecord : orderStressTestRecords){
            system.debug('orderStressTestRecord.NextRunTime__c: ' + orderStressTestRecord.NextRunTime__c);
            system.debug('System.now(): ' + System.now());
            system.debug('orderStressTestRecord.RunAutomationUntil__c :' + orderStressTestRecord.RunAutomationUntil__c);
            
            // run the job if the next scheduled run time is past or if its now OR if the job has not run before
            // dont run the job if orderStressTestRecord.RunAutomationUntil__c is in the past
            if((System.now() >= orderStressTestRecord.NextRunTime__c || orderStressTestRecord.LastRun__c == null) && System.now() <= orderStressTestRecord.RunAutomationUntil__c) {
                system.debug('=== RUNNING JOB FOR: === ' + orderStressTestRecord);
                Order_StressTest_BATCH bc = new Order_StressTest_BATCH(orderStressTestRecord);
                Id batchId = Database.executeBatch(bc, 2000);
                
            } else if (System.now() > orderStressTestRecord.RunAutomationUntil__c){
                // abort current job because the next scheduled run time is past
                canCancelJob.add(1);
            } else {
                // schedule the job to run in a minute to check if the job needs to run
                system.debug('Job will run again in 1 min to see if it needs to be run');

                //parse to a cron expression
                String nextFireTime = getCronExpression(1);
                
                // abort existing job
                Boolean cancelJob = abortScheduledJob();
                
                if(cancelJob){
                    // call job 1 minute after last run, so that it's always running
                    Order_StressTestScheduleable stressTest = new Order_StressTestScheduleable();
                    System.schedule('Order_StressTestScheduleable-' + System.now(), nextFireTime, stressTest);
                }
            }
        }
        
        if(canCancelJob.size() == orderStressTestRecords.size()){
            Boolean cancelJob = abortScheduledJob();
        }
    }
}