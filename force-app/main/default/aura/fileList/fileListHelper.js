({
	fetchFiles : function(cmp) {
        var r_ID = cmp.get("v.recordId");
        
        var action = cmp.get("c.queryLoadFiles");
        action.setParams({recordId : r_ID});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if(state === "SUCCESS") {
                console.log("Successfully fetched files");
                cmp.set("v.relatedFiles", res.getReturnValue());
                this.organizeFiles(cmp);
            }
        });
		$A.enqueueAction(action);
	},
    
    organizeFiles : function(cmp) {
        var files = cmp.get("v.relatedFiles");
        var invoices = [];
        var pods = [];
        var other = [];
        for(var i = 0; i < files.length; i++) {
            if((files[i].fileName).includes("Invoice")) {
                invoices.push(files[i]);
            }
            else if((files[i].fileName).includes("PoD")) {
                pods.push(files[i]);
            }
                else {
                    other.push(files[i]);
                }
        }
        cmp.set("v.invoices", invoices);
        cmp.set("v.PoDs", pods);
		cmp.set("v.otherFiles", other);
    }
})