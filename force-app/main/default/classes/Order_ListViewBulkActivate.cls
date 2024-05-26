/*
* CH: List View Button to bulk activate orders.
* Dependencies: BulkOrderListViewActivate.vfp
*/
public with sharing class Order_ListViewBulkActivate {
    public List<Order> SelectedOrderLs {
        get;
        set;
    }


    public Order_ListViewBulkActivate(ApexPages.StandardSetController lsCtrl) {
        Set<Id> selectedOrderIdLs = new Set<Id>();
        SelectedOrderLs = new List<Order>();

        system.debug('lsCtrl: ' + lsCtrl);
        system.debug('== lsCtrl.getSelected(): ' + lsCtrl.getSelected());

        for (Order ord: (Order[]) lsCtrl.getSelected()) {
            system.debug('ord.Id: ' + ord.Id);
            selectedOrderIdLs.add(ord.Id);
        }
        
        SelectedOrderLs = [SELECT Id, ActivateforBatchProcessing__c FROM Order WHERE Id IN: selectedOrderIdLs];
        system.debug('SelectedOrderLs: ' + SelectedOrderLs);
    }

    public PageReference activateOrders(){
        if(SelectedOrderLs.size() > 0){
            for(Order ord : SelectedOrderLs){
                ord.ActivateforBatchProcessing__c = true;
            }

            update SelectedOrderLs;

            Order_BatchOrderActivateAssetRenewal activateOrderLsBulk = new Order_BatchOrderActivateAssetRenewal();
            database.executebatch(activateOrderLsBulk, 1);
    
            system.debug('activateOrderLsBulk: ' + activateOrderLsBulk);
        }

        return null;
    }
}