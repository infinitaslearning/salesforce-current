global class ImportOrderRetryBatch implements Database.Batchable<ImportOrder__c>, Database.AllowsCallouts {
    private DateTime dtNow;
    
    public ImportOrderRetryBatch(DateTime dt){
        dtNow = dt;
    }
    
    global Iterable<ImportOrder__c> start(Database.BatchableContext bc) {        
        List<ImportOrder__c> ioLs = [SELECT Id, ExternalOrderId__c FROM ImportOrder__c WHERE Status__c = 'Error' AND Error__c LIKE '%UNABLE_TO_LOCK_ROW%' AND ProductId__c = null];
        
        // this is new, was previously handled in ImportOrderRetryRESTAPI
        for(ImportOrder__c io : ioLs){
            io.Status__c = 'Pending';
        }
        
        update ioLs;
        
        return ioLs;
    }
    
    global void execute(Database.BatchableContext bc, List<ImportOrder__c> records){
        string response;
        
        for(ImportOrder__c io : records){
            // originally just the line below this that calls the rest api
            //response = ImportOrderRetryRESTAPI.retryImportOrder(io.ExternalOrderId__c);
            
            String externalOrderId = io.ExternalOrderId__c;
            
            ImportOrder__c[] ioLine_HasTriggerBusinessRules = [Select Id from ImportOrder__c where ExternalOrderId__c =: externalOrderId AND ProductId__c != null AND Status__c = 'Error' AND TriggerBusinessLogic__c = TRUE];
            
            // check to see if this order has a line with TriggerBusinessLogic__c = true (if so, then we can process because that means all lines for the order are in)
            if(ioLine_HasTriggerBusinessRules.size() > 0){
                ImportOrder__c[] lst_ImportOrderLines = [Select Id from ImportOrder__c where ExternalOrderId__c =: externalOrderId AND ProductId__c != null AND Status__c = 'Error'];
                
                for(ImportOrder__c ioLine : lst_ImportOrderLines){
                    ioLine.Status__c = 'Pending';
                }
                
                if(lst_ImportOrderLines.size() > 0){
                	update lst_ImportOrderLines;    
                }
                
                
                response= 'Success';
            } else {
                response= 'failed - not all lines are in for order: ' + externalOrderId;
            }
        }
        
        system.debug('response: ' + response);

    } 
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        
        //DateTime dtNow;
        if(dtNow == null){
            dtNow = DateTime.now();
        }

        system.debug('ImportOrderRetryBatch dtNow: ' + dtNow);
        
        if(dTNow.Hour() >= 9 && dTNow.Hour() < 11){
            // run every 5 mins
			system.debug('run every 5 mins because hour is: ' + dTNow.Hour());
            DateTime schDate = dtNow.addMinutes(5);
            
            String hour = String.valueOf(schDate.hour());
            String min = String.valueOf(schDate.minute()); 
            String ss = String.valueOf(schDate.second());
            Integer intHour = Integer.valueOf(hour);
            
            system.debug('hour: ' + hour);
            system.debug('min: ' + min);
            system.debug('ss: ' + ss);
            
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            
            // delete existing job (if there is one)
            CronTrigger[] jobRecordLs = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE '%ImportOrderRetrySchedulable%'];
            
            if(jobRecordLs.size() > 0){
                for(CronTrigger cTrig : jobRecordLs){
                    System.abortJob(cTrig.Id);
                }
            }
            
            ImportOrderRetrySchedulable s = new ImportOrderRetrySchedulable(); 
            System.schedule('ImportOrderRetrySchedulable_ ' + String.valueOf(dtNow), nextFireTime, s);
            
        } else if(dTNow.Hour() >= 11 && dTNow.Hour() < 17){
            // run every 30mins
            system.debug('run every 30 mins because hour is: ' + dTNow.Hour());
            DateTime schDate = dtNow.addMinutes(30);
            //DateTime schDate = dtNow.addMinutes(5); // 5 mins for testing purposes
            
            String hour = String.valueOf(schDate.hour());
            String min = String.valueOf(schDate.minute()); 
            String ss = String.valueOf(schDate.second());
            Integer intHour = Integer.valueOf(hour);
            
            system.debug('hour: ' + hour);
            system.debug('min: ' + min);
            system.debug('ss: ' + ss);
            
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            
            // delete existing job (if there is one)
            CronTrigger[] jobRecordLs = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE '%ImportOrderRetrySchedulable%'];
            
            if(jobRecordLs.size() > 0){
                for(CronTrigger cTrig : jobRecordLs){
                    System.abortJob(cTrig.Id);
                }
            }
            
            ImportOrderRetrySchedulable s = new ImportOrderRetrySchedulable();
            System.schedule('ImportOrderRetrySchedulable_ ' + String.valueOf(dtNow), nextFireTime, s);
            
        } else if(dTNow.Hour() >= 17 && dTNow.Hour() < 23) {
            // schedule to 9am the following day
            system.debug('schedule to 9am the following day because hour is: ' + dTNow.Hour());
            DateTime schDate = DateTime.newInstance(dtNow.year(), dtNow.month(), dtNow.day(), 09, 00, 00);
            schDate = schDate.addDays(1);
            
            String hour = String.valueOf(schDate.hour());
            String min = String.valueOf(schDate.minute()); 
            String ss = String.valueOf(schDate.second());
            Integer intHour = Integer.valueOf(hour);
            
            system.debug('hour: ' + hour);
            system.debug('min: ' + min);
            system.debug('ss: ' + ss);
            
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            
            // delete existing job (if there is one)
            CronTrigger[] jobRecordLs = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE '%ImportOrderRetrySchedulable%'];
            
            if(jobRecordLs.size() > 0){
                for(CronTrigger cTrig : jobRecordLs){
                    System.abortJob(cTrig.Id);
                }
            }
            
            ImportOrderRetrySchedulable s = new ImportOrderRetrySchedulable();
            System.schedule('ImportOrderRetrySchedulable_ ' + String.valueOf(dtNow), nextFireTime, s);
        } else {
            // schedule to 9am for current day
            system.debug('schedule to 9am the current day because hour is: ' + dTNow.Hour());
            DateTime schDate = DateTime.newInstance(dtNow.year(), dtNow.month(), dtNow.day(), 09, 00, 00);
            
            String hour = String.valueOf(schDate.hour());
            String min = String.valueOf(schDate.minute()); 
            String ss = String.valueOf(schDate.second());
            Integer intHour = Integer.valueOf(hour);
            
            system.debug('hour: ' + hour);
            system.debug('min: ' + min);
            system.debug('ss: ' + ss);
            
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            
            // delete existing job (if there is one)
            CronTrigger[] jobRecordLs = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE '%ImportOrderRetrySchedulable%'];
            
            if(jobRecordLs.size() > 0){
                for(CronTrigger cTrig : jobRecordLs){
                    System.abortJob(cTrig.Id);
                }
            }
            
            ImportOrderRetrySchedulable s = new ImportOrderRetrySchedulable();
            System.schedule('ImportOrderRetrySchedulable_ ' + String.valueOf(dtNow), nextFireTime, s);
        }
    }    
}