({
    /*
	fetchFiles : function(cmp) {
		var r_ID = cmp.get("v.load.Id");
        var action = cmp.get("c.queryLoadFiles");
        action.setParams({"recordId" : r_ID});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if(state === "SUCCESS") {
                console.log("Successfully fetched load files...");
                cmp.set("v.relatedFiles", res.getReturnValue());
                var files = cmp.get("v.relatedFiles");
                console.log("RELATED FILES: ");
                console.log(files);
            }
        });
        $A.enqueueAction(action);
        
    }, */
    
    fetchDriverLoc : function(cmp) {
        var r_ID = cmp.get("v.load.Id");
        var action = cmp.get("c.getDriverLoc");
        action.setParams({"recordId" : r_ID});
        action.setCallback(this, function(res) {
            console.log("Successfully called back driver loc query");
            var state = res.getState();
            if(state === "SUCCESS") {
                cmp.set("v.driverLoc", res.getReturnValue());
                cmp.set('v.loadMarkers', [
                    {
                        location: {
                            Street: cmp.get("v.load.FreightTM__Pickup_Address__c"),
                            City: cmp.get("v.load.FreightTM__Pickup_City__c"),
                            State: cmp.get("v.load.FreightTM__Pickup_State__c")
                        },
                        icon: 'standard:product_service_campaign_item',
                        title: cmp.get("v.load.FreightTM__PickupFacility__r.Name"),
                        description: 'Pickup Location',
                       
                    },
                    {
                        location: {
                            Street: cmp.get("v.load.FreightTM__Delivery_Address__c"),
                            City: cmp.get("v.load.FreightTM__Delivery_City__c"),
                            State: cmp.get("v.load.FreightTM__Delivery_State__c")
                        },
                        icon: 'standard:service_territory_location',
                        title: cmp.get("v.load.FreightTM__DeliveryFacility__r.Name"),
                        description: 'Delivery Location',
                    },
                    {
                        location: {
                            Latitude: cmp.get("v.driverLoc.FreightTM__Coordinates__Latitude__s"),
                            Longitude: cmp.get("v.driverLoc.FreightTM__Coordinates__Longitude__s")
                        },
                        icon: 'custom:custom98',
                        title: cmp.get("v.load.Driver_Name__c"),
                        description: 'Driver Location',
                    }
                    
                ]);
                cmp.set('v.center', {
                    location: {
                        Latitude: cmp.get("v.driverLoc.FreightTM__Coordinates__Latitude__s"),
                        Longitude: cmp.get("v.driverLoc.FreightTM__Coordinates__Longitude__s")                    }
                });
            }
        });
        
        $A.enqueueAction(action);
    }
})