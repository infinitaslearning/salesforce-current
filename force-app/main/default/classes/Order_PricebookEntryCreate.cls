public with sharing class Order_PricebookEntryCreate {
   

    @invocablemethod
    public static void PricebookEntryCreate(List<Id> PriceId){  
        try {
            ProcessPricebookEntryCreate(PriceId);
            
            if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True){
                CalloutException e = new CalloutException();
                e.setMessage('Error');
                throw e;        
              }

        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            system.debug('**Order_PricebookEntryCreate: error**'+e.getMessage());
            HandleCustomException.LogException(e,PriceId[0]); 
        }
        finally {
            // Something executed whether there was an error or not
        }

    }    
    
public static void ProcessPricebookEntryCreate(List<Id> PriceId){  
        /*
        Pricing__c[] lstPricing = [Select id,EndDate__c,ExternalId__c,ProductComponent__r.Product__r.MarketSegment__c,ProductComponent__c,ProductComponent__r.IsActive__c,
                            ProductComponent__r.Product__c,ListRate__c,Product__c,StartDate__c,Subsidiary__c,Product__r.MarketSegment__c,Product__r.Stocknumber__c,Product__r.SoldInSegment__c,
                            Product__r.SoldInSubSegment__c,IsActive__c,Product__r.DeliveryStatus__c,Product__r.StockLevel__c,Product__r.PlannedPrintDate__c,Product__r.Type__c,
                            Product__r.HasBlock__c,Product__r.IsSuccessorItemActive__c,Product__r.SuccessorItem__c,Product__r.IsActive,CurrencyIsoCode
                            From Pricing__c where id in:PriceId AND ProductComponent__c =:null];
        */

        Pricing__c[] lstPricing = Order_SoqlFactory.returnPricing('Pricebookentrycreate',null,PriceId,null,null);
        system.debug('**Order_SoqlFactory.Order_PricebookEntryCreate.lstPrice :size**'+lstPricing.size());
                            
if(lstPricing.size()>0){ 


        Set<String> Set_Subsid = new Set<String>();
        Set<String> Set_ItemGrpCom = new Set<String>();
        Set<String> Set_priceProductStd = new Set<String>();
        Set<String> Set_priceProduct = new Set<String>();
        Map<String,string> Map_priceProductExisting = new Map<String,string> ();
        Map<String, Boolean> Map_pbeActiveStatus = new  Map<String, Boolean>();


        //GET Price where


        for(Pricing__c price:lstPricing){
            Set_Subsid.Add(price.Subsidiary__c);
            Set_ItemGrpCom.add(price.ProductComponent__c);
            
            Set_priceProduct.add(price.Product__c);
            if(price.ProductComponent__r.Product__c != null){ 
                Set_priceProduct.add(price.ProductComponent__r.Product__c);
            }
            
                
            //(price.Product__r.Stocknumber__c == 0  || price.Product__r.Stocknumber__c ==null) && 
        //((price.Product__r.PlannedPrintDate__c == null || price.Product__r.PlannedPrintDate__c < system.today()) && price.Product__r.Type__c =='Inventory Item') ||
           if( 
                 (price.Product__r.DeliveryStatus__c != 'Published' && price.Product__r.DeliveryStatus__c != 'Market Ready' && price.Product__r.DeliveryStatus__c != 'In Reprint' && price.Product__r.DeliveryStatus__c != 'While Stock Lasts') 
                //|| (price.Product__r.DeliveryStatus__c == 'While Stock Lasts' && (price.Product__r.Stocknumber__c == 0 || price.Product__r.Stocknumber__c == null) && price.Product__r.Type__c =='Inventory Item') 
                || price.Product__r.IsActive == false || price.Product__r.HasBlock__c == true 
                || (price.Product__r.IsSuccessorItemActive__c == true && price.Product__r.SuccessorItem__c != null ) 
                || price.IsActive__c == false ||  (price.ProductComponent__c != null & price.ProductComponent__r.IsActive__c == false)){
                    
                    Map_pbeActiveStatus.put(price.id,false);
            
                } 
            else{
                Map_pbeActiveStatus.put(price.id,true);
            }

        }

        Pricebook2[] lstPricebook = [Select Subsidiary__c,isStandard,PricebookType__c,SoldInSubSegment__c,EndDate__c,StartDate__c From Pricebook2 where Subsidiary__c in:Set_Subsid AND IsActive =: true ];
        ProductComponent__c[] lstProductComponent = [Select Product__c,MainProduct__c from ProductComponent__c where MainProduct__c in: Set_ItemGrpCom];
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

        PricebookEntry[] lstPricebookEntryStdExist = [Select id,Product2Id, Pricebook2Id from PricebookEntry where Pricebook2Id=:standardPB.id AND Product2Id in:Set_priceProduct]; //
        PricebookEntry[] lstPricebookEntryExist = [Select id,Product2Id, Pricebook2Id from PricebookEntry where Product2Id in:Set_priceProduct]; // 
       
        String PriceProd;
        for(PricebookEntry prod:lstPricebookEntryStdExist){
            Set_priceProductStd.add(prod.Product2Id);

            PriceProd = prod.Product2Id; 
            PriceProd += prod.Pricebook2Id;
            Map_priceProductExisting.put(PriceProd,prod.Id);
        }
        for(PricebookEntry prod:lstPricebookEntryExist){

            PriceProd = prod.Product2Id; 
            PriceProd += prod.Pricebook2Id;

            Map_priceProductExisting.put(PriceProd,prod.Id);
        }
        
        system.debug('**Order_PricebookEntryCreate: Standard PBE**'+lstPricebookEntryStdExist);
        system.debug('**Order_PricebookEntryCreate: EntryExist**'+lstPricebookEntryExist);


        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        List<PricebookEntry> lstPricebookUpdate = new List<PricebookEntry>();

        List<PricebookEntry> lstPricebookEntryStandard = new List<PricebookEntry>();
        /*
        List<ProductComponentPricing__c> lstProductComponentPricing = new list<ProductComponentPricing__c>();
        */
        
        AWSPricebookMapping__mdt[] AWSPricebookMapping = [Select  MapToPricebook__c,MarketSegment__c,SubSegment__c,Subsidiary__c from AWSPricebookMapping__mdt];   
       
        Map<String,string> Map_SubsMSegment = new Map<String,string> ();

        String SubsMSegment;
        for(AWSPricebookMapping__mdt mappb:AWSPricebookMapping){
            SubsMSegment = mappb.Subsidiary__c;
            SubsMSegment += mappb.MarketSegment__c;

            Map_SubsMSegment.put(SubsMSegment,mappb.MapToPricebook__c);
            system.debug('**Order_PricebookEntryCreate: SubsMSegmentY**'+SubsMSegment);
        }

        
        
        system.debug('**Order_PricebookEntryCreate: Set_priceProductStd**'+Set_priceProductStd);

        system.debug('**Order_PricebookEntryCreate: SIZE: lstPricebook**'+lstPricebook.size());
        system.debug('**Order_PricebookEntryCreate: SIZE: lstPricing**'+lstPricing.size());


         for(Pricebook2 pb:lstPricebook){
       
         //   Set_priceProduct = new Set<String>();       
            for(Pricing__c price:lstPricing){
                

                

                system.debug('**Order_PricebookEntryCreate: SubsMSegmentX**'+SubsMSegment);

                
                   
                    if(pb.PricebookType__c != null ){
                        system.debug('**Order_PricebookEntryCreate: Map_SubsMSegment**'+Map_SubsMSegment.get(SubsMSegment)+'**pb.MarketSegment__c**'+pb.PricebookType__c);
                             
                            //system.debug('**SubsMSegment**'+SubsMSegment);

                           
                        String SoldInMatch='False';
                        
                            
                            List<String> lst_Soldin = new List<String>();
                            lst_Soldin.AddAll(price.Product__r.SoldInSegment__c.Split(';'));
                            for(String Soldin:lst_Soldin){
                                SubsMSegment = price.Subsidiary__c;
                                SubsMSegment += Soldin;
                                if(Map_SubsMSegment.get(SubsMSegment)==pb.PricebookType__c || (Map_SubsMSegment.get(SubsMSegment)== 'All Education' && pb.PricebookType__c.contains('Education'))){
                                    SoldInMatch='True';
                                    break;
                                }
                             }
                         

                             system.debug('**Order_PricebookEntryCreate: SoldInMatch **'+ SoldInMatch);
                             system.debug('**Order_PricebookEntryCreate: Subsidiary **'+ pb.Subsidiary__c +'****'+price.Subsidiary__c);
 
                        PricebookEntry entry;
                        if(SoldInMatch=='True' && pb.Subsidiary__c == price.Subsidiary__c){
                            system.debug('**Order_PricebookEntryCreate: StartDate**' +price.StartDate__c + '***'+pb.StartDate__c);
                            system.debug('**Order_PricebookEntryCreate: EndDate**' +price.EndDate__c + '***'+pb.EndDate__c);

                                if( (pb.StartDate__c <= price.StartDate__c && price.StartDate__c  <= pb.EndDate__c) || (pb.StartDate__c <= price.EndDate__c && price.EndDate__c  <= pb.EndDate__c) 
                                  || (price.StartDate__c <= pb.StartDate__c && price.EndDate__c >= pb.EndDate__c)){ 
                                    system.debug('**Order_PricebookEntryCreate: Subs 2**' );    
                                    
                                    if(price.ProductComponent__r.Product__c != null){
                                        PriceProd = price.ProductComponent__r.Product__c;
                                    }    
                                    else if(price.Product__c != null){
                                        PriceProd = price.Product__c;
                                    } 
                                     
                                    PriceProd += pb.id;                                

                                    //Add to standard
                                    if(!Set_priceProductStd.contains(price.ProductComponent__r.Product__c) && price.ProductComponent__r.Product__c != null){
                                        system.debug('**STD 2**' );
                                        entry = new PricebookEntry(CurrencyIsoCode = price.CurrencyIsoCode,IsActive=Map_pbeActiveStatus.get(price.id),Pricebook2Id = standardPB.id,Price__c = price.id,Product2Id = price.ProductComponent__r.Product__c, UnitPrice = price.ListRate__c, Subsidiary__c = price.Subsidiary__c);
                                        lstPricebookEntryStandard.add(entry);

                                        Set_priceProductStd.add(price.ProductComponent__r.Product__c);
                                        //Prevent adding to Pricebook twice
                                         
                                    }
                                    else if(!Set_priceProductStd.contains(price.Product__c) && price.Product__c != null){
                                        system.debug('**STD 1**' );
                                        entry = new PricebookEntry(CurrencyIsoCode = price.CurrencyIsoCode,IsActive=Map_pbeActiveStatus.get(price.id),Pricebook2Id = standardPB.id,Price__c = price.id,Product2Id = price.Product__c, UnitPrice = price.ListRate__c, Subsidiary__c = price.Subsidiary__c);
                                        lstPricebookEntryStandard.add(entry);

                                        //Prevent adding to Pricebook twice
                                        Set_priceProductStd.add(price.Product__c);
                                    }
                                    
                                    system.debug('**Order_PricebookEntryCreate: IN**'+Map_priceProductExisting.get(PriceProd) );
                                    system.debug('**Order_PricebookEntryCreate: pb.isStandard**'+pb.isStandard);
                                if(pb.isStandard==false){   


                                    if(Map_priceProductExisting.get(PriceProd) != null && price.Product__c != null && !Set_priceProduct.contains(PriceProd)){
                                            system.debug('**Order_PricebookEntryCreate :IN**'+Map_pbeActiveStatus.get(price.id));
                                            entry = new PricebookEntry(CurrencyIsoCode = price.CurrencyIsoCode,id = Map_priceProductExisting.get(PriceProd) ,IsActive=Map_pbeActiveStatus.get(price.id),Pricebook2Id = pb.id,Price__c = price.id,Product2Id = price.Product__c, UnitPrice = price.ListRate__c, Subsidiary__c = price.Subsidiary__c);
                                            lstPricebookUpdate.add(entry);
                                            Set_priceProduct.add(PriceProd);
                                    }
                                    else if(Map_priceProductExisting.get(PriceProd) != null && price.ProductComponent__r.Product__c != null && !Set_priceProduct.contains(PriceProd)){
                                            entry = new PricebookEntry(CurrencyIsoCode = price.CurrencyIsoCode,id = Map_priceProductExisting.get(PriceProd) ,IsActive=Map_pbeActiveStatus.get(price.id),Pricebook2Id = pb.id,Price__c = price.id,Product2Id = price.ProductComponent__r.Product__c, UnitPrice = price.ListRate__c, Subsidiary__c = price.Subsidiary__c);
                                            lstPricebookUpdate.add(entry);
                                            Set_priceProduct.add(PriceProd);
                                    }
                                    else if(price.Product__c != null  && !Set_priceProduct.contains(PriceProd)){
                                            system.debug('**Order_PricebookEntryCreate: Out Prod**'+Set_priceProduct);
                                            entry = new PricebookEntry(CurrencyIsoCode = price.CurrencyIsoCode,IsActive=Map_pbeActiveStatus.get(price.id),Pricebook2Id = pb.id,Price__c = price.id,Product2Id = price.Product__c, UnitPrice = price.ListRate__c, Subsidiary__c = price.Subsidiary__c);
                                            lstPricebookEntry.add(entry);
                                            Set_priceProduct.add(PriceProd);
                                    }
                                    else if(price.ProductComponent__r.Product__c != null && !Set_priceProduct.contains(PriceProd)){
                                        system.debug('**Order_PricebookEntryCreate: Out Prodcom**');
                                        entry = new PricebookEntry(CurrencyIsoCode = price.CurrencyIsoCode, IsActive=Map_pbeActiveStatus.get(price.id),Pricebook2Id = pb.id,Price__c = price.id,Product2Id = price.ProductComponent__r.Product__c, UnitPrice = price.ListRate__c, Subsidiary__c = price.Subsidiary__c);
                                        lstPricebookEntry.add(entry);
                                        Set_priceProduct.add(PriceProd);
                                    }
                                }        
                                    system.debug('**Order_PricebookEntryCreate: lstPricebookEntry**'+lstPricebookEntry);
                                    system.debug('**Order_PricebookEntryCreate: lstPricebookUpdate**'+lstPricebookUpdate);
                                    
                                    system.debug('**Order_PricebookEntryCreate: price.Product__c**'+price.Product__c);
                                    system.debug('**Order_PricebookEntryCreate: price.ProductComponent__r.Product__c**'+price.ProductComponent__r.Product__c);




                             }
                             else{
                                if(price.ProductComponent__r.Product__c != null){
                                    PriceProd = price.ProductComponent__r.Product__c;
                                }    
                                else if(price.Product__c != null){
                                    PriceProd = price.Product__c;
                                } 
                                 
                                PriceProd += pb.id;
    
                                if(Map_priceProductExisting.get(PriceProd) != null && price.Product__c != null && !Set_priceProduct.contains(PriceProd)){
                                    system.debug('**IN**'+Map_pbeActiveStatus.get(price.id));
                                    entry = new PricebookEntry(id = Map_priceProductExisting.get(PriceProd) ,IsActive=false,Pricebook2Id = pb.id,Price__c = price.id,Product2Id = price.Product__c, UnitPrice = price.ListRate__c, Subsidiary__c = price.Subsidiary__c);
                                    lstPricebookUpdate.add(entry);
                                    Set_priceProduct.add(PriceProd);
                                }
    
                             }
                             
                            
                            }
                            else{

                                if(price.ProductComponent__r.Product__c != null){
                                    PriceProd = price.ProductComponent__r.Product__c;
                                }    
                                else if(price.Product__c != null){
                                    PriceProd = price.Product__c;
                                } 
                                 
                                PriceProd += pb.id;

                                if(Map_priceProductExisting.get(PriceProd) != null && price.Product__c != null && !Set_priceProduct.contains(PriceProd)){
                                    system.debug('**IN**'+Map_pbeActiveStatus.get(price.id));
                                    entry = new PricebookEntry(id = Map_priceProductExisting.get(PriceProd) ,IsActive=false,Pricebook2Id = pb.id,Price__c = price.id,Product2Id = price.Product__c, UnitPrice = price.ListRate__c, Subsidiary__c = price.Subsidiary__c);
                                    lstPricebookUpdate.add(entry);
                                    Set_priceProduct.add(PriceProd);
                                }
                            }
                            
                        }
                       
                    }
                        
                    
                    
            }    
             

        if(lstPricebookUpdate.size()>0){
            try {
                system.debug('**Order_PricebookEntryCreate" Update**');
                update lstPricebookUpdate;
                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True)
			    {
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
			    }
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e); 
               system.debug('Order_PricebookEntryCreate: Error:******'+e.getMessage());
                      
            }
            
        }
        if(lstPricebookEntryStandard.size()>0){
            

            try {
                system.debug('**STD Upsert**');
                upsert lstPricebookEntryStandard;
                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True)
			    {
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
			    }
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e); 
               system.debug('******'+e.getMessage());
                      
            }
        }    
        if(lstPricebookEntry.size()>0){
            

            try {
                

                for(PricebookEntry pbe:lstPricebookEntry){
                    system.debug('**PBE Upsert**'+pbe.Product2Id);
                }
                upsert lstPricebookEntry;

                if(Test.isRunningTest() && UTIL_TestClassExceptions.TESTCLASSEXCEPTION==True)
			    {
                    CalloutException e = new CalloutException();
                    e.setMessage('Error');
                    throw e;        
			    }
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e); 
               system.debug('******'+e.getMessage());
                      
            }
        }
        /*
        if(lstProductComponentPricing.size()>0){
            system.debug('**STD Component**');
            upsert lstProductComponentPricing;
        }
        */
    }

}
/*
    public static void ProcessPricebookEntryDeactivate(List<Id> PriceId){  
        Pricing__c[] lstPricing = [Select id,EndDate__c,ExternalId__c,ProductComponent__r.Product__r.MarketSegment__c,ProductComponent__c,ProductComponent__r.Product__c,ListRate__c,Product__c,StartDate__c,Subsidiary__c,Product__r.MarketSegment__c,Product__r.SoldInSubSegment__c,IsActive__c From Pricing__c where id in:PriceId AND IsActive__c =: true];


       

    }    
*/

}