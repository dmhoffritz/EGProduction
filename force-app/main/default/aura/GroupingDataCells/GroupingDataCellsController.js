({
	doInit : function(component, event, helper) {
		var factMap = component.get("v.factMap");
		var includeDetailAttribute = component.get("v.includeDetailAttribute");
		var isAggregateRow = component.get("v.isAggregateRow");
		if( factMap ){
			var groupingKey = component.get("v.groupingKey");

			if (includeDetailAttribute) {
				if (isAggregateRow == 'no') {
					component.set("v.dataRows", factMap[groupingKey+"!T"].rows);
				} else {
					// refomulate the data so that it can extract easily in lightning component
					var aggColumnsPosition = component.get("v.aggColumnsPosition");
					var tmpAgg = factMap[groupingKey+"!T"].aggregates;
					var theCount = 0;
					var aggLabelValue = [];
					for( var i = 0; i < aggColumnsPosition.length; i++ ){
						var labels = aggColumnsPosition[i];
						var labels1 = [];
						for( var j = 0; j < labels.length; j++ ){
							labels1[j] = labels[j] + ": " + tmpAgg[theCount].label;
							theCount++;
						}
						aggLabelValue.push(labels1);
					}
					component.set("v.aggLabelValue", aggLabelValue);				}
			} else {
				component.set("v.dataRows", factMap[groupingKey+"!T"].aggregates);
			}
		}
	},
	editRecord : function (component, event, helper) {
		var recordId = event.currentTarget.dataset.recordid;
		var editRecordEvent = $A.get("e.force:editRecord");
		editRecordEvent.setParams({
			 "recordId": recordId
		});
		editRecordEvent.fire();
	}
})