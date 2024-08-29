({
    styleData : function(cmp) {
        var load_list = cmp.get("v.data");
        console.log("Styling data for following loads:");
        console.log(load_list);
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
            } else if (load_list[i].FreightTM__Bill_Status__c == 'Dispute') {
                load_list[i].bill_style = 'slds-badge slds-theme_error';
                load_list[i].bill_status = 'Disputed';
            }
            
            if(load_list[i].FreightTM__Pay_Status__c == 'Processed for Payment') {
                load_list[i].pay_status = 'slds-badge slds-theme_success';
            } else if(load_list[i].FreightTM__Pay_Status__c == 'Dispute') {
                load_list[i].pay_status = 'slds-badge slds-theme_error';
            }
        }
        
        cmp.set("v.data", load_list);

    },
    
    setColumns : function(cmp) {
        var bucket = cmp.get('v.loadType');
        var actions = [];
        if(bucket == 'New') {
            actions = [
                {label: 'View BOL', name: 'view_bol'},
                {label: 'View RateCon', name: 'view_rateCon'},
                {label: 'Load Details', name: 'view'}
            ]
            cmp.set('v.columns', [
                { label: 'Load #', fieldName: 'Name', type: 'button', initialWidth: 125, sortable: true, wrapText: true, iconName: 'utility:truck', iconPosition: 'right', typeAttributes: { label: { fieldName: 'Name' }, name: 'view_details', title: 'Click to View Details' } },
                { label: 'Covered?', fieldName: 'Covered__c', type: 'boolean', initialWidth: 125, sortable: true, wrapText: true, editable: true },
                {label: 'Pickup By', fieldName: 'Pickup_By__c', type: 'date', initialWidth: 200, sortable: true, wrapText: true, iconName: 'utility:date_input', typeAttributes: {day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12:true}},
                {label: 'Deliver By', fieldName: 'Deliver_By__c', type: 'date', initialWidth: 200, sortable: true, wrapText: true, iconName: 'utility:date_time', typeAttributes: {day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12:true}},
                {label: 'Origin --> Destination', fieldName: 'FreightTM__Calendar_Load__c', type: 'text', sortable: true, wrapText: true, initialWidth: 250, iconName: 'utility:location'},
                {label: 'Rate', fieldName: 'FreightTM__Total_Rate_to_Carrier__c', type: 'currency', sortable: true, iconName: 'utility:money', cellAttributes: { alignment: 'center'}},
                {label: 'Driver Name', fieldName: 'Driver_Name__c', type: 'text', iconName: 'utility:user', sortable: true, wrapText: true, editable: true, cellAttributes: {class: 'editAction'}},
                {label: 'Driver Phone', fieldName: 'Driver_Phone__c', type: 'phone', iconName: 'utility:call', sortable: true, wrapText: true, editable: true, cellAttributes: {class: 'editAction'}},
                {label: 'RateCon Status', fieldName: 'rateCon_signed', type: 'text', initialWidth: 175, sortable: true, wrapText: true, iconName: 'utility:signature',
                 cellAttributes: { class: {fieldName: 'rateCon_status'}, alignment: 'left'}},
                {type: 'action', typeAttributes: {rowActions: actions}, wrapText: true, cellAttributes: {class: 'tableAction'}}
            ]);
        }
        else if(bucket == 'Working') {
            actions = [
                {label: 'View BOL', name: 'view_bol'},
                {label: 'View RateCon', name: 'view_rateCon'},
                {label: 'Load Details', name: 'view'}
            ];
            cmp.set('v.columns', [
                {label: 'Load #', fieldName: 'Name', type: 'button', initialWidth: 125, sortable: true, iconName: 'utility:truck', typeAttributes: {label: {fieldName: 'Name'}, name: 'view_details', title: 'Click to View Details'}},
                {label: 'Status', fieldName: 'FreightTM__Status__c', type: 'text', sortable: true, iconName: 'utility:events'},
                {label: 'Pickup By', fieldName: 'Pickup_By__c', type: 'date', sortable: true, iconName: 'utility:date_input', typeAttributes: {day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12:true}},
                {label: 'Deliver By', fieldName: 'Deliver_By__c', type: 'date', sortable: true, iconName: 'utility:date_time', typeAttributes: {day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12:true}},
                {label: 'Origin --> Destination', fieldName: 'FreightTM__Calendar_Load__c', type: 'text', sortable: true, initialWidth: 300, iconName: 'utility:location'},
                {label: 'Rate', fieldName: 'FreightTM__Total_Rate_to_Carrier__c', type: 'currency', sortable: true, iconName: 'utility:money', cellAttributes: { alignment: 'center'}},
                {label: 'Driver Name', fieldName: 'Driver_Name__c', type: 'text', sortable: true, iconName: 'utility:user'},
                { label: 'Driver Phone', fieldName: 'Driver_Phone__c', type: 'phone', sortable: true, iconName: 'utility:call' },
                {label: 'POD Status', fieldName: 'pod_signed', type: 'text',
                    cellAttributes: { class: {fieldName: 'pod_status'}, alignment: 'left'}},
                {type: 'action', typeAttributes: {rowActions: actions}, wrapText: true, cellAttributes: {class: 'tableAction'}}
            ]); 
        } else if(bucket == 'Bill' || bucket == 'Delivered') {
           cmp.set('v.columns', [
                {label: 'Load #', fieldName: 'Name', type: 'button', initialWidth: 125, sortable: true, iconName: 'utility:truck', typeAttributes: {label: {fieldName: 'Name'}, name: 'view_details', title: 'Click to View Details'}},
                {label: 'Driver Name', fieldName: 'Driver_Name__c', type: 'text', iconName: 'utility:user', cellAttributes: {alignment: 'center'}},
                {label: 'Quantity', fieldName: 'Quantity__c', type: 'text', iconName: 'utility:product_service_campaign', initialWidth: 150, cellAttributes: {alignment: 'center'}},
                {label: 'Commodity', fieldName: 'FreightTM__Commodity__c', type: 'text', iconName: 'utility:price_book_entries', initialWidth: 150, cellAttributes: {alignment: 'center'}},
                {label: 'Billed On', fieldName: 'FreightTM__Billed_On__c', type: 'date', iconName: 'utility:event', cellAttributes: {alignment: 'center'}, typeAttributes: {day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12:true}},
                {label: 'Invoice #', fieldName: 'Invoice__c', type: 'text', iconName: 'utility:product_workspace', cellAttributes: {alignment: 'center'}},
                {label: 'Rate', fieldName: 'FreightTM__Total_Rate_to_Carrier__c', type: 'currency', iconName: 'utility:money', cellAttributes: { alignment: 'center'}},
                {label: 'Bill Status', fieldName: 'bill_status', type: 'text', iconName: 'utility:product_warranty_term',
                cellAttributes: { class: {fieldName: 'bill_style'}, alignment: 'left'}}
            ]); 
        }
    },
    
    getData : function(cmp) {
        console.log('Fetching Updated Loads...');
        var r_id=cmp.get("v.recordId");
        var l_type = cmp.get("v.loadType");
        var action=cmp.get("c.getRelatedLoads");
        action.setParams({"recordId": r_id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.savedData", response.getReturnValue());
                this.bucketData(cmp);
                this.styleData(cmp);
            }
            else if (state === "INCOMPLETE") {
                //do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error whenever fetching load data: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    
    bucketData : function(cmp) {
        var allLoads = cmp.get("v.savedData");
        var newLoads = [];
        for(let i = 0; i < allLoads.length; i++) {
            if(allLoads[i].FreightTM__Status__c == 'Assigned') {
                newLoads.push(allLoads[i]);
            }
        }
        cmp.set("v.data", newLoads);
    },
 
    //store relativeLoads attribute    
    organizeCellStyles : function(cmp) {
        var data_list = cmp.get("v.data");
        var newList = [];
        for(var i = 0; i < data_list.length; i++) {
            if(data_list[i].FreightTM__Status__c == "Assigned") {
                if(data_list[i].RateCon_Signed__c != true) {
                    data_list[i].rateCon_status = 'slds-badge slds-theme_error';
                } else {
                    data_list[i].rateCon_status = 'slds-badge slds-theme_success';
                }
                newList.push(data_list[i]);
            }
        }
        cmp.set("v.data", newList);
    },
    
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    //Fire event to be handled from VF Page
    showRowDetails: function(cmp, row) {
        var updateEvent = $A.get("e.c:navLoad");
        updateEvent.setParams({"navItem": "load_detail", "recordId": row.Id});
        updateEvent.fire();
    },
    
    signRateCon: function(cmp, row) {
        var rateCon_URL = 'https://yourempiregroup.secure.force.com/ratecon/RateConSignatureV2VFP?id=' + row.Id;
        cmp.set("v.formURL", rateCon_URL);
        cmp.set("v.formToDisplay", 'RateCon');
        cmp.set("v.loadName", row.Name);
        cmp.set("v.displayForm", true);
    },
    
    viewBOL: function (cmp, row) {
        var bol_URL = 'https://yourempiregroup.secure.force.com/bol/BOLWithSignature?id=' + row.Id;
        cmp.set("v.formURL", bol_URL);
        cmp.set("v.formToDisplay", 'BOL');
        cmp.set("v.loadName", row.Name);
        cmp.set("v.displayForm", true);
    }
});