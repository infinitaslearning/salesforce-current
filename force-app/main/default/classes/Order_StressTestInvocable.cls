global class Order_StressTestInvocable {

    @InvocableMethod(label='Create Stress Test Orders')
    public static void createStressTests(){ 
        CronTrigger[] cronJob = [SELECT Id, StartTime from CronTrigger WHERE CronJobDetail.Name LIKE '%Order_StressTestScheduleable%' AND StartTime != null];
        
        for(CronTrigger cron : cronJob){
            System.abortJob(cron.Id);
        }
        
        String hour = String.valueOf(Datetime.now().hour());
        //You can add any no of Minute you want to add to schedule it for next
        String min = String.valueOf(Datetime.now().addMinutes(1).minute());
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to a cron expression
        String nextFireTime = Order_StressTestScheduleable.getCronExpression(1);
        
        // this calls the scheduled job once, but then in the batch job it gets called again in the finish method
        Order_StressTestScheduleable stressTest = new Order_StressTestScheduleable();
        System.schedule('Order_StressTestScheduleable-Generic' + '-' + System.now(), nextFireTime, stressTest);
    }
}