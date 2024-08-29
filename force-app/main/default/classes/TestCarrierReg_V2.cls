@isTest
public class TestCarrierReg_V2 {
    
    @testSetup 
    static void makeData() {
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock()); 
        
        String factoring_company_id = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Factoring_Company').getRecordTypeId();
        String carrier_factoring_id = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Carrier_Factoring').getRecordTypeId();
        String carrier_notFactoring_id = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Carrier_Not_Factoring').getRecordTypeId();
        
        //Insert carrier obj
        FreightTM__Carrier__c test_carrier_factoring = new FreightTM__Carrier__C(Name = 'Carrier Factoring', Factoring_Company_Selection__c = 'No');
        insert test_carrier_factoring;
        
        //Insert factoring obj
        Factoring_Company__c test_factorer = new Factoring_Company__c(Name = 'Factoring Company', PrimaryContact__c = 'PC', Phone__c = '2283651970', 
                                                                      Email__c = 'johndoe123@gmail.com', Street__c = 'St', City__c = 'City',
                                                                      State__c = 'MS', ZipCode__c = '55451');
        insert test_factorer;
        
        String factoringContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Factoring_Company_Billing_Contact').getRecordTypeId();

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test.contact@email.com',
                                            Phone = '0001112222', FactoringCompany__c = test_factorer.Id,
                                            RecordTypeId = factoringContactRecordTypeId);
        insert testContact;

        //Insert carrier obj
        FreightTM__Carrier__c test_carrier_notFactoring = new FreightTM__Carrier__c(Name = 'Carrier Not Factoring', Factoring_Company_Selection__c = 'Yes', 
                                                                                    FactoringCompany_obj__c = test_factorer.Id);
        insert test_carrier_notFactoring;
        
        //Insert user obj related to carrier
        Portal_User_Registration__c test_carrier_factoring_user = new Portal_User_Registration__c(Name = 'Carrier Factoring User', FirstName__c = 'Test', LastName__c = 'User', 
                                                                                                  Email__c = 'johndoe123@gmail.com', Password__c = 'TestPassword', Temp_Password__c = 'temp_pass',
                                                                                                  Carrier__c = test_carrier_factoring.Id, RecordTypeId = carrier_factoring_id);
        insert test_carrier_factoring_user;
        
        Portal_User_Registration__c test_carrier_notFactoring_user = new Portal_User_Registration__c(Name = 'Carrier Not Factoring User', FirstName__c = 'Test', LastName__c = 'User', 
                                                                                                     Email__c = 'johndoe123@gmail.com', Password__c = 'TestPassword2', Temp_Password__c = 'temp_pass',
                                                                                                     Carrier__c = test_carrier_notFactoring.Id, RecordTypeId = carrier_notFactoring_id);
        insert test_carrier_notFactoring_user;
        
        /****************************
         * REMEMBER TO REMOVE CARRIER__C
         * WHENEVER PUSHING TO PROD
         * **************************
         */
        Portal_User_Registration__c test_factoring_user = new Portal_User_Registration__c(Name = 'Factoring User', FirstName__c = 'Test', LastName__c = 'User', 
                                                                                          Email__c = 'johndoe123@gmail.com', Password__c = 'TestPassword3', Temp_Password__c = 'temp_pass',
                                                                                          FactoringCompany__c = test_factorer.Id,
                                                                                          RecordTypeId = factoring_company_id);
        insert test_factoring_user;
        
        Id record_type_id = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        //Id record_type_id = '0121Y000000tzXpQAI';
        FreightTM__Load__c load = new FreightTM__Load__c (RecordTypeId = record_type_id, FreightTM__Status__c = 'Dispatched', Quantity__c = 20, FreightTM__Commodity__c = 'MAT', FreightTM__Distance__c = 100.20, FreightTM__Remarks__c = 'Remarks',
                                                          FreightTM__Deadhead__c = 50.10, FreightTM__Confirmation_Number__c = '000000', FreightTM__Driver_Remarks__c = 'Driver Remarks', Driver_reason_for_the_delay__c = 'Delay Reason', Delayed_Reason__c = 'Breakdown', 
                                                          FreightTM__Pickup_Address__c = '140 Mayfair Rd', FreightTM__Pickup_City__c = 'Hattiesburg', FreightTM__Pickup_State__c = 'MS',
                                                          Pickup_Lat_Long__latitude__s = 31.318751392097873, Pickup_Lat_Long__longitude__s = -89.36321383130439,
                                                          FreightTM__Pickup_Zip_Code__c = '39402', FreightTM__Pickup_Country__c = 'United States', Pickup_By__c = datetime.newInstance(2021, 10, 10, 8, 0, 0), 
                                                          FreightTM__Pickup_By_Appointment__c = 'No', FreightTM__Pickup_Ref__c = '0000', FreightTM__Pickup_Remarks__c = 'Pickup Remarks', Driver_Name__c = 'Driver Name', 
                                                          Date__c = datetime.newInstance(2021, 9, 10, 8, 0, 0), FreightTM__Pickup_Contact__c = 'Pickup Contact', FreightTM__Pickup_Phone__c = '1234567890', 
                                                          Shipper_Date__c = datetime.newInstance(2021, 10, 10, 8, 0, 0), FreightTM__Delivery_Address__c = '105 Caillavet St', FreightTM__Delivery_City__c = 'Biloxi', 
                                                          FreightTM__Delivery_State__c = 'MS', Delivery_Lat_Long__latitude__s = 30.394986624231198, Delivery_Lat_Long__longitude__s = -88.89261883132431, 
                                                          FreightTM__Delivery_Contact__c = 'Delivery Contact', FreightTM__Delivery_Phone__c = '1234567890', Receiver_Date__c = datetime.newInstance(2021, 10, 10, 8, 0, 0),
                                                          FreightTM__Delivery_Zip_Code__c = '39530', FreightTM__Delivery_Country__c = 'United States', Deliver_By__c = datetime.newInstance(2021, 10, 15, 8, 0, 0),
                                                          FreightTM__Delivery_By_Appointment__c = 'No', FreightTM__Delivery_Ref__c = '1111', FreightTM__Delivery_Remarks__c = 'Delivery Remarks', 
                                                          ETA__c = datetime.newInstance(2021, 10, 15, 8, 0, 0), Pickup_Signature__c = '', Shipper_Signature__c = '', Receiver_Signature__c = '',
                                                          Mat_Grade__c = 'A');
        insert load;
        
        FreightTM__Site_Location__c test_site = new FreightTM__Site_Location__c(FreightTM__Coordinates__latitude__s = 31.318921162267138,
                                                                                FreightTM__Coordinates__longitude__s = -89.3641532313047,
                                                                                FreightTM__Load__c = load.Id);
        insert test_site;
        
    }
    
    @isTest
    public static void testLanding() {
        test.startTest();
        FreightTM__Carrier__c test_carrier = [SELECT Id, FactoringCompany_obj__c FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Not Factoring'];
        system.currentPageReference().getParameters().put('Id', test_carrier.Id);
        Carrier_Registration_V2 testRegistration = new Carrier_Registration_V2();
        test.stopTest();
    }

    @isTest 
    public static void testCarrierQuery() {
        test.startTest();
        FreightTM__Carrier__c testCarrier = [SELECT Id FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Not Factoring'];
        FreightTM__Carrier__c carrierQuery = Carrier_Registration_V2.carrierQuery(testCarrier.Id);
        test.stopTest();
    }
    
    @isTest 
    public static void testCarrierUpdate() {
        test.startTest();
        FreightTM__Carrier__c testCarrier = [SELECT Id FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Not Factoring'];
        FreightTM__Carrier__c updatedCarrier = Carrier_Registration_V2.updateCarrier(testCarrier.Id, 'Contact',
                                                                                    '228-000-1111', 'Email@email.com', 
                                                                                    'AL;');
        test.stopTest();
    }

    @isTest 
    public static void testCarrierBillingUpdate() {
        test.startTest();
        FreightTM__Carrier__c testCarrier = [SELECT Id FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Not Factoring'];
        FreightTM__Carrier__c updatedCarrier = Carrier_Registration_V2.updateBilling(testCarrier.Id, 'Contact', '601-111-2222', 'email@test.com',
                                                                                    'street', 'city', 'MS', '0000');
        test.stopTest();
    }

    @isTest
    public static void testFactoringCompQuery() {
        test.startTest();
        List<Factoring_Company__c> companyQuery = Carrier_Registration_V2.factoringCompanyQuery();
        test.stopTest();
    }

    @isTest 
    public static void testFactoringCompanyFetch() {
        test.startTest();
        Factoring_Company__c testFactoringCompany = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company'];
        Factoring_Company__c companyFetch = Carrier_Registration_V2.fetchFactoringCompany(testFactoringCompany.Id);
        test.stopTest();
    }

    @isTest 
    public static void testFactoringCompanyUpdate() {
        test.startTest();
        FreightTM__Carrier__c testCarrier = [SELECT Id FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Not Factoring'];
        Factoring_Company__c testFactoringCompany = [SELECT Id, Name FROM Factoring_Company__c WHERE Name =: 'Factoring Company'];
        Contact testContact = [SELECT Id FROM Contact WHERE FirstName =: 'Test'];
        FreightTM__Carrier__c updatedCarrier = Carrier_Registration_V2.updateFactoringCompany(testCarrier.Id, testFactoringCompany.Id, testContact.Id);
        test.stopTest();
    }

    @isTest 
    public static void testContactFetch() {
        test.startTest();
        Contact testContact = [SELECT Id FROM Contact WHERE FirstName =: 'Test'];
        Contact fetchedContact = Carrier_Registration_V2.fetchContact(testContact.Id);
        test.stopTest();
    }

    @isTest 
    public static void testContactSave() {
        test.startTest();
        Factoring_Company__c testFactoringComp = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company'];
        String testFirstName = 'John';
        String testLastName = 'Doe';
        String testEmail = 'john.doe@test.com';
        String testPhone = '0001112222';
        Contact savedContact = Carrier_Registration_V2.saveContact(testFirstName, testLastName, testEmail, testPhone, testFactoringComp.Id);
        test.stopTest();
    }

    @isTest 
    public static void testUserRegistration() {
        test.startTest();
        FreightTM__Carrier__c testCarrierNotFactoring = [SELECT Id, Name FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Not Factoring'];
        FreightTM__Carrier__c testCarrierFactoring = [SELECT Id, Name FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Factoring'];
        String testFirstName = 'John';
        String testLastName = 'Doe';
        String testEmail = 'john.doe@test.com';
        String testPhone = '0001112222';
        String testPass = 'pass';
        String testConfirmPass = 'pass';
        Portal_User_Registration__c registeredUser2 = Carrier_Registration_V2.userRegistration(testCarrierNotFactoring.Id, testFirstName, testLastName, testPhone, testEmail, testPass, testConfirmPass);
        Portal_User_Registration__c registeredUser3 = Carrier_Registration_V2.userRegistration(testCarrierFactoring.Id, testFirstName, testLastName, testPhone, testEmail, testPass, testConfirmPass);

        test.stopTest();
    }
    /*
    
    @isTest
    public static void testRegistration () {
        test.startTest();
        FreightTM__Carrier__c test_carrier = [SELECT Id FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Factoring'];
        ApexPages.StandardController stndCont = new ApexPages.StandardController(test_carrier);
        system.currentPageReference().getParameters().put('Id', test_carrier.Id);
        Carrier_Registration testRegistration = new Carrier_Registration(stndCont);
        testRegistration.updateCarrier();
        testRegistration.updateBilling();
        testRegistration.registerUser();
        test.stopTest();
    } */
}