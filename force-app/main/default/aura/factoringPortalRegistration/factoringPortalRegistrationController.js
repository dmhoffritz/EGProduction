({
    init : function(cmp, event, helper) {
        console.log("Initialized Registration CMP");
        //helper.fetchFactorer(cmp);
    },

    registerUser: function (cmp, event, helper) {
        let pWord = cmp.get("v.password");
        let confirmPWord = cmp.get("v.confirmPassword");
        if (pWord != confirmPWord) {
            //throw error
            cmp.set("v.passwordError", true);
        } else {
            helper.register(cmp);
        }
    }
})