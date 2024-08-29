({
    getUser : function(cmp) {
        var u_ID = cmp.get('v.profile_id');
        var action = cmp.get('c.fetchUser');
        action.setParams({"user_id": u_ID});
        action.setCallback(this, function(res) {
            var status = res.getState();
            if(status === "SUCCESS") {
                //store user results
                cmp.set("v.current_user", res.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }

})