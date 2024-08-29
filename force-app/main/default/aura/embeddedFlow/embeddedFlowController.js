({
    init : function (cmp) {
        // Find the cmp whose aura:id is "flowData"
        var flow = cmp.find("flowData");
        var recId = cmp.get("v.recordId");
        var l_list = cmp.get("v.loads");
        var u_ID = cmp.get("v.user_id");
        var flow_name = cmp.get("v.flowName");
        if(flow_name == "File_List") {
            var u_type = cmp.get("v.userType");
            var inputVariables = [
                { 
                    name : 'recordId', 
                    type : 'String', 
                    value : recId 
                },
                {
                    name : 'userType',
                    type : 'String',
                    value : u_type
                }
            ];
        } else if(flow_name == "Carrier_Portal_Batch_Invoice_V4") {
            var inputVariables = [
                {
                    name : 'load_list',
                    type : 'SObject',
                    value : l_list
                },
                {
                    name : 'userId',
                    type : 'String',
                    value : u_ID
                }
            ];
        } else if(flow_name == "Carrier_Portal_Stage_Assigned") {
            var inputVariables = [
                { 
                    name : 'recordId', 
                    type : 'String', 
                    value : recId 
                }
            ];
        }
        
        
        // In that cmp, start your flow. Reference the flow's API Name.
        flow.startFlow(flow_name, inputVariables);
    },
    handleStatusChange : function (cmp, event) {
        var f_name = cmp.get("v.flowName");
        if(f_name == "Carrier_Portal_Batch_Invoice_V4") {
            if(event.getParam("status") === "FINISHED") {
                var outputVariables = event.getParam("outputVariables");
                if(outputVariables != null) {
                    var outputVar;
                    for(var i = 0; i < outputVariables.length; i++) {
                        outputVar = outputVariables[i];
                        // Pass the values to the cmp's attributes
                        if(outputVar.name === "finishURL" && outputVar.name != null) {
                            //window.location.assign(outputVar.value);
                        }  
                    }
                } 
                var evt = $A.get("e.c:flowFinished");
                evt.fire();
            }        
        } 
        else {
            if(event.getParam("status") === "FINISHED") {
                var outputVariables = event.getParam("outputVariables");
                if(outputVariables != null) {
                    var outputVar;
                    for(var i = 0; i < outputVariables.length; i++) {
                        outputVar = outputVariables[i];
                        // Pass the values to the cmp's attributes
                        if(outputVar.name === "finishURL" && outputVar.name != null) {
                            //window.location.assign(outputVar.value);
                        }  
                    }
                } 
                
            }        
        }
        
    }
})