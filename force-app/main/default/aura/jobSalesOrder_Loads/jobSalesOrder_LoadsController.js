({
    init: function (cmp, event, helper) {
        cmp.set("v.spinnerToggle", true);
        console.log("Load List initialized...");
        console.log("FOUND ITEM W/ ID IN LOAD LIST CMP: " + cmp.get("v.itemId"));
        cmp.set("v.initialized", false);
        helper.refreshAttributes(cmp);
        helper.fetchItemData(cmp);
    },

    goBack: function (cmp, event, helper) {
        console.log("Going back...");
        let evt = $A.get("e.c:navSalesOrder");
        evt.setParams({
            'navTo': 'orders'
        });
        evt.fire();
    },

    createLoadTemplate: function (cmp, event, helper) {
        //call flow to create load template
        console.log("Creating new load template...");
        cmp.set("v.displayFlow", true);
        let flow = cmp.find("flowData");
        let inputVar = [
            {
                name: 'recordId',
                type: 'String',
                value: cmp.get("v.itemId")
            }
        ]
        console.log("Inputting item w/ ID: " + cmp.get("v.itemId") + ' into new load template flow');
        cmp.set("v.flowTitle", cmp.get("v.item.LineItemNumber") + " - New Load Template");
        flow.startFlow("Job_TEST_NEW_LOAD_TEMPLATE", inputVar);
    },

    editItem: function (cmp, event, helper) {
        //display lightning record edit form
        console.log("Editing Item Data...");
        let editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": cmp.get("v.itemId")
        });
        editRecordEvent.fire();
    },

    handleStatusChange: function (cmp, event, helper) {
        //handle flow status change
        if (event.getParam("status") === "FINISHED") {
            /*
            let outputVariables = event.getParam("outputVariables");
            if (outputVariables == null) {
                let outputVar;
                for (let i = 0; i < outputVariables.length; i++) {
                    outputVar = outputVariables[i];
                }
            } 
            */
            cmp.set("v.displayFlow", false);
            helper.fetchItemData(cmp);
        }
    },

    closeModal: function (cmp, event, helper) {
        cmp.set("v.displayFlow", false);
    },

    remove: function (cmp, event, helper) {
        //call apex action to remove item
        helper.removeItem(cmp, cmp.get("v.itemId"));
    },

    handleSelect: function (cmp, event, helper) {
        let stepName = event.getParam("detail").value;
        helper.changeItemStatus(cmp, stepName);
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Item status updated to " + stepName
        });
        toastEvent.fire();
    },

    handleSaveEdition: function (cmp, event, helper) {
        let draftValues = event.getParam('draftValues');
        helper.updateLoads(cmp, draftValues, helper);
    },

    handleRowAction: function (cmp, event, helper) {
        //execute lone clone here
        console.log("Handling row action...");
        let action = event.getParam('action');
        let row = event.getParam('row');
        console.log("Load ID: " + row.Id);
        console.log("Performing action w/ Name: " + action.name);
        if (action.name == 'clone') {
            
            console.log("Cloning load template...");
            cmp.set("v.displayFlow", true);
            let flow = cmp.find("flowData");
            let inputVar = [
                {
                    name: 'recordId',
                    type: 'String',
                    value: row.Id
                }
            ]
            console.log("Inputting load w/ ID: " + row.Id + ' into load clone flow');
            cmp.set("v.flowTitle", row.Name + " - Clone Loads");
            flow.startFlow("Create_Duplicate_Load_Records_v2", inputVar);
        } else if (action.name == 'remove') {
            console.log("SWAPPED TO REMOVE ACTION CASE");
            helper.removeLoad(cmp, row.Id);
        } else if (action.name == 'edit') {
            console.log("Trigger load record edit");
            helper.editLoad(cmp, row.Id);
        }

    },

    showSpinner: function (cmp, event, helper) {
        //cmp.set("v.spinnerToggle", true);
    },

    hideSpinner: function (cmp, event, helper) {
        //cmp.set("v.spinnerToggle", false);
    }
})