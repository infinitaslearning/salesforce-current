public with sharing class DevOps_FeatureHandler {
   
    
    Public static void maintainlists (){

        DevOpsFeature__c[] lstDevOpsFeature =[Select Name, Type__c From DevOpsFeature__c];

        String ConactName;
        Set<String> Set_DevOpsItem = new Set<String>();

        for(DevOpsFeature__c devop :lstDevOpsFeature){
            ConactName = devop.Type__c;
            ConactName += devop.Name;
            Set_DevOpsItem.add(ConactName);
        }

        List<ApexClass> classes = [select ApiVersion, Body, BodyCrc, CreatedById, CreatedDate, Id, IsValid, LastModifiedById, LastModifiedDate, LengthWithoutComments, Name, NamespacePrefix, Status, SystemModstamp from ApexClass where NamespacePrefix =:null Order by Name ASC];

        List<DevOpsFeature__c> lstNewDevOpsFeature = new List<DevOpsFeature__c>();
        for (ApexClass apex: classes){ 
            
            ConactName = 'ApexClass';
            ConactName += apex.Name;

            if(!Set_DevOpsItem.Contains(ConactName)){
                DevOpsFeature__c NewDevOpsFeature = new DevOpsFeature__c();
                NewDevOpsFeature.Type__c = 'ApexClass';
                NewDevOpsFeature.Name = apex.Name;
                lstNewDevOpsFeature.add(NewDevOpsFeature);
            }

            system.debug('***'+apex.Name);
        }
        

        ApexPage[] VFPage = [SELECT Name,NamespacePrefix FROM ApexPage where NamespacePrefix =null];

        for (ApexPage page: VFPage){ 
            
            ConactName = 'VFPage';
            ConactName += page.Name;

            if(!Set_DevOpsItem.Contains(ConactName)){
                DevOpsFeature__c NewDevOpsFeature = new DevOpsFeature__c();
                NewDevOpsFeature.Type__c = 'VisualforcePage';
                NewDevOpsFeature.Name = page.Name;
                lstNewDevOpsFeature.add(NewDevOpsFeature);
            }

            system.debug('***'+page.Name);
        }


        
        AuraDefinitionBundle[] AuraDefinition = [SELECT DeveloperName FROM AuraDefinitionBundle WHERE NamespacePrefix =: Null Order by DeveloperName ASC];
        
        for(AuraDefinitionBundle aura:AuraDefinition){
            system.debug('***'+aura.DeveloperName);
            ConactName = 'Aura';
            ConactName += aura.DeveloperName;

            if(!Set_DevOpsItem.Contains(ConactName)){
                DevOpsFeature__c NewDevOpsFeature = new DevOpsFeature__c();
                NewDevOpsFeature.Type__c = 'Aura';
                NewDevOpsFeature.Name = aura.DeveloperName;
                lstNewDevOpsFeature.add(NewDevOpsFeature);
            }

        }
        
        FlowDefinitionView[] FlowDefinition = [SELECT ApiName FROM FlowDefinitionView Order by ApiName ASC];
        
        
        for(FlowDefinitionView flow:FlowDefinition){
             
            ConactName = 'Flow';
            ConactName += flow.ApiName;

            if(!Set_DevOpsItem.Contains(ConactName)){
                DevOpsFeature__c NewDevOpsFeature = new DevOpsFeature__c();
                NewDevOpsFeature.Type__c = 'Flow';
                NewDevOpsFeature.Name = flow.ApiName;
                lstNewDevOpsFeature.add(NewDevOpsFeature);
            }

            system.debug('***'+flow.ApiName);
        }

        ApexTrigger[] Triggers = [SELECT Body,Name,NamespacePrefix FROM ApexTrigger WHERE NamespacePrefix = Null];

        for(ApexTrigger trig:Triggers){

            ConactName = 'ApexTrigger';
            ConactName += trig.name;

            if(!Set_DevOpsItem.Contains(ConactName)){
                DevOpsFeature__c NewDevOpsFeature = new DevOpsFeature__c();
                NewDevOpsFeature.Type__c = 'ApexTrigger';
                NewDevOpsFeature.Name = trig.name;
                lstNewDevOpsFeature.add(NewDevOpsFeature);
            }

            system.debug('***'+trig.name);
        }

        

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('https://infinitaslearning--devcentral.sandbox.my.salesforce.com/services/data/v56.0/tooling/query/?q=Select+NamespacePrefix,DeveloperName,id,ManageableState+from+LightningComponentBundle+where+ManageableState=%27unmanaged%27+and+NamespacePrefix=null');
        req.setMethod('GET');

        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug('#######'+res.getHeader('Location'));
        while (res.getStatusCode() == 302) {
            req.setEndpoint(res.getHeader('Location'));
            res = new Http().send(req);
        }
        system.debug(res.getBody());
        system.debug('*****');

        Map<String, Object> mainNode;
        
        mainNode = (Map<String, Object>)JSON.deserializeUntyped(res.getBody()); 

        List<Object> firtInstance = new List<Object>();

        system.debug('***mainNode***'+mainNode);

        firtInstance = (List< Object>)mainNode.get('records'); 

        system.debug('***firtInstance***'+firtInstance);

        for(integer x=0;x<firtInstance.size();x++){
                Map<String, Object> d1 =  (Map<String, Object>)firtInstance[x];            
                system.debug('DeveloperName'+x+': '+d1.get('DeveloperName'));  
                
                ConactName = 'LWC';
                ConactName += string.valueof(d1.get('DeveloperName'));

            if(!Set_DevOpsItem.Contains(ConactName)){
                DevOpsFeature__c NewDevOpsFeature = new DevOpsFeature__c();
                NewDevOpsFeature.Type__c = 'LWC';
                NewDevOpsFeature.Name = string.valueof(d1.get('DeveloperName'));
                lstNewDevOpsFeature.add(NewDevOpsFeature);
            }

        } 



        if(lstNewDevOpsFeature.size()>0){
            insert lstNewDevOpsFeature;
        }


    }
}