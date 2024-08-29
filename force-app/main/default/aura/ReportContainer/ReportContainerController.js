({
    getReport : function(component, event, helper) {
        //hide report and show spinner while we process
        debugger;
        var loadingSpinner = component.find('loading');
        $A.util.removeClass(loadingSpinner, 'slds-hide');
        var reportContainer = component.find('report');
        $A.util.addClass(reportContainer, 'slds-hide');
        var reportError = component.find('report-error');
        $A.util.addClass(reportError, 'slds-hide');

        

        //get report data from Apex controller using report ID provided
        var action = component.get('c.getReportMetadata');
        action.setParams({ 
            reportId: component.get("v.reportIdAttribute"),
            includeDetailAttribute: component.get("v.includeDetailAttribute")
        });

        //handle response from Apex controller
        action.setCallback(this, function(response){
            // transform into JSON object
            var returnValue = JSON.parse(response.getReturnValue());
            var groupingLabels = {};
            
            if( returnValue && returnValue.reportExtendedMetadata ){
                // categorize groupings into levels so we can access them as we go down grouping level
                var columnInfo = returnValue.reportExtendedMetadata.groupingColumnInfo;
                for( var property in columnInfo ){
                    if( columnInfo.hasOwnProperty(property) ){
                        var level = columnInfo[property].groupingLevel;
                        var label = columnInfo[property].label;
                        groupingLabels[level] = label;
                    }
                }
                // set lightning attributes so we have access to variables in the view
                component.set("v.groupingLevelToLabel", groupingLabels)
                component.set("v.reportData", returnValue);
                component.set("v.factMap", returnValue.factMap);
                
                var includeDetailAttribute = component.get('v.includeDetailAttribute');
                if (includeDetailAttribute) {
                    // get all aggregated columns, 
                    var aggColumns = [];
                    var aggColumnsLabel = [];
                    var tableHeaders = [];
                    var isRowCountExists = false;

                    for( var i = 0; i < returnValue.reportMetadata.aggregates.length; i++ ){
                        var fieldAPIName = returnValue.reportMetadata.aggregates[i];
                        var fieldLabel = returnValue.reportExtendedMetadata.aggregateColumnInfo[fieldAPIName].label;

                        if (fieldAPIName == 'RowCount') {
                            isRowCountExists = true;
                        }

                        // only capture the one starting with !
                        // coz there are patterns like s!, m!, mx!, a!,
                        var pos1 = fieldAPIName.indexOf('!');
                        aggColumns.push(fieldAPIName.substring(pos1+1));
                        aggColumnsLabel.push (fieldLabel);

                    }

                    //get column headers, this assumes that they are returned in order
                    var aggColumnsPos = [];
                    
                    for( var i = 0; i < returnValue.reportMetadata.detailColumns.length; i++ ){
                        var fieldAPIName = returnValue.reportMetadata.detailColumns[i];
                        var fieldLabel = returnValue.reportExtendedMetadata.detailColumnInfo[fieldAPIName].label;
                        var aggColumnsLabel1 = [];

                        for (var j=0; j< aggColumns.length; j++) {
                            if (aggColumns[j] == '') {
                                continue;
                            }

                            if (fieldAPIName == aggColumns[j]) {
                                // 1. push the aggregagte column name, take the first word before space (Sum, Min, Max, Avg)
                                // 2. set aggregate column api name to blank
                                // note that there may be multiple match due to the patterns will be stored in aggColumnsLabel1
                                var theLabel = aggColumnsLabel[j];
                                var pos1 = theLabel.indexOf(' ');
                                if (pos1 > 0) {
                                    theLabel = theLabel.substring(0, pos1);
                                }
                                aggColumnsLabel1.push(theLabel);
                                aggColumns[j] = '';
                            }
                        }

                        aggColumnsPos.push(aggColumnsLabel1);
                        tableHeaders.push(fieldLabel);
                    }

                    if (isRowCountExists) {
                        // add the rowcount column if there is such thing
                        tableHeaders.push('Record Count');
                        var aggColumnsLabel2 = [];
                        aggColumnsLabel2.push('Sum');
                        aggColumnsPos.push(aggColumnsLabel2);
                    }
                    
                    component.set("v.columnLabels", tableHeaders);
                    component.set("v.aggColumnsPosition", aggColumnsPos);
                } else {
                    // these are aggregated column value
                    var tableHeaders = [];
                    var aggColumnsPos = [];
                    for( var i = 0; i < returnValue.reportMetadata.aggregates.length; i++ ){
                        var fieldAPIName = returnValue.reportMetadata.aggregates[i];
                        var fieldLabel = returnValue.reportExtendedMetadata.aggregateColumnInfo[fieldAPIName].label;
                        tableHeaders.push(fieldLabel);
                        aggColumnsPos.push(i);
                    }
                    component.set("v.columnLabels", tableHeaders);
                    component.set("v.aggColumnsPosition", aggColumnsPos);
                }
                
                //hide spinner, reveal data
                $A.util.addClass(loadingSpinner, 'slds-hide');
                $A.util.removeClass(reportContainer, 'slds-hide');
            }
            else {
                $A.util.addClass(loadingSpinner, 'slds-hide');
                $A.util.removeClass(reportError, 'slds-hide');
            }
        })
        $A.enqueueAction(action);
    }
})