public with sharing class bg_LogResponse {
    
    public class myJson{
        public List<String> items;
   }

    Public static void logresponse(String jsonInput,Set<ID> ids){

        List<SystemMonitor__c> lstSystemMonitor = new List<SystemMonitor__c>();

        /*
        myJson deser = (myJson) JSON.deserialize( json, myJson.Class);

        Map<String, Object> Map_Json;// = (Map<String, Object>) JSON.deserializeUntyped(json);

        for(String item:deser.items){

            Map_Json = (Map<String, Object>) JSON.deserializeUntyped(item)
            for(String rec:Map_Json.get(rec)){

            }    
        }
        */

        Map<String, Object> Map_FullList =    (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        List<Object> listFail = (List<Object>)Map_FullList.get('failures');
       
        


        Map<String, Object> Map_ind;
        Map<String, String> Map_Failures = new Map<String, String>();
        Map<String, String> Map_Correlation = new Map<String, String>();
        

        if(listFail != null){
            for(object fail:listFail){
                Map_ind = (Map<String, Object>) fail;
                Map_Failures.put(string.valueof(Map_ind.get('id')),string.valueof(Map_ind.get('message')));
                system.debug('*******'+Map_ind.get('id'));
                system.debug('*******'+Map_ind.get('message'));
            }
        }
        



        List<string> recordIdStrings = new List<string>();
        String ObjName;
        if(ids.size()>0){

            for(Id recId:ids){
                recordIdStrings.add(string.valueof(recId));
                break;
            }
            
            ObjName=UTIL_getObjectName.returnObjectName(recordIdStrings)[0];
        }
        string OperatingCompany = returnOpco(ids,ObjName);

        Boolean Success = false;
        
        for(ID recId : ids)
        {
            SystemMonitor__c SystemMonitor = new SystemMonitor__c();
            SystemMonitor.Type__c = 'Integration';            
            SystemMonitor.RecordId__c =  recId;
            SystemMonitor.OperatingCompany__c = OperatingCompany;
            SystemMonitor.Object__c = ObjName;

            if(Map_Failures.get(recId) != null){
                SystemMonitor.ErrorMessage__c = Map_Failures.get(recId);
                SystemMonitor.Message__c = 'Status: Failed, ' + 'correlationId: '+ string.valueof(Map_FullList.get('correlationId'));
            }            
            else {
                SystemMonitor.Message__c = 'CorrelationId: '+ string.valueof(Map_FullList.get('correlationId'));              
            }

            lstSystemMonitor.add(SystemMonitor);           
        }

        database.insert(lstSystemMonitor);

    }


    public static String returnOpco(Set<ID> ids,String ObjName){

            string query;
            string OperatingCompany;

            

            if(ObjName == 'Account'){

                Account[] lstAccount = [Select OperatingCompany__c from Account where id in:ids and OperatingCompany__c !=:null limit 1];
                /*
                query='Select OperatingCompany__c from Account where id in:ids and OperatingCompany__c !=:null limit 1';
                records = Database.query(query);
                */

                if(lstAccount.size()>0){
                    OperatingCompany = lstAccount[0].OperatingCompany__c;
                }
                
            }
            else if(ObjName == 'AccountSubsidiary__c'){
                
                AccountSubsidiary__c[] lstAccountSubsidiary = [Select Account__r.OperatingCompany__c from AccountSubsidiary__c where id in:ids and Account__r.OperatingCompany__c !=:null limit 1];

                /*
                query='Select Account__r.OperatingCompany__c from AccountSubsidiary__c where id in:ids and Account__r.OperatingCompany__c !=:null limit 1';
                records = Database.query(query);
                */

                if(lstAccountSubsidiary.size()>0){
                    OperatingCompany = lstAccountSubsidiary[0].Account__r.OperatingCompany__c;
                }
            }
            else if(ObjName == 'Contact'){
                Contact[] lstContact = [Select OperatingCompany__c from Contact where id in:ids and OperatingCompany__c !=:null limit 1];
                /*
                query='Select OperatingCompany__c from Contact where id in:ids and OperatingCompany !=:null limit 1';
                records = Database.query(query);
                */

                if(lstContact.size()>0){
                    OperatingCompany = lstContact[0].OperatingCompany__c;
                }
            }
            else if(ObjName == 'Order'){
                
                Order[] lstOrder = [Select OperatingCompany__c from Order where id in:ids and OperatingCompany__c !=:null limit 1];
                /*
                query='Select OperatingCompany__c from Order where id in:ids and OperatingCompany__c !=:null limit 1';
                records = Database.query(query);
                */

                if(lstOrder.size()>0){
                    OperatingCompany = lstOrder[0].OperatingCompany__c;
                }
            }
            else if(ObjName == 'OrderItem'){

                OrderItem[] lstOrderItem =  [Select Order.OperatingCompany__c from OrderItem where id in:ids and Order.OperatingCompany__c !=:null limit 1];
                /*
                query='Select Order.OperatingCompany__c from OrderItem where id in:ids and OperatingCompany !=:null limit 1';
                records = Database.query(query);
                */

                if(lstOrderItem.size()>0){
                    OperatingCompany = lstOrderItem[0].Order.OperatingCompany__c;
                }
            }

       
            return OperatingCompany;

    }


}