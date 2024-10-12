import { LightningElement, api, wire, track } from 'lwc';
import getAssetListForBillTo from '@salesforce/apex/ASSET_showRenewableAssetsHelper.getAssetListForBillTo';
import getSortedAssetListForBillToJS from '@salesforce/apex/ASSET_showRenewableAssetsHelper.getSortedAssetListForBillTo';
import { pageNumber, pageSize, totalRecords, records } from 'c/paginator';
import ContrastInvertedColor from '@salesforce/schema/EmbeddedServiceDetail.ContrastInvertedColor';

export default class ShowRenewableAssets extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track columns = [
        {
            label: 'Name',
            fieldName: 'assetUrl',
            sortable: "true",
            type: 'url',
            typeAttributes: {label: { fieldName: 'AssetName'},
            target: '_self'}
        },
        {
            label: 'External Customer ID',
            fieldName: 'ExternalCustID',
            type: 'text',
            initialWidth: 110,
            hideDefaultActions: true
        },
        {
            label: 'Subscription Id',
            fieldName: 'subscriptionId',
            type: 'text',
            initialWidth: 110,
            hideDefaultActions: true
        },
        {
            label: 'EAN',
            fieldName: 'EAN',
            type: 'text',
            initialWidth: 110,
            hideDefaultActions: true
        },
        {
            label: 'Ship-To',
            fieldName: 'shipToUrl',
            type: 'url',
            typeAttributes: 
            {
                label: 
                { 
                    fieldName: 'ShipToName'
                },
                target: '_self'
            }
        },
        {
            label: 'Bill-To',
            fieldName: 'BillToUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'BillToName'},
            target: '_self'}
        },
        {
            label: 'Active',
            fieldName: '',
            cellAttributes: {
                iconName: {
                    fieldName: 'activeSymbol'
                }
            },
            initialWidth: 60,
            hideDefaultActions: true
        },
        {
            label: 'Type',
            fieldName: '',
            cellAttributes: {
                iconName: {
                    fieldName: 'itemTypeIcon'
                }
            },
            initialWidth: 60,
            hideDefaultActions: true
        },
        {
            label: 'Quantity',
            fieldName: 'Amount',
            sortable: "true",
            type: 'number',
            initialWidth: 80,
            hideDefaultActions: true
        },
        {
            label: 'Renewable Date',
            fieldName: 'RenewalDate',
            type: 'date',
            initialWidth: 100,
            sortable: "true",
            hideDefaultActions: true,
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            }

        },
        {
            label: 'Start Date',
            fieldName: 'StartDate',
            type: 'date',
            initialWidth: 100,
            sortable: "true",
            hideDefaultActions: true,
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            }
        },
        {
            label: 'End Date',
            fieldName: 'EndDate',
            type: 'date',
            initialWidth: 100,
            sortable: "true",
            hideDefaultActions: true,
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            }
        },
        {
            label: 'Cancelation Date',
            fieldName: 'CancelationDate',
            type: 'date',
            sortable: "true",
            initialWidth: 100,
            hideDefaultActions: true,
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric"
            }
        }
    ];

    @track showTable = false;
    @track noData = false;
    @track datePicker = false;
    @track error;
    @track assetList = [];
    @track recordsToDisplay = [];
    @track rowNumberOffset;
    @track dateSelection = '';
    @track dateFieldSelectoin = 'RenewalDate__c';
    @track currentRecordId;
    @track selectedDate;
    @track dateValue;

    @track sortBy;
    @track sortDirection;

    @track currenObjectName;

    @track filterPopupIsOpen = false;

    @wire(getAssetListForBillTo, { "recordId": '$recordId' })
    wiredBillToAssets({ error, data }) {

        this.currenObjectName = this.objectApiName;
        this.currentRecordId = this.recordId;

        if (data) {
            let d = [];
            data.forEach(element => {
                let elt ={};
                elt.Id = element.Id;
                elt.AssetName = element.Name;
                elt.ExternalCustID = element.Account?.ExternalCustomerId__c;
                elt.Amount = element.Quantity;
                elt.assetUrl = `/${element.Id}`;
                if (element.AccountId) {
                    elt.ShipToName = element.Account.Name;
                    elt.shipToUrl = `/${element.AccountId}`;
                } else {
                    elt.ShipToName = '';
                    elt.shipToUrl = '';
                }
                elt.BillToName = element.BillToAccount__r.Name;
                elt.BillToUrl = `/${element.BillToAccount__c}`;
                elt.StartDate = element.ActivationDate__c;
                elt.RenewalDate = element.RenewalDate__c;
                elt.CancelationDate = element.CancellationDate__c;
                //elt.EndDate = element.UsageEndDate;
                elt.EndDate = element.EndDate__c;
                if (element.Active__c) {
                    elt.activeSymbol = 'utility:check';
                } else {
                    elt.activeSymbol = null;
                }
                if (element.Product2Id) {
                    switch (element.Product2.Type__c) {
                        case 'Inventory Item':
                            elt.itemTypeIcon = 'utility:knowledge_base';
                            break;
                        case 'Non-inventory Item':
                            elt.itemTypeIcon = 'utility:screen';
                            break;
                        case 'Item Group':
                            elt.itemTypeIcon = 'utility:overflow';
                            break;
                        case 'Kit/Package':
                            elt.itemTypeIcon = 'utility:ad_set';
                            break;
                        case 'Service':
                            elt.itemTypeIcon = 'utility:questions_and_answers';
                            break;
                        default:
                            elt.itemTypeIcon = '';
                    }
                } else {
                    elt.itemTypeIcon = '';
                }
                elt.subscriptionId = element.SubscriptionId__c;
                elt.EAN = element.Product2.EAN__c;

                d.push(elt);
            });
            this.assetList = d;

            this.showTable = true;
            this.error = null;
            this.noData = false;
            
        } else if (error) {
            this.showTable = false;
            this.error = error;
        }

    }

    handleDateSelection(event) {
        this.dateSelection = event.target.value;
        console.log(this.dateSelection);
        console.log(this.dateFieldSelectoin);

        if (this.dateSelection == "customDate") {
            this.datePicker = true;
        } else {
            this.datePicker = false;

            getSortedAssetListForBillToJS({ 
                "recordId": this.currentRecordId,
                "sorting": this.dateSelection,
                "sortField": this.dateFieldSelectoin,
                "selectedDate": ''
            })
            .then(result => {
                console.log('getting results');
                let dataSet = [];
                dataSet = result;
                console.log(dataSet);
    
                if (dataSet.length > 0) {
                    let x = [];
                    result.forEach(element => {
                        let elt ={};
                        elt.Id = element.Id;
                        elt.AssetName = element.Name;
                        elt.ExternalCustID = element.Account?.ExternalCustomerId__c;
                        elt.Amount = element.Quantity;
                        elt.assetUrl = `/${element.Id}`;
                        if (element.AccountId) {
                            elt.ShipToName = element.Account.Name;
                            elt.shipToUrl = `/${element.AccountId}`;
                        } else {
                            elt.ShipToName = '';
                            elt.shipToUrl = '';
                        }
                        elt.BillToName = element.BillToAccount__r.Name;
                        elt.BillToUrl = `/${element.BillToAccount__c}`;
                        elt.StartDate = element.ActivationDate__c;
                        elt.RenewalDate = element.RenewalDate__c;
                        elt.CancelationDate = element.CancellationDate__c;
                       // elt.EndDate = element.UsageEndDate;
                        elt.EndDate = element.EndDate__c;
                        if (element.Active__c) {
                            elt.activeSymbol = 'utility:check';
                        } else {
                            elt.activeSymbol = null;
                        }
                        if (element.Product2Id) {
                            switch (element.Product2.Type__c) {
                                case 'Inventory Item':
                                    elt.itemTypeIcon = 'utility:knowledge_base';
                                    break;
                                case 'Non-inventory Item':
                                    elt.itemTypeIcon = 'utility:screen';
                                    break;
                                case 'Item Group':
                                    elt.itemTypeIcon = 'utility:overflow';
                                    break;
                                case 'Kit/Package':
                                    elt.itemTypeIcon = 'utility:ad_set';
                                    break;
                                case 'Service':
                                    elt.itemTypeIcon = 'utility:questions_and_answers';
                                    break;
                                default:
                                    elt.itemTypeIcon = '';
                            }
                        } else {
                            elt.itemTypeIcon = '';
                        }
                        elt.subscriptionId = element.SubscriptionId__c;
                        elt.EAN = element.Product2.EAN__c;
                        
                        x.push(elt);
                        });
                    this.assetList = x;
                    this.noData = false;
                    this.showTable = true;
                
                } else {
                    this.showTable = false;
                    this.noData = true;
                    this.assetList = [];
                }
    
                let tempRecords = [];
                console.log('pageNumber: ' + this.pageNumber);
                console.log('pageSize: ' + pageSize);
                console.log('totalRecords: ' + totalRecords);
    
                for(let i=(1-1)*10; i < 1*10; i++){
                    if(i === this.assetList.length) break;
                    tempRecords.push(this.assetList[i]);
                }
                this.recordsToDisplay = tempRecords;
                // setRecordsToDisplayOnPaginator();
    
                this.error = null;
    
            })
            .catch(error => {
                this.error = error;
                console.log('Error: ' + error);
            })

        }
    }

    handleDateFieldSelection(event) {
        this.dateFieldSelectoin = event.target.value;
    }

    handlePaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = parseInt(this.recordsToDisplay[0].rowNumber-1);
    }

    get activeAssetList() {
        return this.assetList;
    }

    get recordsToDisplayInTable() {
        return this.recordsToDisplay;
    }

    setRecordsToDisplayOnPaginator() {
        const paginator = this.template.querySelector('c-paginator');
        paginator.setRecordsToDisplay();
    }

    handleDateInput(event) {
        this.selectedDate = event.target.value;
        console.log('this.selectedDate = ' + this.selectedDate);
        console.log('this.currentRecordId = ' + this.currentRecordId);   
        console.log('this.dateSelection = ' + this.dateSelection);   
        console.log('this.dateFieldSelectoin = ' + this.dateFieldSelectoin);   

        getSortedAssetListForBillToJS({ 
            "recordId": this.currentRecordId,
            "sorting": this.dateSelection,
            "sortField": this.dateFieldSelectoin,
            "selectedDate": this.selectedDate
        })
        .then(result => {
            console.log('getting results');
            let dataSet = [];
            dataSet = result;
            console.log(dataSet);

            if (dataSet.length > 0) {
                let x = [];
                result.forEach(element => {
                    let elt ={};
                    elt.Id = element.Id;
                    elt.AssetName = element.Name;
                    elt.ExternalCustID = element.Account?.ExternalCustomerId__c;
                    elt.Amount = element.Quantity;
                    elt.assetUrl = `/${element.Id}`;
                    if (element.AccountId) {
                        elt.ShipToName = element.Account.Name;
                        elt.shipToUrl = `/${element.AccountId}`;
                    } else {
                        elt.ShipToName = '';
                        elt.shipToUrl = '';
                    }
                    elt.BillToName = element.BillToAccount__r.Name;
                    elt.BillToUrl = `/${element.BillToAccount__c}`;
                    elt.StartDate = element.ActivationDate__c;
                    elt.RenewalDate = element.RenewalDate__c;
                    elt.CancelationDate = element.CancellationDate__c;
                  //  elt.EndDate = element.UsageEndDate;
                  elt.EndDate = element.EndDate__c;
                    if (element.Active__c) {
                        elt.activeSymbol = 'utility:check';
                    } else {
                        elt.activeSymbol = null;
                    }
                    if (element.Product2Id) {
                        switch (element.Product2.Type__c) {
                            case 'Inventory Item':
                                elt.itemTypeIcon = 'utility:knowledge_base';
                                break;
                            case 'Non-inventory Item':
                                elt.itemTypeIcon = 'utility:screen';
                                break;
                            case 'Item Group':
                                elt.itemTypeIcon = 'utility:overflow';
                                break;
                            case 'Kit/Package':
                                elt.itemTypeIcon = 'utility:ad_set';
                                break;
                            case 'Service':
                                elt.itemTypeIcon = 'utility:questions_and_answers';
                                break;
                            default:
                                elt.itemTypeIcon = '';
                        }
                    } else {
                        elt.itemTypeIcon = '';
                    }
                    x.push(elt);
                    });
                this.assetList = x;
                this.noData = false;
                this.showTable = true;
            
            } else {
                this.showTable = false;
                this.noData = true;
                this.assetList = [];
            }

            let tempRecords = [];
            console.log('pageNumber: ' + this.pageNumber);
            console.log('pageSize: ' + pageSize);
            console.log('totalRecords: ' + totalRecords);

            for(let i=(1-1)*10; i < 1*10; i++){
                if(i === this.assetList.length) break;
                tempRecords.push(this.assetList[i]);
            }
            this.recordsToDisplay = tempRecords;
            // setRecordsToDisplayOnPaginator();

            this.error = null;

        })
        .catch(error => {
            this.error = error;
            console.log('Error: ' + error);
        })
    }


    handleSortAccountData(event) {      
       
        
        
        try{
            
        // this.recordsToDisplay = event.detail;
        // this.rowNumberOffset = parseInt(this.recordsToDisplay[0].rowNumber-1);
            this.sortBy = event.detail.fieldName;       
            this.sortDirection = event.detail.sortDirection;
            
            console.log("**handleSortAccountData:event.detail.fieldName**"+event.detail.fieldName);
            this.sortAccountData(event.detail.fieldName, event.detail.sortDirection);

          //  this.recordsToDisplay = event.detail;
          //  this.rowNumberOffset = parseInt(this.recordsToDisplay[0].rowNumber-1);
        }
        catch(e){
            console.error("e.message => " + e.message ); 
        }
        
    }


    sortAccountData(fieldname, direction) {
        console.log("**sortAccountData:direction1**"+direction);
        let parseData = [];
        console.log("**sortAccountData: recordsToDisplay.length**"+this.recordsToDisplay.length);
        console.log("**sortAccountData: this.pageNumber**"+this.pageNumber);
        if(this.pageNumber == 1){
            parseData = JSON.parse(JSON.stringify(this.assetList));
        }
        else{
            parseData = JSON.parse(JSON.stringify(this.recordsToDisplay));
        }
        
        console.log("**sortAccountData:fieldname2**"+fieldname);


        let keyValue = (a) => {
            return a[fieldname];
        };  
        console.log("**sortAccountData:direction**"+direction);

       let isReverse = direction === 'asc' ? 1: -1;


           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        console.log("**sortAccountData:isReverse**"+isReverse);
        console.log("**sortAccountData:isReverse2**"+parseData);
        this.recordsToDisplay = parseData;

        if(this.pageNumber == 1){
            for(let i=(1-1)*10; i < 1*10; i++){
                if(i === parseData.length) break;
                tempRecords.push(this.parseData[i]);
            }
            this.recordsToDisplay = tempRecords;
        }

       /* */

    } 

}