({
    init : function(cmp, event, helper) {
        helper.organizeMap(cmp);
        helper.organizeButtons(cmp);
        helper.organizeModal(cmp);
    },

    getDirections: function (cmp, event, helper) {
        let URL = 'http://maps.google.com/maps?daddr=' + cmp.get("v.lat") + ',' + cmp.get("v.long") + '&ll=';
        window.open(URL, '_blank');
    },

    handleMarkerSelect: function (cmp, event, helper) {
        let marker = event.getParam("selectedMarkerValue");
    },

    handleArrival: function (cmp, event, helper) {
        helper.updateStatus(cmp, event);
    },

    getSignature: function (cmp, event, helper) {
        location.reload();
    },

    closeModal: function (cmp, event, helper) {
        cmp.set("v.showModal", false);
    },

    storeSignature: function (cmp, event, helper) {
        //callout apex method & reference signature field to store pickup signature
        cmp.set("v.showModal", false);
    }
})