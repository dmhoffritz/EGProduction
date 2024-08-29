({
    /*
    fetchCarrier : function(cmp) {
        let record = cmp.get("v.Carrier");
        let rId = record.Id;
        console.log("Fetching carrier w/ ID: " + rId);
        console.log("BROKER??");
        console.log(cmp.get("v.isBroker"));
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
    }, */

    register: function (cmp) {
        let factorer = cmp.get("v.factoringCompany");
        let factoringId = factorer.Id;
        console.log("--REGISTRATION PARAMETERS--");
        console.log(cmp.get("v.factoringCompany"));
        console.log("First Name: " + cmp.get("v.firstName"));
        console.log("Last Name: " + cmp.get("v.lastName"));
        console.log("Phone: " + cmp.get("v.phone"));
        console.log("Email: " + cmp.get("v.email"));
        console.log("Password: " + cmp.get("v.password"));
        console.log("Confirm Password: " + cmp.get("v.confirmPassword"));
        let action = cmp.get("c.registerFactoringCompany");
        action.setParams({
            recordId: factoringId,
            userFirstName: cmp.get("v.firstName"),
            userLastName: cmp.get("v.lastName"),
            userPhone: cmp.get("v.phone"),
            userEmail: cmp.get("v.email"),
            userPassword: cmp.get("v.password"),
            userConfirmPassword: cmp.get("v.confirmPassword")
        }); 
        action.setCallback(this, function (res) {
            let state = res.getState();
            console.log("CALLBACK STATE: " + state);
            if (state === "SUCCESS") {
                //store analytics
                console.log("Successfully saved user data");
                console.log("-- USER DATA --");
                console.log(res.getReturnValue());
                //cmp.set("v.newUser", res.getReturnValue());
                window.location.replace('https://yourempiregroup.secure.force.com/carrier');

            }
            else if (state === "INCOMPLETE") {
                //do something
            }
            else if (state === "ERROR") {
                console.log("UNABLE TO REGISTER UESR");
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
            else {
                //throw error
                console.log("UNABLE TO REGISTER USER");
                console.log("UNKNOWN ERROR");
            }

        });

        $A.enqueueAction(action);

    }
})