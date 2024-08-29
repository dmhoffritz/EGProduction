({
    init: function (cmp, event, helper) {
        helper.styleData(cmp);
        helper.setColumns(cmp);
    },

    handleRowAction: function(cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                console.log("Showing details for load w/ id: " + row.Id);
                helper.showRowDetails(cmp, row);
                break;
            case 'view':
                helper.showRowDetails(cmp, row);
                break;
            case 'view_rateCon':
                cmp.set("v.displaySuccess", false);
                helper.signRateCon(cmp, row);
                break;
            case 'view_bol':
                cmp.set("v.displaySuccess", false);
                helper.viewBOL(cmp, row);
                break;
        }
    },
    
    handleSaveEdition: function (cmp, event, helper) {
        cmp.set("v.isLoading", true);
        console.log("Edit details: ");
        console.log(JSON.parse(JSON.stringify(event)));
        var draftValues = event.getParam('draftValues');
        console.log("Editing following draft values: ");
        console.log(draftValues);
        /*
        let recordIds = [];
        let driverNames = [];
        let driverPhones = [];
        for (var i = 0; i < draftValues.length; i++) {
            recordIds.push(draftValues[i].Id);
            if (draftValues[i].Driver_Name__c) {
                driverNames.push(draftValues[i].Driver_Name__c);
            } else {
                driverNames.push('No Change');
            }
            if (draftValues[i].Driver_Phone__c) {
                driverPhones.push(draftValues[i].Driver_Phone__c);
            } else {
                driverPhones.push('No Change');
            }
        }
        */
        var action=cmp.get("c.updateLoads");
        action.setParams(
            {
                "loadsToUpdate" : draftValues
            }
        );
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("SUCCESSFULLY SAVED RECORDS");
                cmp.set('v.displaySuccess', true);
                cmp.set('v.errors', []);
                cmp.set('v.draftValues', []);
                helper.getData(cmp);
            }
            
            else if (state === "ERROR") {
                console.log("ERROR WHEN SAVING DRAFT VALUES");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error Whenever Saving Draft Values: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                cmp.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    handleCancelEdition: function (cmp) {
        // do nothing for now...
    },
    
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = cmp.get("v.sortedDirection");
        
        if (sortDirection == 'asc') {
            sortDirection = 'desc';
        } else {
            sortDirection = 'asc';
        }
        
        console.log("Sort By: " + fieldName);
        console.log("Sort Direction: " + sortDirection);
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    
    closeToast: function(cmp) {
        cmp.set("v.displaySuccess", false);
    },
    
    closeModal : function(cmp, event, helper) {
        cmp.set("v.displayForm", false);
        let evt = $A.get("e.c:onsave");
        evt.fire();
    }
});