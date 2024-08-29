({
    fetchCarrier : function(cmp) {
        let rId = cmp.get("v.recordId");
        console.log("Fetching carrier w/ ID: " + rId);
        let action = cmp.get("c.carrierQuery");
        action.setParams({ recordId: rId });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                console.log("Successfully fetched Carrier record!");
                cmp.set("v.Carrier", res.getReturnValue());
                console.log("CARRIER RETURNED: ");
                console.log(cmp.get("v.Carrier"));
                cmp.set("v.initialized", true);
            } else {
                console.log("Unable to fetch Carrier record");
            }
        });

        $A.enqueueAction(action);
    },

    toggleCarrier: function (cmp) {
        console.log("Toggling Carrier Verification Page...");
        cmp.set("v.verifyCarrier", true);
        cmp.set("v.verifyBilling", false);
        cmp.set("v.registerUser", false);
        cmp.set("v.initialized", true);
    },

    toggleBilling: function (cmp) {
        console.log("Toggling Billing Verification Page...");
        cmp.set("v.verifyCarrier", false);
        cmp.set("v.verifyBilling", true);
        cmp.set("v.registerUser", false); 
        cmp.set("v.initialized", true);

    },

    toggleRegistration: function (cmp) {
        console.log("Toggling Registration Page...");
        cmp.set("v.verifyCarrier", false);
        cmp.set("v.verifyBilling", false);
        cmp.set("v.registerUser", true);
        cmp.set("v.initialized", true);

    }
})