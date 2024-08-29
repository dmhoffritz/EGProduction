({
    getRecords: function (cmp, event, helper) {
        let rId = cmp.get("v.recordId");
        console.log("PASSING FOLLOWING ID INTO ACTION: " + rId);
        let action = cmp.get("c.fetchFactoringCompany");
        action.setParams({ recordId: rId });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                //store results
                cmp.set("v.factoringCompany", res.getReturnValue());
                cmp.set("v.initialized", true);
            } else if (state === "INCOMPLETE") {
                //handle incompletion
            } else if (state === "ERROR") {
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever fetching factoring co. data: " + errors[0].message);
                    } else {
                        console.log("Unknown error");
                    }
                }
            }
        });

        $A.enqueueAction(action);
    },

    toggleRegistration: function (cmp) {
        cmp.set("v.verifyFactoring", false);
        cmp.set("v.registerUser", true);
        cmp.set("v.initialized", true);
    }
})