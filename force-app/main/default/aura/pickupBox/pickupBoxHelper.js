({
    organizeMap: function (cmp) {

        let markerDescription = '<p>' + cmp.get("v.instructions")  + '</p>'; 
        cmp.set("v.mapMarkers", [
            {
                location: {
                    Street: cmp.get("v.street"),
                    City: cmp.get("v.city"),
                    State: cmp.get("v.state")
                },
                value: 'pickupLocation',
                title: cmp.get("v.location"),
                description: markerDescription
            }
        ]);
    },

    organizeButtons: function (cmp) {
        let status = cmp.get("v.loadStatus");
        let locType = cmp.get("v.locationType");
        let signature = cmp.get("v.contactSignature");
        if (locType == 'Pickup') {
            if (signature == null) {
                if (status == 'Arrived for pickup' || status == 'Loaded in Transit' || status == 'Arrived for delivery' || status == 'Delivered') {
                    cmp.set("v.buttonLabel", "Click here to obtain pickup contact signature");
                    cmp.set("v.buttonIcon", "utility:signature");
                    cmp.set("v.statusAction", false);
                    cmp.set("v.signatureAction", true);
                    cmp.set("v.buttonCSS", "pickupSignatureButton");
                } else {
                    cmp.set("v.buttonLabel", "Arrived for Pickup");
                    cmp.set("v.buttonIcon", "");
                    cmp.set("v.statusAction", true);
                    cmp.set("v.signatureAction", false);
                    cmp.set("v.buttonCSS", "statusButton");
                }
            } else {
                cmp.set("v.statusAction", true);
                cmp.set("v.signatureAction", false);
                cmp.set("v.disableButton", true);
                cmp.set("v.buttonLabel", "Successfully stored pickup signature");
                cmp.set("v.buttonIcon", "utility:check");
                
            }
        } else if (locType == 'Delivery') {
            if (signature == null) {
                if (status == 'Arrived for delivery') {
                    cmp.set("v.buttonLabel", "Click here to obtain delivery contact signature");
                    cmp.set("v.buttonIcon", "utility:signature");
                    cmp.set("v.statusAction", false);
                    cmp.set("v.signatureAction", true);
                    cmp.set("v.buttonCSS", "deliverySignatureButton");
                } else {
                    cmp.set("v.buttonLabel", "Arrived for Delivery");
                    cmp.set("v.buttonIcon", "");
                    cmp.set("v.statusAction", true);
                    cmp.set("v.signatureAction", false);
                    cmp.set("v.buttonCSS", "statusButton");
                    if (status != 'Loaded In Transit') {
                        cmp.set("v.disableButton", true);
                    }
                }
            } else {
                cmp.set("v.statusAction", true);
                cmp.set("v.signatureAction", false);
                cmp.set("v.disableButton", true);
                cmp.set("v.buttonLabel", "Successfully stored delivery signature");
                cmp.set("v.buttonIcon", "utility:check");
            }
        }

    },

    organizeModal : function(cmp) {
        let lType = cmp.get("v.locationType");
        let status = cmp.get("v.loadStatus");
        let signature = cmp.get("v.contactSignature");

        if (lType == "Pickup") {
            if (status == 'Arrived for pickup' && signature == null) {
                cmp.set("v.showModal", true);
            }
        } else if (lType == "Delivery") {
            if (status == 'Arrived for delivery' && signature == null) {
                cmp.set("v.showModal", true);
            }
        }
        
    },

    updateStatus: function (cmp, evt) {
        this.showSpinner(cmp, evt);
        let lType = cmp.get("v.locationType");
        let loadStatus = '';
        if (lType == 'Pickup') {
            loadStatus = 'Arrived for pickup';
        } else if (lType == 'Delivery') {
            loadStatus = 'Arrived for delivery';
        }
        console.log("Updating load status to: " + loadStatus);
        console.log("Updating load w/ ID: " + cmp.get("v.loadId"));
        let action = cmp.get("c.updateLoadStatus");
        action.setParams(
            {
                "recordId": cmp.get("v.loadId"),
                "status": loadStatus
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                //fire event to update load data
                this.hideSpinner(cmp, evt);

            } else if (state === "INCOMPLETE") {
                //handle incompletion
            } else if (state === "ERROR") {
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error occurred whenever updating load's status: " + errors[0].message);
                    }
                }
            } else {
                console.log("Unknown error occurerd whenever updating load's status");
            }
        });

        $A.enqueueAction(action);
    },

    showSpinner: function (cmp, evt) {
        let updatingEvent = $A.get("e.c:loadUpdating");
        updatingEvent.fire();
    },

    hideSpinner: function (cmp, evt) {
        let updatedEvent = $A.get("e.c:loadUpdated");
        updatedEvent.fire();
    }
    
})