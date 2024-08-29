public without sharing class Carrier_Registration_V2 {
    
    public String carrierId {get; set;}
    
    public Carrier_Registration_V2() {
        carrierId = ApexPages.currentPage().getParameters().get('id');
        //carrierId = 'a2Q02000000Lp9OEAS';
    }

    @AuraEnabled 
    public static FreightTM__Carrier__c carrierQuery(String recordId) {
        FreightTM__Carrier__c returnCarrier = new FreightTM__Carrier__c();
        try {
            returnCarrier = [SELECT Id, Name, FactoringCompany_obj__c, 
                    FactoringCompany_obj__r.Email__c, FactoringCompany_obj__r.PrimaryContact__c,
                    FactoringCompany_obj__r.Phone__c, FC_Billing_Contact__c,
                    FreightTM__Primary_Contact__c,
                    FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Address__c, Preferred_Lanes__c,
                    FreightTM__City__c, FreightTM__State_Province__c, FreightTM__Zip_Code__c,
                    Billing_Contact__c, Billing_Email__c, Billing_Phone__c, FreightTM__Billing_Address__c, 
                    FreightTM__Billing_City__c, FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c 
            FROM FreightTM__Carrier__c WHERE Id =: recordId];
        } catch(Exception e) {
            System.debug('Error whenever fetching Carrier record');
            System.debug('Exception: ' + e);
        }

        return returnCarrier;
    }

    @AuraEnabled
    public static FreightTM__Carrier__c updateCarrier(String recordId, String companyContact, 
                                                        String companyPhone, String companyEmail,
                                                        String opStates){
        try {
            //update carrierRec;
            FreightTM__Carrier__c carrierToUpdate = [SELECT Id, Name, FactoringCompany_obj__c, 
                    FactoringCompany_obj__r.Email__c, FactoringCompany_obj__r.PrimaryContact__c,
                    FactoringCompany_obj__r.Phone__c, FC_Billing_Contact__c,
                    FreightTM__Primary_Contact__c,
                    FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Address__c, Preferred_Lanes__c,
                    FreightTM__City__c, FreightTM__State_Province__c, FreightTM__Zip_Code__c,
                    Billing_Contact__c, Billing_Email__c, Billing_Phone__c, FreightTM__Billing_Address__c, 
                    FreightTM__Billing_City__c, FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c 
                    FROM FreightTM__Carrier__c WHERE Id=: recordId];
            carrierToUpdate.FreightTM__Primary_Contact__c = companyContact;
            carrierToUpdate.FreightTM__Phone__c = companyPhone;
            carrierToUpdate.FreightTM__Email__c = companyEmail;
            /*
            carrierToUpdate.FreightTM__Address__c = companyStreet;
            carrierToUpdate.FreightTM__City__c = companyCity;
            carrierToUpdate.FreightTM__State_Province__c = companyState;
            carrierToUpdate.FreightTM__Zip_Code__c = companyZip;
            */
            carrierToUpdate.Preferred_Lanes__c = opStates;
            update carrierToUpdate;

            return carrierToUpdate;
            /*
            FreightTM__Carrier__c returnCarrier = [SELECT Id, Name, FactoringCompany_obj__c, 
                    FactoringCompany_obj__r.Email__c, FactoringCompany_obj__r.PrimaryContact__c,
                    FactoringCompany_obj__r.Phone__c,
                    FreightTM__Primary_Contact__c,
                    FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Address__c, Preferred_Lanes__c,
                    FreightTM__City__c, FreightTM__State_Province__c, FreightTM__Zip_Code__c,
                    Billing_Contact__c, Billing_Email__c, Billing_Phone__c, FreightTM__Billing_Address__c, 
                    FreightTM__Billing_City__c, FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c 
            FROM FreightTM__Carrier__c WHERE Id =: carrierRec.Id]; 
            return returnCarrier; 

            return new FreightTM__Carrier__c();
            */

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static FreightTM__Carrier__c updateBilling(String recordId, String billingContact, String billingPhone,
                                                        String billingEmail, String billingStreet, String billingCity,
                                                        String billingState, String billingZip) {
        try {
            FreightTM__Carrier__c carrierToUpdate = [SELECT Id, Name, FactoringCompany_obj__c, 
                    FactoringCompany_obj__r.Email__c, FactoringCompany_obj__r.PrimaryContact__c,
                    FactoringCompany_obj__r.Phone__c, FC_Billing_Contact__c,
                    FreightTM__Primary_Contact__c, Use_a_Factoring_Company__c,
                    FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Address__c, Preferred_Lanes__c,
                    FreightTM__City__c, FreightTM__State_Province__c, FreightTM__Zip_Code__c,
                    Billing_Contact__c, Billing_Email__c, Billing_Phone__c, FreightTM__Billing_Address__c, 
                    FreightTM__Billing_City__c, FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c 
                    FROM FreightTM__Carrier__c WHERE Id =: recordId];
            carrierToUpdate.Billing_Contact__c = billingContact;
            carrierToUpdate.Billing_Phone__c = billingPhone;
            carrierToUpdate.Billing_Email__c = billingEmail;
            carrierToUpdate.FreightTM__Address__c = billingStreet;
            carrierToUpdate.FreightTM__City__c = billingCity;
            carrierToUpdate.FreightTM__State_Province__c = billingState;
            carrierToUpdate.FreightTM__Zip_Code__c = billingZip;
            carrierToUpdate.Use_a_Factoring_Company__c = 'No';
            carrierToUpdate.FactoringCompany_obj__c = null;
            carrierToUpdate.FC_Billing_Contact__c = null;
            update carrierToUpdate;

            return carrierToUpdate;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Factoring_Company__c> factoringCompanyQuery(){
        try {
            List<Factoring_Company__c> returnList = [SELECT Id, Name, 
                            PrimaryContact__c, Phone__c, Email__c,
                            Street__c, City__c, State__c, ZipCode__c,
                            (SELECT Id, Name, FirstName, LastName, Email, Phone 
                                FROM Billing_Contacts__r)
                            FROM Factoring_Company__c
                            ORDER BY Name ASC];
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Factoring_Company__c fetchFactoringCompany(String factoringId){
        try {
            Factoring_Company__c factoringCompany = new Factoring_Company__c();
            factoringCompany = 
            [SELECT Id, Name, 
            PrimaryContact__c, Phone__c, Email__c,
            Street__c, City__c, State__c, ZipCode__c,
            (SELECT Id, Name, FirstName, LastName, Email, Phone 
                FROM Billing_Contacts__r)
            FROM Factoring_Company__c WHERE Id =: factoringId];
            return factoringCompany;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static FreightTM__Carrier__c updateFactoringCompany(String carrierId, String factoringCompanyId, String billingContactId){
        try {
            FreightTM__Carrier__c carrierRec = [SELECT Id, Name, FactoringCompany_obj__c, 
                    FactoringCompany_obj__r.Email__c, FactoringCompany_obj__r.PrimaryContact__c,
                    FactoringCompany_obj__r.Phone__c, FC_Billing_Contact__c,
                    FreightTM__Primary_Contact__c, Use_a_Factoring_Company__c,
                    FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Address__c, Preferred_Lanes__c,
                    FreightTM__City__c, FreightTM__State_Province__c, FreightTM__Zip_Code__c,
                    Billing_Contact__c, Billing_Email__c, Billing_Phone__c, FreightTM__Billing_Address__c, 
                    FreightTM__Billing_City__c, FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c
                            FROM FreightTM__Carrier__c WHERE Id =: carrierId];
            //Factoring_Company__c factoringCompRec = [SELECT Id FROM FactoringCompany_obj__c WHERE Id =: factoringCompanyId];
            carrierRec.FactoringCompany_obj__c = factoringCompanyId;
            carrierRec.FC_Billing_Contact__c = billingContactId;
            carrierRec.Use_a_Factoring_Company__c = 'Yes';
            update carrierRec;

            return carrierRec;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
    @AuraEnabled
    public static Factoring_Company__c updateFactoringCompany(Factoring_Company__c factoringCompany){
        try {
            update factoringCompany;
            Factoring_Company__c returnFactoringCompany = [SELECT Id, Name, 
            PrimaryContact__c, Phone__c, Email__c,
            Street__c, City__c, State__c,
            (SELECT Id, Name, FirstName, LastName, Email, Phone 
                FROM Billing_Contacts__r)
            FROM Factoring_Company__c WHERE Id =: factoringCompany.Id];

            return returnFactoringCompany;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } */

    @AuraEnabled
    public static Contact fetchContact(String recordId){
        try {
            Contact returnContact = [SELECT Id, Name, FirstName, LastName,
                                        Email, Phone, FactoringCompany__c
                                        FROM Contact
                                        WHERE Id =: recordId];
            return returnContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Contact saveContact(String firstName, String lastName, String email, String phone, String factoringCompanyId) {
        try {

            
            String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Factoring_Company_Billing_Contact').getRecordTypeId();

            Contact newContact = new Contact(
                RecordTypeId = recordTypeId,
                FirstName = firstName,
                LastName = lastName,
                Phone = phone,
                Email = email,
                FactoringCompany__c = factoringCompanyId
            );

            insert newContact;


            Contact returnContact = [SELECT Id, Name, FirstName, LastName, Phone, Email, FactoringCompany__c
                                        FROM Contact WHERE Id =: newContact.Id];

            return returnContact;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Portal_User_Registration__c userRegistration(String carrierRecId, String userFirstName, String userLastName, String userPhone, String userEmail, String userPassword, String userConfirmPassword){
        try {
            String recordTypeId = '';
            FreightTM__Carrier__c carrierRec = [SELECT Id, Name, FactoringCompany_obj__c, 
                    FactoringCompany_obj__r.Email__c, FactoringCompany_obj__r.PrimaryContact__c,
                    FactoringCompany_obj__r.Phone__c,
                    FreightTM__Primary_Contact__c,
                    FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Address__c, Preferred_Lanes__c,
                    FreightTM__City__c, FreightTM__State_Province__c, FreightTM__Zip_Code__c,
                    Billing_Contact__c, Billing_Email__c, Billing_Phone__c, FreightTM__Billing_Address__c, 
                    FreightTM__Billing_City__c, FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c 
            FROM FreightTM__Carrier__c WHERE Id =: carrierRecId];
            
            if(carrierRec.FactoringCompany_obj__c == null) {
                recordTypeId = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Carrier_Not_Factoring').getRecordTypeId();
            } else {
                recordTypeId = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Carrier_Factoring').getRecordTypeId();
            }
            Portal_User_Registration__c newUser = new Portal_User_Registration__c(RecordTypeId = recordTypeId, AgreedtoTermsConditions__c = true,
                                                                    Name = userEmail, FirstName__c = userFirstName, LastName__c = userLastName, 
                                                                    Email__c = userEmail, Phone__c = userPhone, 
                                                                    Password__c = userPassword, ConfirmPassword__c = userConfirmPassword, 
                                                                    Carrier__c = carrierRecId);
            try {
                insert newUser;
            } catch(Exception e) {
                System.debug('Error whenever inserting registered user into database');
                System.debug('Exception: ' + e);
            }
            Portal_User_Registration__c returnUser = [SELECT Id, Name, FirstName__c, LastName__c,
                                                        Email__c, Phone__c, Password__c, ConfirmPassword__c,
                                                        Carrier__c 
                                                        FROM Portal_User_Registration__c WHERE Id=: newUser.Id];

            return returnUser;
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            System.debug('Error whenever creating new portal user record');
            System.debug('Exception: ' + e);
            return null;
        }
    }
}