/**
 * Created by Jai Chaturvedi on 29/05/2017.
 */
({
    loadValues : function (component) {
        var record = component.get("v.record");
        var subheading = '';
        for(var i=0; i<component.get("v.subHeadingFieldsAPI").length ;i++ ){
            if(record[component.get("v.subHeadingFieldsAPI")[i]]){
                subheading = subheading + record[component.get("v.subHeadingFieldsAPI")[i]] + ' • ';
            }
        }
        subheading = subheading.substring(0,subheading.lastIndexOf('•'));
        component.set("v.subHeadingFieldValues", subheading);
    },

    choose : function (component,event) {
        var chooseEvent = component.getEvent("lookupChoose");
        chooseEvent.setParams({
            "recordId" : component.get("v.record").recordId,
            "recordLabel":component.get("v.record").recordName
        });
        chooseEvent.fire();
        console.log('event fired');
    }
})