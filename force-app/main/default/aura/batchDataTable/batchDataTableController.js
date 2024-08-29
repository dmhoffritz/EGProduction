({
    init: function (cmp, event, helper) {
        helper.styleData(cmp);
        helper.setColumns(cmp);
        helper.groupDataByJob(cmp);
    },
    
    handleRowAction: function(cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                console.log("Showing details for load w/ id: " + row.Id);
                helper.showRowDetails(cmp, row);
                break;
            case 'view':
                helper.showRowDetails(cmp, row);
                break;
        }
    },
    
    handleSelect: function (component, event, helper) {
        console.log("EVT:");
        console.log(JSON.parse(JSON.stringify(event)));
        // Get the selected rows from the event
        var selectedRows = event.getParam('selectedRows');
        // Get the job number of the selected datatable
        var jobNumber = event.getSource().get('v.id');
        
        // Find the company and job objects within the dataGroupedByJob
        var dataGroupedByJob = component.get('v.dataGroupedByJob');
        var companyObj, jobObj;
        
        for (var i = 0; i < dataGroupedByJob.length; i++) {
          var company = dataGroupedByJob[i];
          for (var j = 0; j < company.jobs.length; j++) {
            var job = company.jobs[j];
            if (job.jobNumber === jobNumber) {
              companyObj = company;
              jobObj = job;
              break;
            }
          }
          if (jobObj) {
            break;
          }
        }
        
        // Update the selected rows in the job's tableData
        if (jobObj) {
          jobObj.tableData.selectedRows = selectedRows;

          component.set("v.editedDataGroupedByJob", dataGroupedByJob);
        }
        
        console.log("EDITED DATA:");
        console.log(JSON.parse(JSON.stringify(component.get("v.editedDataGroupedByJob"))));

    },
    
    invoiceSelectedLoads: function(component, event, helper) {
        //var tableId = evt.target.name;
        // Get the job number of the selected button
        var jobNumber = event.target.name;
        
        // Find the job object within the editedDataGrouedByJob
        var dataGroupedByJob = component.get("v.editedDataGroupedByJob");
        
        console.log("Scanning following data for invoicing:");
        console.log(JSON.parse(JSON.stringify(dataGroupedByJob)));
        var jobObj;
        
        for (var i = 0; i < dataGroupedByJob.length; i++) {
          var company = dataGroupedByJob[i];
          for (var j = 0; j < company.jobs.length; j++) {
            var job = company.jobs[j];
            if (job.jobNumber === jobNumber) {
              jobObj = job;
              break;
            }
          }
          if (jobObj) {
            break;
          }
        }
        
        // Get the selected rows from the job's tableData
        var selectedRows = jobObj.tableData.selectedRows;
        console.log("Found the following selected rows:");
        console.log(selectedRows);
        
        // Perform further processing or invoke the necessary actions with the selected rows
        // ...
        
        component.set("v.selectedLoads", selectedRows);
        component.set("v.displayBatch", true);
    },
    
    
    closeModal : function (cmp, event, helper) {
        cmp.set("v.displayBatch", false);
        setTimeout(() => {
            helper.groupDataByJob(cmp);
        }, 1000);
    }
})