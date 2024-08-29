({
    styleData: function (cmp) {
        var load_list = cmp.get("v.data") 
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
    },
    
    setColumns : function(cmp) {
        var actions = [];
        var cols = [
            {label: 'Load #', fieldName: 'Name', type: 'button', initialWidth: 125, iconName: 'utility:truck', typeAttributes: {label: {fieldName: 'Name'}, name: 'view_details', title: 'Click to View Details'}},
            {label: 'Carrier Load #', fieldName: 'Reference_Number__c', type: 'text', iconName: 'utility:truck', cellAttributes: {alignment: 'center'}},
            { label: 'Origin --> Destination', fieldName: 'FreightTM__Calendar_Load__c', type: 'text', initialWidth: 225, iconName: 'utility:location' },
            {label: 'Quantity', fieldName: 'Quantity__c', type: 'text', iconName: 'utility:product_service_campaign', initialWidth: 150, cellAttributes: {alignment: 'center'}},
            {label: 'Commodity', fieldName: 'FreightTM__Commodity__c', type: 'text', iconName: 'utility:price_book_entries', initialWidth: 150, cellAttributes: {alignment: 'center'}},
            {label: 'Date Delivered', fieldName: 'FreightTM__Delivery_Arrival__c', type: 'date', iconName: 'utility:event', cellAttributes: {alignment: 'center'}, typeAttributes: {day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12:true}},
            {label: 'Bill Status', fieldName: 'bill_status', type: 'text', iconName: 'utility:product_warranty_term',
             cellAttributes: { alignment: 'center'}},
            {label: 'Rate', fieldName: 'FreightTM__Total_Rate_to_Carrier__c', type: 'currency', iconName: 'utility:money', cellAttributes: { alignment: 'center'}}
        ];
        for (var i = 0; i < cols.length; i++) {
            cols[i].hideDefaultActions = 'true';
        }
        
        cmp.set("v.columns", cols);
		        
    },
    
    groupDataByJob : function(cmp) {
        console.log("Grouping data by job...");
        var data = cmp.get("v.data");
        console.log("Grouping following data:");
        console.log(JSON.parse(JSON.stringify(data)));
        var dataGroupedByJob = [];
        
        data.forEach(function(record) {
          var company = record.FreightTM__Commodity__c.includes('#') ? 'Empire Service Loads' : 'Empire Mat Loads';
          var job = '';
          if (record.Delivery_Ref_Job__c != undefined && record.Delivery_Ref_Job__c != null) {
            job = record.FreightTM__Delivery_Ref__c;
          } else if (record.Pickup_Ref_Job__c != undefined && record.Pickup_Ref_Job__c != null) {
            job = record.FreightTM__Pickup_Ref__c;
          } else {
            job = record.FreightTM__Calendar_Load__c;
          }
          var load = record;
        
          // Find the company object within dataGroupedByJob
          var companyObj = dataGroupedByJob.find(function(item) {
            return item.companyName === company;
          });
        
          // If the company object doesn't exist, create a new one and add it to dataGroupedByJob
          if (!companyObj) {
            companyObj = {
              companyName: company,
              jobs: []
            };
            dataGroupedByJob.push(companyObj);
          }
        
          // Find the job object within the company object
          var jobObj = companyObj.jobs.find(function(item) {
            return item.jobNumber === job;
          });
        
          // If the job object doesn't exist, create a new one and add it to the company object
          if (!jobObj) {
            jobObj = {
              jobNumber: job,
              tableData: {
                columns: cmp.get("v.columns"),
                data: [],
                selectedRows: []
              }
            };
            companyObj.jobs.push(jobObj);
          }
        
          // Add the load record to the corresponding job's data array
          jobObj.tableData.data.push(record);
        });
        
        console.log("Mapped data:");
        console.log(JSON.parse(JSON.stringify(dataGroupedByJob)));
        

        cmp.set("v.dataGroupedByJob", dataGroupedByJob);
    },
    
    //Fire event to be handled from VF Page
    showRowDetails : function(cmp, row) {
        var updateEvent = $A.get("e.c:navLoad");
        updateEvent.setParams({"navItem": "load_detail", "recordId": row.Id});
        updateEvent.fire();
    }
    
})