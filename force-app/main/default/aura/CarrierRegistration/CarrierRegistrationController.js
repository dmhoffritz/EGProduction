({
    init : function(cmp, event, helper) {
        console.log("Initializing Carrier Registration Bundle...");

        helper.fetchCarrier(cmp);
    },

    nav: function (cmp, event, helper) {
        cmp.set("v.initialized", false);
        let navTo = event.getParam('navTo');
        console.log("Naving To: " + navTo);
        if (navTo == "billing") {
            helper.toggleBilling(cmp);
        } else if (navTo == "registration") {
            helper.toggleRegistration(cmp);
        }
    }
})