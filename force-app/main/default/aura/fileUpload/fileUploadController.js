({
    showModal: function (cmp, event, helper) {
        cmp.set("v.showModal", true);  
    },
    closeModal: function (cmp, event, helper) {
        cmp.set("v.showModal", false);
    },
    save: function (component, event, helper) {
        helper.save(component);
    },
    waiting: function (component, event, helper) {
        component.set("v.uploading", true);
    },
    doneWaiting: function (component, event, helper) {
        component.set("v.uploading", false);
    },
    getFileName: function (component, event, helper) {
        helper.getFile(component);
    }
    
})