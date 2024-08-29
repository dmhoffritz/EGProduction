({
    refreshAttributes: function (cmp) {
        cmp.set("v.item", null);
        cmp.set("v.loadTemplates", null);
        cmp.set("v.jobDeliveries", null);
        cmp.set("v.jobPickups", null);
    },
    fetchItemData: function (cmp) {
        console.log("Fetching item data...");
        console.log("Fetching line item data for item w/ id: " + cmp.get("v.itemId"));
        let action = cmp.get("c.getItemData");
        action.setParams({
            "lineItemId": cmp.get("v.itemId")
        });
        action.setCallback(this, function (res) {
            console.log("Made getItemData Callback fcn...");
            let state = res.getState();
            if (state === "SUCCESS") {
                //store item data
                console.log("Successfully fetched item data!");
                let itemData = res.getReturnValue();
                console.log("RETRIEVED THE FOLLOWING ITEM DATA: ");
                console.log(itemData);
                console.log("ITEM DATA:");
                console.log(itemData.itemRef);
                cmp.set("v.item", itemData.itemRef);
                cmp.set("v.loadTemplates", itemData.loadTemplates);
                cmp.set("v.jobDeliveries", itemData.freightIn);
                cmp.set("v.jobPickups", itemData.freightOut);
                cmp.set("v.loadsLeapfrogged", itemData.leapfrogLoads);
                cmp.set("v.loadsDelivered", itemData.loadsDelivered);
                cmp.set("v.loadsPickedUp", itemData.loadsPickedUp);
                cmp.set("v.matsDelivered", itemData.matsDelivered);
                cmp.set("v.matsPickedUp", itemData.matsPickedUp);
                this.organizeData(cmp);
                this.analyzeProgress(cmp);
                this.organizeStatusSteps(cmp);
                cmp.set("v.spinnerToggle", false);
            } else if (state === "INCOMPLETE") {
                // handle incompletion
            } else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever fetching load data: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log("Unknown error whenever fetching item data");
            }
        });

        $A.enqueueAction(action);
    },

    organizeData: function (cmp, event, helper) {
        console.log("Organizing item/load data...");
        let templates = cmp.get("v.loadTemplates");
        let fIn = cmp.get("v.jobDeliveries");
        let fOut = cmp.get("v.jobPickups");
        let frogs = cmp.get("v.loadsLeapfrogged");
        console.log("Template data (BEFORE ORGANIZATION): ");
        console.log(templates);
        console.log("Freight In Data (BEFORE ORGANIZATION): ");
        console.log(fIn);
        console.log("Freight Out Data (BEFORE ORGANIZATION): ");
        console.log(fOut);
        if (templates != undefined) {
            for (let i = 0; i < templates.length; i++) {

                /*
                if (templates[i].FreightTM__PickupFacility__c == undefined) {
                    templates[i].pickupFacility = 'N/A';
                    templates[i].pickupFacilityLink = '#';
                } else {
                    console.log("PICKUP FACILITY: ");
                    templates[i].pickupFacility = templates[i].FreightTM__PickupFacility__r.Name;
                    templates[i].pickupFacilityLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Facility__c/' + templates[i].FreightTM__PickupFacility__r.Id + '/view';
                }

                if (templates[i].FreightTM__DeliveryFacility__c == undefined) {
                    templates[i].deliveryFacility = 'N/A';
                    templates[i].deliveryFacilityLink = '#';
                } else {
                    templates[i].deliveryFacility = templates[i].FreightTM__DeliveryFacility__r.Name;
                    templates[i].deliveryFacilityLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Facility__c/' + templates[i].FreightTM__DeliveryFacility__r.Id + '/view';
                }
                */
                templates[i].recordLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Load__c/' + templates[i].Id + '/view';
            }
        } else {
            templates = [];
        }
        if (fIn != undefined) {
            for (let i = 0; i < fIn.length; i++) {
                if (fIn[i].FreightTM__PickupFacility__c == undefined) {
                    fIn[i].pickupFacility = 'N/A';
                    fIn[i].pickupFacilityLink = '#';
                } else {
                    fIn[i].pickupFacility = fIn[i].FreightTM__PickupFacility__r.Name;
                    fIn[i].pickupFacilityLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Facility__c/' + fIn[i].FreightTM__PickupFacility__r.Id + '/view';
                }

                if (fIn[i].FreightTM__DeliveryFacility__c == undefined) {
                    fIn[i].deliveryFacility = 'N/A';
                    fIn[i].deliveryFacilityLink = '#';
                } else {
                    fIn[i].deliveryFacility = fIn[i].FreightTM__DeliveryFacility__r.Name;
                    fIn[i].deliveryFacilityLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Facility__c/' + fIn[i].FreightTM__DeliveryFacility__r.Id + '/view';
                }
                fIn[i].recordLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Load__c/' + fIn[i].Id + '/view';
            }
        } else {
            fIn = [];
        }
        if (fOut != undefined) {
            for (let i = 0; i < fOut.length; i++) {
                if (fOut[i].FreightTM__PickupFacility__c == undefined) {
                    fOut[i].pickupFacility = 'N/A';
                    fOut[i].pickupFacilityLink = '#';
                } else {
                    fOut[i].pickupFacility = fOut[i].FreightTM__PickupFacility__r.Name;
                    fOut[i].pickupFacilityLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Facility__c/' + fOut[i].FreightTM__PickupFacility__r.Id + '/view';
                }

                if (fOut[i].FreightTM__DeliveryFacility__c == undefined) {
                    fOut[i].deliveryFacility = 'N/A';
                    fOut[i].deliveryFacilityLink = '#';
                } else {
                    fOut[i].deliveryFacility = fOut[i].FreightTM__DeliveryFacility__r.Name;
                    fOut[i].deliveryFacilityLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Facility__c/' + fOut[i].FreightTM__DeliveryFacility__r.Id + '/view';
                }
                fOut[i].recordLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Load__c/' + fOut[i].Id + '/view';
            }
        } else {
            fOut = [];
        }
        if (frogs != undefined) {
            for (let i = 0; i < frogs.length; i++) {
                if (frogs[i].FreightTM__PickupFacility__c == undefined) {
                    frogs[i].pickupFacility = 'N/A';
                    frogs[i].pickupFacilityLink = '#';
                } else {
                    frogs[i].pickupFacility = frogs[i].FreightTM__PickupFacility__r.Name;
                    frogs[i].pickupFacilityLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Facility__c/' + frogs[i].FreightTM__PickupFacility__r.Id + '/view';
                }

                if (frogs[i].FreightTM__DeliveryFacility__c == undefined) {
                    frogs[i].deliveryFacility = 'N/A';
                    frogs[i].deliveryFacilityLink = '#';
                } else {
                    frogs[i].deliveryFacility = frogs[i].FreightTM__DeliveryFacility__r.Name;
                    frogs[i].deliveryFacilityLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Facility__c/' + frogs[i].FreightTM__DeliveryFacility__r.Id + '/view';
                }
                frogs[i].recordLink = 'https://yourempiregroup.lightning.force.com/lightning/r/FreightTM__Load__c/' + frogs[i].Id + '/view';
            }
        } else {
            frogs = [];
        }
        console.log("Template Data (AFTER ORGANIZATION): ");
        console.log(templates);
        console.log("Delivery Data (AFTER ORGANIZATION): ");
        console.log(fIn);
        console.log("Pickup Data (AFTER ORGANIZATION): ");
        console.log(fOut);
        console.log("Leapfrog Data (AFTER ORGANIZATION): ");
        console.log(frogs);
        cmp.set("v.lTemplates", templates);
        cmp.set("v.jDeliveries", fIn);
        cmp.set("v.jPickups", fOut);
        cmp.set("v.loadsLeapfrogged", frogs);
        let actions = [
            {
                label: 'Clone',
                name: 'clone'
            },
            {
                label: 'Edit',
                name: 'edit'
            },
            {
                label: 'Delete',
                name: 'remove'
            }
        ];
        let activeActions = [
            {
                label: 'Delete',
                name: 'remove'
            }
        ];
        cmp.set("v.templateColumns", [
            {
                label: 'Load #',
                fieldName: 'recordLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'Name'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Origin --> Destination',
                fieldName: 'FreightTM__Calendar_Load__c',
                type: 'text'
            },
            {
                label: 'Pickup By',
                fieldName: 'Pickup_By__c',
                type: 'date',
                typeAttributes:{
                    year: "2-digit",
                    month: "2-digit",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit"
                },
                editable: true
            },
            {
                label: 'Deliver By',
                fieldName: 'Deliver_By__c',
                type: 'date',
                typeAttributes:{
                    year: "2-digit",
                    month: "2-digit",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit"
                },
                editable: true
            },
            {
                label: 'Qty',
                fieldName: 'Quantity__c',
                type: 'number',
                initialWidth: 75
            },
            {
                type: 'action',
                typeAttributes:
                {
                    rowActions: actions
                },
                wrapText: true,
                cellAttributes:
                {
                    class: 'tableAction'
                }
            }
        ]);
        cmp.set("v.deliveryColumns", [
            {
                label: 'Load #',
                fieldName: 'recordLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'Name'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Status',
                fieldName: 'FreightTM__Status__c',
                type: 'text'
            },
            {
                label: 'Sourcing Location',
                fieldName: 'pickupFacilityLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'pickupFacility'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Delivery Location',
                fieldName: 'deliveryFacilityLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'deliveryFacility'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Qty',
                fieldName: 'Quantity__c',
                type: 'text',
                initialWidth: 75
            },
            {
                label: 'Deliver By',
                fieldName: 'Deliver_By__c',
                type: 'date'
            },
            {
                type: 'action',
                typeAttributes:
                {
                    rowActions: activeActions
                },
                wrapText: true,
                cellAttributes:
                {
                    class: 'tableAction'
                }
            }
        ]);
        cmp.set("v.pickupColumns", [
            {
                label: 'Load #',
                fieldName: 'recordLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'Name'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Status',
                fieldName: 'FreightTM__Status__c',
                type: 'text'
            },
            {
                label: 'Sourcing Location',
                fieldName: 'pickupFacilityLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'pickupFacility'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Delivery Location',
                fieldName: 'deliveryFacilityLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'deliveryFacility'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Qty',
                fieldName: 'Quantity__c',
                type: 'text',
                initialWidth: 75
            },
            {
                label: 'Pickup By',
                fieldName: 'Pickup_By__c',
                type: 'date'
            },
            {
                type: 'action',
                typeAttributes:
                {
                    rowActions: activeActions
                },
                wrapText: true,
                cellAttributes:
                {
                    class: 'tableAction'
                }
            }
        ]);
        cmp.set("v.leapfrogColumns", [
            {
                label: 'Load #',
                fieldName: 'recordLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'Name'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Status',
                fieldName: 'FreightTM__Status__c',
                type: 'text'
            },
            {
                label: 'Sourcing Location',
                fieldName: 'pickupFacilityLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'pickupFacility'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Delivery Location',
                fieldName: 'deliveryFacilityLink',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'deliveryFacility'
                    },
                    target: '_blank'
                }
            },
            {
                label: 'Qty',
                fieldName: 'Quantity__c',
                type: 'text',
                initialWidth: 75
            },
            {
                label: 'Pickup By',
                fieldName: 'Pickup_By__c',
                type: 'date'
            },
            {
                label: 'Deliver By',
                fieldName: 'Deliver_By__c',
                type: 'date'
            },
            {
                type: 'action',
                typeAttributes:
                {
                    rowActions: activeActions
                },
                wrapText: true,
                cellAttributes:
                {
                    class: 'tableAction'
                }
            }
        ]);
        cmp.set("v.initialized", true);
    },

    analyzeProgress: function (cmp, event, helper) {
        let matsIn = cmp.get("v.matsDelivered");
        let matsOrdered = cmp.get("v.item.Quantity");

        let percentDiff_FreightIn = (matsIn / matsOrdered) * 100;
        if (percentDiff_FreightIn > 100) {
            percentDiff_FreightIn = 100;
        }
        percentDiff_FreightIn = Math.round(percentDiff_FreightIn);
        cmp.set("v.freightInProgress", percentDiff_FreightIn);

        let matsOut = cmp.get("v.matsPickedUp");
        let percentDiff_FreightOut = (matsOut / matsIn) * 100;
        if (percentDiff_FreightOut > 100) {
            percentDiff_FreightOut = 100;
        } else if (matsIn == 0) {
            percentDiff_FreightOut = 0;
        }
        percentDiff_FreightOut = Math.round(percentDiff_FreightOut);
        cmp.set("v.freightOutProgress", percentDiff_FreightOut);
        //here we will show the progress of pickups and deliveries
        console.log("PROGRESS ANALYZED...");
        console.log("FREIGHT IN PROGRESS: " + percentDiff_FreightIn);
        console.log("FREIGHT OUT PROGRESS: " + percentDiff_FreightOut);
    },

    organizeStatusSteps: function (cmp, event, helper) {
        cmp.set('v.itemSteps', [
            {
                label: 'New',
                value: 'New'
            },
            {
                label: 'Delivery In Progress',
                value: 'Delivery In Progress'
            },
            {
                label: 'Fulfilled',
                value: 'Fulfilled'
            },
            {
                label: 'Pickup In Progress',
                value: 'Pickup_In_Progress'
            },
            {
                label: 'Completed',
                value: 'Completed'
            },
            {
                label: 'Canceled',
                value: 'Canceled'
            }
        ]);
    },

    changeItemStatus: function (cmp, status) {
        let action = cmp.get("c.updateItemStatus");
        action.setParams(
            {
                "itemId": cmp.get("v.itemId"),
                "itemStatus": status
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                this.fetchItemData(cmp);
            } else if (state === "INCOMPLETE") {
                //handle incompletion
            } else if (state === "ERROR") {
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Unable to update item status: " + errors[0].message);
                    } else {
                        console.log("Unknown error occurred");
                    }
                } else {
                    console.log("Uknown error occurred");
                }
            }
        });

        $A.enqueueAction(action);
    },

    updateLoads: function (cmp, draftValues, helper) {
        cmp.set("v.spinnerToggle", true);
        console.log('Updating the following loads: ');
        console.log(draftValues);
        let action = cmp.get("c.updateLoads");
        console.log('Action initialized');
        action.setParams(
            {
                "loadsToUpdate": draftValues
            }
        );
        console.log('Paramaters initialized');
        action.setCallback(this, function (res) {
            let state = res.getState();
            console.log('Received callback from action');
            if (state === "SUCCESS") {
                console.log("Successfully updated loads!");
                cmp.set("v.errors", []);
                cmp.set("v.draftValues", []);
                helper.refreshAttributes(cmp);
                helper.fetchItemData(cmp);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Load Template updated"
                });
                toastEvent.fire();
            } else if (state === "ERROR") {
                console.log("ERROR WHENEVER UPDATING LOAD DATA:");
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever saving draft values: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }

            } else {
                console.log('Unknown error occurred whenever updating loads...');
            }
            cmp.set("v.spinnerToggle", false);
        });

        $A.enqueueAction(action);
    },

    editLoad: function (cmp, recId) {
        //display lightning record edit form
        console.log("Editing Load Data...");
        let editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recId
        });
        editRecordEvent.fire();
    },

    removeItem: function (cmp, recId) {
        console.log("Deleting item w ID: " + recId);
        let action = cmp.get("c.deleteItem");
        action.setParams(
            {
                "itemId": recId
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                let updateEvent = $A.get("e.c:flowFinished");
                updateEvent.fire();
            } else if (state === "INCOMPLETE") {
                //do something
            } else if (state === "ERROR") {
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever deleting Sales Order Item: " + errors[0].message);
                    }
                }
            } else {
                console.log("Unknown error whenever removing Sales Order Item");
            }
        });

        $A.enqueueAction(action);
    },

    removeLoad: function (cmp, recId) {
        console.log("Deleting load w ID: " + recId);
        let action = cmp.get("c.deleteLoad");
        action.setParams(
            {
                "loadId": recId
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                console.log("Successfully removed load...");
                this.fetchItemData(cmp);
            } else if (state === "INCOMPLETE") {
                //do something
            } else if (state === "ERROR") {
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever deleting Load: " + errors[0].message);
                    }
                }
            } else {
                console.log("Unknown error whenever removing Load");
            }
        });

        $A.enqueueAction(action);
    }
})