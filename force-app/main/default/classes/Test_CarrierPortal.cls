/***
 * PORTAL RECORD TYPE IDs: 
 * Carrier (Factoring) : 01202000000L8KzAAK
 * Carrier (Not Factoring) : 01202000000L8OwAAK
 * Factoring Company : 01202000000L8L4AAK
 * ***/

@isTest
public class Test_CarrierPortal {
    
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
                                                                      State__c = 'MS');
        insert test_factorer;
        
        //Insert carrier obj
        FreightTM__Carrier__c test_carrier_notFactoring = new FreightTM__Carrier__c(Name = 'Carrier Not Factoring', Factoring_Company_Selection__c = 'No', 
                                                                        FactoringCompany_obj__c = test_factorer.Id);
        insert test_carrier_notFactoring;
        
        //Insert user obj related to carrier
        Portal_User_Registration__c test_carrier_factoring_user = new Portal_User_Registration__c(Name = 'Carrier Factoring User', FirstName__c = 'Test', LastName__c = 'User', 
                                                                                Email__c = 'johndoe123@gmail.com', Password__c = 'TestPassword', Temp_Password__c = 'temp_pass',
                                                                                Carrier__c = test_carrier_factoring.Id, RecordTypeId = carrier_factoring_id);
        insert test_carrier_factoring_user;
        
        Portal_User_Registration__c test_carrier_notFactoring_user = new Portal_User_Registration__c(Name = 'Carrier Not Factoring User', FirstName__c = 'Test', LastName__c = 'User', 
                                                                                Email__c = 'johndoe1@gmail.com', Password__c = 'TestPassword2', Temp_Password__c = 'temp_pass',
                                                                                Carrier__c = test_carrier_notFactoring.Id, RecordTypeId = carrier_notFactoring_id);
        insert test_carrier_notFactoring_user;
        
        /**************************
         * REMOVE
         * CARRIER 
         * REFERENCE 
         * ON PORTAL USER INSERTION
         * **************************/
        
        Portal_User_Registration__c test_factoring_user = new Portal_User_Registration__c(Name = 'Factoring User', FirstName__c = 'Test', LastName__c = 'User', 
                                                                                Email__c = 'johndoe12@gmail.com', Password__c = 'TestPassword3', Temp_Password__c = 'temp_pass',
                                                                                FactoringCompany__c = test_factorer.Id,
                                                                                 RecordTypeId = factoring_company_id);
        insert test_factoring_user;
        
        String record_type_id = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
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

        ContentVersion cv = new ContentVersion();
        cv.Description  = 'test description';
        cv.PathOnClient ='test_file.txt';
        cv.Title = 'test file '+ DateTime.now();
        cv.versiondata= EncodingUtil.base64Decode('Test');
        insert cv;
        
        CarrierPortal_Cont.ContentWrapper test_fileWrapper = new CarrierPortal_Cont.ContentWrapper('Test_File', 'testfile.com/testFile', cv.ContentDocumentId);

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = load.Id;
        cdl.ShareType = 'V';
        insert cdl;
        
		ContentVersion cv2 = new ContentVersion();
		cv2.Description = 'Test_Description';
		cv2.PathOnClient = 'test.txt;';
		cv2.Title = 'test file ' + DateTime.now();  
        cv2.VersionData = EncodingUtil.base64Decode('Test');
        insert cv2; 
    }
    
    @isTest
    private static void testCarrierLogin()
    {
        test.startTest();
        
        Portal_User_Registration__c factoring_user = [SELECT Id, Email__c, Password__c FROM Portal_User_Registration__c WHERE Name =: 'Carrier Factoring User'];
        Portal_User_Registration__c notFactoring_user = [SELECT Id, Email__c, Password__c FROM Portal_User_Registration__c WHERE Name =: 'Carrier Not Factoring User'];
        Portal_User_Registration__c factorer_user = [SELECT Id, Email__c, Password__c FROM Portal_User_Registration__c WHERE Name =: 'Factoring User'];
        
        CarrierPortal_Cont factoringUser_Login = new CarrierPortal_Cont();
        factoringUser_Login.redirectHome();
        factoringUser_Login.username = factoring_user.Email__c;
        factoringUser_Login.password = factoring_user.Password__c;
        factoringUser_Login.Login();
        
        CarrierPortal_Cont notFactoringUser_Login = new CarrierPortal_Cont();
        notFactoringUser_Login.redirectHome();
        notFactoringUser_Login.username = notFactoring_user.Email__c;
        notFactoringUser_Login.password = notFactoring_user.Password__c;
        notFactoringUser_Login.Login();
        
        CarrierPortal_Cont factorerUser_Login = new CarrierPortal_Cont();
        factorerUser_Login.username = factorer_user.Email__c;
        factorerUser_Login.password = factorer_user.Password__c;
        factorerUser_Login.Login();
        
        CarrierPortal_Cont unsuccessfullLogin = new CarrierPortal_Cont();
        unsuccessfullLogin.username = 'Bad_Username';
        unsuccessfullLogin.password = 'incorrect';
        unsuccessfullLogin.Login();
        
        test.stopTest();  
    }

    @isTest 
    private static void testForgotPass() {
        test.startTest();
        Portal_User_Registration__c factoring_user = [SELECT Id, Email__c, Password__c FROM Portal_User_Registration__c WHERE Name =: 'Carrier Factoring User'];
        Site_ForgotPass_Cont forgotPass = new Site_ForgotPass_Cont();
        forgotPass.username = factoring_user.Email__c;
        forgotPass.checkUser();
        forgotPass.username = 'invaliduser';
        forgotPass.checkUser();
        test.stopTest();
    }
    
    @isTest
    private static void testNewPass() 
    {
        test.startTest();
        
        Portal_User_Registration__c factoring_user = [SELECT Id, Email__c, Password__c, Temp_Password__c FROM Portal_User_Registration__c WHERE Name =: 'Carrier Factoring User'];
        
        Site_NewPassConfirm_Cont test_success = new Site_NewPassConfirm_Cont();
        test_success.temp_pass = factoring_user.Temp_Password__c;
        test_success.new_pass = 'new_pass';
        test_success.confirm_pass = 'new_pass';
        test_success.updatePass();
        
        Site_NewPassConfirm_Cont test_failure = new Site_NewPassConfirm_Cont();
        test_failure.temp_pass = factoring_user.Temp_Password__c;
        test_failure.new_pass = 'new_pass';
        test_failure.confirm_pass = 'newpass';
        test_failure.updatePass();
        
        Site_NewPassConfirm_Cont test_failure2 = new Site_NewPassConfirm_Cont();
        test_failure2.temp_pass = 'Wrong_Temp';
        test_failure2.new_pass = 'new_pass';
        test_failure2.confirm_pass = 'newpass';
        test_failure2.updatePass();
        
        test.stopTest();
    }
    
    @isTest 
    private static void testDisputeFetch() {
        test.startTest();
        
		FreightTM__Carrier__c test_carrier = [SELECT Id FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Factoring'];
		Factoring_Company__c test_factorer = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company']; 
        FreightTM__Load__c test_load = [SELECT Id FROM FreightTM__Load__c];
        List<FreightTM__Load__c> returnList = new List<FreightTM__Load__c>();
        
        returnList = CarrierPortal_Cont.findDisputes(String.valueOf(test_carrier.Id));
        returnList = CarrierPortal_Cont.findDisputes(String.valueOf(test_factorer.Id));
        returnList = CarrierPortal_Cont.findDisputes(test_load.Id);
        
        test.stopTest();
    }
    
    @isTest
    private static void testLoadFetch() 
    {
        test.startTest();
        
		FreightTM__Carrier__c test_carrier = [SELECT Id FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Factoring'];
		Factoring_Company__c test_factorer = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company']; 
        FreightTM__Load__c test_load = [SELECT Id FROM FreightTM__Load__c];
        List<FreightTM__Load__c> returnList = new List<FreightTM__Load__c>();
        
        CarrierPortal_Cont success_test = new CarrierPortal_Cont();
        success_test.redirectHome();
        returnList = CarrierPortal_Cont.getRelatedLoads(String.valueOf(test_carrier.Id));
        returnList = CarrierPortal_Cont.getRelatedLoads(String.valueOf(test_factorer.Id));
        returnList = CarrierPortal_Cont.getRelatedLoads(test_load.Id);
        FreightTM__Load__c ref_load = CarrierPortal_Cont.getLoad(test_load.Id);
        
        test.stopTest();
    }
    
    
    @isTest
    private static void testFiles() 
    {
        
/***
* Id saveTheFile(String rec_id, String fileName, String base64Data, String label)
* Id saveTheChunk(String rec_id, String fileName, String base64Data, String fileId, String docLabel)
* void appendToFile(Id fileId, String base64Data)
* ***/
        
        test.startTest();
        
        FreightTM__Load__c load = [SELECT Id FROM FreightTM__Load__c];
        ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion WHERE PathOnClient =: 'test_file.txt'];
        String encodedData = EncodingUtil.base64encode(cv.VersionData);
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock()); 
        CarrierPortal_Cont.queryLoadFiles(String.valueOf(load.Id));
        Id test_fileId = CarrierPortal_Cont.saveTheChunk(String.valueOf(load.Id), 'Test_Title', encodedData, String.valueOf(cv.Id), 'Invoice', '');
        Id test_fileId2 = CarrierPortal_Cont.saveTheChunk(String.valueOf(load.Id), 'Test_Title', encodedData, '', 'Invoice', '');
        test.stopTest(); 
    } 
    
    @isTest
    private static void testFetchDriverLoc() 
    {
        test.startTest();
		
        FreightTM__Load__c load = [SELECT Id FROM FreightTM__Load__c];
        
        CarrierPortal_Cont.getDriverLoc(load.Id);
        
        test.stopTest();
    }
    
    @isTest
    private static void testLoadUpdates() 
    {
        test.startTest();
        
        List<FreightTM__Load__c> loadList = [SELECT Id, Covered__c, Driver_Name__c, Driver_Phone__c FROM FreightTM__Load__c];
        for(Integer i = 0; i < loadList.size(); i++) {
            loadList[i].Covered__c = true;
            loadList[i].Driver_Name__c = 'John Doe';
        }
        
        CarrierPortal_Cont.updateLoads(loadList);
        
        test.stopTest();
    }
    
    @isTest
    private static void testCompanyProf() 
    {
        test.startTest();
        
        Portal_User_Registration__c test_user = [SELECT Id FROM Portal_User_Registration__c WHERE Name =: 'Carrier Factoring User'];
        FreightTM__Carrier__c test_carrier = [SELECT Id FROM FreightTM__Carrier__c WHERE Name =: 'Carrier Factoring'];
        Factoring_Company__c test_factorer = [SELECT Id FROM Factoring_Company__c WHERE Name =: 'Factoring Company'];
        
        Factoring_Company__c t_factor = CarrierPortal_Cont.fetchFactorer(test_user.Id);
        FreightTM__Carrier__c t_carrier = CarrierPortal_Cont.fetchCarrier(test_user.Id);
        String carrierId = test_carrier.Id;
        String cContact = 'Test Carrier Contact';
        String cPhone = '0001112222';
        String cTitle = 'Test Carrier Title';
        String cEmail = 'TestCarrier@email.com';
        String cWeb = 'www.testweb.com';
        String cFax = '0001112222';
        String bContact = 'Test Billing Contact';
        String bStreet = 'Test Billing St';
        String bEmail = 'testbilling@billing.com';
        String bPhone = '0001112222';
        String bCity = 'Test City';
        String bState = 'MS';
        String bZip = '0000';
        Boolean ret = CarrierPortal_Cont.saveFactorer(test_factorer);
        Boolean ret2 = CarrierPortal_Cont.saveCarrier(carrierId, cContact, cPhone, cTitle, cEmail,
                                                        cWeb, cFax, bContact, bStreet,
                                                        bEmail, bPhone, bCity, bState, bZip);
        
        test.stopTest();
    }
    
  
    @isTest
    private static void testUserProf() 
    {
        test.startTest();
        
        Portal_User_Registration__c test_user = [SELECT Id FROM Portal_User_Registration__c WHERE Name=: 'Carrier Factoring User'];
        
        Portal_User_Registration__c t_user = CarrierPortal_Cont.fetchUser(test_user.Id);
        Boolean ret = CarrierPortal_Cont.saveUser(test_user);
        
        test.stopTest();
    } 
    
    @isTest
    static void testPortalSearch() {
        // Create test data
        FreightTM__Carrier__c testCarrier = new FreightTM__Carrier__c(FreightTM__Cargo_Insurance_Expiration__c = Date.newInstance(2060, 1, 1), FreightTM__Liability_Insurance_Expiration__c = Date.newInstance(2060, 1, 1));
        insert testCarrier;

        FreightTM__Load__c testLoad = new FreightTM__Load__c(
            FreightTM__Carrier_Obj__c = testCarrier.Id,
            Reference_Number__c = '123456'
        );
        insert testLoad;

        // Call the portalSearch method
        Test.startTest();
        List<CarrierPortal_Cont.SearchResult> results = CarrierPortal_Cont.portalSearch(testCarrier.Id, 'Test Load');
        Test.stopTest();

    }

    @isTest
    static void testGetRecentlyViewed() {
        // Create test data
        FreightTM__Carrier__c testCarrier = new FreightTM__Carrier__c(FreightTM__Cargo_Insurance_Expiration__c = Date.newInstance(2060, 1, 1), FreightTM__Liability_Insurance_Expiration__c = Date.newInstance(2060, 1, 1));
        insert testCarrier;

        FreightTM__Load__c testLoad = new FreightTM__Load__c(
            FreightTM__Carrier_Obj__c = testCarrier.Id,
            Reference_Number__c = '123456'
        );
        insert testLoad;

        // Call the getRecentlyViewed method
        Test.startTest();
        List<CarrierPortal_Cont.SearchResult> results = CarrierPortal_Cont.getRecentlyViewed(testCarrier.Id);
        Test.stopTest();

    }
    
}