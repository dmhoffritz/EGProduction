import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import loadReportStyles from '@salesforce/resourceUrl/loadReportStyles';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import getitems from '@salesforce/apex/LoadReportController.fetchLoads';

const WIDTH_RATIO = 12; //ratio of how much width should be applied to each column header per character in the column's label

export default class CustomLoadReport extends LightningElement {
    @api title;
    @api loadFilter;
    @track itemFilter;

    isLoaded = false;
    connectedCallback() {
        console.log("Hitting load report connected callback...");
        this.itemFilter = this.loadFilter;
        this.itemFilters = {
            ...this.itemFilters,
            declaredFilter: this.itemFilter,
            receiverDate: null,
            recordType: 'All',
            projectManager: 'All',
            pickupJob: 'All',
            deliveryJob: 'All',
            order: 'All',
            deliveryLocation: 'All',
            commodity: 'All',
            sellType: 'All',
            grade: 'All'
        };

    }

    renderedCallback() {
        console.log("Firing rendered callback for load processing report...");
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, loadReportStyles).then(()=>{
            console.log("Styles Loaded Successfully");
        }).catch(error=>{ 
            console.error("Error in loading the colors: " + error.message);
        })
    }

    @track numItems = 0;
    get listLabel() {
        return this.title + ' (' + this.numItems + ')';
    }

    get headerIcon() {
        var icon = "";
        if (this.title == "Inventory Review") {
            icon = "standard:observation_component";
        } else if (this.title == "PM Review") {
            icon = "standard:work_plan_template_entry";
        } else if (this.title == "QB Movements") {
            icon = "standard:data_transforms";
        } else if (this.title == "Invoicing") {
            icon = "standard:contract_payment";
        } else if (this.title == "Rejected") {
            icon = "standard:incident";
        } else {
            icon = "custom:custom98";
        }

        return icon;
    }

    get showRejectButton() {
        if (this.title == "Inventory Review" || this.title == "PM Review" || this.title == "Invoicing") {
            return true;
        } else {
            return false;
        }
    }

    get actionLabel() {
        var label = "";
        if (this.title == "Invoicing") {
            label = "Log Invoice #";
        } else if (this.title == "QB Movements") {
            label = "Finalize";
        } else {
            label = "Approve";
        }
        return label;
    }

    get buttonIcon() {
        return this.title == "Invoicing" ? "utility:adjust_value" : "utility:check"; 
    }
    
    items;
    recordTypeOptions;
    pmOptions;
    pickupOptions;
    deliveryOptions;
    orderOptions;
    locationOptions;
    commodityOptions;
    sellTypeOptions;
    gradeOptions;

    itemFilters = {
        declaredFilter: this.loadFilter,
        receiverDate: null,
        recordType: 'All',
        projectManager: 'All',
        pickupJob: 'All',
        deliveryJob: 'All',
        order: 'All',
        deliveryLocation: 'All',
        commodity: 'All',
        sellType: 'All',
        grade: 'All'
    };

    refreshData() {
        this.itemFilters = {
            ...this.itemFilters,
            declaredFilter: this.loadFilter,
            receiverDate: null,
            recordType: 'All',
            projectManager: 'All',
            pickupJob: 'All',
            deliveryJob: 'All',
            order: 'All',
            deliveryLocation: 'All',
            commodity: 'All',
            sellType: 'All',
            grade: 'All'
        };
        refreshApex(this.itemData);
        const cmpEvent = new CustomEvent('update', {});
        this.dispatchEvent(cmpEvent);
    }

    updateFilters(evt) {
        this.isLoaded = false;
        const filters = this.itemFilters;
        filters[evt.target.name] = evt.detail.value;
        this.itemFilters = {...filters};
    }

    get columns() {
        var cols = [];
        if (this.title == "Rejected") {
            cols = [
                {   
                    label: 'Rejection Comments',
                    fieldName: 'Rejection_Comments__c',
                    type: 'text',
                    sortable: true
                
                },
                {
                    label: 'Shipper Date',
                    fieldName: 'shipperDate',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Receiver Date',
                    fieldName: 'receiverDate',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Load #',
                    fieldName: 'loadLink',
                    type: 'url',
                    typeAttributes: {
                        label: {
                            fieldName: 'loadNumber'
                        },
                        target: '_blank'
                    },
                    sortable: true
                },
                {
                    label: 'Pickup PM',
                    fieldName: 'pickupPm',
                    sortable: true
                },
                {
                    label: 'Pickup Ref #',
                    fieldName: 'pickupRef',
                    sortable: true
                },
                {
                    label: 'Pickup SO',
                    fieldName: 'pickupOrder',
                    sortable: true
                },
                {
                    label: 'Delivery PM',
                    fieldName: 'deliveryPm',
                    sortable: true
                },
                {
                    label: 'Delivery Ref #',
                    fieldName: 'deliveryRef',
                    sortable: true
                },
                {
                    label: 'Delivery SO',
                    fieldName: 'deliveryOrder',
                    sortable: true
                },
                {
                    label: 'Qty',
                    fieldName: 'quantity',
                    type: 'number',
                    sortable: true
                },
                {
                    label: 'Commodity',
                    fieldName: 'commodity',
                    sortable: true
                },
                {
                    label: 'New',
                    fieldName: 'newGrade',
                    sortable: true
                },
                {
                    label: 'A4',
                    fieldName: 'aFour',
                    sortable: true
                },
                {
                    label: 'A3',
                    fieldName: 'aThree',
                    sortable: true
                },
                {
                    label: 'B2',
                    fieldName: 'bTwo',
                    sortable: true
                },
                {
                    label: 'B1',
                    fieldName: 'bOne',
                    sortable: true
                },
                {
                    label: 'Cull',
                    fieldName: 'cull',
                    sortable: true
                },
                {
                    label: 'Unit Price',
                    fieldName: 'unitPrice',
                    type: 'currency',
                    sortable: true
                },
                {
                    label: 'Subtotal',
                    fieldName: 'subtotal',
                    type: 'currency',
                    sortable: true
                },
                {
                    label: 'Rejected By',
                    fieldName: 'rejectedBy',
                    sortable: true
                },
                {
                    label: 'Rejected On',
                    fieldName: 'rejectedOn',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Rejection Comments',
                    fieldName: 'rejectionComments',
                    wrapText: true
                }
            ];
        } else if (this.title == "Inventory Review" || this.title == "QB Movements") {
            cols = [
                {
                    label: 'Shipper Date',
                    fieldName: 'shipperDate',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Receiver Date',
                    fieldName: 'receiverDate',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Load #',
                    fieldName: 'loadLink',
                    type: 'url',
                    typeAttributes: {
                        label: {
                            fieldName: 'loadNumber'
                        },
                        target: '_blank'
                    },
                    sortable: true
                },
                {
                    label: 'Origin --> Destination',
                    fieldName: 'lane',
                    type: 'text',
                    sortable: true
                },
                {
                    label: 'Pickup Customer',
                    fieldName: 'pickupCustomer',
                    sortable: true
                },
                {
                    label: 'Pickup Ref #',
                    fieldName: 'pickupRef',
                    sortable: true
                },
                {
                    label: 'Pickup Sell Type',
                    fieldName: 'pickupSellType',
                    sortable: true
                },
                {
                    label: 'Delivery Customer',
                    fieldName: 'deliveryCustomer',
                    sortable: true
                },
                {
                    label: 'Delivery PM',
                    fieldName: 'deliveryPm',
                    sortable: true
                },
                {
                    label: 'Delivery Ref #',
                    fieldName: 'deliveryRef',
                    sortable: true
                },
                {
                    label: 'Delivery Sell Type',
                    fieldName: 'sellType',
                    sortable: true
                },
                {
                    label: 'Job Class',
                    fieldName: 'jobClass',
                    sortable: true
                },
                {
                    label: 'Qty',
                    fieldName: 'quantity',
                    type: 'number',
                    sortable: true
                },
                {
                    label: 'Commodity',
                    fieldName: 'commodity',
                    sortable: true
                },
                {
                    label: 'Grade (to Bill)',
                    fieldName: 'grade',
                    sortable: true
                },
                {
                    label: 'New',
                    fieldName: 'newGrade',
                    sortable: true
                },
                {
                    label: 'A4',
                    fieldName: 'aFour',
                    sortable: true
                },
                {
                    label: 'A3',
                    fieldName: 'aThree',
                    sortable: true
                },
                {
                    label: 'B2',
                    fieldName: 'bTwo',
                    sortable: true
                },
                {
                    label: 'B1',
                    fieldName: 'bOne',
                    sortable: true
                },
                {
                    label: 'Cull',
                    fieldName: 'cull',
                    sortable: true
                }
            ];
        } else if (this.title == "PM Review") {
            cols = [
                {
                    label: 'Shipper Date',
                    fieldName: 'shipperDate',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Receiver Date',
                    fieldName: 'receiverDate',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Load #',
                    fieldName: 'loadLink',
                    type: 'url',
                    typeAttributes: {
                        label: {
                            fieldName: 'loadNumber'
                        },
                        target: '_blank'
                    },
                    sortable: true
                },
                {
                    label: 'Origin --> Destination',
                    fieldName: 'lane',
                    type: 'text',
                    sortable: true
                },
                {
                    label: 'Pickup PM',
                    fieldName: 'pickupPm',
                    sortable: true
                },
                {
                    label: 'Pickup Ref #',
                    fieldName: 'pickupRef',
                    sortable: true
                },
                {
                    label: 'Pickup SO',
                    fieldName: 'pickupOrder',
                    sortable: true
                },
                {
                    label: 'Delivery PM',
                    fieldName: 'deliveryPm',
                    sortable: true
                },
                {
                    label: 'Delivery Ref #',
                    fieldName: 'deliveryRef',
                    sortable: true
                },
                {
                    label: 'Delivery SO',
                    fieldName: 'deliveryOrder',
                    sortable: true
                },
                {
                    label: 'Qty',
                    fieldName: 'quantity',
                    type: 'number',
                    sortable: true
                },
                {
                    label: 'Commodity',
                    fieldName: 'commodity',
                    sortable: true
                },
                {
                    label: 'Grade (to Bill)',
                    fieldName: 'grade',
                    sortable: true
                },
                {
                    label: 'New',
                    fieldName: 'newGrade',
                    sortable: true
                },
                {
                    label: 'A4',
                    fieldName: 'aFour',
                    sortable: true
                },
                {
                    label: 'A3',
                    fieldName: 'aThree',
                    sortable: true
                },
                {
                    label: 'B2',
                    fieldName: 'bTwo',
                    sortable: true
                },
                {
                    label: 'B1',
                    fieldName: 'bOne',
                    sortable: true
                },
                {
                    label: 'Cull',
                    fieldName: 'cull',
                    sortable: true
                },
                {
                    label: 'Pickup Sell Type',
                    fieldName: 'pickupSellType',
                    sortable: true
                },
                {
                    label: 'Delivery Sell Type',
                    fieldName: 'sellType',
                    sortable: true
                },
                {
                    label: 'Rate to Carrier',
                    fieldName: 'rateToCarrier',
                    type: 'currency',
                    sortable: true
                },
                {
                    label: 'Unit Price',
                    fieldName: 'unitPrice',
                    type: 'currency',
                    sortable: true
                },
                {
                    label: 'Subtotal',
                    fieldName: 'subtotal',
                    type: 'currency',
                    sortable: true
                }
            ];
        } else {
            cols = [
                {
                    label: 'Shipper Date',
                    fieldName: 'shipperDate',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Receiver Date',
                    fieldName: 'receiverDate',
                    type: 'date-local',
                    typeAttributes: {
                        month: "2-digit",
                        day: "2-digit"
                    },
                    sortable: true
                },
                {
                    label: 'Load #',
                    fieldName: 'loadLink',
                    type: 'url',
                    typeAttributes: {
                        label: {
                            fieldName: 'loadNumber'
                        },
                        target: '_blank'
                    },
                    sortable: true
                },
                {
                    label: 'Load Type',
                    fieldName: 'recordType',
                    type: 'text',
                    sortable: true
                },
                {
                    label: 'Pickup Ref #',
                    fieldName: 'pickupRef',
                    sortable: true
                },
                {
                    label: 'Pickup SO',
                    fieldName: 'pickupOrder',
                    sortable: true
                },
                {
                    label: 'Pickup Sell Type',
                    fieldName: 'pickupSellType',
                    sortable: true
                },
								{
                    label: 'Delivery Address ',
                    fieldName: 'deliveryAddress',
                    type: 'text',
                    sortable: true
                },
								{
                    label: 'Delivery Ref #',
                    fieldName: 'deliveryRef',
                    sortable: true
                },
                {
                    label: 'Delivery SO',
                    fieldName: 'deliveryOrder',
                    sortable: true
                },
                {
                    label: 'Delivery Sell Type',
                    fieldName: 'sellType',
                    sortable: true
                },
								{
                    label: 'Carrier',
                    fieldName: 'carrier',
                    sortable: true
                },
                {
                    label: 'Rate to Carrier',
                    fieldName: 'rateToCarrier',
                    type: 'currency',
                    sortable: true
                },
                {
                    label: 'Qty',
                    fieldName: 'quantity',
                    type: 'number',
                    sortable: true
                },
                {
                    label: 'Commodity',
                    fieldName: 'commodity',
                    sortable: true
                },
                {
                    label: 'Grade (to Bill)',
                    fieldName: 'grade',
                    sortable: true
                },
                {
                    label: 'New',
                    fieldName: 'newGrade',
                    sortable: true
                },
                {
                    label: 'A4',
                    fieldName: 'aFour',
                    sortable: true
                },
                {
                    label: 'A3',
                    fieldName: 'aThree',
                    sortable: true
                },
                {
                    label: 'B2',
                    fieldName: 'bTwo',
                    sortable: true
                },
                {
                    label: 'B1',
                    fieldName: 'bOne',
                    sortable: true
                },
                {
                    label: 'Cull',
                    fieldName: 'cull',
                    sortable: true
                }
            ]; 
        }
        var colsToReturn = cols.map(function (col) {

            var labelCharacters = col.label.length;
            var widthToInitialize = labelCharacters * WIDTH_RATIO;
            if (widthToInitialize < 85) {
                col.initialWidth = 85;
            } else {
                col.initialWidth = widthToInitialize;
            }

            col.cellAttributes = {
                class: { fieldName: 'loadCSS' }
            }

            return col;
        });
        console.log("Applying following columns to datatable: ");
        console.log(colsToReturn);
        return colsToReturn;
    }

    getDateDifferenceInDays(date1, date2) {
        // Parse the datetime strings into Date objects
        const parsedDateTime1 = new Date(date1);
        const parsedDateTime2 = new Date(date2);

        // Calculate the difference in milliseconds
        const differenceInMilliseconds = Math.abs(parsedDateTime2 - parsedDateTime1);

        // Convert the difference to days
        const millisecondsInADay = 24 * 60 * 60 * 1000; // 24 hours * 60 minutes * 60 seconds * 1000 milliseconds
        const differenceInDays = Math.floor(differenceInMilliseconds / millisecondsInADay);

        return differenceInDays;
    }

    get itemsForTable() {
        var data = JSON.parse(JSON.stringify([...this.items]));
        try {
            data.forEach((item) => {
                var diffDays = this.getDateDifferenceInDays(new Date(), item.receiverDate);
                console.log("DIFFERENCE IN DAYS: " + diffDays);
                if (diffDays >= 14) {
                    item.loadCSS = 'red-background';
                }
                
            });

        } catch (error) {
            console.log("Error whenever assigning load CSS property to data: ");
            console.log(error.message);
        }
        return data;

    }

    loadCount;
    commodityCount;
    totalCarrierRate;
    totalPrice;

    @track itemData = [];
    @wire(getitems, { filters: '$itemFilters' })
    wiredItems(result) {
        this.isLoaded = false;
        this.itemData = result;
        console.log("REPORT WIRE RESULT:");
        console.log(result);
        if (result.data != undefined) {
            console.log("Successfully fetched item data: ");
            this.items = result.data.itemsForTable;
            this.recordTypeOptions = [
                {
                    label: '--ALL--',
                    value: 'ALL'
                },
                {
                    label: 'Standard',
                    value: 'Standard'
                },
                {
                    label: 'Equipment',
                    value: 'Equipment'
                }, 
                {
                    label: 'CPU',
                    value: 'Customer Pickup'
                },
                {
                    label: 'Day Rate',
                    value: 'Day Rate Load'
                }
            ];
            this.pmOptions = result.data.pmOptions;
            this.pickupOptions = result.data.pickupOptions;
            this.deliveryOptions = result.data.deliveryOptions;
            this.orderOptions = result.data.orderOptions;
            this.locationOptions = result.data.locationOptions;
            this.commodityOptions = result.data.commodityOptions;
            this.sellTypeOptions = [
                {
                    label: '--ALL--',
                    value: 'All'
                },
                {
                    label: 'Purchase',
                    value: 'Purchase'
                },
                {
                    label: 'Lease',
                    value: 'Lease'
                },
                {
                    label: 'Rental',
                    value: 'Rental'
                }
            ];
            this.gradeOptions = [
                {
                    label: '--ALL--',
                    value: 'All'
                },
                {
                    label: 'New',
                    value: 'New'
                },
                {
                    label: 'A',
                    value: 'A'
                },
                {
                    label: 'B',
                    value: 'B'
                },
                {
                    label: 'Cull',
                    value: 'Cull'
                }
            ];

            this.loadCount = result.data.summary.loadCount;
            var commCt = result.data.summary.commodityCount;
            this.commodityCount = commCt.toLocaleString('en', {useGrouping:true});
            var rate = result.data.summary.totalRate;
            this.totalCarrierRate = rate.toLocaleString('en', { useGrouping: true });
            var price = result.data.summary.totalPrice;
            this.totalPrice = price.toLocaleString('en', { useGrouping: true });

            console.log("ALL DATA:");
            console.log(result.data);

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


    selectedItems;
    storeSelectedItems(event) {
        this.selectedItems = event.detail.selectedRows;
        console.log("Selected items: ");
        console.log(this.selectedItems);

        if (this.selectedItems.length === 0) {
            this.loadCount = this.itemData.data.summary.loadCount;
            this.commodityCount = this.itemData.data.summary.commodityCount.toLocaleString('en', { useGrouping: true });
            this.totalCarrierRate = this.itemData.data.summary.totalRate.toLocaleString('en', { useGrouping: true });
            this.totalPrice = this.itemData.data.summary.totalPrice.toLocaleString('en', { useGrouping: true });
            return;
        }

        const addressedLoadsSet = new Set();
        let loadCount = 0;
        let totalRate = 0.0;
        let commodityCount = 0;
        let totalPrice = 0.0;

        for (const selectedItem of this.selectedItems) {
            if (!addressedLoadsSet.has(selectedItem.loadNumber)) {
                addressedLoadsSet.add(selectedItem.loadNumber);
                loadCount++;
                totalRate += selectedItem.rateToCarrier;
            }
            commodityCount += selectedItem.quantity;
            totalPrice += selectedItem.subtotal;
        }

        this.loadCount = loadCount;
        this.commodityCount = commodityCount.toLocaleString('en', { useGrouping: true });
        this.totalCarrierRate = totalRate.toLocaleString('en', { useGrouping: true });
        this.totalPrice = totalPrice.toLocaleString('en', { useGrouping: true });
    }

    extractLoadIds(itemList) {
        var extractedLoadIds = [...new Set(itemList.map((item) => item.loadId))];
        return extractedLoadIds.toString();
    }

    batchBOL() {
        let loadIds = this.extractLoadIds(this.selectedItems);
        console.log("LOAD IDS: " + loadIds);
        let vfPage = 'https://yourempiregroup--c.vf.force.com/apex/BatchBOLs?recordIds=' + loadIds;
        window.open(vfPage, '_blank');
    }

    autoLaunchFlow = false;
    screenFlow = false;

    flowApiName;
    inputVariables;
    modalHeader;
    reject(event) {
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
            this.modalHeader = "Reject Item(s)";
            this.flowApiName = "Item_Reject";
            this.screenFlow = true;
        } else {
            //prompt user to select items
        }
    }
    approve(event) {
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
            if (this.title == "Inventory Review") {
                this.flowApiName = "Item_Approve_Inventory";
            } else if (this.title == "PM Review") {
                this.flowApiName = "Item_Log_PM_Review";
            } else if (this.title == "QB Movements") {
                this.flowApiName = "Item_Verify_QB_Movement";
            } else if (this.title == "Invoicing") {
                this.flowApiName = "Item_Log_Mat_Invoice";
            } else if (this.title == "Rejected") {
                this.flowApiName = "Item_Approve_Rejections"; 
            } else {
                //unable to properly designate flow api name...cancel action
                return;
            }
            console.log("Firing the following flow: " + this.flowApiName);
            if (this.title != "Invoicing") {
                this.autoLaunchFlow = true;
            } else {
                this.modalHeader = "Update Invoice #";
                this.screenFlow = true;
            }
        } else {
            //prompt user to select items
        }
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
    downloadItemData() {
        
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