public with sharing class Order_AssetsFromOrder {

        //POTENTIAL DELETE

        public class Request{ 
            @invocablevariable Public List<OrderItem> ListOfItems;
    
        }
        public class Response{ 
            @invocablevariable Public List<Asset> ListOfAssets;         
        }
    
    
       
        @invocablemethod
        public static List<Response> AssetsFromOrder(List<Request> req){
    
            List<Response> responses;
    
            responses = processAssetsFromOrder(req);
            
            try {
                
            }
            catch (Exception e) {
                // "Convert" the exception into an AuraHandledException
                HandleCustomException.LogException(e);
                system.debug('** Error Message: '+e.getMessage());
                throw new AuraHandledException('Something went wrong: '
                    + e.getMessage() + 'Please contact system administator');    
            }
            finally {
                // Something executed whether there was an error or not
            }
            
            return responses;
    
        }    
    
        
        public static List<Response> processAssetsFromOrder(List<Request> req){
            
            Set<string> Set_Shipto = new Set<string>(); 
            Set<string> Set_ProdId = new Set<string>();

            Date Startdate;

            for(OrderItem item:req[0].ListOfItems){
                Set_Shipto.add(item.ShipToAccount__c);
                Set_ProdId.add(item.Product2Id);
                Startdate = item.StartDate__c;
            }

            Asset[] ListOfAssets= [Select AccountCustomerNumber__c,AccountId,AccountName__c,ActivationDate__c,AssetLevel,AutomatedRenewProcess__c,BillToAccount__c,BillToName__c,CancellationDate__c,CancellationReason__c,CancellationTrigger__c,Channel__c,ContactId,Contract__c,CreatedById,CreatedDate,Crebocode__c,CurrencyIsoCode,CurrentEdition__c,CurrentMethod__c,CurrentPublisher__c,Description,DigitalFactor__c,DiscountedPrice__c,Id,InstallDate,IsActive__c,ISBN__c,IsBooklistPresent__c,IsCompetitorProduct,IsDeleted,IsInternal,IsUpForRenewal__c,LastRenewalUpdate__c,LastViewedDate,Level__c,LicenseDuration__c,ListPrice__c,LocationTotalNumberofStudents__c,ManualDiscountPercent__c,ManualDiscountValue__c,ManualDiscount__c,MethodCode__c,MethodName__c,Method__c,Name,NumberofActiveUsers__c,OperatingCompany__c,OrderProduct__c,OwnerId,ParentId,Price,PriceBook__c,PriceValidTillDate__c,PricingMethod__c,Product2Id,ProductClass__c,ProductCode,ProductFamilyType__c,ProductFamily__c,PurchaseDate,Quantity,RecordTypeId,RecordTypeName__c,RenewalDate__c,RenewalTerm__c,Unit__c,UsageEndDate from Asset where Product2Id in: Set_ProdId AND AccountId in: Set_Shipto AND (CancellationDate__c >: Startdate OR CancellationDate__c=:null) ];
    
            List<Response> responses = new List<Response>();
            Response res = new Response();
            res.ListOfAssets = ListOfAssets; 
            responses.add(res);
            return responses;
    
        }    
    
}