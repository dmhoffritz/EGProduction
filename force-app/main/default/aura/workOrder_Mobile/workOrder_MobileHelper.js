({
    getOrder: function (cmp, helper) {
        cmp.set("v.showSpinner", true);
        let action = cmp.get("c.getOrder");
        action.setParams(
            {
                "orderId": cmp.get("v.order.Id")
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                console.log("Sucessfully refreshed order: ");
                console.log(res.getReturnValue());
                cmp.set("v.order", res.getReturnValue());
                helper.organizeData(cmp);
                helper.organizeStatusBadge(cmp);
                cmp.set("v.showSpinner", false);
            } else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE APEX ACTION...");
                cmp.set("v.showSpinner", false);
            } else if (state === "ERROR") {
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error refreshing order: " + errors[0].message);
                    }
                }
                cmp.set("v.showSpinner", false);
            } else {
                console.log("Unknown error when refreshing order...");
                cmp.set("v.showSpinner", false);
            }
        });

        $A.enqueueAction(action);
    },
    organizeData: function (cmp) {
        console.log("Organizing order data...");
        let itemData = cmp.get("v.order.WorkOrderLineItems");
        cmp.set("v.allItems", itemData);
        console.log("Order items (BEFORE ORGANIZATION): ");
        console.log(itemData);
        let purchases = [];
        let purchaseQty = 0;
        let leases = [];
        let leaseQty = 0;
        let rentals = [];
        let rentalQty = 0;
        let services = [];
        let serviceQty = 0;

        if (itemData != undefined) {
            for (let i = 0; i < itemData.length; i++) {
                if (itemData[i].Product__r.Family == 'Mat Sales') {
                    if (itemData[i].Sell_Type__c == 'Purchase') {
                        purchases.push(itemData[i]);
                        purchaseQty++;
                    } else if (itemData[i].Sell_Type__c == 'Lease') {
                        leases.push(itemData[i]);
                        leaseQty++;
                    } else if (itemData[i].Sell_Type__c == 'Rental') {
                        rentals.push(itemData[i]);
                        rentalQty++;
                    } else {

                    }

                } else if (itemData[i].Product__r.Family == 'Services' || itemData[i].Product__r.Family == 'Equipment') {
                    services.push(itemData[i]);
                    serviceQty++;
                }
            }
            console.log("JS Purchases: ");
            console.log(purchases);
            console.log("JS Leases: ");
            console.log(leases);
            console.log("JS Rentals: ");
            console.log(rentals);
            cmp.set("v.purchaseItems", purchases);
            cmp.set("v.purchaseQuantity", purchaseQty);
            cmp.set("v.leaseItems", leases);
            cmp.set("v.leaseQuantity", leaseQty);
            cmp.set("v.rentalItems", rentals);
            cmp.set("v.rentalQuantity", rentalQty);
            cmp.set("v.serviceItems", services);
            cmp.set("v.serviceQuantity", serviceQty);


            //let allItemQty = purchaseQty + leaseQty + rentalQty + serviceQty;
            //cmp.set("v.allItemQuantity", allItemQty);

            let selection = cmp.get("v.selectedItem");
            if (selection == 'purchase') {
                cmp.set("v.activeItems", purchases);
            } else if (selection == 'lease') {
                cmp.set("v.activeItems", leases);
            } else if (selection == 'rental') {
                cmp.set("v.activeItems", rentals);
            } else if (selection == 'service') {
                cmp.set("v.activeItems", services);
            } else {
                cmp.set("v.activeItems", purchases);
            }

            console.log("Purchase Data: ");
            console.log(cmp.get("v.purchaseItems"));
            console.log("Lease Items: ");
            console.log(cmp.get("v.leaseItems"));
            console.log("Rental Data: ");
            console.log(cmp.get("v.rentalItems"));
            console.log("Service Data: ");
            console.log(cmp.get("v.serviceItems"));

        }
    },

    organizeStatusBadge: function (cmp) {
        let cmpTarget = cmp.find('orderStatusBadge');
        let status = cmp.get("v.order.Status");
        if (status == 'Canceled') {
            $A.util.addClass(cmpTarget, 'redBadge');
        } else if (status == 'New' || status == 'In Progress' || status == 'On Hold') {
            $A.util.addClass(cmpTarget, 'yellowBadge');
        } else if (status == 'Completed') {
            $A.util.addClass(cmpTarget, 'greenBadge');
        }
    },
    executeFlow: function (cmp, recId, flowName) {
        cmp.set("v.displayFlow", true);
        let flow = cmp.find("flowData");
        let inputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: recId
            }
        ];
        flow.startFlow(flowName, inputVariables);
    }
})

/*
    Mat Sales - Matting
*/