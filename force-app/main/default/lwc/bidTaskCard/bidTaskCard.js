import { LightningElement, api, track } from 'lwc';

export default class BidTaskCard extends LightningElement {
    @api bid;
    @api task;

    bidLink;
    accountLink;
    contactLink;
    primaryContact;

    renderedCallback() {
        this.bidLink = 'https://yourempiregroup.lightning.force.com/lightning/r/Opportunity/' + this.bid.Id + '/view';
        this.accountLink = 'https://yourempiregroup.lightning.force.com/lightning/r/Account/' + this.bid.AccountId + '/view';
        this.primaryContact = 'N/A';
        this.contactLink = '#';

    }

    @track expand = true;

    get cardCSS() {
        return this.expand ? 'slds-card card-expand' : 'slds-card card-collapse';
    }

    showBody = true;

    toggleBody() {
        if (this.showBody) {
            this.expand = false;
            this.showBody = false;
        } else {
            this.expand = true;
            this.showBody = true;
        }
    }

    inputVariables = [];

    @track isShowModal = false;

    hideModalBox() {  
        this.isShowModal = false;
    }

    @track flowAPIName;
    @track flowInputs;
    @track modalHeading;

    updateStatus() {
        this.flowAPIName = "Sales_Followup_Update_Bid_Status";
        this.flowInputs = [
            {
                name: "recordId",
                type: "String",
                value: this.bid.Id
            }
        ];
        this.modalHeading = "Update Bid Status";

        this.isShowModal = true;
    }

    viewQuote() {
        this.flowAPIName = "View_PDF";
        this.flowInputs = [
            {
                name: "relatedRecordId",
                type: "String",
                value: this.bid.Id
            }
        ];
        this.modalHeading = this.bid.Name + ' - Quote';

        this.isShowModal = true;
    }

    viewBid() {
        window.open('https://yourempiregroup.lightning.force.com/lightning/r/Opportunity/' + this.bid.Id + '/view');
    }

    followup = false;

    completeFollowup() {
        this.followup = true;
    }

    get taskFlowInput() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.task.Id
            }
        ];
    }

    get badgeCSS() {
        let today = new Date();
        let dueDate = new Date(this.task.ActivityDate);
        let nextWeek = new Date();
        nextWeek.setDate(nextWeek.getDate() + 7);

        let badge = '';
        if (dueDate <= today) {
            badge = 'badge-red';
        } else if (dueDate > today && dueDate <= nextWeek) {
            badge = 'badge-yellow';
        } else {
            badge = 'badge-green';
        }
        return badge;
    }

    get dueDate() {
        let today = new Date();
        let dueDate = new Date(this.task.ActivityDate);
        dueDate.setDate(dueDate.getDate() + 1);
        return dueDate.toDateString() == today.toDateString() ? 'Due Today' : dueDate.toDateString();

    }



    handleStatusChange(evt) {
        console.log("Flow status changed to: " + evt.detail.status);
        if (evt.detail.status === "FINISHED") {
            this.isShowModal = false;
        }
    }

    handleFollowupStatusChange(evt) {
        console.log("Followup flow status changed to: " + evt.detail.value);
    }
}