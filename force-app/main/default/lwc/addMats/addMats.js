import { LightningElement, api, track, wire } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationFinishEvent,
} from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//schema declarations
import RFP_OBJECT from '@salesforce/schema/RFP__c';
import RFP_ITEM_OBJECT from '@salesforce/schema/RFP_Item__c';

const actions = [
    { label: 'Delete', name: 'remove_row' }
];

export default class AddMats extends LightningElement {
    @api
    rfpId;


    @api
    availableActions = [];

    @api
    get rfpItems() {
        return this._rfpItems;
    }

    set rfpItems(rfpItems = []) {
        this._rfpItems = [...rfpItems];
    }

    /*
    @track _item = {
        id: Math.random().toString(16).slice(2),
        Product__c: '',
        Quantity__c: 0,
        MAT_Grade__c: ''
    }
    */

    @track _rfpItems = [];

    get hasItems() {
        return this._rfpItems && this._rfpItems.length > 0;
    }
    
    serviceItems = [];
    addService(event) {
        let items = [];
        for (let i = 0; i < event.detail.length; i++) {
            let serviceItem = {
                Product_Family_del__c: 'Services',
                Quantity__c: 1,
                Product__c: event.detail[i].Product__c,
                RFP__c: this.rfpId
            }

            items.push(serviceItem);
        }
        this.serviceItems = items;
    }

    @track _matItems = [];

    @api
    get matItems() {
        return this._matItems;
    }

    set matItems(matItems = []) {
        this._matItems = [...matItems];
    }

    @track showModal = false;

    addMatItem() {
        this.showModal = true;
    }
 
    closeModal() {
        this.showModal = false;
    }

    @track matData = [];

    matColumns = [
        { label: 'Qty', fieldName: 'Quantity__c' },
        { label: 'Commodity', fieldName: 'customCommodity', wrapText: true },
        { label: 'Sell Type', fieldName: 'Sell_Type_del__c' },
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        }
    ];
    storeMatLine(event) {
        console.log("RECEIVING FOLLOWING MAT LINE TO ADD TO DATATABLE: ");
        console.log(event.detail);
        console.log("QUANTITY: " + event.detail.Quantity__c);
        console.log("PRODUCT ID: " + event.detail.Product__c);
        console.log("MAT GRADE: " + event.detail.MAT_Grade__c);
        console.log("RFP ID: " + event.detail.RFP__c);

        let tableItem = {
            id: event.detail.id,
            RFP__c: event.detail.RFP__c,
            Product_Family_del__c: 'Mat Sales',
            Sell_Type_del__c: event.detail.Sell_Type_del__c,
            Quantity__c: event.detail.Quantity__c,
            Product_Type_del__c: event.detail.Product_Type_del__c,           
            Product__c: event.detail.Product__c,
            productName: event.detail.productName,
            MAT_Grade__c: event.detail.MAT_Grade__c,
            customCommodity: (event.detail.Product_Type_del__c + ' - ' + event.detail.productName + ' - ' + event.detail.MAT_Grade__c)
        }

        console.log("MAT DATA (BEFORE PUSH): ");
        console.log(this.matData);
        this.matData.push(tableItem);
        this.matData = [...this.matData];
        console.log("MAT DATA (AFTER PUSH): ");
        console.log(this.matData);

        let item2Add = {
            id: event.detail.id,
            RFP__c: event.detail.RFP__c,
            Product_Family_del__c: 'Mat Sales',
            Sell_Type_del__c: event.detail.Sell_Type_del__c,
            Quantity__c: event.detail.Quantity__c,
            Product_Type_del__c: event.detail.Product_Type_del__c,           
            Product__c: event.detail.Product__c,
            MAT_Grade__c: event.detail.MAT_Grade__c,
        }

        console.log("Pushing following item to list for output: ");
        console.log(item2Add);
        console.log("MAT LIST BEFORE PUSH (FOR OUTPUT): ");
        console.log(this._matItems);
        this._matItems.push(item2Add);
        this._matItems = [...this._matItems];
        console.log("MAT LIST AFTER PUSH (FOR OUTPUT) ");
        console.log(this._matItems);

        this.showModal = false;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'remove_row':
                console.log("Deleting mat item w/ id: ");
                console.log(row);
                console.log("MAT ITEMS: ");
                console.log(this.matData);
                this.deleteRow(row);
                break;
            default:
        }
    }

    deleteRow(row) {

        const { id } = row;
        for (let i = 0; i < this.matData.length; i++) {
            if (this.matData[i].id == id) {
                //delete this._rfpItems[i];
                this.matData.splice(i, 1);
                break;
            }
        }
        this.matData = [...this.matData];
        console.log("Remaining mat items: ");
        console.log(this.matData);
        this._matItems = [...this.matData];
    }

    /*
    addRFPItem() {
        console.log("Adding MAT Item...");
        let item = {
            id: Math.random().toString(16).slice(2),
            Product__c: '',
            Quantity__c: 0,
            MAT_Grade__c: '',
            RFP__c: this.rfpId
        }
        console.log(item);
        this._matItems.push(item);
        this._matItems = [...this._matItems];
        console.log("MAT LIST (AFTER ADDITION)");
        console.log(this._matItems);
    }
    */

    /*
    updateItem(event) {
        console.log("Updating item w/ ID: " + event.detail.id);
        let item2Add = {
            id: event.detail.id,
            Product__c: event.detail.Product__c,
            Quantity__c: event.detail.Quantity__c,
            MAT_Grade__c: event.detail.MAT_Grade__c,
            RFP__c: this.rfpId
        }
        for (let i = 0; i < this._matItems.length; i++) {
            console.log(this._matItems[i]);
            if (this._matItems[i].id == item2Add.id) {
                console.log("IDs MATCH!");
                this._matItems[i] = item2Add;
                break;
            }
        }
        console.log("MAT ITEMS: ");
        this._matItems = [...this._matItems];
        console.log(this._matItems);
        //notify the flow of the new rfp item list
        //const attributeChangeEvt = new FlowAttributeChangeEvent('rfpItems', this._rfpItems);
        //this.dispatchEvent(attributeChangeEvt);

    }
    */
    removeItem(event) {
        let rowId = event.detail;
        for (let i = 0; i < this._matItems.length; i++) {
            if (this._matItems[i].id == rowId) {
                //delete this._rfpItems[i];
                this._matItems.splice(i, 1);
                break;
            }
        }
        this._matItems = [...this._matItems];
        //notify the flow of the new rfp item list
        //const attributeChangeEvt = new FlowAttributeChangeEvent('rfpItems', this._rfpItems);
        //this.dispatchEvent(attributeChangeEvt);
    }


    handleFinish() {
        this.finalizeInputs();
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

    finalizeInputs() {
        console.log("REMOVING IDS BEFORE FINISH");
        console.log("MAT ITEMS: ");
        //this._rfpItems = [...this._rfpItems];
        console.log(this._matItems);
        for (let i = 0; i < this._matItems.length; i++) {
            if (this._matItems[i].Product__c == undefined || this._matItems[i].Product__c == '') {
                delete this._matItems[i];
            } else if (this._matItems[i].id) {
                delete this._matItems[i].id;
            }
        }
        this._matItems.push.apply(this._matItems, this.serviceItems);
        this._rfpItems = [...this._matItems];
        console.log("FINALIZED LIST OF ITEMS :");
        console.log(this._rfpItems);
        //notify the flow of the new rfp item list
        const attributeChangeEvt = new FlowAttributeChangeEvent('rfpItems', this._rfpItems);
        this.dispatchEvent(attributeChangeEvt);
    }
}