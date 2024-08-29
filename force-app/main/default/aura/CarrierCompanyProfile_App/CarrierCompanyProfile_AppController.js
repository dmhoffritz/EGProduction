({
    init : function(cmp, event, helper) {
        console.log("INITIALIZING CARRIER COMPANY PROFILE APP");
        var states = [
            {
                "label": "Alabama",
                "value": "AL"
            },
            {
                "label": "Alaska",
                "value": "AK"
            },
            {
                "label": "American Samoa",
                "value": "AS"
            },
            {
                "label": "Arizona",
                "value": "AZ"
            },
            {
                "label": "Arkansas",
                "value": "AR"
            },
            {
                "label": "California",
                "value": "CA"
            },
            {
                "label": "Colorado",
                "value": "CO"
            },
            {
                "label": "Connecticut",
                "value": "CT"
            },
            {
                "label": "Delaware",
                "value": "DE"
            },
            {
                "label": "District Of Columbia",
                "value": "DC"
            },
            {
                "label": "Federated States Of Micronesia",
                "value": "FM"
            },
            {
                "label": "Florida",
                "value": "FL"
            },
            {
                "label": "Georgia",
                "value": "GA"
            },
            {
                "label": "Guam",
                "value": "GU"
            },
            {
                "label": "Hawaii",
                "value": "HI"
            },
            {
                "label": "Idaho",
                "value": "ID"
            },
            {
                "label": "Illinois",
                "value": "IL"
            },
            {
                "label": "Indiana",
                "value": "IN"
            },
            {
                "label": "Iowa",
                "value": "IA"
            },
            {
                "label": "Kansas",
                "value": "KS"
            },
            {
                "label": "Kentucky",
                "value": "KY"
            },
            {
                "label": "Louisiana",
                "value": "LA"
            },
            {
                "label": "Maine",
                "value": "ME"
            },
            {
                "label": "Marshall Islands",
                "value": "MH"
            },
            {
                "label": "Maryland",
                "value": "MD"
            },
            {
                "label": "Massachusetts",
                "value": "MA"
            },
            {
                "label": "Michigan",
                "value": "MI"
            },
            {
                "label": "Minnesota",
                "value": "MN"
            },
            {
                "label": "Mississippi",
                "value": "MS"
            },
            {
                "label": "Missouri",
                "value": "MO"
            },
            {
                "label": "Montana",
                "value": "MT"
            },
            {
                "label": "Nebraska",
                "value": "NE"
            },
            {
                "label": "Nevada",
                "value": "NV"
            },
            {
                "label": "New Hampshire",
                "value": "NH"
            },
            {
                "label": "New Jersey",
                "value": "NJ"
            },
            {
                "label": "New Mexico",
                "value": "NM"
            },
            {
                "label": "New York",
                "value": "NY"
            },
            {
                "label": "North Carolina",
                "value": "NC"
            },
            {
                "label": "North Dakota",
                "value": "ND"
            },
            {
                "label": "Northern Mariana Islands",
                "value": "MP"
            },
            {
                "label": "Ohio",
                "value": "OH"
            },
            {
                "label": "Oklahoma",
                "value": "OK"
            },
            {
                "label": "Oregon",
                "value": "OR"
            },
            {
                "label": "Palau",
                "value": "PW"
            },
            {
                "label": "Pennsylvania",
                "value": "PA"
            },
            {
                "label": "Puerto Rico",
                "value": "PR"
            },
            {
                "label": "Rhode Island",
                "value": "RI"
            },
            {
                "label": "South Carolina",
                "value": "SC"
            },
            {
                "label": "South Dakota",
                "value": "SD"
            },
            {
                "label": "Tennessee",
                "value": "TN"
            },
            {
                "label": "Texas",
                "value": "TX"
            },
            {
                "label": "Utah",
                "value": "UT"
            },
            {
                "label": "Vermont",
                "value": "VT"
            },
            {
                "label": "Virgin Islands",
                "value": "VI"
            },
            {
                "label": "Virginia",
                "value": "VA"
            },
            {
                "label": "Washington",
                "value": "WA"
            },
            {
                "label": "West Virginia",
                "value": "WV"
            },
            {
                "label": "Wisconsin",
                "value": "WI"
            },
            {
                "label": "Wyoming",
                "value": "WY"
            }
        ];
        cmp.set("v.state_options", states);
        if(cmp.get("v.userType") == 'Factoring_Company') {
            //cmp.set("v.billingToggle", true);
        }
		helper.getCarrier(cmp);
    },
    
    editInfo : function(cmp, event, helper) {
        cmp.set("v.enableEdit", true);
        cmp.set("v.disableEdit", false);
        this.toggleContact(cmp);
    },
    
    editBillingInfo : function(cmp, event, helper) {
        cmp.set("v.enableBillingEdit", true);
        cmp.set("v.disableBillingEdit", false);
    },
    
   handleSave : function(cmp, event, helper) {
        var r_type = cmp.get('v.userType');

        if(r_type == 'Factoring_Company') {
            var factorer = cmp.get('v.related_factorer');
            var action = cmp.get('c.saveFactorer');
            action.setParams(
                {
                    "updatedFactorer": factorer
                }
            );
            action.setCallback(this, function(res) {
                var status = res.getState();
                var update_status = res.getReturnValue();
                console.log("Update Status: " + update_status);

                if(status === "SUCCESS") {
                    console.log('SUCCESSFULLY SAVED VALUES');
                    cmp.set('v.displaySuccess', true);
                    cmp.set("v.enableEdit", false);
                    cmp.set("v.disableEdit", true);
                    cmp.set("v.enableBillingEdit", false);
                    cmp.set("v.disableBillingEdit", true);
                    helper.getCarrier(cmp);
                }                     else if (status === "ERROR") {
                        var errors = res.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error Whenever Saving Factoring Data: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });

        } else {
            let c = cmp.get("v.related_carrier");
            let carrierId = c.Id;
            let carrierContact = c.FreightTM__Primary_Contact__c;
            let carrierPhone = c.FreightTM__Phone__c;
            let carrierTitle = c.FreightTM__Title__c;
            let carrierEmail = c.FreightTM__Email__c;
            let carrierWeb = c.FreightTM__Website__c;
            let carrierFax = c.FreightTM__Fax__c;
            let billingContact = c.Billing_Contact__c;
            let billingPhone = c.Billing_Phone__c;
            let billingEmail = c.Billing_Email__c;
            let billingStreet = c.FreightTM__Billing_Address__c;
            let billingCity = c.FreightTM__Billing_City__c;
            let billingState = c.FreightTM__Billing_State_Province__c;
            let billingZip = c.FreightTM__Billing_Zip_Code__c;
            //var carrier = cmp.get('v.related_carrier');
            var action = cmp.get('c.saveCarrier');
            action.setParams(
                {
                    "carrierId": carrierId,
                    "carrierContact": carrierContact,
                    "carrierPhone": carrierPhone,
                    "carrierTitle": carrierTitle,
                    "carrierEmail": carrierEmail,
                    "carrierWeb": carrierWeb,
                    "carrierFax": carrierFax,
                    "billingContact": billingContact,
                    "billingEmail": billingEmail,
                    "billingPhone": billingPhone, 
                    "billingStreet": billingStreet,
                    "billingCity": billingCity,
                    "billingState": billingState,
                    "billingZip": billingZip
                }
            );
            action.setCallback(this, function(res) {
                var status = res.getState();
                var update_status = res.getReturnValue();
                console.log("Update Status: " + update_status);
                if(status === "SUCCESS") {
                    console.log('SUCCESSFULLY SAVED VALUES');
                    cmp.set('v.displaySuccess', true);
                    cmp.set("v.enableEdit", false);
                    cmp.set("v.disableEdit", true);
                    cmp.set("v.enableBillingEdit", false);
                    cmp.set("v.disableBillingEdit", true);
                    helper.getCarrier(cmp);
                }                    else if (status === "ERROR") {
                        var errors = res.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error Whenever Saving Carrier Data: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
        }

        $A.enqueueAction(action);
        
   },
    
    toggleContact : function(cmp, event, helper) {
        console.log("Toggling Contact");
        var toggle_status = cmp.get("v.contact_toggle");
        var cmpTarget = cmp.find('displayContact');
        if(toggle_status == false) {
            $A.util.removeClass(cmpTarget, 'contact_panel');
            cmp.set("v.contact_toggle", true);
        } else {
            $A.util.addClass(cmpTarget, 'contact_panel');
            cmp.set("v.contact_toggle", false);
        }
    },
    
    toggleBilling : function(cmp, event, helper) {
        console.log("Toggling Billing");
        var toggle_status = cmp.get("v.billing_toggle");
        var cmpTarget = cmp.find('displayBilling');
        if(toggle_status == false) {
            $A.util.removeClass(cmpTarget, 'billing_panel');
            cmp.set("v.billing_toggle", true);
        } else {
            $A.util.addClass(cmpTarget, 'billing_panel');
            cmp.set("v.billing_toggle", false);
        }
    },
    toggleCredentials : function(cmp, event, helper) {
        var toggle_status = cmp.get("v.credential_toggle");
        var cmpTarget = cmp.find('displayCredentials');
        if(toggle_status == false) {
            $A.util.removeClass(cmpTarget, 'credential_panel');
            cmp.set("v.credential_toggle", true);
        } else {
            $A.util.addClass(cmpTarget, 'credential_panel');
            cmp.set("v.credential_toggle", false);
        }
    },
    toggleInsurance : function(cmp, event, helper) {
        console.log("Toggling insurance");
        var toggle_status = cmp.get("v.insurance_toggle");
        var cmpTarget = cmp.find('displayInsurance');
        if(toggle_status == false) {
            $A.util.removeClass(cmpTarget, 'insurance_panel');
            cmp.set("v.insurance_toggle", true);
        } else {
            $A.util.addClass(cmpTarget, 'insurance_panel');
            cmp.set("v.insurance_toggle", false);
        }
    },
    closeToast: function(cmp) {
        cmp.set("v.displaySuccess", false);
    }
})