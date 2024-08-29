({
	init : function(cmp, event, helper) {
		helper.getUser(cmp);
    },
    editInfo : function(cmp, event, helper) {
        cmp.set("v.enableEdit", true);
        cmp.set("v.disableEdit", false);
    },
    handleSave : function(cmp, event, helper) {
        var user = cmp.get('v.current_user');
        if(user.Password__c == user.ConfirmPassword__c) {
            var action = cmp.get('c.saveUser');
            action.setParams({"updatedUser": user});
            action.setCallback(this, function(res) {
                var status = res.getState();
                var update_status = res.getReturnValue();
                if(status === "SUCCESS") {
                    cmp.set('v.displaySuccess', true);
                    cmp.set("v.enableEdit", false);
                    cmp.set("v.disableEdit", true);
                    helper.getUser(cmp);
                } else {
                    console.log("Failed to update user info");
                }
            });
            $A.enqueueAction(action);
        } else {
            console.log('PASSWORDS DO NOT MATCH');
        }

    },
    
    waiting: function (component, event, helper) {
        component.set("v.uploading", true);
    },
    doneWaiting: function (component, event, helper) {
        component.set("v.uploading", false);
    },
    closeToast: function(cmp) {
        cmp.set("v.displaySuccess", false);
    }
})