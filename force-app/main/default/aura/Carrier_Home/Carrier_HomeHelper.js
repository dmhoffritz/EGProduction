({
    /*
    getRelatedLoads : function(cmp) {
        console.log('Fetching load data...');
        var r_Id = cmp.get("v.recordId");
        if(r_Id != null && r_Id != '') {
            var action = cmp.get("c.getRelatedLoads");
            action.setParams({"recordId": r_Id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    //cmp.set("v.master_load_list", response.getReturnValue());
                    //this.bucketLoads(cmp);
                }
            });
            
            $A.enqueueAction(action);
        } else {
            console.log('INVALID USER ID');
        }
    }, */
    getDisputedLoads: function (cmp, event) {
        let carrierId = cmp.get("v.recordId");  
        let action = cmp.get("c.findDisputes");
        action.setParams({
            recordId: carrierId
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                let disputes = res.getReturnValue();
                if (disputes.length > 0) {
                    //pop modal w dispute info
                    cmp.set("v.disputedLoads", disputes);
                    this.showDisputes(cmp);
                } else {
                    //do nothing
                }
            } else if (state === "INCOMPLETE") {
                //do nothing
            } else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever fetching load data: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    showDisputes: function (cmp) {
        this.organizeCells(cmp);
        cmp.set("v.displayDisputes", true);
    },

    organizeCells: function (cmp) {
        let cols = [
            { label: 'Load #', fieldName: 'Name', type: 'button', iconName: 'utility:truck', hideDefaultActions: "true", typeAttributes: { label: { fieldName: 'Name' }, name: 'view_details', title: 'Click to View Details' } },
            {label: 'Dispute Reason', fieldName: 'DisputeReason__c', type: 'text', hideDefaultActions: "true", cellAttributes: {alignment: 'center'}},
            {label: 'Quantity', fieldName: 'Quantity__c', type: 'text', hideDefaultActions: "true", iconName: 'utility:product_service_campaign', cellAttributes: {alignment: 'center'}},
            {label: 'Commodity', fieldName: 'FreightTM__Commodity__c', type: 'text', hideDefaultActions: "true", iconName: 'utility:price_book_entries', cellAttributes: {alignment: 'center'}},
            {label: 'Date Delivered', fieldName: 'FreightTM__Delivery_Arrival__c', type: 'date', hideDefaultActions: "true", iconName: 'utility:event', cellAttributes: {alignment: 'center'}, typeAttributes: {day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12:true}},
            {label: 'Invoice #', fieldName: 'Invoice__c', type: 'text', hideDefaultActions: "true", iconName: 'utility:product_workspace', cellAttributes: {alignment: 'center'}},
            {label: 'Rate', fieldName: 'FreightTM__Total_Rate_to_Carrier__c', type: 'currency', hideDefaultActions: "true", iconName: 'utility:money', cellAttributes: { alignment: 'center'}}
        ];

        cmp.set("v.columns", cols);
    },

    showRowDetails: function(cmp, row) {
        var updateEvent = $A.get("e.c:navEvent");
        updateEvent.setParams({"navItem": "load_detail", "recordId": row.Id});
        updateEvent.fire();
    }
})