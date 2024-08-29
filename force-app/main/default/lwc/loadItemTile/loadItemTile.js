import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
import updateItem from '@salesforce/apex/ItemController.updateItem';
import deleteItem from '@salesforce/apex/ItemController.deleteItem';

export default class LoadItemTile extends LightningElement {
    @api user;
    @api load;
    @api item;
    @api commodityOptions;
    itemToUpdate;
    originalQuantity;
    originalCommodity;
    selectedCommodity;
    editMode = false;
    loading = false;

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
        console.log("Initialized load item tile...");
        this.originalCommodity = this.item.Commodity__c;
        this.originalQuantity = this.item.Quantity__c;
        this.itemToUpdate = { ...this.item };

        let comm = this.commodityOptions.find(record => record.value === this.item.Commodity__c);
        console.log("Default commodity:");
        if (comm != undefined) { //start by checking if indicated commodity was matched with commodity options found from pickup / delivery order
            this.selectedCommodity = this.item.Commodity__c;
        } else if (this.commodityOptions.length > 1 && this.itemToUpdate.Product__c == undefined && this.itemToUpdate.Equipment__c == undefined) { //this checks if raw item is built without any commodity references and item has potential commodity references on delivery / pickup job
            this.selectedCommodity = this.commodityOptions[0].value; //assign first commodity option found from delivery / pickup job
            this.itemToUpdate.Product__c = null;
            this.itemToUpdate.Equipment__c = null;
            this.itemToUpdate.Delivery_Order__c = this.commodityOptions[0].deliveryOrder;
            this.itemToUpdate.Delivery_Item__c = this.commodityOptions[0].deliveryItem;
            this.itemToUpdate.Pickup_Order__c = this.commodityOptions[0].pickupOrder;
            this.itemToUpdate.Pickup_Item__c = this.commodityOptions[0].pickupItem;
        } else { //if no references were found, then set selected commodity to other which will pop-up product / equipment lookup
            this.selectedCommodity = 'Other';
        }
        console.log(this.selectedCommodity);
    }


    get isFieldService() {
        var profile = this.user.Profile.Name;
        return profile.includes("Field Service");
    }

    get isEquipment() {
        return this.load.RecordType.DeveloperName == 'Equipment' ? true : false;
    }


    get editEnabled() {
        return this.item.Mat_Invoice__c != null && this.item.Mat_Invoice__c != '' ? false : true;
    }

    enableEdit() {
        this.editMode = true;
    }

    get disabled() {
        return this.editMode == false ? true : false;
    }

    get gradeDisabled() {
        var profile = this.user.Profile.Name;
        if (this.editMode == false || profile.includes("Field Service")) {
            return true;
        } else {
            return false;
        }
    }

    get gradeInputDiabled() {
        if (this.disabled) {
            return true;
        }
        if (this.selectedCommodity.startsWith("8x4x") == false) {
            return true; 
        } else {
            return false;
        }
    }

    get showProductLookup() {
        return this.selectedCommodity == 'Other' && this.load.RecordType.DeveloperName != 'Equipment' ? true : false;
    }

    get showEquipmentLookup() {
        return this.selectedCommodity == 'Other' && this.load.RecordType.DeveloperName == 'Equipment' ? true : false;
    }

    handleCommodityChange(event) {
        console.log("Updating commodity...");
        this.selectedCommodity = event.detail.value;
        if (this.selectedCommodity == 'Other') {
            return;
        }
        let selectedOption = this.commodityOptions.find(option => option.value === event.detail.value);
        console.log("Selected commodity: ");
        console.log(selectedOption);
        console.log("Updating item's order references...");
        this.itemToUpdate.Product__c = null;
        this.itemToUpdate.Equipment__c = null;
        if (selectedOption.deliveryOrder == undefined) {
            this.itemToUpdate.Delivery_Order__c = null;
            this.itemToUpdate.Delivery_Item__c = null;
        } else {
            this.itemToUpdate.Delivery_Order__c = selectedOption.deliveryOrder;
            this.itemToUpdate.Delivery_Item__c = selectedOption.deliveryItem;
        }
        if (selectedOption.pickupOrder == undefined) {
            this.itemToUpdate.Pickup_Order__c = null;
            this.itemToUpdate.Pickup_Item__c = null;
        } else {
            this.itemToUpdate.Pickup_Order__c = selectedOption.pickupOrder;
            this.itemToUpdate.Pickup_Item__c = selectedOption.pickupItem;
        }

        console.log("Updated item:");
        console.log(this.itemToUpdate);
    }

    logProduct(event) {
        console.log("Logging new product...");
        let selectedProduct = event.target.value;
        if (selectedProduct && selectedProduct != '') {
            this.itemToUpdate.Delivery_Order__c = null;
            this.itemToUpdate.Delivery_Item__c = null;
            this.itemToUpdate.Pickup_Order__c = null;
            this.itemToUpdate.Pickup_Item__c = null;
            this.itemToUpdate.Product__c = selectedProduct;
        } else {
            this.itemToUpdate.Product__c = null;
        }
        console.log("Updated item: ");
        console.log(this.itemToUpdate);
    }

    logEquipment(event) {
        console.log("Logging new product...");
        let selectedEquipment = event.target.value;
        if (selectedEquipment && selectedEquipment != '') {
            this.itemToUpdate.Delivery_Order__c = null;
            this.itemToUpdate.Delivery_Item__c = null;
            this.itemToUpdate.Pickup_Order__c = null;
            this.itemToUpdate.Pickup_Item__c = null;
            this.itemToUpdate.Equipment__c = selectedEquipment;
        } else {
            this.itemToUpdate.Equipment__c = null;
        }
        console.log("Updated item: ");
        console.log(this.itemToUpdate);
    }

    updateQty(event) {
        console.log("Updating quantities...");
        let newVal = isNaN(event.target.value) || event.target.value == '' ? 0 : parseInt(event.target.value);
        this.itemToUpdate[event.target.name] = newVal;
        console.log('Updated Item: ');
        console.log(this.itemToUpdate);
    }

    updateGrade(evt) {
        console.log("Updating item's grade to bill...");
        console.log("Updated grade:");
        console.log(evt.target.value);
        let selectedGrade = evt.target.value;
        if (selectedGrade) {
            this.itemToUpdate.Grade__c = selectedGrade;
        }

        console.log("Updated item: ");
        console.log(this.itemToUpdate);
    }

    deleteItem(event) {
        this.loading = true;
        console.log("Confirming deletion...");
        if (window.confirm('Are you sure you want to delete this item?')) {
            console.log("Deletion confirmed!");
            if (this.item.Id != undefined && this.item.Id != null) { //check if item was created by client or fetched from server
                deleteItem({ item: this.item }).then(res => {
                    console.log("Successfully deleted item record");
                     const component = this.template.host;
                    component.remove();
                }).catch(error => {
                    console.log("Error deleting commodity: " + error.body.message);
                    this.showToast('Error deleting commodity...', error.body.message, 'error');
                });
            } else {
                delete this.item;
                this.loading = false;
                const component = this.template.host;
                component.remove();
            }

        }
    }

    saveChanges(event) {
        this.loading = true;
        console.log("Updating item...");
        updateItem({ item: this.itemToUpdate }).then(res => {
            this.itemToUpdate.Id = res.Id;
            console.log("Successfully updated item!");
            this.editMode = false;
            this.loading = false;
            this.showToast('Successfully updated commodity!', '', 'success');
            let originalCommodity = this.itemToUpdate.Commodity__c;
            let newCommodity = res.Commodity__c;
            if (originalCommodity != newCommodity && FORM_FACTOR != "Large") {
                window.location.reload();
            }
        }).catch(error => {
            console.log('Error updating item: ' + error.body.message);
            this.loading = false;
            this.showToast('Error updating commodity...', error.body.message, 'error');
        });
    }
}