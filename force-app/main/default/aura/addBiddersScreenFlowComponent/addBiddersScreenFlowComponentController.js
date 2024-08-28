({
    init : function (cmp) {
        var flow = cmp.find("flowData");
        var variables = [
            { name : "recordId", type : "String", value: cmp.get("v.recordId") }
        ];
        flow.startFlow("Bid_List", variables);
    }
})