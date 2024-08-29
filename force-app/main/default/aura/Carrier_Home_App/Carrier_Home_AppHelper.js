({
	getLoads : function(cmp) {
        var u_type = cmp.get("v.userType");
        var r_Id = cmp.get("v.record_id");
        if(r_Id != null && r_Id != '') {
            var action = cmp.get("c.getRelatedLoads");
            action.setParams({"recordId": r_Id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    cmp.set("v.master_load_list", response.getReturnValue());
                    cmp.set("v.relative_load_list", response.getReturnValue());
                    this.bucketLoads(cmp);
                    if(u_type == 'Factoring_Company') {
                        this.organizeCarriers(cmp);
                    }
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error whenever fetching load data: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                cmp.set("v.loading", false);

            });
            
            $A.enqueueAction(action);
        } else {
        }
        
        
        
    },
    
    handleChange: function (cmp) {
        cmp.set("v.loading", true);
        var u_type = cmp.get("v.userType");
        var timeoutTime = 1500;
        if(u_type == "Carrier_Factoring" || u_type == "Carrier_Not_Factoring") {
            var new_selection = cmp.find("newPicker").getElement();
            var working_selection = cmp.find("workingPicker").getElement();
            if(new_selection.checked) {
                cmp.set("v.showWorking", false);
                cmp.set("v.showDelivered", false);
                cmp.set("v.showBillReceived", false);
                cmp.set("v.showProcessed", false);
                window.setTimeout(function () {
                    cmp.set("v.showNew", true);
                    cmp.set("v.loading", false);
                    return;
                }, timeoutTime);

            } else if(working_selection.checked) {
                cmp.set("v.showNew", false);
                cmp.set("v.showDelivered", false);
                cmp.set("v.showBillReceived", false);
                cmp.set("v.showProcessed", false);
                window.setTimeout(function () {
                    cmp.set("v.showWorking", true);
                    cmp.set("v.loading", false);
                    return;
                }, timeoutTime);

            }
        }
        
        var delivered_selection = cmp.find("deliveredPicker").getElement();
        if(u_type == "Carrier_Not_Factoring" || u_type == "Factoring_Company") {
            var billReceived_section = cmp.find("billPicker").getElement();
            
            if(billReceived_section.checked) {
                cmp.set("v.showNew", false);
                cmp.set("v.showWorking", false);
                cmp.set("v.showDelivered", false);
                cmp.set("v.showProcessed", false);
                window.setTimeout(function () {
                    cmp.set("v.showBillReceived", true);
                    cmp.set("v.loading", false);
                    return;
                }, timeoutTime);

            } 
        }
        
        
        if(delivered_selection.checked) {
            cmp.set("v.showNew", false);
            cmp.set("v.showWorking", false);
            cmp.set("v.showBillReceived", false);
            cmp.set("v.showProcessed", false);
            window.setTimeout(function () {
                cmp.set("v.showDelivered", true);
                cmp.set("v.loading", false);
                return;
            }, timeoutTime);

        }

   

    },

    
	//store relativeLoads attribute    
    bucketLoads : function(cmp) {
        var u_type = cmp.get("v.userType");
        var master_list = cmp.get("v.relative_load_list");
        var newList = [];
        var workingList = [];
        var deliveredList = [];
        var billReceivedList = [];
        var processedList = [];
        
        if(u_type == 'Carrier_Factoring') {
            for(var i = 0; i < master_list.length; i++) {
                if(master_list[i].FreightTM__Status__c == "Assigned") {
                    newList.push(master_list[i]);
                }
                else if (master_list[i].FreightTM__Status__c == "Dispatched" || master_list[i].FreightTM__Status__c == "Arrived for pickup" || 
                          master_list[i].FreightTM__Status__c == 'Loaded In Transit' || master_list[i].FreightTM__Status__c == 'Delayed' || 
                          master_list[i].FreightTM__Status__c == 'Arrived for delivery') {
                    workingList.push(master_list[i]);
                    
                }
                else if (master_list[i].FreightTM__Status__c == "Delivered") {

                    deliveredList.push(master_list[i]);
                }
            }
        }
            
        else if(u_type == 'Carrier_Not_Factoring') {
            for(var i = 0; i < master_list.length; i++) {
                if(master_list[i].FreightTM__Status__c == "Assigned") {
                    newList.push(master_list[i]);
                }
                else if (master_list[i].FreightTM__Status__c == "Dispatched" || master_list[i].FreightTM__Status__c == "Arrived for pickup" || 
                          master_list[i].FreightTM__Status__c == 'Loaded In Transit' || master_list[i].FreightTM__Status__c == 'Delayed' || 
                          master_list[i].FreightTM__Status__c == 'Arrived for delivery') {
                    workingList.push(master_list[i]); 
                }
                else if (master_list[i].FreightTM__Status__c == "Delivered" && (master_list[i].FreightTM__Bill_Status__c == "Bill/POD Needed" || master_list[i].FreightTM__Bill_Status__c == null) && master_list[i].FreightTM__Total_Rate_to_Carrier__c > 0) {
                    deliveredList.push(master_list[i]);
                }
                else if (master_list[i].FreightTM__Bill_Status__c != null && master_list[i].FreightTM__Bill_Status__c != "Bill/POD Needed" && master_list[i].FreightTM__Pay_Status__c != "Processed for Payment") {
                    billReceivedList.push(master_list[i]);
                }
                else if (master_list[i].FreightTM__Pay_Status__c == "Processed for Payment") {
                    processedList.push(master_list[i]);
                }
            }
        }
        
        else if(u_type == 'Factoring_Company') {
            for(var i = 0; i < master_list.length; i++) {
                if(master_list[i].FreightTM__Status__c == "Delivered" && (master_list[i].FreightTM__Bill_Status__c == "Bill/POD Needed" || master_list[i].FreightTM__Bill_Status__c == null) && master_list[i].FreightTM__Total_Rate_to_Carrier__c > 0) {
                    deliveredList.push(master_list[i]);
                }
                else if (master_list[i].FreightTM__Bill_Status__c != null && master_list[i].FreightTM__Bill_Status__c != "Bill/POD Needed" && master_list[i].FreightTM__Bill_Status__c != "Past Payment Time Allowed" && master_list[i].FreightTM__Pay_Status__c != "Processed for Payment") {
                    billReceivedList.push(master_list[i]);
                }
                else if (master_list[i].FreightTM__Pay_Status__c == "Processed for Payment") {
                    processedList.push(master_list[i]);
                }
            }
        } 
        
        
        
        cmp.set("v.newLoads", newList);
        cmp.set("v.workingLoads", workingList);
        cmp.set("v.deliveredLoads", deliveredList);
        cmp.set("v.billReceivedLoads", billReceivedList);
        cmp.set("v.processedLoads", processedList);
        this.styleData(cmp);
        
    },
    
        
    styleData : function(cmp) {
        var load_list = cmp.get("v.newLoads");
        for(var i = 0; i < load_list.length; i++) {
            if(load_list[i].Carrier_Signature__c != null) {
                load_list[i].rateCon_status = 'slds-badge slds-theme_success';
                load_list[i].rateCon_signed = 'Signed';
            } else {
                load_list[i].rateCon_status = 'slds-badge slds-theme_error';
                load_list[i].rateCon_signed = 'Awaiting Signature';
            }

            if (load_list[i].BOL_Signed__c == true) {
                load_list[i].pod_status = 'slds-badge slds-theme_success';
                load_list[i].pod_signed = 'POD Received';
            } else {
                load_list[i].pod_status = 'slds-badge slds-theme_error';
                load_list[i].pod_signed = 'POD Needed';
            }
            
            if(load_list[i].FreightTM__Bill_Status__c == 'Bill/POD Needed') {
                load_list[i].bill_style = 'slds-badge slds-theme_warning';
                load_list[i].bill_status = 'Bill Needed';
            } else if(load_list[i].FreightTM__Bill_Status__c == 'Needs Review') {
                load_list[i].bill_style = 'slds-badge slds-theme_error';
                load_list[i].bill_status = 'Needs Review';
            } else if(load_list[i].FreightTM__Bill_Status__c == 'Bill/POD Received' || load_list[i].FreightTM__Bill_Status__c == 'Reconciled') {
                load_list[i].bill_style = 'slds-badge slds-theme_success';
                load_list[i].bill_status = 'Bill Received';
            }
            
            if(load_list[i].FreightTM__Pay_Status__c == 'Processed for Payment') {
                load_list[i].pay_status = 'slds-badge slds-theme_success';
            } else if(load_list[i].FreightTM__Pay_Status__c == 'Dispute') {
                load_list[i].pay_status = 'slds-badge slds-theme_error';
            }
        }
        cmp.set("v.newLoads", load_list);
        
    },

    
        
    organizeCarriers : function(cmp) {
        var load_list = cmp.get("v.master_load_list");
        var carrier_names = [];
        var carrier_list = [];
        var default_option = {
            value : 'All',
            label : '--Select a Carrier--'
        }
		carrier_list.push(default_option);
        for(var i = 0; i < load_list.length; i++) {
            var c_name = load_list[i].FreightTM__Carrier_Obj__r.Name;
            if(carrier_names.includes(c_name) != true) {
                var carrier = {
                    value : c_name,
                    label : c_name
                };
                carrier_names.push(c_name);
                carrier_list.push(carrier);
            }
            
        }
        cmp.set("v.carrierList", carrier_list);
    },
    
    reorganizePickers : function(cmp, selectedCarrier) {
        var load_list = cmp.get("v.master_load_list");
        var updated_list = [];
        for(var i = 0; i < load_list.length; i++) {
            if(load_list[i].FreightTM__Carrier_Obj__r.Name == selectedCarrier) {
                updated_list.push(load_list[i]);
            } else if(selectedCarrier == 'All') {
                updated_list = cmp.get("v.master_load_list");
            }
        }
        cmp.set("v.relative_load_list", updated_list);
        this.bucketLoads(cmp);
        cmp.set("v.showDelivered", false);
        var delivered_selection = cmp.find("deliveredPicker").getElement();
        delivered_selection.checked = false;
        
    }
})