({
    init : function(cmp, event, helper) {
        console.log("Initializing Record Info");
        helper.fetchDriverLoc(cmp);
        console.log("Driver location should be stored");

        
        cmp.set('v.center', {
            location: {
                Street: cmp.get("v.load.FreightTM__Pickup_Address__c"),
                City: cmp.get("v.load.FreightTM__Pickup_City__c"),
                State: cmp.get("v.load.FreightTM__Pickup_State__c")
            }
        });

        cmp.set('v.pickupMarkers', [
            {
                location: {
                    Street: cmp.get("v.load.FreightTM__Pickup_Address__c"),
                    City: cmp.get("v.load.FreightTM__Pickup_City__c"),
                    State: cmp.get("v.load.FreightTM__Pickup_State__c")
                },
                
                title: cmp.get("v.load.FreightTM__PickupFacility__r.Name"),
                description: 'Pickup Location',
            }
        ]);
        cmp.set('v.deliveryMarkers', [
            {
                location: {
                    Street: cmp.get("v.load.FreightTM__Delivery_Address__c"),
                    City: cmp.get("v.load.FreightTM__Delivery_City__c"),
                    State: cmp.get("v.load.FreightTM__Delivery_State__c")
                },
                
                title: cmp.get("v.load.FreightTM__DeliveryFacility__r.Name"),
                description: 'Delivery Location',
                mapIcon: {
                    fillColor: 'green'
                }
            }
        ]);
        //helper.fetchFiles(cmp);
    },
    
    toggleLoad : function(cmp, event) {
        cmp.set("v.loadToggle", true);
        cmp.set("v.locationToggle", false);
        cmp.set("v.billingToggle", false);
        cmp.set("v.fileToggle", false);
    },
    
    toggleLocation : function(cmp, event) {
        cmp.set("v.loadToggle", false);
        cmp.set("v.locationToggle", true);
        cmp.set("v.billingToggle", false);
        cmp.set("v.fileToggle", false);
    },
    
    toggleBilling : function(cmp, event) {
        cmp.set("v.loadToggle", false);
        cmp.set("v.locationToggle", false);
        cmp.set("v.billingToggle", true);
        cmp.set("v.fileToggle", false);
    },
    
    toggleFiles : function(cmp, event) {
        cmp.set("v.loadToggle", false);
        cmp.set("v.locationToggle", false);
        cmp.set("v.billingToggle", false);
        cmp.set("v.fileToggle", true);
    }
})