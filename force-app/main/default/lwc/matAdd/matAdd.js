import { LightningElement, wire, track, api } from 'lwc';

//apex used to update product name options whenever product type is changed
import getProductNameOptions from '@salesforce/apex/RFP_Cont.getProductNameOptions';
import deleteItem from '@salesforce/apex/WorkOrder_Cont.deleteItem';

export default class MatAdd extends LightningElement {
    @api matItem;

    matGradeOptions = [
        { label: 'New', value: 'New' },
        { label: 'A', value: 'A' },
        { label: 'New/A Mix', value: 'New/A Mix' },
        { label: 'A/B Mix', value: 'A/B Mix' },
        { label: 'B', value: 'B' },
        { label: 'Cull', value: 'Cull' },
        { label: 'Unspecified', value: 'Unspecified'}
    ];

    @track sellType = 'Purchase';
    @track duration = 0;
    //@track includeBuyback = false;
    @track prodType = 'Digging Mat';
    @track prodName = '8x4x18';
    @track prodId = '01t1Y00000BtdR1QAJ';
    @track qty = 0;
    @track grade = 'New';
    @track notes = '';

    get sellTypeOptions() {
        return [
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
    }

    get purchase() {
        return this.sellType.includes("Purchase");
    }

    get leaseOrRental() {
        return this.sellType.includes("Lease") || this.sellType.includes("Rental");
    }

    _item = {};
    renderedCallback() {
        this._item = {
            id: this.matItem.id,
            sellType: this.sellType,
            duration: this.duration,
            productType: this.prodType,
            productName: this.productName,
            quantity: this.qty,
            matGrade: this.grade,
            notes: this.notes
        };
    }

    deleteItem() {
        const updateItemEvent = new CustomEvent("delete", {
            detail: this._item
        });
        this.dispatchEvent(updateItemEvent);
    }

    productTypeOptions = [
        { label: 'Bridge Mat', value: 'Bridge Mat' },
        { label: 'CLT', value: 'CLT' },
        { label: 'Composite', value: 'Composite' },
        { label: 'Digging Mat', value: 'Digging Mat' },
        { label: 'Laminated Mat', value: 'Laminated Mat' },
        { label: 'Skid', value: 'Skid' }
    ];

    updateSellType(event) {

        if (event.target.value) {
            this._item = {
                ...this._item,
                id: this.matItem.id,
                sellType: (this.sellType = event.detail.value),
                duration: this.duration,
                productType: this.prodType,           
                productName: this.prodName,
                productId: this.prodId,
                quantity: this.qty,
                matGrade: this.grade,
                notes: this.notes
            }

            console.log('SELECTED SELL TYPE: ');
            console.log(this.sellType);
            this.productFilters = {
                ...this.productFilters,
                sellType: event.detail.value,
                productType: this.prodType
            };
            this.updateMatItem();
        } else {

        }
    }

    updateDuration(event) {
        if (event.target.value) {
            this._item = {
                ...this._item,
                id: this.matItem.id,
                sellType: this.sellType,
                duration: (this.duration = event.detail.value),
                productType: this.prodType,           
                productName: this.prodName,
                productId: this.prodId,
                quantity: this.qty,
                matGrade: this.grade,
                notes: this.notes
            }

            console.log('SELECTED DURATION: ');
            console.log(this.duration);
            this.updateMatItem();
        } else {
            
        }
    }

    updateProductType(event) {
        if (event.target.value) {
            this._item = {
                ...this._item,
                id: this.matItem.id,
                sellType: this.sellType,
                duration: this.duration,
                productType: (this.prodType = event.target.value),           
                productName: this.prodName,
                productId: this.prodId,
                quantity: this.qty,
                matGrade: this.grade,
                notes: this.notes
            }
            console.log('SELECTED PROD TYPE: ');
            console.log(this.prodType);
            this.productFilters = {
                ...this.productFilters,
                sellType: this.sellType,
                productType: this.prodType
            };
            this.updateMatItem();
        } else {
        }
        this.prodName = '';

    }

    @track productFilters = {
        sellType: 'Purchase',
        productType: 'Digging Mat'
    };

    @wire(getProductNameOptions, { filters: '$productFilters' })
    nameResponse;

    handleNameSelection(event) {
        console.log("Updating mat product name & id...");
        console.log("Selected mat: " + event.target.options.find(opt => opt.value === event.detail.value).label);
        console.log("Selected mat id: " + event.target.value);
        if (event.target.value) {
            this._item = {
                ...this._item,
                id: this.matItem.id,
                sellType: this.sellType,
                duration: this.duration,
                productType: this.prodType,
                productName: (this.prodName = event.target.options.find(opt => opt.value === event.detail.value).label),
                productId: (this.prodId = event.target.value),
                quantity: this.qty,
                matGrade: this.grade,
                notes: this.notes
            }
            this.updateMatItem();
        } else {

        }
    }

    updateQty(evt) {
        console.log("Updating qty w/ the following event details: ");
        console.log(evt);
        if (evt.target.value) {
            this._item = {
                ...this._item,
                id: this.matItem.id,
                sellType: this.sellType,
                duration: this.duration,
                productType: this.prodType,
                productName: this.prodName,
                productId: this.prodId,
                quantity: (this.qty = evt.target.value),
                matGrade: this.grade,
                notes: this.notes
            }
            this.updateMatItem();
        } else {
            
        }
    }

    updateMatGrade(evt) {
        console.log("Updating mat grade w/ the following event details: ");
        console.log(evt);
        if (evt.target.value) {
            this._item = {
                ...this._item,
                id: this.matItem.id,
                sellType: this.sellType,
                duration: this.duration,
                productType: this.prodType,
                productName: this.prodName,
                productId: this.prodId,
                quantity: this.qty,
                matGrade: (this.grade = evt.target.value),
                notes: this.notes
            }
            this.updateMatItem();
        } else {

        }
    }

    updateNotes(evt) {
        console.log("Updating notes w/ the following event details: ");
        console.log(evt);
        if (evt.target.value) {
            this._item = {
                ...this._item,
                id: this.matItem.id,
                sellType: this.sellType,
                duration: this.duration,
                productType: this.prodType,
                productName: this.prodName,
                productId: this.prodId,
                quantity: this.qty,
                matGrade: this.grade,
                notes: (this.notes = evt.target.value)
            }
            this.updateMatItem();
        } else {
            
        }
    }

    updateMatItem() {
        console.log("Updating the following mat item: ");
        console.log(this._item);
        const updateItemEvent = new CustomEvent("update", {
            detail: this._item
        });
        this.dispatchEvent(updateItemEvent);
    }

    submitMatLine() {
        console.log("Submitting following mat item: ");
        console.log(this._item);
        const submitItemEvent = new CustomEvent("submission", {
            detail: this._item
        });
        this.dispatchEvent(submitItemEvent);
    }

    updateItemDetails(itemToAdd) {
        const itemUpdateEvent = new CustomEvent("itemupdate", {
            detail: itemToAdd
        });

        this.dispatchEvent(itemUpdateEvent);
    }

}