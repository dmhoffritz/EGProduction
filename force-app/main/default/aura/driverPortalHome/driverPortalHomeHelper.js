({
    fetchLoadData : function(cmp, event) {
        console.log("Fetching load data...");
        let action = cmp.get("c.getLoadData");
        action.setParams(
            {
                "recordId": cmp.get("v.loadId")
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                console.log("SUCCESSFULLY FETCHED THE FOLLOWING LOAD DATA: ");
                console.log(res.getReturnValue());
                cmp.set("v.load", res.getReturnValue());
                cmp.set("v.initialized", true);
                cmp.set("v.showSpinner", false);
                this.organizeDriverContactInfo(cmp);
                this.checkDriverSignature(cmp);
            } else if (state === "INCOMPLETE") {
                //handle incompletion
            } else if (state === "ERROR") {
                let error = res.getErrors();
                if (error) {
                    if (error[0] && error[0].message) {
                        console.log("Error whenever fetching load data " + error[0].message);
                    }
                }
            } else {
                console.log("Unknown error occurred whenever fetching load data");
            }
        });

        $A.enqueueAction(action);
    },

    checkDriverSignature : function(cmp) {
        let loadRecord = cmp.get("v.load");
        let status = loadRecord.FreightTM__Status__c;
        let driverSignature = loadRecord.Pickup_Signature__c;
        if (driverSignature == null || driverSignature == undefined) {
            cmp.set("v.needDriverSign", true);
        }
    },

    organizeDriverContactInfo: function (cmp) {
        var carrier = cmp.get("v.load.FreightTM__Carrier_Obj__r.Name");
        var contact;
        var cell;
        if (carrier.includes("Brothers Logistics")) {
            contact = cmp.get("v.load.Dispatcher_Carrier__c");
            cell = cmp.get("v.load.Carrier_Phone__c");
        } else {
            contact = cmp.get("v.load.FreightTM__Dispatch__r.Name");
            cell = cmp.get("v.load.FreightTM__Dispatch__r.MobilePhone");
        }
        
        console.log("Using following phone #: " + cell);

        cmp.set("v.driverContact", contact);
        cmp.set("v.driverContactCell", cell);
    }
})