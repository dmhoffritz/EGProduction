({
	getLoads : function(cmp) {
        var u_type = cmp.get("v.userType");
        var r_Id = cmp.get("v.recordId");
        if(r_Id != null && r_Id != '') {
            var action = cmp.get("c.getRelatedLoads");
            action.setParams({"recordId": r_Id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    cmp.set("v.master_load_list", response.getReturnValue());
                    cmp.set("v.relativeLoads", response.getReturnValue());
					this.stripNames(cmp);
                }
            });
            
            $A.enqueueAction(action);
        } else {
            console.log('INVALID USER ID');
        }

    },
    
    stripNames : function(cmp) {
        var l_list = cmp.get("v.master_load_list");
        var l_names = [];
        for(var i = 0; i < l_list.length; i++) {
            l_names.push(l_list[i].Name);
        }
        cmp.set("v.loadNames", l_names);
    }
})