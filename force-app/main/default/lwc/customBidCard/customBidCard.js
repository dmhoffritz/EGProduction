import { LightningElement, api } from 'lwc';

export default class CustomBidCard extends LightningElement {
    @api bid;
    bidToUpdate;
    renderedCallback() {
        this.bidToUpdate = { ...this.bid };
    }

    viewBid() {
        window.open('https://yourempiregroup.lightning.force.com/lightning/r/Opportunity/' + this.bid.Id + '/view')
    }

    updateNoBid() {
        console.log('Updating bid -> no bid');
        this.bidToUpdate = {
            ...this.bidToUpdate,
            Id: this.bidToUpdate.Id,
            Name: this.bidToUpdate.Name,
            StageName: 'No Bid'
        };
        console.log('Updated bid stage name: ');
        console.log(this.bidToUpdate.StageName);
        this.submitUpdate();
    }

    updateContractorLost() {
        console.log('Updating bid -> Contractor Lost');
        this.bidToUpdate = {
            ...this.bidToUpdate,
            Id: this.bidToUpdate.Id,
            Name: this.bidToUpdate.Name,
            StageName: 'Contractor Lost'
        };
        console.log('Updated bid stage name: ');
        console.log(this.bidToUpdate.StageName);
        this.submitUpdate();
    }

    updateBidLost() {
        console.log('Updating bid -> bid lost');
        this.bidToUpdate = {
            ...this.bidToUpdate,
            Id: this.bidToUpdate.Id,
            Name: this.bidToUpdate.Name,
            StageName: 'Bid Lost'
        };
        console.log('Updated bid stage name: ');
        console.log(this.bidToUpdate.StageName);
        this.submitUpdate();
    }

    updateBidWon() {
        console.log('Updating bid -> Bid Won');
        this.bidToUpdate = {
            ...this.bidToUpdate,
            Id: this.bidToUpdate.Id,
            Name: this.bidToUpdate.Name,
            StageName: 'Bid Won'
        };
        console.log('Updated bid stage name: ');
        console.log(this.bidToUpdate.StageName);
        this.submitUpdate();
    }

    submitUpdate() {
        console.log("Updating stage name for bid w/ id: " + this.bidToUpdate.Id + " to stage: " + this.bidToUpdate.StageName);
        console.log("Handling update submission...");
        const updateBidEvent = new CustomEvent("bidupdate", {
            detail: this.bidToUpdate
        });
        this.dispatchEvent(updateBidEvent);

    }
}