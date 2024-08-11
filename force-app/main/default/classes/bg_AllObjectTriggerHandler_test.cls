@Istest

Public class bg_AllObjectTriggerHandler_test{




Public static testmethod void bg_AllObjectTriggerHandler1(){


    test.starttest();
       
    TestDataFactory.insertAccounts(1,'Plantyn',true);
    test.stoptest();

}

Public static testmethod void bg_AllObjectTriggerHandler2(){


    test.starttest();
       
    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

    List<Id> Set_AccId = new List<Id>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        Order_AccountSubsidiary.AccountSubsidiary(Set_AccId);

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,true);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);


        List<Id> RecordIds = new List<Id>();
        Set<Id> Set_RecordIds = new Set<Id>();
        for(Order ord:lstOrder){
            system.debug('**Map_AccSub**'+Map_AccSub.get(ord.AccountId));
            ord.AccountSubsidiary__c = Map_AccSub.get(ord.AccountId); 
            ord.NetSuiteIdAccountSubsidiary__c = '12345';
            RecordIds.add(ord.id);
            Set_RecordIds.add(ord.id);
        }
        
        for(OrderItem item:lstOrderItems){
            system.debug('**Map_AccSub**'+Map_AccSub.get(item.ShipToAccount__c));
            item.AccountSubsidiary__c = Map_AccSub.get(item.ShipToAccount__c); 
        }

        insert lstOrderItems;
        
        system.debug('**AccountSubsidiary**'+lstOrder[0].AccountSubsidiary__c);
        system.debug('**NetSuiteIdAccountSubsidiary**'+lstOrder[0].NetSuiteIdAccountSubsidiary__c);
        
        system.debug('**ValidationErrorsOrderProducts**'+lstOrder[0].ValidationErrorsOrderProducts__c);
        system.debug('**ValidationErrorsOrder**'+lstOrder[0].ValidationErrorsOrder__c);
        


        lstOrder[0].Status ='Activated';
        //update lstOrder;

        bg_AllObjectInvocableHandler.AllObjectInvocableHandler(RecordIds);

        bg_CustomApiParameter apiParam = new bg_CustomApiParameter();
            
           

                apiParam = new bg_CustomApiParameter();
                apiParam.ids = Set_RecordIds;
                apiParam.DMLOperation =  'Update'; 

                system.debug('***ORDERREST Before ***');
                //bg_RESTCalloutUtil bg = new bg_RESTCalloutUtil(apiParam);
                System.enqueueJob(new bg_RESTCalloutUtil(apiParam));
                system.debug('***ORDERREST After ***');           

    test.stoptest();

}

