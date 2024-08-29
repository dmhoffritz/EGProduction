({
    init: function (cmp, event, helper) {
        cmp.set("v.initialized", false);
        cmp.set("v.showSpinner", true);
        console.log("Successfully initialized Driver Portal for load w/ Id: " + cmp.get("v.loadId"));
        helper.fetchLoadData(cmp, event);
    },

    storeSignature: function (cmp, event, helper) {
        let sigPad = cmp.find("SignaturePad_Driver");
        sigPad.set("v.recordId", cmp.get("v.loadId"));
        sigPad.set("v.signatureType", "Driver");
        sigPad.SaveSignature(cmp, event, helper);
    },

    showSpinner: function (cmp, event, helper) {
        cmp.set("v.showSpinner", true);
    }
})