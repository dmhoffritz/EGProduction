import { LightningElement, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getUpcomingBids from '@salesforce/apex/SalesFollowup.getUpcomingBids';
import updateBidStatus from '@salesforce/apex/SalesFollowup.updateBidStatus';

export default class SalesFollowup extends LightningElement {

    @track error;
    @track bids;

    showBids;
    renderedCallback() {
        getUpcomingBids()
            .then(result => {
                console.log('Receiving the following response when fetching bids: ');
                console.log(result);
                this.bids = result;
                this.error = undefined;
                if (this.bids.length > 0) {
                    this.showBids = true;
                } else {
                    this.showBids = false;
                }
            })
            .catch(error => {
                console.log('Error fetching bids: ' + error);
                this.bids = undefined;
                this.error = error;
            });
    }
    updating = false;
    updateBidStatus(event) {
        this.updating = true;
        console.log('Receiving the following bid to update: ');
        console.log(event.detail);
        console.log('Updating bid w/ id: ' + event.detail.Id + ' BID NAME: ' + event.detail.Name);
        console.log('Updating StageName to: ' + event.detail.StageName);
        updateBidStatus({ bidId: event.detail.Id, status: event.detail.StageName })
            .then(result => {
                console.log("Successfully updated bid!");
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Bid ' + event.detail.Name + ' stage updated to ' + event.detail.StageName + '!',
                    variant: 'success'
                });

                /*
                    messageData: [
                        event.detail.Name,
                        event.detail.StageName,
                        {
                            url: 'https://yourempiregroup--dev3.sandbox.lightning.force.com/lightning/r/Opportunity/' + event.detail.Id + '/view',
                            label: 'here'
                        },
                    ],
                */
                this.dispatchEvent(evt);
                this.updating = false;
            })
            .catch(error => {
                console.log('Error fetching bids: ');
                console.log(error);
                this.bids = undefined;
                this.error = error;
            });
    }

}