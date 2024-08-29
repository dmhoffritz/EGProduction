/**
* An apex class that creates a portal user
*/
global without sharing class Carrier_Registration {
    public FreightTM__Carrier__c Carrier {get; set;}
    public List<Factoring_Company__c> FactoringCompanies {get; set;}
    public String company_name {get; set;}
    public String primary_contact {get; set;}
    public String first_name {get; set;}
    public String last_name {get; set;}
    public String username {get; set;}
    public String phone {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String carrier_id {get; set;}
    public Boolean isCarrier {get; set;}
    public Boolean isBroker {get; set;}
    public Boolean isFactorer {get; set;}
    public Boolean error {get; set;}
    public Boolean verifyCarrier {get; set;}
    public Boolean verifyBilling {get; set;}
    public Boolean registerUser {get; set;}
    public Boolean factoring {get; set;}
    public List<SelectOption> factoringNames {get; set;}
    public String factorer {get; set;}
    public List<SelectOption> states {get; set;}
    public List<SelectOption> selectedStates {get; set;}
    public String state {get; set;}


    public Boolean agree {get; set;}
    /*
Name, FactoringCompany_obj__c, FreightTM__Primary_Contact__c,
                    FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Address__c,
                    FreightTM__City__c, FreightTM__State_Province__c, FreightTM__Zip_Code__c,
                    Billing_Contact__c, Billing_Email__c, Billing_Phone__c, FreightTM__Billing_Address__c, 
                    FreightTM__Billing_City__c, FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c 
    */

    public String carrierName {get; set;}
    public String carrierPrimaryContact {get; set;}
    public String carrierPhone {get; set;}
    public String carrierEmail {get; set;}
    public String carrierAddress {get; set;}
    public String carrierCity {get; set;}
    public String carrierZip {get; set;}
    public String billingContact {get; set;}
    public String billingEmail {get; set;}
    public String billingPhone {get; set;}
    public String billingAddress {get; set;}
    public String billingCity {get; set;}
    public String billingState {get; set;}
    public String billingZip {get; set;}

    public List<FreightTM__Carrier__c> relatedCarrier {get; set;}
    
    global Carrier_Registration(ApexPages.StandardController stndCont) {
        System.debug('CARRIER PORTAL REGISTRATION LOG');
        carrier_id = '';
        isCarrier = false;
        isBroker = false;
        isFactorer = false;
        factoringNames = new List<SelectOption> ();
        factorer = '';
        states = new List<SelectOption>();
        selectedStates = new List<SelectOption>();
        carrier_id = ApexPages.currentPage().getParameters().get('id');



        //for test
        //carrier_id = 'a2Q02000000LnqwEAC';

        System.debug('Initializing Registration Form');

        try {
            //initialize local variables from Carrier query
            Carrier = [SELECT Id, Name, FactoringCompany_obj__c, FreightTM__Primary_Contact__c,
                    FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Address__c, Preferred_Lanes__c,
                    FreightTM__City__c, FreightTM__State_Province__c, FreightTM__Zip_Code__c,
                    Billing_Contact__c, Billing_Email__c, Billing_Phone__c, FreightTM__Billing_Address__c, 
                    FreightTM__Billing_City__c, FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c 
            FROM FreightTM__Carrier__c WHERE Id =: carrier_id];

            carrierName = Carrier.Name;
            carrierPrimaryContact = Carrier.FreightTM__Primary_Contact__c;
            carrierPhone = Carrier.FreightTM__Phone__c;
            carrierEmail = Carrier.FreightTM__Email__c;
            carrierAddress = Carrier.FreightTM__Address__c;
            carrierCity = Carrier.FreightTM__City__c;
            carrierZip = Carrier.FreightTM__Zip_Code__c;


            billingContact = Carrier.Billing_Contact__c;
            billingPhone = Carrier.Billing_Phone__c;
            billingEmail = Carrier.Billing_Email__c;
            billingAddress = Carrier.FreightTM__Billing_Address__c;
            billingCity = Carrier.FreightTM__Billing_City__c;
            billingState = Carrier.FreightTM__Billing_State_Province__c;
            billingZip = Carrier.FreightTM__Billing_Zip_Code__c;

            FactoringCompanies = [SELECT Id, Name FROM Factoring_Company__c];
            if(FactoringCompanies.size() > 0) {
                factoringNames.add(new SelectOption('--Select a Factoring Company--', '--Select a Factoring Company--'));
                for(Factoring_Company__c f : FactoringCompanies) {
                    factoringNames.add(new SelectOption(f.Id, f.Name));
                    if(f.Id == Carrier.FactoringCompany_obj__c) {
                        factorer = String.valueOf(f.Id);
                    }
                }
            }

            System.debug(Carrier);

            Schema.DescribeFieldResult stateResult = FreightTM__Carrier__c.FreightTM__State_Province__c.getDescribe();
            List<Schema.PicklistEntry> ple = stateResult.getPicklistValues();
            for(Schema.PicklistEntry pickListVal : ple) {
                if(pickListVal.getValue() == Carrier.FreightTM__State_Province__c) {
                    state = Carrier.FreightTM__State_Province__c;
                    System.debug(state);
                }
                states.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
            }
            System.debug(states);
            //FreightTM__Carrier__c carrier = new FreightTM__Carrier__c(Id = Id.valueOf(carrier_id));
        } catch(Exception e) {
            System.debug(Carrier);
            System.debug('Error whenever relating carrier based on URL id');
            System.debug('Exception: ' + e);
        }
        verifyCarrier = true;
        verifyBilling = false;
        registerUser = false;
        error = false;
        System.debug(Carrier);
    }

    global PageReference goBack() {
        if(verifyBilling) {
            verifyBilling = false;
            verifyCarrier = true;
        } else if(registerUser){
            registerUser = false;
            verifyBilling = true;
        }

        return null;
    }

    global PageReference updateCarrier () {
        system.debug('UPDATING CARRIER INFO');
        try {
            //Carrier.Name = carrierName;
            Carrier.FreightTM__Primary_Contact__c = carrierPrimaryContact;
            Carrier.FreightTM__Phone__c = carrierPhone;
            Carrier.FreightTM__Email__c = carrierEmail;
            Carrier.FreightTM__Address__c = carrierAddress;
            Carrier.FreightTM__City__c = carrierCity;
            Carrier.FreightTM__State_Province__c = state;
            Carrier.FreightTM__Zip_Code__c = carrierZip;

            String multiSelect = '';

            for(SelectOption sel : selectedStates) {
                multiSelect += sel.getValue() + ';';
            }

            Carrier.Preferred_Lanes__c = multiSelect;
            system.debug('Carrier to Update: ');
            system.debug(Carrier);
            update Carrier;
            error = false;
            verifyCarrier = false;
            verifyBilling = true;
            System.debug('SUCCESSFULLY VERIFIED CARRIER INFO');
        } catch (Exception e) {
            System.debug('Error updating Carrier info');
            System.debug('Exception: ' + e);
            error = true;
            //verifyCarrier = false;
            //verifyBilling = true;
        }
        verifyCarrier = false;
        verifyBilling = true;
        return null;
    }

    global PageReference updateBilling () {
        if(factorer == '' || factorer == '--Select a Factoring Company--') {
            Carrier.FactoringCompany_obj__c = null;
        } else {
            System.debug('Setting carrier factorer to id: ');
            System.debug(factorer);
            Carrier.FactoringCompany_obj__c = factorer;
        }
        try {
            Carrier.Billing_Contact__c = billingContact;
            Carrier.Billing_Phone__c = billingPhone;
            Carrier.Billing_Email__c = billingEmail;
            Carrier.FreightTM__Billing_Address__c = billingAddress;
            Carrier.FreightTM__Billing_City__c = billingCity;
            Carrier.FreightTM__Billing_State_Province__c = state;
            Carrier.FreightTM__Billing_Zip_Code__c = billingZip;
            update Carrier;
            error = false;
            verifyBilling = false;
            registerUser = true;
        } catch (Exception e) {
            System.debug('Error whenever updating Carrier Billing info');
            System.debug('Exception: ' + e);
            error = true;
        }          
        
        return null;
    }

    global PageReference registerUser() {
        String recordTypeId = '';
        if(carrier_id != null && carrier_id != '') {
            if(Carrier.FactoringCompany_obj__c == null && isBroker == false) {
                recordTypeId = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Carrier_Not_Factoring').getRecordTypeId();
                /*
            try {
                Portal_User_Registration__c new_user = new Portal_User_Registration__c(RecordTypeId = recordTypeId, Name = email, FirstName__c = first_name, LastName__c = last_name, Email__c = email, Phone__c = phone, Password__c = password, ConfirmPassword__c = confirmPassword, Carrier__c = Carrier.Id);
                insert new_user;
                //PageReference redirectPortalRegistration = new PageReference('https://yourempiregroup--ethandev2.sandbox.my.salesforce-sites.com/carrier');
                PageReference redirectPortalRegistration = new PageReference('https://yourempiregroup.secure.force.com/carrier');
                error = false;
                return redirectPortalRegistration;
            } catch (Exception e) {
                System.debug('Error updating carrier info during portal registration');
                System.debug('Exception: ' + e);
                error = true;
                return null;
            } */
            } else if(Carrier.FactoringCompany_obj__c == null && isBroker == true) {
                recordTypeId = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Broker').getRecordTypeId();
            }
            
            else {
                recordTypeId = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Carrier_Factoring').getRecordTypeId();
            }
            try {
                Portal_User_Registration__c new_user = new Portal_User_Registration__c(RecordTypeId = recordTypeId, Name = email, FirstName__c = first_name, LastName__c = last_name, Email__c = email, Phone__c = phone, Password__c = password, ConfirmPassword__c = confirmPassword, Carrier__c = Carrier.Id);
                insert new_user;
                //PageReference redirectPortalRegistration = new PageReference('https://yourempiregroup--ethandev2.sandbox.my.salesforce-sites.com/carrier');
                PageReference redirectPortalRegistration = new PageReference('https://yourempiregroup.secure.force.com/carrier');
                error = false;
                return redirectPortalRegistration;
            } catch (Exception e) {
                System.debug('Error updating carrier info during portal registration');
                System.debug('Exception: ' + e);
                error = true;
                return null;
            }
            

        } else {
            error = true;
            return null;
        }
        
    }
    
}