import { LightningElement, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTasks from '@salesforce/apex/SalesFollowup.getTasks';

export default class SalesTasks extends LightningElement {

    @track error;
    @track tasks;

    updating = false;

    showBids;
    renderedCallback() {
        getTasks()
            .then(result => {
                this.tasks = result;
                this.error = undefined;
                if (this.tasks.length > 0) {
                    this.showBids = true;
                } else {
                    this.showBids = false;
                }
            })
            .catch(error => {
                console.log('Error fetching bids: ' + error);
                this.tasks = undefined;
                this.error = error;
            });
    }
}