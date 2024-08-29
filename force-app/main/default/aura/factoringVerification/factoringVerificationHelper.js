({
    updateRecord : function(cmp) {
        let action = cmp.get("c.updateFactoringCompany");
        action.setParams({
            recordId: cmp.get("v.factoringCompany.Id"),
            primaryContact: cmp.get("v.factoringCompany.PrimaryContact__c"),
            phone: cmp.get("v.factoringCompany.Phone__c"),
            email: cmp.get("v.factoringCompany.Email__c"),
            street: cmp.get("v.factoringCompany.Street__c"),
            city: cmp.get("v.factoringCompany.City__c"),
            state: cmp.get("v.factoringCompany.State__c"),
            zip: cmp.get("v.factoringCompany.ZipCode__c")
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                cmp.set("v.factoringCompany", res.getReturnValue());
                //jump to registration page
                this.navReg(cmp);
            } else if (state === "INCOMPLETE") {
                //handle incompletion
            } else if (state === "ERROR") {
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error whenever updating Factoring Company: " + errors[0].message);
                    } else {
                        console.log("Unknown error");
                    }
                }
            }
        });

        $A.enqueueAction(action);
    },

    navReg: function (cmp) {
        let navEvent = $A.get("e.c:navRegistration");
        navEvent.setParams({
            "navTo": "registration"
        });
        navEvent.fire();
    }
})