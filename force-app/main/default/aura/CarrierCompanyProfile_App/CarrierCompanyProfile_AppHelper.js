({
    getCarrier : function(cmp) {
        var u_ID = cmp.get('v.profile_id');
        var r_type = cmp.get('v.userType');
        if(r_type == 'Factoring_Company') {
            var action = cmp.get('c.fetchFactorer');
            action.setParams({"user_id": u_ID});
            action.setCallback(this, function(res) {
                var status = res.getState();
                if(status === "SUCCESS") {
                    //store user results
                    cmp.set("v.related_factorer", res.getReturnValue());
                }
                else if (status === "INCOMPLETE") {
                    //do something
                }
                    else if (status === "ERROR") {
                        var errors = res.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error Whenever Fetching Carrier Data: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
        }
        else {
            var action = cmp.get('c.fetchCarrier');
            action.setParams({"user_id": u_ID});
            action.setCallback(this, function(res) {
                var status = res.getState();
                if(status === "SUCCESS") {
                    //store user results
                    cmp.set("v.related_carrier", res.getReturnValue());
                }
                else if (status === "INCOMPLETE") {
                    //do something
                }
                    else if (status === "ERROR") {
                        var errors = res.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error Whenever Fetching Carrier Data: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
        }

        $A.enqueueAction(action);
    }

})