@isTest
public class Test_FactoringCompanyRegistration {
    
    @testSetup 
    static void makeData() {
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock()); 

        //Insert factoring obj
        Factoring_Company__c test_factorer = new Factoring_Company__c(Name = 'Factoring Company', PrimaryContact__c = 'PC', Phone__c = '2283651970', 
                                                                      Email__c = 'johndoe123@gmail.com', Street__c = 'St', City__c = 'City',
                                                                      State__c = 'MS', ZipCode__c = '55451');
        insert test_factorer;
        
    }
    
    @isTest
    public static void testLanding() {
        test.startTest();
        Factoring_Company__c testFactoring = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company'];
        system.currentPageReference().getParameters().put('Id', testFactoring.Id);
        FactoringCompanyRegistration_Cont testRegistration = new FactoringCompanyRegistration_Cont();
        test.stopTest();
    }

    @isTest 
    public static void testFactoringQuery() {
        test.startTest();
        Factoring_Company__c testFactoring = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company'];
        testFactoring = FactoringCompanyRegistration_Cont.fetchFactoringCompany(testFactoring.Id);
        test.stopTest();
    }
    
    @isTest 
    public static void testFactoringUpdate() {
        test.startTest();
        Factoring_Company__c testFactoring = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company'];
        testFactoring = FactoringCompanyRegistration_Cont.updateFactoringCompany(testFactoring.Id, 'Contact', '601-111-2222', 'email@test.com',
                                                                                    'street', 'city', 'MS', '0000');
        test.stopTest();
    }


    @isTest 
    public static void testUserRegistration() {
        test.startTest();
        Factoring_Company__c testFactoring = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company'];
        String testFirstName = 'John';
        String testLastName = 'Doe';
        String testEmail = 'john.doe@test.com';
        String testPhone = '0001112222';
        String testPass = 'pass';
        String testConfirmPass = 'pass';
        Portal_User_Registration__c registeredUser = FactoringCompanyRegistration_Cont.registerFactoringCompany(testFactoring.Id, testFirstName, testLastName, testPhone, testEmail, testPass, testConfirmPass);
        test.stopTest();
    }

}