public without sharing class UTIL_CloneObjectAndRelatedrecord {

     public class FlowInputs{
    
        @InvocableVariable
        public Id recordId;
         
        @InvocableVariable
        public String orderType;
         
        @InvocableVariable
        public Boolean createdByCorrectionProcess;
    }

    public class FlowOutputs{
        
        @InvocableVariable
        public List<Id> clonedRecordLs;
    }

    // fetches related objects from Record_Clone_Setting__mdt
    public static List<String> recordCloneMetadata(String objectAPIName){
        List<String> relatedObjLs = new List<String>();
        List<Record_Clone_Setting__mdt> mdtLs = Database.query('SELECT RelatedObject__c FROM Record_Clone_Setting__mdt WHERE SourceObject__c =: objectAPIName');

        for(Record_Clone_Setting__mdt mdt : mdtLs){
            relatedObjLs.add(mdt.RelatedObject__c);
        }

        return relatedObjLs;
    }

    @InvocableMethod(label='Clone with Related')
    public static List<FlowOutputs> CloneRelatedListItems(List<FlowInputs> request){
        system.debug('request: ' + request);
        List<FlowOutputs> response = new List<FlowOutputs>();

        if(request != null){
            Id RecordId = request[0].recordId;
            String sobjectType = RecordId.getSObjectType().getDescribe().getName();
            system.debug('sobjectType: ' + sobjectType);

            List<String> lstofRelatedObjects = recordCloneMetadata(sobjectType);
            

            Map<String, Map<String,String>> Map_ObjField = new Map<String, Map<String,String>>(); 
            List<String> lstHeader = new List<String>();
            lstHeader.Add(sobjectType);
            
            Map_ObjField = ReturnAllFields(lstHeader);
            
            Map<String, String> Map_ObjSoql = CreateSOQL(Map_ObjField,RecordId,SObjectType);
            
            Map<String, List<SObject>> Map_Objrecord = new Map<String, List<SObject>>();
        
            for(String obj:Map_ObjSoql.keyset()){
                Map_Objrecord.put(obj, getRecords(Map_ObjSoql.get(obj)));
            }
        
            List<sObject> lstSobj = InsertRecords(Map_ObjField,Map_Objrecord,RecordId,SObjectType, request);

            Map_ObjField = ReturnAllFields(lstofRelatedObjects);
            Map_ObjSoql = CreateSOQL(Map_ObjField,RecordId,SObjectType);
            
            Map_Objrecord = new Map<String, List<SObject>>();
        
            for(String obj:Map_ObjSoql.keyset()){
                Map_Objrecord.put(obj, getRecords(Map_ObjSoql.get(obj)));
            }
        
            InsertRecords(Map_ObjField,Map_Objrecord,lstSobj[0].id,SObjectType, request);

            FlowOutputs res = new FlowOutputs();
            res.clonedRecordLs = new List<Id>();
            for(sObject sObj : lstSobj){
                res.clonedRecordLs.add(sObj.Id);
            }
            system.debug('**Util_Clone Item Group**'+SObjectType);
            if(SObjectType == 'Order'){
                orderlineItemhelper(lstSobj[0].id);
            }


            response.add(res);
        }

        return response;
    }
    /*
    @future
    public static void insertrelatedRecords(Map<String, Map<String,String>> Map_ObjField,Map<String, List<SObject>> Map_Objrecord,id RecordId,String sobjectType){
        InsertRecords(Map_ObjField,Map_Objrecord,lstSobj[0].id,SObjectType);
    }
    */

    public static void orderlineItemhelper(String RecordId){

       OrderItem[] lstCloneItems =  [Select Id,ItemGroup__c,ProductType__c,ImportItemGroupEAN__c from OrderItem where OrderId =: RecordId];

       Map<String, String> Map_IGLookup = new Map<String, String>();
       
       system.debug('**Util_Clone Item Group**: In');
       for(OrderItem  item: lstCloneItems){
                if(item.ProductType__c == 'Item Group'){                  
                   Map_IGLookup.put(item.ImportItemGroupEAN__c,Item.id);
                }
       }
       
       for(OrderItem  item:lstCloneItems){
            if(item.ItemGroup__c != null){                  
                item.ItemGroup__c = Map_IGLookup.get(item.ImportItemGroupEAN__c);
            }
       }

       try{
            system.debug('**Util_Clone Item Group**: Before Update');    
            update lstCloneItems;
            system.debug('**Util_Clone Item Group**: After Update');
       }
       catch(exception e){
            system.debug('**Util_Clone Item Group: Error on Item Groups ***'+e.getMessage());
       }


    }



    public static Map<String, Map<String,String>> ReturnAllFields(List<String> lstofObjects){
    
        
        Map<String, Map<String,String>> Map_ObjField = new Map<String, Map<String,String>>();
        
        for(String obj:lstofObjects){
            system.debug('obj**'+obj);
            
            SObjectType objectType = Schema.getGlobalDescribe().get(obj);
            
            if(objectType != null){   
                Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
                
                Map<String,String> Map_field = new Map<String,String>();
                
                for(String field: mfields.keyset()){
                    Schema.DescribeFieldResult fieldResult = mfields.get(field).getDescribe();
                    fieldResult.getReferenceTo();
                    
                    //&& !fieldResult.isCustom() 
                    
                    if(fieldResult.isCreateable() && field !='IsReductionOrder' && field !='OriginalOrderId' && field !='cleanstatus'  && field !='billingstatecode' && field != 'billingcountrycode'  && field !='shippingstatecode' && field !='shippingcountrycode'
                      && field != 'OldId__c') {
                        if(fieldResult.getReferenceTo()==null){
                            Map_field.put(field,'');
                        } 
                        else{
                            // system.debug('FieldName**'+field +'****'+fieldResult.getReferenceTo());
                            String strreference=string.valueof(fieldResult.getReferenceTo());
                            strreference=strreference.replace('(','');
                            strreference=strreference.replace(')','');
                            
                            Map_field.put(field,strreference);   
                        }
                    }
                }
                
                Map_ObjField.put(obj,Map_field);
            }
    
        }
        return Map_ObjField;
        
    }
    
                 
    public static Map<String, String> CreateSOQL(Map<String, Map<String,String>> Map_ObjField, String RecordId,String sobjectType){
        
        String Soql='';
    
        Map<String, String> Map_ObjSoql = new Map<String, String>();
        
        
        Map<integer, String> Map_FieldEdit = new Map<integer, String>();
        system.debug('sobjectType**'+sobjectType);
        for(String obj:Map_ObjField.keyset()){
            Soql='Select';
           
            SObjectType objectType = Schema.getGlobalDescribe().get(obj);
            Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
            
            String referenceObject='';
            integer i=1;
            for(String field:Map_ObjField.get(obj).Keyset()){
                //Soql = Soql + ' '+ field; OLD
                     
                        Soql = Soql + ' '+field;
                        
                        if(Map_ObjField.get(obj).size() > i){
                          //  Soql = Soql + ',';
                              Soql = Soql + ' ,';
                              system.debug('**LessONE**');
                        }
                        else{
                             // Soql = Soql + '+';
                              system.debug('**FINAL**');
                        }
                        
                        
                        system.debug('referenceObject MAP**'+Map_ObjField.get(obj).get(field)+'**sobjectType**'+sobjectType+'**field**'+field);

                      if(Map_ObjField.get(obj).get(field) == sobjectType){
                        system.debug('referenceObject MAP: field**'+field);  
                        referenceObject = field;
                      }  
                       
               i++;
                
                
            }
           
            system.debug('referenceObject MAP: referenceObject**'+referenceObject);  
            String WhereClause;
            if(sobjectType == obj){
                WhereClause = ' where id =   \''+ RecordId +'\' ';
            }
            else{
                WhereClause = ' where '+referenceObject + ' =   \''+ RecordId +'\' ';
            }
                
            
            // Soql = Soql + ' from' + obj;
            system.debug('WhereClause**'+WhereClause);
             system.debug('Soql**'+Soql);
             Soql = Soql + ' from ' + obj + WhereClause; //' where '+PrimaryObject + '=   \''+ RecordId +'\' limit 1';
            
            Map_ObjSoql.put(obj,Soql);
                
        }
        
        return Map_ObjSoql;
    
    }
    
    public static List<sObject> InsertRecords(Map<String, Map<String,String>> Map_ObjField,Map<String, List<SObject>> Map_Objrecord,id RecordId,String sobjectType, List<FlowInputs> request){
       
       // sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
       //     sObj.put('name' , RecordName) ;
       //     insert sObj ;
        
        List<sObject> lstSobj = new List<sObject>();
        

        for(String obj:Map_ObjField.keyset()){
            system.debug('==object api name: ' + obj);
            
            String PrimLookUp='';   
            
            SObjectType objectType = Schema.getGlobalDescribe().get(obj);        
            Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
            
            

            
            for(SObject val:Map_Objrecord.get(obj)){    

                sObject sObj = Schema.getGlobalDescribe().get(obj).newSObject() ;
                
                for(String field: Map_ObjField.get(obj).Keyset()){
                
                    
                 
                       Schema.DescribeFieldResult fieldResult = mfields.get(field).getDescribe();
                    
                        if(fieldResult.isCreateable()) {
                            
                           for(Schema.SObjectType reference : fieldResult.getReferenceTo()) {
                                
                                if(reference.getDescribe().getName() == sobjectType){
                                    system.debug('**field**'+field+'**value*'+val.get(field));
                                    sObj.put(field ,RecordId);
                                    PrimLookUp=field;          
                                }
                                
                            }
                            
                            
                            if(PrimLookUp=='' || PrimLookUp!=field){
                                if(field == 'Status' || field == 'OrderStatus__c'){
                                    sObj.put(field,'Draft'); // cannot create an order/orderitem with activated status
                                } else if(obj == 'Order' && field == 'Type' && request[0].orderType == 'Correction'){
                                    sObj.put(field,'Correction');
                                } else if(obj == 'Order' && field == 'CreatedByCorrectionProcess__c' && request[0].createdByCorrectionProcess == true){
                                    sObj.put(field,true);
                                } else if(obj == 'Order' && field == 'ExternalOrderId__c' && request[0].createdByCorrectionProcess == true){
                                    if(request[0].orderType == 'Correction'){
                                        String externalOrderId = val.get('OrderNumberId__c') + '-Correction';
                                        sObj.put(field,externalOrderId);
                                    } else {
                                        String externalOrderId = String.valueOf(val.get('ExternalOrderId__c'));
                                        sObj.put(field,externalOrderId);
                                    }
                                    
                                } else if (obj == 'Order' && field == 'CorrectionOrderNSID__c' && request[0].orderType == 'Correction'){
                                    sObj.put(field, val.get('NSOrderId__c'));
                                } else if (obj == 'OrderItem' && field == 'CorrectionOrderLineID__c' && request[0].orderType == 'Correction'){
                                    sObj.put(field, val.get('Id'));
                                } else if (obj == 'Order' && field == 'RecordTypeId'){
                                    // leave it
                                } else if (obj == 'OrderItem' && field == 'ProductType__c'){
                                    sObj.put(field ,val.get(field));
                                    system.debug('=-= ProductType__c: ' + val.get(field));
                                } else if (obj == 'OrderItem' && field == 'TotalDiscountAmount__c'){
                                    sObj.put(field ,val.get(field));
                                    system.debug('=-= TotalDiscountAmount__c: ' + val.get(field));
                                } else if (field == 'NSOrderStatus__c' || field == 'NSOrderInternalId__c' || field == 'SuccessStatusOfLastAWSUpdate__c' || field == 'LastUpdateToAWS__c') {
                                    //clear fields that should not be cloned with original master record values
                                    System.debug('**clearing fied: ' + field);
                                    sObj.put(field, null);
                                } else if(field != 'ImportItemGroupEAN__c') {
                                    sObj.put(field ,val.get(field));
                                }
                                
                                System.debug('**Util_Clone Object: ITEM group** field == '+ field +'' +  val.get(field));
                                if(obj == 'OrderItem' && field == 'ProductType__c' && val.get('ItemGroup__c') != null){

                                    System.debug('**Util_Clone Object: ProductType** field == '+ field +'' +  val.get(field));
                                    sObj.put('ImportItemGroupEAN__c' ,val.get('ItemGroup__c'));
                                }
                                
                                else if(field == 'ProductType__c' && val.get(field) == 'Item Group'){ 
                                    System.debug('**Util_Clone Object: ProductType: IG** field == '+ field +'' +  val.get('Id'));
                                    sObj.put('ImportItemGroupEAN__c' ,val.get('Id'));
                                }    


                                system.debug('**field**'+field+'**value*'+val.get(field));
                            }   
                        }    
                     
                         
                                            
                  //  }
                }
                lstSobj.add(sObj);
            }
           
           
            
                        
        }
        
        system.debug('**lstSobj**'+lstSobj.size());
        insert lstSobj;
            
        return lstSobj;
        
        
    }
    
    
    public static list<sobject> getRecords(String query){
            list<sobject> records;
            
            records = Database.query(query);

            system.debug('**Query size**'+records.size());
            return records;
    }
    
}