({
	init : function(cmp, event, helper) {
		helper.organizeData(cmp);
	},
    
    redirectRateCon : function(cmp, event, helper) {
        cmp.set("v.showRateCon", true);
        var loadId = cmp.get("v.load.Id");
        var url = 'https://yourempiregroup.secure.force.com/ratecon/RateConSignatureV2VFP?id=' + loadId;
        cmp.set("v.rateConURL", url);

    },
    
    redirectBOL : function(cmp, event, helper) {
        cmp.set("v.showBOL", true);
        var loadId = cmp.get("v.load.Id");
        var url = 'https://yourempiregroup.secure.force.com/bol/BOLWithSignature_PDF?id=' + loadId;
        cmp.set("v.bolURL", url);
    },
    
    closeModal : function(cmp, event, helper) {
        cmp.set("v.showRateCon", false);
        cmp.set("v.showBOL", false);
    }
})