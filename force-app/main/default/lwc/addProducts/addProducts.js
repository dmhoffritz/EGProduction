import { LightningElement, api, track, wire } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationFinishEvent,
} from 'lightning/flowSupport';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const actions = [
    { label: 'Delete', name: 'remove_row' }
];

export default class AddProducts extends LightningElement {
    @api
    get rfpDescription() {
        return this.rfpDescription;
    }
    
    set rfpDescription(rfpDescription) {
        this.rfpDescription = rfpDescription;
    }

    @track
    rfpDescription;

    @api
    availableActions = [];

    @api
    get rfpItems() {
        return this._rfpItems;
    }

    set rfpItems(rfpItems = []) {
        this._rfpItems = [...rfpItems];
    }

    @track _rfpItems = [];

    get hasItems() {
        return this._rfpItems && this._rfpItems.length > 0;
    }

    renderedCallback() {

    }

    //list of items to manipulate on client side
    @track matData = [{
        id: Math.random().toString(16).slice(2),
        Sell_Type__c: 'Purchase',
        Include_Buy_Back__c: false,
        Duration__c: this.duration,
        Product_Type__c: 'Digging Mat',
        productName: '8x4x18',
        Product__c: '',
        Quantity__c: 0,
        MAT_Grade__c: 'New',
        Notes__c: ''
    }];

    @track _matItems = [];

    @api
    get matItems() {
        return this._matItems;
    }

    set matItems(matItems = []) {
        this._matItems = [...matItems];
    }

    addMatItem() {
        console.log("Adding mat...");
        //this.showModal = true;
        let item = {
            id: Math.random().toString(16).slice(2),
            Sell_Type__c: 'Purchase',
            Include_Buy_Back__c: false,
            Duration__c: this.duration,
            Product_Type__c: 'Digging Mat',
            productName: '8x4x18',
            Product__c: '',
            Quantity__c: 0,
            MAT_Grade__c: 'New',
            Notes__c: ''
        };
        this.matData.push(item);
        this.matData = [...this.matData];
    }

    updateProductList(evt) {
        console.log("Receiving following mat item from update: ");
        console.log(evt.detail);
        for (let i = 0; i < this.matData.length; i++) {
            if (this.matData[i].id == evt.detail.id) {
                this.matData[i].Sell_Type__c = evt.detail.sellType;
                this.matData[i].Duration__c = evt.detail.duration;
                this.matData[i].Product_Type__c = evt.detail.productType;
                this.matData[i].productName = evt.detail.productName;
                this.matData[i].Product__c = evt.detail.productId;
                this.matData[i].Quantity__c = evt.detail.quantity;
                this.matData[i].MAT_Grade__c = evt.detail.matGrade;
                this.matData[i].Notes__c = evt.detail.notes;
                break;
            }
        }

        this.matData = [...this.matData];
    }

    deleteProduct(evt) {
        for (let i = 0; i < this.matData.length; i++) {
            if (this.matData[i].id == evt.detail.id) {
                //delete this._rfpItems[i];
                this.matData.splice(i, 1);
                break;
            }
        }
        this.matData = [...this.matData];
    }

    serviceItems = [];
    addService(event) {
        let items = [];
        for (let i = 0; i < event.detail.length; i++) {
            let serviceItem = {
                Quantity__c: 1,
                Product__c: event.detail[i].Product__c,
                MAT_Grade__c: 'New',
                Include_Buy_Back__c: false
            }

            items.push(serviceItem);
        }
        this.serviceItems = items;
    }

    updateDescription(event) {
        this.rfpDescription = event.detail.value;
    }

    handleFinish() {
        this.finalizeInputs();
    }

    finalizeInputs() {
        console.log("REMOVING EMPTIES BEFORE FINISH");
        let dataForEval = this.matData;
        var productsForOutput = [];
        for (let p = 0; p < dataForEval.length; p++) {
            console.log("Loop #: " + p);
            if (dataForEval[p].Quantity__c == 0) {
                console.log("No qty defined...deleting item");
                //delete dataForEval[p];
                this.deleteRow(dataForEval[p].id);
            } else {
                console.log('PUSHING PROD:');
                let prod = dataForEval[p];
                console.log("SELL TYPE: " + prod.Sell_Type__c);
                console.log("PRODUCT TYPE: " + prod.Product_Type__c);
                console.log('PROD ID: ' + prod.Product__c);
                console.log('PROD NAME: ' + prod.productName);
                console.log('QTY: ' + prod.Quantity__c);
                console.log('GRADE: ' + prod.MAT_Grade__c);
                console.log('DURATION: ' + prod.Duration__c);
                console.log('NOTES: ' + prod.Notes__c);
                productsForOutput.push(prod);
            }
        }

        this.matData = [...productsForOutput];

        console.log("Pushing following products for apex to process outputs:");
        console.log(productsForOutput);
        this._rfpItems = [...this.matData, ...this.serviceItems];

        if (this.availableActions.find((action) => action === 'FINISH')) {
            //finish flow
            const navFinishEvt = new FlowNavigationFinishEvent();
            this.dispatchEvent(navFinishEvt);
        } else {
            //nav next screen
            const navNextEvt = new FlowNavigationNextEvent();
            this.dispatchEvent(navNextEvt);
        }

    }

}