({
    fetchData : function(cmp) {
        let action = cmp.get("c.fetchFactoringCo");
        action.setParams({
            recId: cmp.get("v.recordId")
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state == "SUCCESS") {
                //store factoring co data
                console.log("Results: ");
                console.log(res.getReturnValue());
                cmp.set("v.factoringCo", res.getReturnValue());
                cmp.set("v.verifyCo", true);
            } else if (state === "INCOMPLETE") {
                // handle incompletion
            } else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever fetching factoring co data: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log("Unknown error whenever fetching factoring co data");
            }
        });

        $A.enqueueAction(action);
    },

    updateData: function (cmp) {
        let action = cmp.get("c.updateFactoringCo");
        action.setParams({
            updatedRecord: cmp.get("v.factoringCo")
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state == "SUCCESS") {
                //store factoring co data
                console.log("Results: ");
                console.log(res.getReturnValue());
                cmp.set("v.factoringCo", res.getReturnValue());
                cmp.set("v.verifyCo", false);
                cmp.set("v.registerPanel", true);
            } else if (state === "INCOMPLETE") {
                // handle incompletion
            } else if (state === "ERROR") {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever updating factoring co: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log("Unknown error whenever updating factoring co");
            }
        });

        $A.enqueueAction(action);    }
})