public without sharing class Factoring_Registration_Cont {
    
    public String factoringId {get; set;}
    
    public Factoring_Registration_Cont() {
        factoringId = ApexPages.currentPage().getParameters().get('id');
        //carrierId = 'a2Q02000000Lp9OEAS';
    }

    @AuraEnabled 
    public static Factoring_Company__c fetchFactoringCo(String recId) {
        Factoring_Company__c returnRecord = new Factoring_Company__c();
        try {
            returnRecord = [SELECT Id, Name, 
                            City__c, Email__c, Phone__c, PrimaryContact__c,
                            State__c, Street__c, ZipCode__c
                            FROM Factoring_Company__c 
                            WHERE Id =: recId];
            return returnRecord;

        } catch(Exception e) {
            System.debug('Error whenever fetching Carrier record');
            System.debug('Exception: ' + e);

            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static Factoring_Company__c updateFactoringCo(Factoring_Company__c updatedRecord){
        try {
            update updatedRecord;
            return updatedRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Portal_User_Registration__c userRegistration(String recordId, String userFirstName, String userLastName, String userPhone, String userEmail, String userPassword, String userConfirmPassword){
        try {
            String recordTypeId = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Factoring_Company').getRecordTypeId();
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