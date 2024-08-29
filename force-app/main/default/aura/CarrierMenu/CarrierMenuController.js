({
    init : function(cmp, event, helper) {
        var f_name = cmp.get("v.first_name");
        var l_name = cmp.get("v.last_name");
        var user_name = f_name + ' ' + l_name;
        cmp.set("v.full_name", user_name);
        helper.getUser(cmp);
    },
    handleSelect : function(component, event) {
        var userId = component.get("v.user_id");
        var selectedItem = event.getParam("value");
        if(selectedItem == 'logout') {
            //var login_URL = 'https://ethandev2-yourempiregroup.cs195.force.com/carrier';
            var login_URL = 'https://yourempiregroup.secure.force.com/carrier';
            window.location.replace(login_URL);
        } else if(selectedItem == 'my_profile') {
            var updateEvent = $A.get("e.c:navEvent");
            updateEvent.setParams({"navItem": "my_profile", "recordId": "row.Id"});
            updateEvent.fire();
        } else if(selectedItem == 'company_profile') {
            var updateEvent = $A.get("e.c:navEvent");
            updateEvent.setParams({"navItem": "company_profile", "recordId": "row.Id"});
            updateEvent.fire();
        }
    }
})