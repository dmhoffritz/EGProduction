import { LightningElement, api, wire } from 'lwc';
import getTemplates from '@salesforce/apex/JobLoadReportController.fetchTemplates';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const actions = [
    { label: 'Clone', name: 'clone' }
];

export default class LoadTemplates extends LightningElement {
    @api recordId;

    columns = [
        {
            label: 'Load #',
            fieldName: 'Record_Link__c',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_blank'
            }
        },
        {
            label: 'Origin --> Destination',
            fieldName: 'FreightTM__Calendar_Load__c'
        },
        {
            label: 'Qty',
            fieldName: 'Qty__c'
        },
        {
            label: 'Commodity',
            fieldName: 'FreightTM__Commodity__c'
        },
        {
            label: 'Pickup By',
            fieldName: 'Pickup_By__c',
            type: 'date',
            typeAttributes: {
                year: "2-digit",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            },
            editable: true
        },
        {
            label: 'Deliver By',
            fieldName: 'Deliver_By__c',
            type: 'date',
            typeAttributes: {
                year: "2-digit",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            },
            editable: true
        },
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        }
    ];

    connectedCallback() {
        console.log("Hitting job load template connected callback...");
        //this.getLoads();
    }
    loadRes;
    loads;
    loading = true;
    @wire(getTemplates, { jobId: '$recordId' })
    wiredLoads(result) {
        this.loadRes = result;
        if (result.data) {
            console.log("Successfully fetched templates!");
            console.log(result.data);
            this.loads = result.data;
            this.error = undefined;
            this.loading = false;
        } else if (result.error) {
            console.log("Error fetching loading templates: " + result.error.body.message);
            this.error = result.error;
            this.loads = undefined;
            this.loading = false;
            this.showToast("Error fetching load data", result.error.body.message, "error");
        } else {
            console.log("Unknown error fetching load templates...");
            this.loading = false;
        }
    }


    showToast(toastTitle, msg, toastVariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            messag: msg,
            variant: toastVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    draftValues = [];
    async handleSaveEdition(event) {
        this.loading = true;
       // Convert datatable draft values into record objects
        const records = event.detail.draftValues.slice().map((draftValue) => {
            const fields = Object.assign({}, draftValue);
            return { fields };
        });

        // Clear all datatable draft values
        this.draftValues = [];

        try {
            // Update all records in parallel thanks to the UI API
            const recordUpdatePromises = records.map((record) =>
                updateRecord(record)
            );
            await Promise.all(recordUpdatePromises);

            // Report success with a toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message: 'Load(s) updated',
                    variant: 'success'
                })
            );

            // Display fresh data in the datatable
            await refreshApex(this.loadRes);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading load templates',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    handleRowAction(evt) {
        let actionName = evt.detail.action.name;
        let record = evt.detail.row;
        console.log("Handling action for row: ");
        console.log(record);
        switch (actionName) {
            case 'clone':
                this.cloneLoad(record.Id);
                break;
        }
    }

    screenFlow = false;
    flowApiName;
    inputVariables;
    cloneLoad(loadId) {
        if (loadId) {
            this.flowApiName = 'Create_Duplicate_Load_Records_v2';
            this.inputVariables = [
                {
                    name: 'recordId',
                    type: 'String',
                    value: loadId
                },
                {
                    name: 'navToLoad',
                    type: 'Boolean',
                    value: false
                }
            ];
            this.screenFlow = true;
        } else {
            //error retrieving load id
        }
    }

    handleModalClose() {
        this.screenFlow = false;
    }

    handleFlowStatusChange(event) {
        console.log("Handling flow status change...");
        console.log("Flow status: " + event.detail.status);
        if (event.detail.status === 'FINISHED' || event.detail.status === 'FINISHED_SCREEN') {
            // set behavior after a finished flow interview
            this.screenFlow = false;
            this.loading = false;
            this.showToast("Successfully cloned loads!", "", "success");
        }
    }

}