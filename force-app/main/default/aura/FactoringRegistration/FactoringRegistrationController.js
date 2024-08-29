({
    init : function(cmp, event, helper) {
        console.log("Initializing Factoring Co. Registration Bundle...");
        helper.getRecords(cmp, event, helper);
    },

    nav: function (cmp, event, helper) {
        cmp.set("v.initialized", false);
        let navTo = event.getParam('navTo');
        if (navTo == "registration") {
            helper.toggleRegistration(cmp);
        }
    }
})