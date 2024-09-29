public with sharing class Order_ProductCalculationDates {
    
    Public static Map<String,Date> Map_EffectiveDate;
    Public static Map<String,Date> Map_ShipByDate; 
    Public Static String AddOrSubtractYear;


    public static List<OrderItem> UpdateOrderItemDate(List<OrderItem> lstOrderItem, List<Order> CurOrder){ //List<string> OrderId,
        system.debug('***Dates :Main Method');
        Map_EffectiveDate = new Map<String,Date>();
        Map_ShipByDate = new Map<String,Date>();
        Map<String,String> Map_OrderType = new Map<String,String>();

        Date ShipbyDate;

         for(Order  ord:CurOrder){
            
             Map_EffectiveDate.put(ord.id,ord.EffectiveDate); 
             Map_ShipByDate.put(ord.id,ord.ShipByDate__c);
             Map_OrderType.put(ord.id,ord.Type);

             ShipbyDate = ord.ShipByDate__c;

         }
         system.debug('***Dates :Main Method: Map_EffectiveDate**'+Map_EffectiveDate);       
 
                 Set<String> Set_Products = new Set<String>();
 
                 for(OrderItem item:lstOrderItem){
                     Set_Products.add(item.Product2Id);
                 }    
             
 
                 Product2[] lstProduct = [Select id,FreeFromDate__c,LicenseBreakDate__c,FixedStartDate__c,DurationMeasure__c,StartDate__c,LicenseDuration__c,LicenseDurationIndays__c from Product2 where id in: Set_Products];
 
                 Map<String,Date> Map_FreeFromDate = new Map<String,Date>();
                 Map<String,Date> Map_BreakDate = new Map<String,Date>();
                 Map<String,Date> Map_FixedStartDate = new Map<String,Date>();
                 Map<String,Date> Map_StartDate = new Map<String,Date>();
                 Map<String,Decimal> Map_LicenseDuration = new Map<String,Decimal>();
 
                 Date FixedStartDate;
                 Date FreeFromDate;
                 for(Product2 prod:lstProduct){
                     
                     if(prod.FixedStartDate__c != null){
                         FixedStartDate = date.newinstance(ShipbyDate.year(), prod.FixedStartDate__c.month(), prod.FixedStartDate__c.day());
                         Map_FixedStartDate.put(prod.id,FixedStartDate);
                     }               

                    
                    if(prod.LicenseBreakDate__c != null){
                        FreeFromDate = date.newinstance(ShipbyDate.year(), prod.LicenseBreakDate__c.month(), prod.LicenseBreakDate__c.day());
                        Map_BreakDate.put(prod.id,FreeFromDate);
                     }
                     

                     if(prod.FreeFromDate__c != null){
                        FreeFromDate = date.newinstance(ShipbyDate.year(), prod.FreeFromDate__c.month(), prod.FreeFromDate__c.day());
                        Map_FreeFromDate.put(prod.id,FreeFromDate);
                     }

                     Map_StartDate.put(prod.id,prod.StartDate__c );
                     
                    if(prod.DurationMeasure__c =='DAYS'){
                        if(prod.LicenseDurationIndays__c != null){
                                 Map_LicenseDuration.put(prod.id,prod.LicenseDurationIndays__c);
                         } 
                    }
                    else{
                        if(prod.LicenseDuration__c != null){
                                 Map_LicenseDuration.put(prod.id,decimal.valueof(prod.LicenseDuration__c));
                         }        
                    }
                     
                 }
 
                 
                 
               // Is this needed (LicenseType__c) since the break date needs to be populated anyway: 
                    Boolean UpdateOrder = false;  

                 Date curItemStartDate;
                 AddOrSubtractYear = 'Empty';
                 for(OrderItem item:lstOrderItem){

                    if(!item.Order.Pricebook2.Name.contains('Zorg') || item.StartDate__c == null ){

                            if(Map_OrderType.get(item.OrderId) !='RenewalOrder' || (Map_OrderType.get(item.OrderId) =='RenewalOrder' && item.StartDate__c ==null )){

                            
                                Date EndDate=null;
                                Date StartDate;
                               // To ensure that items with no licence duration and Don't block SF Rules for mixed products
                                if(item.StartDate__c < Map_ShipByDate.get(item.OrderId) && Map_FixedStartDate.get(item.Product2Id) == NULL){
                                    AddOrSubtractYear = 'Subtract';
                                }   

                                //Assign Start date now but it can change based on rules below
                                    item.StartDate__c = Map_ShipByDate.get(item.OrderId);
                                 //   item.ServiceDate = Map_ShipByDate.get(item.OrderId);
                             
           
                                system.debug('***Dates :FixedStartDate'+Map_FixedStartDate);
                                system.debug('***Dates :LicenseDuration'+Map_LicenseDuration);
                                system.debug('***Dates :FreeFromDate'+Map_FreeFromDate);
                                system.debug('***Dates :BreakDate'+Map_BreakDate);
                                system.debug('***Dates :StartDate'+item.StartDate__c);
                                //1 Start Date

                                    Integer StartDateYear = item.StartDate__c.year();

                                    if (Map_FixedStartDate.get(item.Product2Id) != NULL 
                                        && Map_LicenseDuration.get(item.Product2Id) != null 
                                        && Map_BreakDate.get(item.Product2Id) != null
                                        &&
                                        ((
                                           //1
                                            Map_FixedStartDate.get(item.Product2Id) >= item.StartDate__c
                                            && Map_BreakDate.get(item.Product2Id) <= item.StartDate__c
                                            && Map_FixedStartDate.get(item.Product2Id) > Map_BreakDate.get(item.Product2Id)
                                        )
                                        ||
                                        (
                                            //2
                                            Map_FixedStartDate.get(item.Product2Id) >= item.StartDate__c                                
                                            && Map_BreakDate.get(item.Product2Id) >= item.StartDate__c
                                            && Map_FixedStartDate.get(item.Product2Id) < Map_BreakDate.get(item.Product2Id)
                                        )
                                        ||
                                        (
                                            //3
                                            Map_FixedStartDate.get(item.Product2Id) <= item.StartDate__c
                                            && Map_BreakDate.get(item.Product2Id) >= item.StartDate__c
                                            && Map_FixedStartDate.get(item.Product2Id) < Map_BreakDate.get(item.Product2Id)
                                        )
                                        ||
                                        (
                                            //4
                                            Map_FixedStartDate.get(item.Product2Id) <= item.StartDate__c
                                            && Map_BreakDate.get(item.Product2Id) <= item.StartDate__c
                                            && Map_FixedStartDate.get(item.Product2Id) > Map_BreakDate.get(item.Product2Id)
                                        ))
                                       
                                        ){ 
                                                system.debug('**Dates :1,2,3,4**');
                                        
                                      //Check start date against Break date of next year to determine if start start remains current year
                                      Date NextBreakDate = date.newinstance(item.StartDate__c.year(), Map_BreakDate.get(item.Product2Id).month(), Map_BreakDate.get(item.Product2Id).day());
                                      
                                      Date NextFixedstartDate = date.newinstance(item.StartDate__c.year(), Map_FixedStartDate.get(item.Product2Id).month(), Map_FixedStartDate.get(item.Product2Id).day());
                                      
                                      
                                      if(NextBreakDate > NextFixedstartDate && item.StartDate__c >= NextBreakDate && item.StartDate__c > NextFixedstartDate){
                                            StartDateYear = NextFixedstartDate.year()+1; 
                                      }
                                      if(NextFixedstartDate > NextBreakDate && item.StartDate__c < NextBreakDate && item.StartDate__c < NextFixedstartDate){
                                        StartDateYear = NextFixedstartDate.year()-1; 
                                      }
                                      else{
                                            StartDateYear = NextFixedstartDate.year(); 
                                      }

                                      system.debug('**Dates :1: AddOrSubtractYear**'+AddOrSubtractYear);		
                                      system.debug('**Dates :1: LicenseDuration**'+Map_LicenseDuration.get(item.Product2Id));
                                      

                                      system.debug('**Dates :1: NextBreakDate**'+NextBreakDate);
                                      system.debug('**Dates :1: StartDateYear**'+StartDateYear);    

                                       
                                      StartDate  = date.newinstance(StartDateYear, Map_FixedStartDate.get(item.Product2Id).month(), Map_FixedStartDate.get(item.Product2Id).day());                                       
                                      EndDate = date.newinstance(StartDate.year(), StartDate.month()+integer.valueof(Map_LicenseDuration.get(item.Product2Id)), StartDate.day());  
                                     
                                      
                                        //  UpdateOrder = true;
                                        //To manage Salesforce Start date on order vs order Item
                                        if(StartDate >= Map_ShipByDate.get(item.OrderId) && !AddOrSubtractYear.contains('Subtract')){ 
                                            AddOrSubtractYear = 'Current';
                                        }
                                        else {
                                            AddOrSubtractYear = 'CurrentSubtract'; 
                                            if(Map_ShipByDate.get(item.Orderid) > StartDate){
                                                Map_EffectiveDate.put(item.Orderid,StartDate); 
                                               // Map_ShipByDate.put(item.Orderid,StartDate);
                                            }
                                            
                                        }
                                        system.debug('***Item Dates :ONE'+StartDate);
                                        system.debug('***Item Dates :AddOrSubtractYear'+AddOrSubtractYear);
                                        
                                        item.StartDate__c = StartDate;
                                       // item.ServiceDate = StartDate;
                        
                                        item.OrderItemEndDate__c = EndDate-1;  
                                        item.EndDate = EndDate-1;   
                                        
                                        //Free From
                                        if(Map_FreeFromDate.get(item.Product2Id) != null){

                                            //StartDateYear
                                            FreeFromDate = date.newinstance(Map_ShipByDate.get(item.OrderId).year(), Map_FreeFromDate.get(item.Product2Id).month(), Map_FreeFromDate.get(item.Product2Id).day());
                                      
                                            system.debug('***Item Dates :Free: Ship by'+Map_ShipByDate.get(item.OrderId));
                                            

                                            if(StartDate >= Map_ShipByDate.get(item.OrderId) && Map_ShipByDate.get(item.OrderId) >= FreeFromDate ){
                                                item.TrialStartDate__c = Map_ShipByDate.get(item.OrderId); 
                                                item.TrialEndDate__c = item.StartDate__c - 1;
                                            }
                                            else if(StartDate >= Map_ShipByDate.get(item.OrderId) && FreeFromDate >= Map_ShipByDate.get(item.OrderId)){
                                                item.TrialStartDate__c = FreeFromDate; 
                                                item.TrialEndDate__c = item.StartDate__c - 1;
                                            }
                                            else{
                                                item.TrialStartDate__c = null; 
                                                item.TrialEndDate__c = null;
                                            }
                                           
                                        }
                                        else{
                                            item.TrialStartDate__c = null; 
                                            item.TrialEndDate__c = null;
                                        }
                                       

                                    } 
                                 
                                    //5 Start Date - 1 year 

                                    else if (Map_FixedStartDate.get(item.Product2Id) != NULL 
                                    && Map_LicenseDuration.get(item.Product2Id) != null 
                                    && Map_BreakDate.get(item.Product2Id) != null 

                                    && Map_FixedStartDate.get(item.Product2Id) >= item.StartDate__c
                                    && Map_BreakDate.get(item.Product2Id) >= item.StartDate__c
                                    && Map_FixedStartDate.get(item.Product2Id) > Map_BreakDate.get(item.Product2Id)
                                    ){ 
                                        system.debug('**Dates :5: Start Date - 1 year**'+StartDateYear);
                                        AddOrSubtractYear = 'Subtract';
                                        

                                      //  Date NextBreakDate = date.newinstance(item.StartDate__c.year(), Map_BreakDate.get(item.Product2Id).month(), Map_BreakDate.get(item.Product2Id).day());
                                        
                                        Date NextFixedstartDate = date.newinstance(item.StartDate__c.year()-1, Map_FixedStartDate.get(item.Product2Id).month(), Map_FixedStartDate.get(item.Product2Id).day());
                                        
                                        StartDateYear = NextFixedstartDate.year();


                                     // system.debug('**Dates :5: NextBreakDate**'+NextBreakDate);
                                      system.debug('**Dates :5: StartDateYear**'+StartDateYear);

                                         StartDate  = date.newinstance(StartDateYear, Map_FixedStartDate.get(item.Product2Id).month(), Map_FixedStartDate.get(item.Product2Id).day());      
                                        
                                        EndDate = date.newinstance(StartDate.year(), StartDate.month()+integer.valueof(Map_LicenseDuration.get(item.Product2Id)), StartDate.day());  

                                        if(Map_ShipByDate.get(item.Orderid) > StartDate){
                                            Map_EffectiveDate.put(item.Orderid,StartDate); 
                                          //  Map_ShipByDate.put(item.Orderid,StartDate);
                                        }
                                        
                                        system.debug('**Dates :5:'+StartDate);
                                        system.debug('**Dates :5:'+StartDate);
                                     
                                        item.StartDate__c = StartDate;
                                    //    item.ServiceDate = StartDate;
                        
                                        item.OrderItemEndDate__c = EndDate-1;  
                                        item.EndDate = EndDate-1;   
                                        item.TrialStartDate__c = null; 
                                        item.TrialEndDate__c = null;
                                        
                                    }   
                                    //6 Start Date + 1 year
                                    else if (Map_FixedStartDate.get(item.Product2Id) != NULL 
                                    && Map_LicenseDuration.get(item.Product2Id) != null 
                                    && Map_BreakDate.get(item.Product2Id) != null

                                    && Map_FixedStartDate.get(item.Product2Id) <= item.StartDate__c 
                                    && Map_BreakDate.get(item.Product2Id) <= item.StartDate__c
                                    && Map_FixedStartDate.get(item.Product2Id) < Map_BreakDate.get(item.Product2Id)
                                    ){ 
                                        system.debug('**Dates :6**');

                                        
                                        Date NextBreakDate = date.newinstance(item.StartDate__c.year(), Map_BreakDate.get(item.Product2Id).month(), Map_BreakDate.get(item.Product2Id).day());                                           
                                      Date NextFixedstartDate = date.newinstance(item.StartDate__c.year(), Map_FixedStartDate.get(item.Product2Id).month(), Map_FixedStartDate.get(item.Product2Id).day());
                                        
                                  
                                      if(item.StartDate__c < NextBreakDate && item.StartDate__c < NextFixedstartDate){
                                        //-1 = current year but could be a few years into the past?                                      
                                        StartDateYear = NextFixedstartDate.year()-1; 
                                      }
                                      if(item.StartDate__c >= NextBreakDate && item.StartDate__c > NextFixedstartDate){
                                        //-1 = current year but could be a few years into the past?
                                        StartDateYear = NextFixedstartDate.year()+1; 
                                      }
                                      else if(item.StartDate__c >= NextBreakDate){
                                        //Start date greater than the break date of next year
                                        StartDateYear = NextFixedstartDate.year();
                                      }        


                                        system.debug('**Dates :1: NextBreakDate**'+NextBreakDate);
                                      //  system.debug('**Dates :1: BreakDateYearDiff**'+BreakDateYearDiff);
                                        system.debug('**Dates :1: StartDateYear**'+StartDateYear); 

                                        if(AddOrSubtractYear != null && !AddOrSubtractYear.contains('Subtract')){  
                                            AddOrSubtractYear = 'Current';
                                        }
                                        else{
                                           // AddOrSubtractYear = 'Add';
                                        }

                                         StartDate  = date.newinstance(StartDateYear, Map_FixedStartDate.get(item.Product2Id).month(), Map_FixedStartDate.get(item.Product2Id).day());

                                        EndDate = date.newinstance(StartDate.year(), StartDate.month()+integer.valueof(Map_LicenseDuration.get(item.Product2Id)), StartDate.day());  

                                        if(Map_FreeFromDate.get(item.Product2Id) != null){
                                           


                                            FreeFromDate = date.newinstance(Map_ShipByDate.get(item.OrderId).year(), Map_FreeFromDate.get(item.Product2Id).month(), Map_FreeFromDate.get(item.Product2Id).day());                        
                                            system.debug('***Item Dates 6:FreeFromDate'+FreeFromDate); 
                                            
                                            if(FreeFromDate < Map_ShipByDate.get(item.OrderId) && FreeFromDate < StartDate & StartDate != Map_ShipByDate.get(item.OrderId)){
                                            
                                              item.TrialStartDate__c = Map_ShipByDate.get(item.OrderId); 
                                                item.TrialEndDate__c = StartDate - 1;
                                            }
                                            else if(FreeFromDate < StartDate && FreeFromDate >= Map_ShipByDate.get(item.OrderId)){
                                                item.TrialStartDate__c = FreeFromDate; 
                                                item.TrialEndDate__c = StartDate - 1;
                                            }
                                            else{
                                                item.TrialStartDate__c = null; 
                                                item.TrialEndDate__c = null; 
                                            }
                                          
                                        }
                                        else{
                                            item.TrialStartDate__c = null; 
                                            item.TrialEndDate__c = null;
                                        }

                                        if(Map_ShipByDate.get(item.Orderid) > StartDate){
                                            Map_EffectiveDate.put(item.Orderid,StartDate); 
                                           // Map_ShipByDate.put(item.Orderid,StartDate);
                                        }


                                        system.debug('***Item Dates :ONE'+StartDate);     
                                        
                                        item.StartDate__c = StartDate;
                                   //     item.ServiceDate = StartDate;
                        
                                        item.OrderItemEndDate__c = EndDate-1;  
                                        item.EndDate = EndDate-1;   

                                    }                                     
                                    else if(Map_FixedStartDate.get(item.Product2Id) == NULL && Map_LicenseDuration.get(item.Product2Id) != null && item.StartDate__c != null){
                        
                                        system.debug('***Dates :Item Dates :THREE'+Map_ShipByDate.get(item.OrderId));
                                        EndDate = date.newinstance(item.StartDate__c.year(), item.StartDate__c.month()+integer.valueof(Map_LicenseDuration.get(item.Product2Id)), item.StartDate__c.day());  
                                    
                                        item.OrderItemEndDate__c = EndDate-1; 
                                        item.EndDate = EndDate-1;  
                        
                                        item.TrialStartDate__c = null; 
                                        item.TrialEndDate__c = null; 
                                        
                                    }
                                     
                                    
                            }

                    } 
                 }  
                 
                 system.debug('***Dates :order updates'+UpdateOrder);


         
           return  lstOrderItem;
 
         }


}