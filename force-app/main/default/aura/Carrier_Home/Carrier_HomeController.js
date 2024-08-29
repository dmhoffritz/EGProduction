({
	init : function(cmp, event, helper) {
        console.log(cmp.get("v.recordType"));
        helper.getDisputedLoads(cmp);
		//helper.getRelatedLoads(cmp);
    },
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                helper.showRowDetails(cmp, row);
                break;
        }  
    },

    closeModal: function (cmp, event, helper) {
        cmp.set("v.displayDisputes", false);
    },
    
    initializeLoad : function(cmp, event, helper) {
        //helper.getLoad(cmp, event);
    }
})