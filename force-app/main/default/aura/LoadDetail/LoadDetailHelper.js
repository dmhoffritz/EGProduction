({
	fetchLoad : function(cmp) {
		var r_Id = cmp.get("v.recordId");
        var action = cmp.get("c.getLoad");
        action.setParams({"recordId": r_Id});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if(state === "SUCCESS") {
                cmp.set("v.load", res.getReturnValue());
                cmp.set("v.initializationComplete", true);
            }
        });
        $A.enqueueAction(action);
    }
})