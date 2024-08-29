({
    organizeStages : function(cmp) {
        var stages = ["Assigned", "Dispatched", "Arrived for pickup", "Loaded In Transit", "Arrived for delivery", "Delivered", "Bill/POD Received", "Processed for Payment"];
        var load_status = cmp.get("v.load.FreightTM__Status__c");
        var bill_status = cmp.get("v.load.FreightTM__Bill_Status__c");
        var pay_status = cmp.get("v.load.FreightTM__Pay_Status__c");
        var earlier_stages = true;
        var later_stages = false;

        for(var i = 0; i < stages.length; i++) {
            var stage_id = stages[i].replaceAll(' ', '_');
            var cmpTarget = cmp.find(stage_id);
            switch(load_status != "Delivered") {
                case true: 
                    if(earlier_stages == true) {
                        $A.util.addClass(cmpTarget, 'slds-is-complete');
                    }
                    if(later_stages == true) {
                        $A.util.addClass(cmpTarget, 'slds-is-incomplete');
                    }
                    if(stages[i] == load_status) {
                        $A.util.removeClass(cmpTarget, 'slds-is-complete');
                        $A.util.addClass(cmpTarget, 'slds-is-current');
                        $A.util.addClass(cmpTarget, 'slds-is-active');
                        cmp.set("v.carrierStage", stages[i]);
                        earlier_stages = false;
                        later_stages = true;
                    }
                    break;
                case false:
                    if((bill_status == null && pay_status == null) || bill_status == "Bill/POD Needed") {
                        if(earlier_stages == true) {
                            $A.util.addClass(cmpTarget, 'slds-is-complete');
                        }
                        if(later_stages == true) {
                            $A.util.addClass(cmpTarget, 'slds-is-incomplete');
                        }
                        if(stages[i] == "Delivered") {
                            $A.util.removeClass(cmpTarget, 'slds-is-complete');
                            $A.util.addClass(cmpTarget, 'slds-is-current');
                            $A.util.addClass(cmpTarget, 'slds-is-active');
                            cmp.set("v.carrierStage", "Delivered");
                            earlier_stages = false;
                            later_stages = true;
                        }
                    }
                    else if((bill_status != "Bill/POD Needed" && pay_status != "Processed for Payment")) {
                        if(earlier_stages == true) {
                            $A.util.addClass(cmpTarget, 'slds-is-complete');
                        }
                        if(later_stages == true) {
                            $A.util.addClass(cmpTarget, 'slds-is-incomplete');
                        }
                        if(stages[i] == "Bill/POD Received") {
                            $A.util.removeClass(cmpTarget, 'slds-is-complete');
                            $A.util.addClass(cmpTarget, 'slds-is-current');
                            $A.util.addClass(cmpTarget, 'slds-is-active');
                            cmp.set("v.carrierStage", "Bill Received");
                            earlier_stages = false;
                            later_stages = true;
                        }
                    }
                    
                        else if(pay_status == "Processed for Payment") {
                            if(earlier_stages == true) {
                                $A.util.addClass(cmpTarget, 'slds-is-complete');
                            }
                            if(later_stages == true) {
                                $A.util.addClass(cmpTarget, 'slds-is-incomplete');
                            }
                            if(stages[i] == "Processed for Payment") {
                                $A.util.removeClass(cmpTarget, 'slds-is-complete');
                                $A.util.addClass(cmpTarget, 'slds-is-current');
                                $A.util.addClass(cmpTarget, 'slds-is-active');
                                cmp.set("v.carrierStage", "Payment Processed");
                                earlier_stages = false;
                                later_stages = true;
                            }
                        }
                    
                    
                    break;
            }
            
            
        }
        
    }
})