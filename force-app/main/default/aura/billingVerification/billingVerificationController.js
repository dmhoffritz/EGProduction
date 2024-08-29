({
    init : function(cmp, event, helper) {
        console.log("Verifying Billing Info for Carrier: ");
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
                "label": "Florida",
                "value": "FL"
            },
            {
                "label": "Georgia",
                "value": "GA"
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
                "label": "Pennsylvania",
                "value": "PA"
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
        cmp.set("v.stateOptions", states);

        helper.getFactoringCompanies(cmp);
    },

    handleFactoringIndication: function (cmp, event, helper) {

        cmp.set("v.loading", true);
        let selection = cmp.get("v.isFactoring");
        if (selection) {
            //show factoring company selection
            $A.util.addClass(cmp.find('checkbox'), 'checkboxColumn');
        } else {
            //hide factoring company selection
            $A.util.removeClass(cmp.find('checkbox'), 'checkboxColumn');
        }

        cmp.set("v.loading", false);
    },

    chooseFactoringComp: function (cmp, event, helper) {
        let selection = cmp.get("v.selectedCompany");
        helper.fetchFactoringCompany(cmp, selection);
    },

    chooseContact: function (cmp, event, helper) {
        let selection = cmp.find('contactSelection').get('v.value');
        if (selection == "add") {
            //pop-up new contact modal
            cmp.set("v.newContactModal", true);
        } else if (selection == "") {
            //do nothing
        }
        else {
            helper.fetchContact(cmp, selection);
        }

    },

    saveCarrier: function (cmp, event, helper) {
        helper.updateCarrier(cmp);
        //helper.saveNewContact(cmp);
    },

    saveFactoring: function (cmp, event, helper) {
        helper.updateFactoring(cmp);
    },

    newContact: function (cmp, event, helper) {
        helper.saveNewContact(cmp);
    },

    closeModal: function (cmp, event, helper) {
        console.log("Closing modal...");
        cmp.set("v.newContactModal", false);
    }
})