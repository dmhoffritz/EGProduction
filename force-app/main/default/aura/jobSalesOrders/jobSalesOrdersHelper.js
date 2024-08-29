({
    fetchOrders: function (cmp) {
        let action = cmp.get("c.getOrders");
        action.setParams(
            {
                "recordId": cmp.get("v.recordId")
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                cmp.set("v.orders", res.getReturnValue());
                console.log("Successfully returned the following orders: ");
                console.log(cmp.get("v.orders"));
                cmp.set("v.spinner", false);
            } else if (state === "INCOMPLETE") {
                //do something
                cmp.set("v.spinner", false);

            } else if (state === "ERROR") {
                console.log("UNABLE TO FETCH ORDERS");
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
                cmp.set("v.spinner", false);
            } else {
                console.log("UNKNOWN ERROR");
                cmp.set("v.spinner", false);
            }
        });

        $A.enqueueAction(action);
    }
})