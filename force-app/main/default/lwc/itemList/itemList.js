import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getItems from '@salesforce/apex/ItemController.getItems';

export default class ItemList extends LightningElement {
    @api recordId;
    user;
    load;
    @track items;
    commodityOptions;
    @track error;
    invoiced = false;

    showToast(toastTitle, msg, toastVariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: msg,
            variant: toastVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    connectedCallback() {
        // Fetch the list of Item__c records related to the Load__c record
        getItems({loadId: this.recordId})
            .then(result => {
                console.log("ITEMS:");
                console.log(result);
                this.user = result.usr;
                this.load = result.load;
                this.commodityOptions = result.commodityOptions;
                this.invoiced = this.load.Invoiced_Item_Count__c > 0 ? true : false;
                this.items = result.items;
            })
            .catch(error => {
                // Handle error
                console.log("Unable to fetch load item records...");
                console.log(error);
            });
    }

    addNewItem(evt) {
        console.log("adding new item...");
        var newItem = {
            Id: null,
            Load__c: this.recordId,
            New__c: 0,
            A_Four__c: 0,
            A_Three__c: 0,
            B_Two__c: 0,
            B_One__c: 0,
            Cull__c: 0,
            Commodity__c: null,
            Delivery_Item__c: null,
            Delivery_Order__c: null,
            Pickup_Order__c: null,
            Pickup_Item__c: null
        };
        console.log("New Item to add: ");
        console.log(newItem);
        this.items.push(newItem);

    }

    get showAddButton() {
        return this.invoiced ? false : true;
    }
}