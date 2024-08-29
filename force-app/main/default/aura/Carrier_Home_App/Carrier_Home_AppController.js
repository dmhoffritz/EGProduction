({
    init: function (cmp, event, helper) {
        cmp.set("v.loading", true);
        helper.getLoads(cmp);
        if(cmp.get("v.userType") == 'Carrier_Factoring') {
            cmp.set("v.showNew", true);
        }
    },
    
    handleSelection: function (cmp, event, helper) {
        //cmp.set("v.loading", true);
        helper.handleChange(cmp);
    },
    
    swapCarrier : function(cmp, event, helper) {
        var carrier_selection = cmp.find('carrierList').get('v.value');
        helper.reorganizePickers(cmp, carrier_selection);
    },

    stopLoading: function (cmp, event, helper) {
       // console.log("DT CMP LOADED");
        //console.log("EVENT BEING HANDLED FROM CARRIER HOME APP CMP");
       // cmp.set("v.loading", false);
    }
})