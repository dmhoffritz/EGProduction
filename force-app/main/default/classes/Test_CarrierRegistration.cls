@isTest
public class Test_CarrierRegistration {
    
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
        ApexPages.StandardController stndCont = new ApexPages.StandardController(test_carrier);
        system.currentPageReference().getParameters().put('Id', test_carrier.Id);
        Carrier_Registration testRegistration = new Carrier_Registration(stndCont);
        testRegistration.updateCarrier();
        testRegistration.factorer = '';
        testRegistration.goBack();
        testRegistration.factorer = test_carrier.FactoringCompany_obj__c;
        testRegistration.updateBilling();
        testRegistration.goBack();
        testRegistration.registerUser();
        test.stopTest();
    }
    
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
    }
}