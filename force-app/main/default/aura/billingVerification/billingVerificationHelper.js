({
    getFactoringCompanies : function(cmp) {
        let action = cmp.get("c.factoringCompanyQuery");
        action.setCallback(this, function (res) {
            let state = res.getState();
            console.log("CALLBACK STATE: " + state);
            if (state === "SUCCESS") {
                //store analytics
                console.log("Successfully fetched factoring company data");
                let companies = res.getReturnValue();
                companies.unshift(
                    {
                        Id: '',
                        Name: '--SELECT FACTORING COMPANY --'
                    }
                );
                cmp.set("v.factoringCompanies", companies);

                cmp.set("v.loading", false);
            }
            else if (state === "INCOMPLETE") {
                //do something
            }
            else if (state === "ERROR") {
                console.log("UNABLE TO QUERY FACTORING COMPANIES");
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }

                cmp.set("v.loading", false);
            }
            else {
                //throw error
                console.log("UNABLE TO QUERY FACTORING COMPANIES");
                console.log("UNKNOWN ERROR");
                cmp.set("v.loading", false);
            }

            cmp.set("v.initialized", true);
        });

        $A.enqueueAction(action);
    },

    fetchFactoringCompany: function (cmp, companyId) {
        let action = cmp.get("c.fetchFactoringCompany");
        action.setParams(
            {
                factoringId: companyId
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            console.log("CALLBACK STATE: " + state);
            if (state === "SUCCESS") {
                //store analytics
                console.log("Successfully fetched factoring company data");

                let company = res.getReturnValue();
                cmp.set("v.factoringCompany", company);
                let contacts = [];
                if (company.Billing_Contacts__r == null) {
                    //need to add a billing contact
                    //cmp.set("v.newContactModal", true);
                } else {
                    for (let i = 0; i < company.Billing_Contacts__r.length; i++) {
                        contacts.push(company.Billing_Contacts__r[i]);
                    }

                }
                contacts.push(
                    {
                        Id: 'add',
                        Name: '+ Add Contact'
                    }
                );
                contacts.unshift({
                    Id: '',
                    Name: '--SELECT A CONTACT--'
                });
                cmp.set("v.factoringContacts", contacts);
                cmp.set("v.selectedContact", contacts[0]);

            }
            else if (state === "INCOMPLETE") {
                //do something
            }
            else if (state === "ERROR") {
                console.log("UNABLE TO FETCH FACTORING COMPANY DATA");
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
            else {
                //throw error
                console.log("UNABLE TO FETCH FACTORING COMPANY DATA");
                console.log("UNKNOWN ERROR");
            }

        });

        $A.enqueueAction(action);
    },

   updateCarrier: function (cmp) {
        let record = cmp.get("v.Carrier");
        let action = cmp.get("c.updateBilling");
        action.setParams({
                recordId: record.Id,
                billingContact: record.Billing_Contact__c,
                billingPhone: record.Billing_Phone__c,
                billingEmail: record.Billing_Email__c,
                billingStreet: record.FreightTM__Address__c,
                billingCity: record.FreightTM__City__c,
                billingState: record.FreightTM__State_Province__c,
                billingZip: record.FreightTM__Zip_Code__c
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            console.log("CALLBACK STATE: " + state);
            if (state === "SUCCESS") {
                //store analytics
                console.log("Successfully updated Carrier Data");
                cmp.set("v.Carrier", res.getReturnValue());
                this.navRegistration(cmp);

            }
            else if (state === "INCOMPLETE") {
                //do something
            }
            else if (state === "ERROR") {
                console.log("UNABLE TO UPDATE CARRIER");
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
            else {
                //throw error
                console.log("UNABLE TO UPDATE CARRIER");
                console.log("UNKNOWN ERROR");
            }

        });

        $A.enqueueAction(action);
    },

    updateFactoring : function(cmp) {
        let record = cmp.get("v.Carrier");
        let factoringComp = cmp.get("v.factoringCompany");
        let contact = cmp.get("v.selectedContact");
        record.FactoringCompany_obj__c = factoringComp;
        record.FC_Billing_Contact__c = contact.Id;
        let action = cmp.get("c.updateFactoringCompany");
        action.setParams({
                carrierId: record.Id,
                factoringCompanyId: record.FactoringCompany_obj__c.Id,
                billingContactId: record.FC_Billing_Contact__c
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            console.log("CALLBACK STATE: " + state);
            if (state === "SUCCESS") {
                //store analytics
                console.log("Successfully updated Factoring Company Data");
                cmp.set("v.Carrier", res.getReturnValue());
                this.navRegistration(cmp);
                /*
                record.Billing_Contact__c = contact.Name;
                record.Billing_Email__c = contact.Email;
                record.Billing_Phone__c = contact.Phone;
                */
                //record.FC_Billing_Contact__c = contact.Id;
                //cmp.set("v.Carrier", record);
                //this.updateCarrier(cmp);

            }
            else if (state === "INCOMPLETE") {
                //do something
            }
            else if (state === "ERROR") {
                console.log("UNABLE TO UPDATE FACTORING COMPANY");
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
            else {
                //throw error
                console.log("UNABLE TO UPDATE FACTORING COMPANY");
                console.log("UNKNOWN ERROR");
            }

        });

        $A.enqueueAction(action);        
    },

    fetchContact: function (cmp, selection) {
        let contactId = selection;
        let action = cmp.get("c.fetchContact");
        action.setParams(
            {
                recordId: contactId
            }
        );
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                console.log("Successfully fetched contact record");
                //cmp.find('contactSelection').set('v.value', res.getReturnValue);
                cmp.set("v.selectedContact", res.getReturnValue());
            } else if (state === "INCOMPLETE") {
                //do something
            } else if (state === "ERROR") {
                console.log("UNABLE TO FETCH CONTACT");
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            } else {
                //throw error
                console.log("UNABLE TO FETCH CONTACT");
                console.log("UNKNOWN ERROR");
            }
        });

        $A.enqueueAction(action);
    },

    saveNewContact: function (cmp) {
        
        let contactFirstName = cmp.get("v.newContact_FirstName");
        let contactLastName = cmp.get("v.newContact_LastName");
        let contactPhone = cmp.get("v.newContact_Phone");
        let contactEmail = cmp.get("v.newContact_Email");
        let factoringCompId = cmp.get("v.selectedCompany");
        console.log("-- NEW CONTACT PARAMS --");
        console.log("First Name: " + contactFirstName);
        console.log("Last Name: " + contactLastName);
        console.log("Contact Phone: " + contactPhone);
        console.log("Contact Email: " + contactEmail);
        let saveCarrierAction = cmp.get("c.saveContact");
        saveCarrierAction.setParams({
                firstName: contactFirstName,
                lastName: contactLastName,
                phone: contactPhone,
                email: contactEmail,
                factoringCompanyId: factoringCompId
        }); 
        saveCarrierAction.setCallback(this, function (res) {
            let state = res.getState();
            console.log("CALLBACK STATE: " + state);
            if (state === "SUCCESS") {
                //store analytics
                console.log("Successfully stored new contact");
                let contacts = cmp.get("v.factoringContacts");
                contacts.unshift(res.getReturnValue());
                cmp.set("v.factoringContacts", contacts);
                cmp.set("v.newContactModal", false);

                cmp.set("v.selectedContact", res.getReturnValue());
                cmp.find('contactSelection').set('v.value', res.getReturnValue().Id);
                cmp.set("v.newContact_FirstName", '');
                cmp.set("v.newContact_LastName", '');
                cmp.set("v.newContact_Phone", '');
                cmp.set("v.newContact_Email", '');
            
            }
            else if (state === "INCOMPLETE") {
                //do something
            }
            else if (state === "ERROR") {
                console.log("UNABLE TO STORE NEW CONTACT");
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
            else {
                //throw error
                console.log("UNABLE TO STORE NEW CONTACT");
                console.log("UNKNOWN ERROR");
            }

        });

        $A.enqueueAction(saveCarrierAction);  
    },

    navRegistration: function (cmp) {
        let navEvent = $A.get("e.c:navRegistration");
        navEvent.setParams(
            {
                "navTo": "registration"
            }
        );
        navEvent.fire();
    }
})