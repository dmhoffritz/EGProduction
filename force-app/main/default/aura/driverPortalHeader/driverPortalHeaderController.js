({
    init : function(cmp, event, helper) {
        console.log("Initialized driver portal header!");
        let status = cmp.get("v.loadStatus");
        if (status == 'Delivered') {
            cmp.set("v.iconName", "utility:success");
        }
    },

    viewBOL: function (cmp, event, helper) {
        let URL = 'https://yourempiregroup.my.salesforce-sites.com/bol/BOLWithSignature_PDF?id=' + cmp.get("v.loadId");
        window.open(URL, '_blank');
    }
})