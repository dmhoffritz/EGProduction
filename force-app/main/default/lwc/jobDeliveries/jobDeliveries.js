import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getLoads from '@salesforce/apex/JobLoadReportController.fetchLoads';


export default class JobDeliveries extends LightningElement {
    @api recordId;
    @api showPickups;
    @api showDeliveries;
    @track itemFilter;
    isLoaded = false;
    connectedCallback() {
        console.log("Hitting job load report connected callback...");
        this.itemFilter = this.loadFilter;
        this.itemFilters = {
            ...this.itemFilters,
            jobId: this.recordId,
            showPickups: this.showPickups,
            showDeliveries: this.showDeliveries,
            status: this.status,
            startDate: this.startDate,
            endDate: this.endDate
        };

    }

    renderedCallback() {
        console.log("Firing rendered callback!");
    }
    @track numItems = 0;
    get listLabel() {
        return this.showDeliveries ? 'Deliveries (' + this.numItems + ')' : 'Pickups (' + this.numItems + ')';
    }

    get headerIcon() {
        return "custom:custom98";
    }
    
    items;
    statusOptions;
    statusSelection;
    startDate = null;
    endDate = null;

    itemFilters = {
        jobId: this.recordId,
        showPickups: this.showPickups,
        showDeliveries: this.showDeliveries,
        status: this.status,
        commodity: this.commodity,
        startDate: this.startDate,
        endDate: this.endDate
    };

    refreshData() {
        refreshApex(this.itemData);
    }

    updateStatus(evt) {
        this.isLoaded = false;
        console.log("Filtering status: " + evt.detail.value);
        this.statusSelection = evt.detail.value;
        this.itemFilters = {
            ...this.itemFilters,
            jobId: this.recordId,
            showPickups: this.showPickups,
            showDeliveries: this.showDeliveries,
            status: (this.status = evt.detail.value),
            commodity: this.commodity,
            startDate: this.startDate,
            endDate: this.endDate
        }
    }

    updateStartDate(evt) {
        this.isLoaded = false;
        console.log("Filtering start date: " + evt.detail.value);
        this.itemFilters = {
            ...this.itemFilters,
            jobId: this.recordId,
            showPickups: this.showPickups,
            showDeliveries: this.showDeliveries,
            status: this.status,
            commodity: this.commodity,
            startDate: (this.startDate = evt.detail.value),
            endDate: this.endDate
        }
    }

    updateEndDate(evt) {
        this.isLoaded = false;
        console.log("Filtering end date: " + evt.detail.value);
        this.itemFilters = {
            ...this.itemFilters,
            jobId: this.recordId,
            showPickups: this.showPickups,
            showDeliveries: this.showDeliveries,
            status: this.status,
            commodity: this.commodity,
            startDate: this.startDate,
            endDate: (this.endDate = evt.detail.value)
        }
    }

