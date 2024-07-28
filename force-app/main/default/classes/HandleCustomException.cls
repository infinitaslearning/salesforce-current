public with sharing class HandleCustomException extends Exception {

    // Method when errorlogging does not receive relatedToId
    public static void  LogException(Exception e) {
        LogException(e,'');
    }

    // Method to log Exception in Custom Object ErrorLog__c
    public static void LogException(Exception e, String relatedToId) {
        try {

            // Get class- and MethodNames from Stacktrace
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String className = stackTrace.substringAfter('.').substringBefore('.');
            String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');

            Map<String,Map<String,Integer>> governorLimits = getGovernorLimts();

            // Log information in ErrorLog object
            ErrorLog__c errorLog = new ErrorLog__c();
            errorLog.Errororigin__c = 'Apex';
            errorLog.RelatedToId__c = relatedToId;
            errorLog.ClassName__c = className;
            errorLog.MethodName__c = methodName;
            errorLog.ExceptionMessage__c = e.getMessage();
            errorLog.ExceptionType__c = e.getTypeName();
            errorLog.LineNumber__c = e.getLineNumber();
            errorLog.StackTrace__c = e.getStackTraceString();
            errorLog.GovtLimitExecutingCode__c = createGovernorLimtsString(governorLimits);
            database.insert(errorLog);

            // For DML Specific errors
            if(e.getTypeName() == 'System.DmlException') {
                List<DMLErrorLog__c> dmlErrorLogs = new List<DMLErrorLog__c>();
                for (Integer i = 0; i < e.getNumDml(); i++) {

                    // Create DML FieldNames String
                    String fieldNames = '';
                    for(String fieldName : e.getDmlFieldNames(i)) {
                        fieldNames += fieldName + '\n';
                    }

                    // Log DML information to DML log object
                    DMLErrorLog__c dmle = new DMLErrorLog__c();
                    dmle.ErrorLog__c = errorLog.Id;
                    dmle.DMLTypes__c = String.valueOf(e.getDmlType(i));
                    dmle.FieldNames__c = fieldNames;
                    dmle.IDofFailedRecord__c = e.getDmlId(i);
                    dmle.Index__c = e.getDmlIndex(i);
                    dmle.Message__c = e.getDmlMessage(i);
                    dmlErrorLogs.add(dmle);
                }
                insert dmlErrorLogs;
            }
        }
        finally { }
    }

    public static void checkCriticalGovernorLimits(String stacktraceString) {
        checkCriticalGovernorLimits(stacktraceString, '');
    }

    public static void checkCriticalGovernorLimits(String stacktraceString, String relatedToId) {

        try {

            // Get class- and MethodNames from Stacktrace
            String className = stacktraceString.substringAfter('.').substringBefore('.');
            String methodName = stacktraceString.substringBefore(':').substringAfter(className).substringAfter('.');

            System.debug('Stacktrace: ' + stacktraceString);

            Map<String,Map<String,Integer>> governorLimitMap = getGovernorLimts();

            List<CustomExceptionHandlingSettings__c> cehList = [SELECT CriticalGovernorLimitPercentage__c FROM CustomExceptionHandlingSettings__c LIMIT 1];
            Integer criticalPercentage = 90; // For defaulting back to 90 if there is no custom setting to be found
            if(!cehList.isEmpty()) {
                criticalPercentage = Integer.valueOf(cehList[0].CriticalGovernorLimitPercentage__c);
                System.debug(LoggingLevel.INFO, 'a Cutsomsetting is found, the value = ' + cehList[0].CriticalGovernorLimitPercentage__c);
            } else {System.debug(LoggingLevel.INFO, 'No CustomSetting was found!');}

            // IF any of the governor limit percentages gets above the in the Custom Settings specified percentage (Standard 90 %) ...
            if(governorLimitMap.get('SOQL').get('percentage') > criticalPercentage || governorLimitMap.get('DML').get('percentage') > criticalPercentage || governorLimitMap.get('DML Statements').get('percentage') > criticalPercentage || governorLimitMap.get('CPU').get('percentage') > criticalPercentage) {
                // ... Log information in ErrorLog object
                ErrorLog__c errorLog = new ErrorLog__c();
                errorLog.Errororigin__c = 'Apex';
                errorLog.RelatedToId__c = relatedToId;
                errorLog.ClassName__c = className;
                errorLog.MethodName__c = methodName;
                errorLog.ExceptionType__c = 'Critical Governor Limits';
                errorLog.GovtLimitExecutingCode__c = createGovernorLimtsString(governorLimitMap);
                database.insert(errorLog);
            }

        }
        finally { }
    }

    public static Map<String,Map<String,Integer>> getGovernorLimts() {

        Map<String,Map<String,Integer>> returnMap = new Map<String,Map<String,Integer>>();

        Map<String,Integer> SOQLgovernorLimits = new Map<String,Integer>();
        Map<String,Integer> DMLgovernorLimits = new Map<String,Integer>();
        Map<String,Integer> DmlStatementsGovernorLimits = new Map<String,Integer>();
        Map<String,Integer> CPUgovernorLimits = new Map<String,Integer>();

        Integer SOQLusage = Limits.getQueries();
        Integer SOQLlimits = Limits.getLimitQueries();
        Integer DMLusage = Limits.getDmlRows();
        Integer DMLlimits = Limits.getLimitDmlRows();
        Integer DMLstatementUsage = Limits.getDmlStatements();
        Integer DMLstatementLimits = Limits.getLimitDmlStatements();
        Integer CPUtimeUsage = Limits.getCpuTime();
        Integer CPUtimeLimits = Limits.getLimitCpuTime();

        // Set Governer Limits
        SOQLgovernorLimits.put('usage', SOQLusage);
        SOQLgovernorLimits.put('limits', SOQLlimits);
        if(SOQLusage > 0) {
            SOQLgovernorLimits.put('percentage', (SOQLusage*100)/SOQLlimits);
        } else {
            SOQLgovernorLimits.put('percentage', 0);
        }

        DMLgovernorLimits.put('usage', Limits.getDmlRows());
        DMLgovernorLimits.put('limits', Limits.getLimitDmlRows());
        if(DMLusage > 0) {
            DMLgovernorLimits.put('percentage', (DMLusage*100)/DMLlimits);
        } else {
            DMLgovernorLimits.put('percentage', 0);
        }

        DmlStatementsGovernorLimits.put('usage', Limits.getDmlStatements());
        DmlStatementsGovernorLimits.put('limits', Limits.getLimitDmlStatements());
        if(DMLstatementUsage > 0 ) {
            DmlStatementsGovernorLimits.put('percentage', (DMLstatementUsage*100)/DMLstatementLimits);
        } else {
            DmlStatementsGovernorLimits.put('percentage', 0);
        }

        CPUgovernorLimits.put('usage', Limits.getCpuTime());
        CPUgovernorLimits.put('limits', Limits.getLimitCpuTime());
        if(CPUtimeUsage > 0) {
            CPUgovernorLimits.put('percentage', (CPUtimeUsage*100)/CPUtimeLimits);
        } else {
            CPUgovernorLimits.put('percentage', 0);
        }

        returnMap.put('SOQL',SOQLgovernorLimits);
        returnMap.put('DML', DMLgovernorLimits);
        returnMap.put('DML Statements', DmlStatementsGovernorLimits);
        returnMap.put('CPU', CPUgovernorLimits);

        return returnMap;
    }

    public static String createGovernorLimtsString(Map<String, Map<String,Integer>> governorLimits) {

        // Calculate Governer Limits percentages
        Decimal SOQLPercentage = 0;
        Decimal DMLPercentage = 0;
        Decimal DMLstatPercentge = 0;
        Decimal CPUTimePercentage = 0;

        if(Limits.getQueries() > 0) {
            SOQLpercentage = (Double.valueOf(governorLimits.get('SOQL').get('usage'))/Double.valueOf(governorLimits.get('SOQL').get('limits')))*100;
        }
        if(Limits.getDmlRows() > 0) {
            DMLPercentage = (Double.valueOf(governorLimits.get('DML').get('usage'))/Double.valueOf(governorLimits.get('DML').get('limits')))*100;
        }
        if(Limits.getDmlStatements() > 0) {
            DMLstatPercentge = (Double.valueOf(governorLimits.get('DML Statements').get('usage'))/Double.valueOf(governorLimits.get('DML Statements').get('limits')))*100;
        }
        if(Limits.getCpuTime() > 0) {
            CPUTimePercentage = (Double.valueOf(governorLimits.get('CPU').get('usage'))/Double.valueOf(governorLimits.get('CPU').get('limits')))*100;
        }
        
        // Create Governer Limit overview
        String queryLimit = '- SOQL Queries used / SOQL queries allowd: ' + governorLimits.get('SOQL').get('usage') + ' / ' + governorLimits.get('SOQL').get('limits') + ' (' + SOQLPercentage.setScale(2) + ' %)';
        String DMLimit = '- Number of records queried so far / Number of allowd: ' + governorLimits.get('DML').get('usage') + ' / ' + governorLimits.get('DML').get('limits') + ' (' + DMLPercentage.setScale(2) + ' %)';
        String DMLStatements = '- Number of DML Statements used so far / Number of allowed: ' + governorLimits.get('DML Statements').get('usage') + ' / ' + governorLimits.get('DML Statements').get('limits') + ' (' + DMLstatPercentge.setScale(2) + ' %)';
        String CPUTime = '- Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + governorLimits.get('CPU').get('usage') + ' / ' + governorLimits.get('CPU').get('limits') + ' (' + CPUTimePercentage.setScale(2) + ' %)';

        return String.format('{0}\n{1}\n{2}\n{3}', new List<String>{queryLimit, DMLimit, DMLStatements, CPUTime});
    }

}