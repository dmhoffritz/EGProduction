({
    updateCarrier : function(cmp) {
        var c = cmp.get("v.Carrier");
        var lanes = cmp.get("v.selectedStates");
        var cLanes = '';
        for (let i = 0; i < lanes.length; i++) {
            cLanes += lanes[i] + ';';
        }
        console.log("Passing the following Carrier lanes into Carrier obj: ");
        console.log(cLanes);
        c.Preferred_Lanes__c = cLanes;
        console.log("Saving Carrier Obj: ");
        console.log(c);
        let action = cmp.get("c.updateCarrier");
        /*
        action.setParams({
                recordId: c.Id,
                companyContact: c.FreightTM__Primary_Contact__c,
                companyPhone: c.FreightTM__Phone__c,
                companyEmail: c.FreightTM__Email__c,
                companyStreet: c.FreightTM__Address__c,
                companyCity: c.FreightTM__City__c,
                companyState: c.FreightTM__State_Province__c,
                companyZip: c.FreightTM__Zip_Code__c,
                opStates: c.Preferred_Lanes__c
            });
        */
        action.setParams({
            recordId: c.Id,
            companyContact: c.FreightTM__Primary_Contact__c,
            companyPhone: c.FreightTM__Phone__c,
            companyEmail: c.FreightTM__Email__c,
            opStates: c.Preferred_Lanes__c
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                //jump to billing verification
                console.log("SUCCESSFULLY UPDATED CARRIER");
                console.log("---UPDATED CARRIER---");
                console.log(res.getReturnValue());
                this.navBilling(cmp);
            } else {
                //throw error message
                console.log("UNABLE TO UPDATE CARRIER");
            }
        });

        $A.enqueueAction(action);
    },

    navBilling: function (cmp) {
        let navEvent = $A.get("e.c:navRegistration");
        navEvent.setParams(
            {
                "navTo": "billing"
            }
        );
        navEvent.fire();
    }
})