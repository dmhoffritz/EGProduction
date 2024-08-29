({
    init : function(cmp, event, helper) {
        console.log("Initialized line item tile");
        helper.computePercentages(cmp);
        helper.organizeBadges(cmp, event);
        //helper.checkSelections(cmp);
    }
})