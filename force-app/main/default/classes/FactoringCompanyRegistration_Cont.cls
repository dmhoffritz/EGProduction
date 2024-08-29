public without sharing class FactoringCompanyRegistration_Cont {

    public String factoringId {get; set;}

    public FactoringCompanyRegistration_Cont() {
        factoringId = ApexPages.currentPage().getParameters().get('id');
    }

    @AuraEnabled
    public static Factoring_Company__c fetchFactoringCompany(String recordId) {
        Factoring_Company__c factoringCompany = new Factoring_Company__c();
        try {
            factoringCompany = [SELECT Id, Name, 
                                PrimaryContact__c, Phone__c, Email__c,
                                Street__c, City__c, State__c, ZipCode__c
                                FROM Factoring_Company__c
                                WHERE Id =: recordId];
            return factoringCompany;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static Factoring_Company__c updateFactoringCompany(String recordId, String primaryContact, String phone, String email,
                                                                String street, String city, String state, String zip) {
        try {
            Factoring_Company__c recordToUpdate = [SELECT Id FROM Factoring_Company__c WHERE Id =: recordId];
            recordToUpdate.PrimaryContact__c = primaryContact;
            recordToUpdate.Phone__c = phone;
            recordToUpdate.Email__c = email;
            recordToUpdate.Street__c = street;
            recordToUpdate.City__c = city;
            recordToUpdate.State__c = state;
            recordToUpdate.ZipCode__c = zip;
            update recordToUpdate;

            return recordToUpdate;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled 
    public static Portal_User_Registration__c registerFactoringCompany(String recordId, String userFirstName, String userLastName,
                                                                        String userPhone, String userEmail, String userPassword,
                                                                        String userConfirmPassword) {
        String recordTypeId = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Factoring_Company').getRecordTypeId();
        try {

            /******************************
             * REMOVE CARRIER REF FOR PROD
             *****************************/
            Portal_User_Registration__c newUser = new Portal_User_Registration__c(RecordTypeId = recordTypeId, AgreedtoTermsConditions__c = true,
                                                                    Name = userEmail, FirstName__c = userFirstName, LastName__c = userLastName, 
                                                                    Email__c = userEmail, Phone__c = userPhone, 
                                                                    Password__c = userPassword, ConfirmPassword__c = userConfirmPassword, 
                                                                    FactoringCompany__c = recordId);
            try {
                insert newUser;
            } catch(Exception e) {
                System.debug('Error whenever inserting registered user into database');
                System.debug('Exception: ' + e);
            }

            return newUser;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }


    }
}