Public static testmethod void bg_AllObjectTriggerHandler3(){


    test.starttest();
       
    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Noordhoff',true,true);

    List<Id> Set_AccId = new List<Id>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        Order_AccountSubsidiary.AccountSubsidiary(Set_AccId);

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
        }

        update lstAccountSubsidiary;

        List<Product2> lstProduct = TestDataFactory.insertProducts(3,false);
        for(Product2 prod:lstProduct){
            prod.FixedStartDate__c = null;
        }
        insert lstProduct;

        Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
        List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
        List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
        List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
        List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false);


        List<Id> RecordIds = new List<Id>();
        Set<Id> Set_RecordIds = new Set<Id>();
        for(Order ord:lstOrder){
            system.debug('**Map_AccSub**'+Map_AccSub.get(ord.AccountId));
            ord.AccountSubsidiary__c = Map_AccSub.get(ord.AccountId); 
            ord.OperatingCompany__c = 'Noordhoff';
            ord.NetSuiteIdAccountSubsidiary__c = '12345';
          //  RecordIds.add(ord.id);
           // Set_RecordIds.add(ord.id);
        }
        Insert lstOrder;

        for(OrderItem item:lstOrderItems){
            system.debug('**Map_AccSub**'+Map_AccSub.get(item.ShipToAccount__c));
            item.AccountSubsidiary__c = Map_AccSub.get(item.ShipToAccount__c); 
            item.OrderId = lstOrder[0].id;
        }

        insert lstOrderItems;

        for(OrderItem item:lstOrderItems){
            RecordIds.add(item.id);
            Set_RecordIds.add(item.id);
        }
        
        system.debug('**AccountSubsidiary**'+lstOrder[0].AccountSubsidiary__c);
        system.debug('**NetSuiteIdAccountSubsidiary**'+lstOrder[0].NetSuiteIdAccountSubsidiary__c);
        
        system.debug('**ValidationErrorsOrderProducts**'+lstOrder[0].ValidationErrorsOrderProducts__c);
        system.debug('**ValidationErrorsOrder**'+lstOrder[0].ValidationErrorsOrder__c);
        

        Order[] nextOrder = [SELECT LineCount__c,ActivateforBatchProcessing__c,ValidateAccountErrors__c,ValidateActivateAccountSubsidiaryRequir__c,ValidateActivateEmailsRequired__c,ValidateActivateShippingAddressRequired__c,ValidateActivateValidation__c,ValidateB2BLineCountError__c,ValidateBilltoErrors__c,ValidateBillingAddress__c,ValidateBillToEmpty__c,ValidateCreditLimitCheck__c,ValidateFreeAndServiceMustbeZeroOnActiv__c,ValidateInventoryOnMultipleLocations__c,ValidateNetSalesPrice__c,ValidateOrderAmount__c,ValidateReferenceNumberCheck__c,ValidateShiptoErrors__c,ValidateShippingCostExclVAT__c,ValidateShippingAddress__c,ValidateShipToEmpty__c,ValidateTotalLineItemQuantities__c,ValidateDigitalforNetherlands__c,ValidateStartEndDateonOnItems__c,ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c
    FROM Order ];
    
    
    system.debug('***ValidateAccountErrors__c**'+nextOrder[0].ValidateAccountErrors__c);
    system.debug('***ValidateActivateAccountSubsidiaryRequir__c**'+nextOrder[0].ValidateActivateAccountSubsidiaryRequir__c);
    system.debug('***ValidateActivateEmailsRequired__c**'+nextOrder[0].ValidateActivateEmailsRequired__c);
    system.debug('***ValidateActivateShippingAddressRequired__c**'+nextOrder[0].ValidateActivateShippingAddressRequired__c);
    system.debug('***ValidateActivateValidation__c**'+nextOrder[0].ValidateActivateValidation__c);
    system.debug('***ValidateB2BLineCountError__c**'+nextOrder[0].ValidateB2BLineCountError__c);
    system.debug('***ValidateBilltoErrors__c**'+nextOrder[0].ValidateBilltoErrors__c);
    system.debug('***ValidateBillingAddress__c**'+nextOrder[0].ValidateBillingAddress__c);
    system.debug('***ValidateBillToEmpty__c**'+nextOrder[0].ValidateBillToEmpty__c);
    system.debug('***ValidateCreditLimitCheck__c**'+nextOrder[0].ValidateCreditLimitCheck__c);
    system.debug('***ValidateFreeAndServiceMustbeZeroOnActiv__c**'+nextOrder[0].ValidateFreeAndServiceMustbeZeroOnActiv__c);
    system.debug('***ValidateInventoryOnMultipleLocations__c**'+nextOrder[0].ValidateInventoryOnMultipleLocations__c);
    system.debug('***ValidateNetSalesPrice__c**'+nextOrder[0].ValidateNetSalesPrice__c);
    system.debug('***ValidateOrderAmount__c**'+nextOrder[0].ValidateOrderAmount__c);
    system.debug('***ValidateReferenceNumberCheck__c**'+nextOrder[0].ValidateReferenceNumberCheck__c);
    system.debug('***ValidateShiptoErrors__c**'+nextOrder[0].ValidateShiptoErrors__c);
    system.debug('***ValidateShippingCostExclVAT__c**'+nextOrder[0].ValidateShippingCostExclVAT__c);
    system.debug('***ValidateShippingAddress__c**'+nextOrder[0].ValidateShippingAddress__c);
    system.debug('***ValidateShipToEmpty__c**'+nextOrder[0].ValidateShipToEmpty__c);
    system.debug('***ValidateTotalLineItemQuantities__c**'+nextOrder[0].ValidateTotalLineItemQuantities__c);
    system.debug('***ValidateDigitalforNetherlands__c**'+nextOrder[0].ValidateDigitalforNetherlands__c);
    system.debug('***ValidateStartEndDateonOnItems__c**'+nextOrder[0].ValidateStartEndDateonOnItems__c);
    system.debug('***ValidationErrorsOrder__c**'+nextOrder[0].ValidationErrorsOrder__c);
    system.debug('***ValidationErrorsOrderProducts__c**'+nextOrder[0].ValidationErrorsOrderProducts__c);


    lstOrderItems = [Select ValidateActivateAccountSubsidiaryRequir__c,ValidateActivateDigitalActivationEmail__c,ValidateActivateNetSuiteId__c,ValidateActivateShippingAddressRequired__c,ValidateActiveandNoAsset__c,ValidateAll__c,ValidateCalculatedVAT__c,ValidateCannotSellLicenseMoreThan12Mont__c,ValidateDigitalActivationEmail__c,ValidateLineItemTotal__c,ValidateNegativeDiscount__c,ValidateNetSalesPrice__c,ValidateNetSalesPriceAgainstDiscount__c,ValidateNetSalesPriceCantbeNegative__c,ValidateNetsuiteQuantityMustbegreaterth__c,ValidateOrderLineTypeCheck__c,ValidateProductComponentNonRenewable__c,ValidateProductMaxQuantity__c,ValidateReferenceNumberCheck__c,ValidateDigitalforNetherlands__c,validateVATNetherlandsDigital__c 
    from Orderitem ];
  


    for(Orderitem item:lstOrderItems){
        system.debug('***Validate ActivateAccountSubsidiaryRequir**'+item.ValidateActivateAccountSubsidiaryRequir__c);
system.debug('***Validate ActivateDigitalActivationEmail**'+item.ValidateActivateDigitalActivationEmail__c);
system.debug('***Validate ActivateNetSuiteId**'+item.ValidateActivateNetSuiteId__c);
system.debug('***Validate ActivateShippingAddressRequired**'+item.ValidateActivateShippingAddressRequired__c);
system.debug('***Validate Active and No Asset**'+item.ValidateActiveandNoAsset__c);
system.debug('***Validate All**'+item.ValidateAll__c);
system.debug('***Validate Calculated VAT**'+item.ValidateCalculatedVAT__c);
system.debug('***Validate CannotSellLicenseMoreThan12Mont**'+item.ValidateCannotSellLicenseMoreThan12Mont__c);
system.debug('***Validate DigitalActivationEmail**'+item.ValidateDigitalActivationEmail__c);
system.debug('***Validate Line Item Total**'+item.ValidateLineItemTotal__c);
system.debug('***Validate NegativeDiscount**'+item.ValidateNegativeDiscount__c);
system.debug('***Validate NetSalesPrice**'+item.ValidateNetSalesPrice__c);
system.debug('***Validate NetSalesPriceAgainstDiscount**'+item.ValidateNetSalesPriceAgainstDiscount__c);
system.debug('***Validate NetSalesPriceCantbeNegative**'+item.ValidateNetSalesPriceCantbeNegative__c);
system.debug('***Validate NetsuiteQuantityMustbegreaterth**'+item.ValidateNetsuiteQuantityMustbegreaterth__c);
system.debug('***Validate OrderLineTypeCheck**'+item.ValidateOrderLineTypeCheck__c);
system.debug('***Validate ProductComponentNonRenewable**'+item.ValidateProductComponentNonRenewable__c);
system.debug('***Validate ProductMaxQuantity**'+item.ValidateProductMaxQuantity__c);
system.debug('***Validate ReferenceNumberCheck**'+item.ValidateReferenceNumberCheck__c);
system.debug('***ValidateDigitalforNetherlands**'+item.ValidateDigitalforNetherlands__c);
system.debug('***validateVATNetherlandsDigital**'+item.validateVATNetherlandsDigital__c);

    }
        lstOrder[0].Status ='Activated';
        update lstOrder;

        bg_AllObjectInvocableHandler.AllObjectInvocableHandler(RecordIds);

        bg_CustomApiParameter apiParam = new bg_CustomApiParameter();
            
           

                apiParam = new bg_CustomApiParameter();
                apiParam.ids = Set_RecordIds;
                apiParam.DMLOperation =  'Update'; 

                system.debug('***ORDERREST Before ***');
                //bg_RESTCalloutUtil bg = new bg_RESTCalloutUtil(apiParam);
                System.enqueueJob(new bg_RESTCalloutUtil(apiParam));
                system.debug('***ORDERREST After ***');           

    test.stoptest();

}
Public static testmethod void bg_AllObjectTriggerHandler4(){


    test.starttest();


    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

    List<Id> Set_AccId = new List<Id>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        Order_AccountSubsidiary.AccountSubsidiary(Set_AccId);

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        List<Id> RecordIds = new List<Id>();
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
            RecordIds.add(sub.id);
        }

    
        update lstAccountSubsidiary;

        Map<Id, sObject> allProductsMap =  new Map<ID, SObject>(lstAccountSubsidiary);
        
        bg_AllObjectTriggerHandler.afterObjectInsert(allProductsMap,'AccountSubsidiary__c');

        
    test.stoptest();
}

