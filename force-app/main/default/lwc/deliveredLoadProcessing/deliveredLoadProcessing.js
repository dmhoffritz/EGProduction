import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import getLoadCounts from '@salesforce/apex/LoadProcessingController.analyzeLoads'; 

export default class DeliveredLoadProcessing extends LightningElement {
    connectedCallback() {
    }

    inventoryReviewCount;
    pmReviewCount;
    qbMovementCount;
    invoicingCount;
    rejectedCount;

    isLoaded = false;
    @track loadAnalysis;
    @wire(getLoadCounts)
    wiredLoadCounts(result) {
        this.loadAnalysis = result;
        console.log('TILE WIRE RESULT:');
        console.log(this.loadAnalysis);
        if (result.data != undefined) {
            console.log("Successfully fetched load counts: ");
            this.inventoryReviewCount = result.data.inventoryCount;
            this.pmReviewCount = result.data.pmCount;
            this.qbMovementCount = result.data.qbCount;
            this.invoicingCount = result.data.invoicingCount;
            this.rejectedCount = result.data.rejectedCount;
        } else if (result.error) {
            console.log("Error fetching load counts...");
            console.log(result.error);
            this.error = result.error;
        } else {
            console.log("Unknown error fetching load counts");
        }

        this.isLoaded = true;
    }

    get displayRejections() {
        return this.rejectedCount > 0 ? true : false;
    }
    loading = false;
    showReport = false;
    reportTitle = '';
    reportFilter = '';
    toggleReport() {
        setTimeout(() => {
            this.showReport = true;
            this.loading = false;
        }, 250);
    }
    showInventoryReview(event) {
        this.showReport = false;
        this.loading = true;
        console.log("Naving to Inventory Review...");
        this.reportTitle = 'Inventory Review';
        this.reportFilter = 'Load__r.FreightTM__Status__c = \'Delivered\' AND Rejected__c = false AND Inventory_Reviewed__c = false';
        this.toggleReport();
    }

    showPMReview(event) {
        this.showReport = false;
        this.loading = true;
        console.log("Naving to PM Review...");
        this.reportTitle = 'PM Review';
        this.reportFilter = 'Rejected__c = false AND Inventory_Reviewed__c = true AND PM_Approved__c = false';
        this.toggleReport();
    }

    showQBMovements(event) {
        this.showReport = false;
        this.loading = true;
        console.log("Naving to QB Movements...");
        this.reportTitle = "QB Movements";
        this.reportFilter = 'Rejected__c = false AND PM_Approved__c = true AND Moved_in_QB__c = false';
        this.toggleReport();
    }

    showInvoicing(event) {
        this.showReport = false;
        this.loading = true;
        console.log("Naving to Invoicing...");
        this.reportTitle = "Invoicing";
        this.reportFilter = 'Rejected__c = false AND (Moved_in_QB__c = true AND (Mat_Invoice__c = null OR Mat_Invoice__c = \'\'))';
        this.toggleReport();
    }
    
    showRejected(event) {
        this.showReport = false;
        this.loading = true;
        console.log("Naving to Rejections...");
        this.reportTitle = "Rejected";
        this.reportFilter = 'Rejected__c = true';
        this.toggleReport();
    }

    refreshData(event) {
        console.log("Refreshing tile data...");
        refreshApex(this.loadAnalysis);
    }
}