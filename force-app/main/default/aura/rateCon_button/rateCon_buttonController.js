({
    init : function(cmp, event, helper) {
        console.log('Inititalizing Rate Con Modal');
        console.log('Passing in load w record ID: ');
        console.log(cmp.get("v.recordId"));
    },
    
    redirectRateCon : function(cmp) {
        var loadId = cmp.get("v.recordId");
        var url = 'https://yourempiregroup.secure.force.com/ratecon/RateConSignatureV2VFP?id=' + loadId;
        cmp.set("v.rateConURL", url);
        cmp.set("v.showRateCon", true);
    },
    
    closeModal : function(cmp) {
        cmp.set("v.showRateCon", false);
    }
})