    get columns() {
        var cols = [
            {
                label: 'Load #',
                fieldName: 'loadLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'loadNumber'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Status',
                fieldName: 'status'
            },

            {
                label: 'Origin --> Destination',
                fieldName: 'freightLane'
            },
            {
                label: 'Qty',
                fieldName: 'quantity'
            },
            {
                label: 'Commodity',
                fieldName: 'commodity'
            },
            {
                label: 'Carrier',
                fieldName: 'carrier'
            },
            {
                label: 'Rate to Carrier',
                fieldName: 'rateToCarrier',
                type: 'currency'
            },
            {
                label: 'Mi.',
                fieldName: 'distance'
            },
            {
                label: 'Receiver Date',
                fieldName: 'receiverDate',
                type: 'date-local',
                typeAttributes: {
                    month: "2-digit",
                    day: "2-digit"
                }
            },
            {
                label: 'Invoice #',
                fieldName: 'invoiceNumber'
            }
        ];
        cols.forEach(col => {
            col.hideDefaultActions = true;
            col.sortable = true;
        });

        return cols;
    }

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.items];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.items = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }


    @track itemData = [];
    @wire(getLoads, { filters: '$itemFilters' })
    wiredItems(result) {
        this.isLoaded = false;
        this.itemData = result;
        console.log("REPORT WIRE RESULT:");
        console.log(result);
        if (result.data != undefined) {
            console.log("Successfully fetched item data: ");
            this.items = result.data.itemsForTable;
            this.statusOptions = [
                {
                    label: '--ALL--',
                    value: 'ALL'
                },
                {
                    label: 'Ordered',
                    value: 'Ordered'
                },
                {
                    label: 'Assigned',
                    value: 'Assigned'
                },
                {
                    label: 'Dispatched',
                    value: 'Dispatched'
                },
                {
                    label: 'In Route',
                    value: 'In Route'
                },
                {
                    label: 'Delivered',
                    value: 'Delivered'
                }
            ];

            console.log("ALL DATA:");
            console.log(this.itemData);

            console.log("items: ");
            console.log(this.items);
            this.summarizeItems(this.items);

            console.log("STATUS OPTIONS:");
            console.log(this.statusOptions);

            this.numItems = this.items.length;
            var timeoutTime = 0;
            if (this.items.length > 50) {
                timeoutTime = 3000;
            } else {
                timeoutTime = 1500;
            }
            setTimeout(() => {
                this.isLoaded = true;
            }, timeoutTime);
        } else if (result.error) {
            console.log("Error whenever fetching load data...");
            console.log(result.error);
            this.error = result.error;
            this.items = undefined;
        } else {
            console.log("Unknown error occurred whenever fetching load data");
        }

    }

    totalMatQty = 0;
    totalCarrierRate = 0.0;
    totalDistance = 0.0;
    ratePerMile = 0.0;
    summarizeItems(itemsToSummarize) {
        if (itemsToSummarize == undefined || itemsToSummarize.length == 0) {
            return;
        }
        //variables to calculate summary
        var matQty = 0;
        var carrierRate = 0.0;
        var distance = 0.0;
        //variables used to calculate rate/mi.
        var ratePerMile = 0.0;
        var rateForAverage = 0.0; 
        var distanceForAverage = 0.0;
        itemsToSummarize.forEach(item => {
            if (item.rateToCarrier != undefined && item.rateToCarrier != null) {
                carrierRate += item.rateToCarrier;
            }
            if (item.distance != undefined && item.distance != null) {
                distance += item.distance;
            }
            if (item.commodity.includes('#') == false && item.quantity != null) {
                matQty += item.quantity;
            }
            if (item.rateToCarrier != 0 && item.distance != 0) {
                rateForAverage += item.rateToCarrier;
                distanceForAverage += item.distance;
            }
            if (distanceForAverage != 0) {
                ratePerMile = rateForAverage / distanceForAverage;
            }

        });
        matQty = matQty.toLocaleString('en', { useGrouping: true });
        carrierRate = carrierRate.toLocaleString('en-US', {style:'currency', currency:'USD', useGrouping: true});
        distance = distance.toLocaleString('en', { useGrouping: true });
        ratePerMile = ratePerMile.toLocaleString('en-US', {style:'currency', currency:'USD', useGrouping: true});

        this.totalMatQty = matQty;
        this.totalCarrierRate = carrierRate;
        this.totalDistance = distance;
        this.ratePerMile = ratePerMile;

    }

    selectedItems;
    storeSelectedItems(event) {
        this.selectedItems = event.detail.selectedRows;
        console.log("Selected items: ");
        console.log(this.selectedItems);
        if (this.selectedItems.length == 0) {
            this.summarizeItems(this.items);
        } else {
            this.summarizeItems(this.selectedItems);
        }
    }
    autoLaunchFlow = false;
    screenFlow = false;

    flowApiName;
    inputVariables;
    setFlowInputs() {
        //need to fix so that only load ids are extracted rather than item ids
        var ids = [];
        if (this.selectedItems) {
            for (let i = 0; i < this.selectedItems.length; i++) {
                let idToPush = this.selectedItems[i].itemId;
                ids.push(idToPush);
            }
            this.inputVariables = [
                {
                    name: 'itemIds',
                    type: 'String',
                    value: ids
                }
            ];
            return true;
        } else {
            //prompt user to select rows
            return false;
        }
    }

    extractLoadIds(itemList) {
        console.log("Extracting load ids from item list:");
        console.log(itemList);
        var extractedLoadIds = [...new Set(itemList.map((item) => item.loadId))];

        return extractedLoadIds.toString();
    }
    bulkUpdate() {
        let loadIds = this.extractLoadIds(this.selectedItems);
        console.log("LOAD IDS: " + loadIds);
        let vfPage = 'https://yourempiregroup--soprep--c.sandbox.vf.force.com/apex/LoadMultiSelectStatusChange?recordIds=' + loadIds;
        window.open(vfPage, '_blank');

    }

    batchBOL() {
        let loadIds = this.extractLoadIds(this.selectedItems);
        console.log("LOAD IDS: " + loadIds);
        let vfPage = 'https://yourempiregroup--c.vf.force.com/apex/BatchBOLs?recordIds=' + loadIds;
        window.open(vfPage, '_blank');
    }

    handleFlowStatusChange(event) {
        console.log("Handling flow status change...");
        console.log("Flow status: " + event.detail.status);
        if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
            // set behavior after a finished flow interview
            this.screenFlow = false;
            this.autoLaunchFlow = false;
            this.isLoaded = false;
            refreshApex(this.itemData);
            const cmpEvent = new CustomEvent('update', {});
            this.dispatchEvent(cmpEvent);
        }
    }

    handleModalClose(evt) {
        this.screenFlow = false;
    }

    columnHeaders() {
        var cols = JSON.parse(JSON.stringify(this.columns));
        var headers = [];
        headers = cols.map((col) => col.label);
        return headers;
    }

    excelData() {
        var data = [];
        var cols = JSON.parse(JSON.stringify(this.columns));
        data = cols.map(function (col) {
            if (col.type == 'url') {
                return col.typeAttributes.label.fieldName;
            } else {
                return col.fieldName;
            }          
        });
        return data;
    }

    downloadLoadData(evt) {
        //prep html table
        //add styles for the table
        let doc = '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '}';
        doc += '</style>';
        doc += '<table>';

        //add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '}';
        doc += '</style>';
        //add all the table headers
        doc += '<tr>';
        var headers = this.columnHeaders();
        headers.forEach(element => {
            doc += '<th>' + element + '</th>'
        });
        doc += '</tr>';
        //add the data rows Id', 'Name', 'Customer', 'Job', 'PO #', 'Sell Type', 'Pickup Location', 'Delivery Location', 'Qty', 'Commodity', 'Grade', 'Receiver Date
        this.items.forEach(record => {
            doc += '<tr>';
            var rowData = this.excelData();
            rowData.forEach(data => {
                if (record[data] != undefined) {
                    doc += '<td>' + record[data] + '</td>';
                } else {
                    doc += '<td></td>';
                }
            });
            doc += '</tr>';
        });
        doc += '</table>';
        console.log("PREPARED EXCEL DOCUMENT:");
        console.log(doc);
        let element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        //use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Load Data.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

}