({
    init: function (cmp, event, helper) {
        cmp.set("v.spinner", true);
        console.log("Initializing sales order component...");
        console.log("Receiving Job w/ ID: " + cmp.get("v.recordId"));
        helper.fetchOrders(cmp);
    },

    newOrder: function (cmp, event, helper) {
        let jobId = cmp.get("v.recordId");
        cmp.set("v.showModal", true);
        let flow = cmp.find("orderFlow");
        let inputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: jobId
            }
        ];
        flow.startFlow("Job_Create_New_Sales_Order", inputVariables);
        /*
        let flowURL = "https://yourempiregroup--soprep.sandbox.lightning.force.com/flow/Job_Create_New_Sales_Order?recordId=" + jobId;
        window.open(flowURL);
        */
    },

    closeModal: function (cmp, event, helper) {
        cmp.set("v.showModal", false);
    },

    handleStatusChange: function (cmp, event, helper) {
        if (event.getParam("status") === "FINISHED") {
            cmp.set("v.showModal", false);
            let updateEvent = $A.get("e.c:flowFinished");
            updateEvent.fire();

        }
    },

    flowStatusChange: function (cmp, event, helper) {
        if (event.getParam("status") === "FINISHED") {
            let outputVar = event.getParam("outputVariables");
            if (outputVar != null) {
                let outputVariable;
                for (let i = 0; i < outputVar.length; i++) {
                    outputVariable = outputVar[i];
                }
            }

            helper.fetchOrders(cmp);
        }
    },

    showSpinner: function (cmp, event, helper) {
        //cmp.set("v.spinner", true);
    },

    hideSpinner: function (cmp, event, helper) {
        //cmp.set("v.spinner", false);
    }
})