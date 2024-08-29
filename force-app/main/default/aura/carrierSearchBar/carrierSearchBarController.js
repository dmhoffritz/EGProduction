({
    init : function (cmp, event, helper) {
        //helper.getLoads(cmp);
        var div = document.getElementById("myDropdown");
        
    },
    
    handleKeyUp: function (cmp, evt) {
        //Check if selection is entered
        var displaySelection = cmp.find("myDropdown");
        $A.util.addClass(displaySelection, "show");
        var isEnterKey = evt.keyCode === 13;
        
        //Query returning from user
        var queryTerm = cmp.find('enter-search').get('v.value');
        var upper = queryTerm.toUpperCase();
        var lower = queryTerm.toLowerCase();
        
        //Get load names for evaluation
        var loadNames = cmp.get("v.loadNames");
        var loads = cmp.get("v.master_load_list");
        var relatedNames = [];
        //String.prototype.fuzzySearch = fuzzySearch;
        for(let i = 0; i < loads.length; i++) {
            if(loads[i].Name.includes(upper) || loads[i].Name.includes(lower)) {
                relatedNames.push(loads[i]);
            }
        }
        cmp.set("v.relativeLoads", relatedNames);
        if(queryTerm != null && queryTerm != '') {
            cmp.set("v.showMenu", true);
        } else {
            var displaySelection = cmp.find("myDropdown");
            $A.util.removeClass(displaySelection, "show");
        }
        if (isEnterKey) {
            alert("PERFORM SEARCH FOR: " + queryTerm);
        }
    },
    
    handleSelection : function(cmp, event) {
        var l_id = event.currentTarget.id;
        var displaySelection = cmp.find("myDropdown");
        $A.util.removeClass(displaySelection, "show");
        cmp.set("v.selectedLoad", event.currentTarget.Name);
        var updateEvent = $A.get("e.c:navLoad");
        updateEvent.setParams({"navItem": "load_detail", "recordId": l_id});
        updateEvent.fire();
    },
    
    handleClear : function(cmp, event) {
        var query = cmp.find('enter-search').get('v.value');
        if(query.length == 0) {
        var displaySelection = cmp.find("myDropdown");
        $A.util.removeClass(displaySelection, "show");
        }

    },
    
    menuOff : function(cmp, event) {
        var displaySelection = cmp.find("myDropdown");
        $A.util.removeClass(displaySelection, "show");
    },
    
    menuOn : function(cmp, event) {
        var displaySelection = cmp.find("myDropdown");
        $A.util.addClass(displaySelection, "show");
    }

});