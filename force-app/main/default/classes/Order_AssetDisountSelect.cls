public with sharing class Order_AssetDisountSelect {
   
    @AuraEnabled
    public static Account UpdateAsset(Decimal DiscountValue, String RecordId,String DiscountType) {
        
        system.debug('Record Id'+ RecordId);
        Asset[] CurAsset = [Select id,ManualDiscount__c,ManualDiscountPercent__c,ManualDiscountValue__c from Asset where id =:RecordId];

        system.debug('**DiscountType'+ DiscountType);
        system.debug('**DiscountValue'+ DiscountValue);
        system.debug('**CurAsset'+CurAsset);

            if(DiscountType == 'Percent'){
                CurAsset[0].ManualDiscount__c = 'Recurring Percentage' ;
                CurAsset[0].ManualDiscountPercent__c = DiscountValue;
                CurAsset[0].ManualDiscountValue__c = null;
            }
            else if(DiscountType == 'Amount'){
                CurAsset[0].ManualDiscount__c = 'Recurring Amount';
                CurAsset[0].ManualDiscountValue__c = DiscountValue;
                CurAsset[0].ManualDiscountPercent__c = null;
            }
            else{
                CurAsset[0].ManualDiscount__c = '';
                CurAsset[0].ManualDiscountValue__c = null;
                CurAsset[0].ManualDiscountPercent__c = null;
            }
            
        
        update CurAsset;

        system.debug('asset updated');
       // insert acc;
        return null;
    }

    @AuraEnabled (cacheable=true)
    public static List<DiscountValues> ReturnDiscountValues(String AssetId){

        Asset[] CurAsset = [Select id,ManualDiscount__c,ManualDiscountPercent__c,ManualDiscountValue__c from Asset where id =:AssetId];

        

        try {
            List<DiscountValues> l_DiscountValues = new List<DiscountValues>();
           
            DiscountValues dv = new DiscountValues();

 //---- Add Percent                       
            dv.DiscountType = 'Amount';
            
            if(CurAsset[0].ManualDiscount__c == 'Recurring Amount'){      
                dv.Discount = CurAsset[0].ManualDiscountValue__c;        
                dv.isSelected = true;
            }
            else{
                dv.Discount = 0;
                dv.isSelected = false;
            } 
            
            
            l_DiscountValues.add(dv);           

//---- Add Percent            
            dv = new DiscountValues();
            dv.DiscountType = 'Percent';
                
            if(CurAsset[0].ManualDiscount__c =='Recurring Percentage'){ 
                dv.Discount = CurAsset[0].ManualDiscountPercent__c;  
                dv.isSelected = true; 
            }
            else{
                dv.Discount = 0;
                dv.isSelected = false;
            }            
            
            l_DiscountValues.add(dv);
//---- Add None
            dv = new DiscountValues();
            dv.DiscountType = '--None--';
            dv.Discount = 0;
            
            if(CurAsset[0].ManualDiscount__c !='Recurring Percentage' && CurAsset[0].ManualDiscount__c != 'Recurring Amount'){
                dv.isSelected = true;               
            }
            else{
                dv.isSelected = false;
            }
            l_DiscountValues.add(dv);
            // Can include multiple fields, 
            // You can also use any standard or custom object
            // You can get values from custom setting also.
             
            return l_DiscountValues;
        } catch (Exception e) {
            System.debug('Exception: '+e.getMessage());
            return null;
        }
    }


    Public Class DiscountValues{

        @auraenabled Public String DiscountType {get;set;} 
        @auraenabled Public Decimal Discount {get;set;}
        @auraenabled Public Boolean isSelected {get;set;}

    }
    
}