Public static testmethod void bg_AWSInvocableUtils(){


    test.starttest();
    List<Id> RecordIds = new List<Id>();
    bg_AWSInvocableUtils.ProcessAWSCallout('Account',RecordIds);

    test.stoptest();
}

Public static testmethod void bg_AllObjectInvocableHandler(){


    test.starttest();


    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

    List<Id> Set_AccId = new List<Id>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        Order_AccountSubsidiary.AccountSubsidiary(Set_AccId);

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        List<Id> RecordIds = new List<Id>();
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
            RecordIds.add(sub.id);
        }

    
        update lstAccountSubsidiary;

        bg_AllObjectInvocableHandler.AllObjectInvocableHandler(RecordIds);

    test.stoptest();
}

Public static testmethod void bg_AWSTriggerUtils(){


    test.starttest();


    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

    List<Id> Set_AccId = new List<Id>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        Order_AccountSubsidiary.AccountSubsidiary(Set_AccId);

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        List<Id> RecordIds = new List<Id>();
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
            RecordIds.add(sub.id);
        }

    
        update lstAccountSubsidiary;

        lstAccount[0].Name = 'ChangeName';
        Update lstAccount;

    test.stoptest();
}

Public static testmethod void bg_LogResponse1(){


    test.starttest();


    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

    Set<ID> ids = new Set<ID>();
        for(Account acc:lstAccount){
            ids.add(acc.id);
        }

        String jsonInput =  '{"success":true,"correlationId":"1a5fd0c6-72b0-4f89-a44d-e55b6e88991e"}';

        bg_LogResponse.logresponse(jsonInput,ids);

    test.stoptest();
}
Public static testmethod void bg_LogResponse2(){


    test.starttest();


    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);
    
    List<Contact> lstContact = CS_TestDataFactory.createContacts(lstAccount[0].Id, 1, true);

    Set<ID> ids = new Set<ID>();
        for(Contact con:lstContact){
            ids.add(con.id);
        }



        String jsonInput =  '{"success":true,"correlationId":"1a5fd0c6-72b0-4f89-a44d-e55b6e88991e"}';

        bg_LogResponse.logresponse(jsonInput,ids);

    test.stoptest();
}
Public static testmethod void bg_LogResponse3(){


    test.starttest();


    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

    List<Id> Set_AccId = new List<Id>();
        for(Account acc:lstAccount){
            Set_AccId.add(acc.id);
        }

        Order_AccountSubsidiary.AccountSubsidiary(Set_AccId);

        AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

        Map<String,String> Map_AccSub = new Map<String,String>();
        Integer i=0;
        List<Id> RecordIds = new List<Id>();
        Set<ID> ids = new Set<ID>();
        for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
            sub.NetsuiteInternalId__c = '88776'+i;
            Map_AccSub.put(sub.Account__c,sub.id);
            i++;
            RecordIds.add(sub.id);
            ids.add(sub.id);
        }

    
        update lstAccountSubsidiary;

        lstAccount[0].Name = 'ChangeName';
        Update lstAccount;


        //jsonInput = JSON.serializePretty(userList);
        String jsonInput =  '{"success":true,"correlationId":"1a5fd0c6-72b0-4f89-a44d-e55b6e88991e"}';

        jsonInput = '{\n' +
        ' "success": false ,\n' +
        ' "correlationId": "xxx0x0x0x0x0x0x0x0x0",\n' +
        ' "failures" : [ ' + 
        '{ "id": "0013N000019rz2bQAA", ' + 
        '"message": "Problem Child 1" }, \n'+
        '{ "id": "0013N00001AzELrQAN", ' + 
        '"message": "Problem Child 2" } ]\n' +
        '}';
        
        ids.add('0013N000019rz2bQAA');
        ids.add('0013N00001AzELrQAN');
        bg_LogResponse.logresponse(jsonInput,ids);

    test.stoptest();
}


}