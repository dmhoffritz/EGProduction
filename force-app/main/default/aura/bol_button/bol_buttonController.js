({
    init : function(cmp, event, helper) {
		
    },
    
    redirectBOL : function(cmp) {
        var loadId = cmp.get("v.recordId");
        var url = 'https://yourempiregroup.secure.force.com/bol/BOLWithSignature_PDF?id=' + loadId;
        cmp.set("v.bolURL", url);
        cmp.set("v.showBOL", true);
    },
    
    closeModal : function(cmp) {
        cmp.set("v.showBOL", false);
    }
})