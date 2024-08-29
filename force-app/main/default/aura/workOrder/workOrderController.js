({
    init: function (cmp, event, helper) {
        console.log("Receiving Job w/ ID: " + cmp.get("v.recordId"));
        helper.organizeData(cmp);
        let poNum = cmp.get("v.order.Purchase_Order_Number__c");
        if (poNum) {
            cmp.set("v.orderNum", poNum);
        } else {
            cmp.set("v.orderNum", cmp.get("v.order.WorkOrderNumber"));
        }
        helper.organizeStatusBadge(cmp);

        var formFactor = $A.get("$Browser.formFactor");
        if (formFactor === "PHONE" || formFactor === "TABLET") {
            cmp.set("v.tileSize", "12");
        } else {
            cmp.set("v.tileSize", "6");
        }
        //helper.organizeColumns(cmp);
    },

    refreshData: function (cmp, evt, helper) {
        helper.getOrder(cmp, helper);
    },

    addNewItem: function (cmp, event, helper) {
        let recId = event.getSource().get("v.name");
        console.log("Adding new Item to record w/ ID: " + recId);
        cmp.set("v.modalHeader", cmp.get("v.orderNum") + " - New Sales Order Line Item");
        helper.executeFlow(cmp, recId, "New_Sales_Order_Item_V2");
        /*
        let createItemEvent = $A.get("e.force:createRecord");
        createItemEvent.setParams({
            "entityApiName": "WorkOrderLineItem",
            "defaultFieldValues": {
                'WorkOrderId': recId,
                'Job__c': cmp.get("v.jobId")
            }
        });
        createItemEvent.fire();
        */
    },

    updateOrderStatus: function (cmp, event, helper) {
        let recId = event.getSource().get("v.name");
        cmp.set("v.modalHeader", cmp.get("v.orderNum") + ' - Update Status');
        helper.executeFlow(cmp, recId, "Sales_Order_Update_Status");
    },

    handleStatusChange: function (cmp, event, helper) {
        if (event.getParam("status") === "FINISHED") {
            cmp.set("v.displayFlow", false);
            helper.getOrder(cmp, helper);

        }
    },

    bookNewLoad: function (cmp, event, helper) {
        console.log('Starting new load template flow w/ the following order id: ');
        console.log(cmp.get("v.order.Id"));
        let orderId = cmp.get("v.order.Id");
        cmp.set("v.modalHeader", cmp.get("v.orderNum") + " - New Load Template");
        cmp.set("v.displayFlow", true);
        let flow = cmp.find("flowData");
        let inputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: orderId
            }
        ];
        flow.startFlow('Sales_Orders_Create_Load_Template_Action', inputVariables);
    },

    handleNavSelection: function (cmp, event, helper) {
        console.log("Selected the following nav item: " + event.getParam('name'));
        let items = event.getParam('name');
        if (items == 'purchase') {
            cmp.set("v.activeItems", cmp.get("v.purchaseItems"));
        } else if (items == 'lease') {
            cmp.set("v.activeItems", cmp.get("v.leaseItems"));
        } else if (items == 'rental') {
            cmp.set("v.activeItems", cmp.get("v.rentalItems"));
        } else if (items == 'service') {
            cmp.set("v.activeItems", cmp.get("v.serviceItems"));
        } else {
            console.log("Unknown order nav item returned...");
        }
    },

    closeModal: function (cmp, event, helper) {
        cmp.set("v.displayFlow", false);
    }
})