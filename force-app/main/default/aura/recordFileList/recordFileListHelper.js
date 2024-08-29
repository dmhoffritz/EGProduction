({
	fetchFiles : function(cmp) {
		var r_ID = cmp.get("v.recordId");
        var action = cmp.get("c.queryLoadFiles");
        action.setParams({recordId : r_ID});
        action.setCallback(this, function(res) {
            var state = res.getState();
            if(state === "SUCCESS") {
               cmp.set("v.files", res.getReturnValue());
               this.organizeFiles(cmp);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    organizeFiles : function(cmp) {
        var file_list = cmp.get("v.files");
        var invoices = [];
        var pods = [];
        var other = [];
        for(let i = 0; i < file_list.length; i++) {
            if(file_list[i].fileName.includes('Invoice')) {
                invoices.push(file_list[i]);
            } else if(file_list[i].fileName.includes('PoD')) {
                pods.push(file_list[i]);
            } else {
                other.push(file_list[i]);
            }
        }
        cmp.set("v.invoices", invoices);
        cmp.set("v.PoDs", pods);
        cmp.set("v.otherFiles", other);
    },

    fetchLoadStatus: function (cmp) {
        var loadId = cmp.get("v.recordId");
        var action = cmp.get("c.getLoad");
        action.setParams(
            {
                recordId : loadId
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            console.log("CALLBACK STATE: " + state);
            if (state === "SUCCESS") {
                //store analytics
                console.log("Successfully fetched load status data");
                console.log("-- LOAD STATUS --");
                console.log(res.getReturnValue());
                let load = res.getReturnValue();
                if (load.BOL_Signed__c == false) {
                    cmp.set("v.showPodUpload", true);
                }
                if (load.FreightTM__Status__c == 'Delivered' && (load.FreightTM__Bill_Status__c == 'Bill/POD Needed' || load.FreightTM__Bill_Status__c == 'Dispute')) {
                    cmp.set("v.showInvoiceUpload", true);
                } 

            }
            else if (state === "INCOMPLETE") {
                //do something
            }
            else if (state === "ERROR") {
                console.log("UNABLE TO FETCH ASSET ANALYSIS");
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
            else {
                //throw error
                console.log("UNABLE TO FETCH ASSET ANALYSIS");
                console.log("UNKNOWN ERROR");
            }

        });

        $A.enqueueAction(action);
    }
    
    
})