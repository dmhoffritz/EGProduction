import { LightningElement, wire, api, track } from 'lwc';
import fetchServiceOptions from '@salesforce/apex/RFP_Cont.fetchServiceOptions';



export default class ServiceSelection extends LightningElement {
    @track
    clearingOptions = [];
    clearingValues = [];
    @track
    accessOptions = [];
    accessValues = [];
    @track
    environmentalOptions = [];
    environmentalValues = [];
    @track
    matOptions = [];
    matValues = [];

    error;

    @wire(fetchServiceOptions)
    serviceOptions({ error, data }) {
        if (data) {
            console.log("successfully fetched service data...");
            console.log(data);
            for (let i = 0; i < data.clearingServices.length; i++) {
                let option = {
                    label: data.clearingServices[i].Name,
                    value: data.clearingServices[i].Id
                }
                this.clearingOptions.push(option);
            }
            for (let i = 0; i < data.accessServices.length; i++) {
                let option = {
                    label: data.accessServices[i].Name,
                    value: data.accessServices[i].Id
                }
                this.accessOptions.push(option);
            }
            for (let i = 0; i < data.environmentalServices.length; i++) {
                let option = {
                    label: data.environmentalServices[i].Name,
                    value: data.environmentalServices[i].Id
                }
                this.environmentalOptions.push(option);
            }
            for (let i = 0; i < data.matServices.length; i++) {
                let option = {
                    label: data.matServices[i].Name,
                    value: data.matServices[i].Id
                }
                this.matOptions.push(option);
            }
            console.log("SERVICE OPTIONS: ");
            console.log("CLEARING: ");
            console.log(this.clearingOptions);
            console.log("ENVIRONMENTAL:");
            console.log(this.environmentalOptions);
            console.log("ACCESS:");
            console.log(this.accessOptions);
            console.log("MAT:");
            console.log(this.matOptions);
        } else if (error) {
            this.error = error;
            console.log('Error fetching service options...' + error);
        }
    }

    _clearingServices;
    handleClearingSelection(e) {
        console.log("SELECTED THE FOLLOWING OPTIONS: ");
        console.log(e.detail.value);
        this._clearingServices = e.detail.value;
        this.addServices();
    }

    _accessServices;
    handleAccessSelection(e) {
        console.log("SELECTED THE FOLLOWING ACCESS OPTIONS: ");
        console.log(e.detail.value);
        this._accessServices = e.detail.value;
        this.addServices();
    }

    _environmentalServices;
    handleEnvironmentalSelection(e) {
        console.log("SELECTED THE FOLLOWING ENVIRONMENTAL OPTIONS: ");
        console.log(e.detail.value);
        this._environmentalServices = e.detail.value;
        this.addServices();
    }

    _matServices;
    handleMatSelection(e) {
        console.log("SELECTED THE FOLLOWING MAT OPTIONS: ");
        console.log(e.detail.value);
        this._matServices = e.detail.value;
        this.addServices();
    }

    allItems = [];
    addServices() {
        console.log("Updating list of services...");

        this.allItems = [];

        if (this._clearingServices != undefined && this._clearingServices.length > 0) 
            this.allItems.push.apply(this.allItems, this._clearingServices);

        if (this._accessServices != undefined && this._accessServices.length > 0) 
            this.allItems.push.apply(this.allItems, this._accessServices);

        if (this._environmentalServices != undefined && this._environmentalServices.length > 0)
            this.allItems.push.apply(this.allItems, this._environmentalServices);

        if (this._matServices != undefined && this._matServices.length > 0) 
            this.allItems.push.apply(this.allItems, this._matServices);
        
        console.log("ALL ITEMS:");
        console.log(this.allItems);

        let itemsToPush = [];
        for (let i = 0; i < this.allItems.length; i++) {
            let rfpServiceItem = {
                Quantity__c: 1,
                Product__c: this.allItems[i]
            }
            itemsToPush.push(rfpServiceItem);
        }

        console.log("Pushing following SERVICE items up to parent cmp: ");
        console.log(itemsToPush);

        const serviceSelectionEvent = new CustomEvent("serviceaddition", {
            detail: itemsToPush
        });

        this.dispatchEvent(serviceSelectionEvent);

    }


}