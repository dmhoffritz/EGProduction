@isTest(SeeAllData=false)
public class Test_driverLoad {
    
    @isTest
    private static void TestDriverAccessWithoutPIN()
    {
        FreightTM__Employee__c emp = new FreightTM__Employee__c ( Name='Smith', FreightTM__Type__c = 'Driver', Title__c = 'Test', FreightTM__PIN__c = '0000', FreightTM__First_Name__c = 'Ethan');
        insert emp;
        
        //List<User> new_user = [SELECT Id, Name, MobilePhone, Phone, Username, Extension FROM User WHERE Username='emyers@yourempiregroup.com' LIMIT 1];
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'Appleseed', FirstName = 'Johnny', Alias = 'japp', Email = 'j.appleseed@mail.com', Username = 'j.appleseed@user.com', ProfileId = profileId.id, TimeZoneSidKey = 'GMT', 
                                LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey= 'en_US');
        
        Id record_type_id = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        FreightTM__Load__c load = new FreightTM__Load__c (RecordTypeId = record_type_id, FreightTM__Status__c = 'Dispatched', FreightTM__Dispatch__c = usr.Id, 
                                                           FreightTM__Driver__c = emp.Id, Quantity__c = 20, FreightTM__Commodity__c = 'MAT', FreightTM__Distance__c = 100.20, FreightTM__Remarks__c = 'Remarks',
                                                           FreightTM__Deadhead__c = 50.10, FreightTM__Driver_Remarks__c = 'Driver Remarks', Driver_reason_for_the_delay__c = 'Delay Reason', Delayed_Reason__c = 'Breakdown', 
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
        
        
        FreightTM__Site_Location__c tmplatLng = new FreightTM__Site_Location__c (FreightTM__Coordinates__latitude__s = 45.555, FreightTM__Coordinates__longitude__s = 54.212);
        insert tmplatLng;
        
        
        /*
        FreightTM__Load__c tload = [select Name, FreightTM__Driver__c
                                            from FreightTM__Load__c
                                            where FreightTM__Driver__r.Name =: load.FreightTM__Driver__r.Name 
                                            ];

        string tinputLoad = tload.Name; */
        
        test.startTest();
        
        
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        system.currentPageReference().getParameters().put('Id', load.Id);
        driverLoad da = new driverLoad(stndCont); 
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock()); 
        da.lat_long = '45.555, 54.212';
        da.storeSignatures();
        da.storeDeviceType();
        da.SaveFiles();
         da.clearPickup();
         da.clearDelivery();
        da.clearConsignee();
        da.StatusDispatched();
        da.StatusArrived();
        da.StatusDelayed();
        da.StatusArrivedDelivered();
        //da.Back();
        //da.EditLoad();
        da.AddAttachs();
        da.storeCoordinates();
        
        System.assert(da.error_message == 'Success: Load has been updated.');
        test.stopTest();    
    }
  @isTest
    private static void TestDriverAccessWithFile()
    {
        FreightTM__Employee__c emp = new FreightTM__Employee__c ( Name='Brown', FreightTM__Type__c = 'Driver', Title__c = 'Test2', FreightTM__PIN__c = '1111', FreightTM__First_Name__c = 'John');
        insert emp;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'Appleseed', FirstName = 'Johnny', Alias = 'japp', Email = 'j.appleseed@mail.com', Username = 'j.appleseed@user.com', ProfileId = profileId.id, TimeZoneSidKey = 'GMT', 
                                LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey= 'en_US');
        
        Id record_type_id = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        FreightTM__Load__c load2 = new FreightTM__Load__c (RecordTypeId = record_type_id, FreightTM__Status__c = 'Dispatched', FreightTM__Dispatch__c = usr.Id, 
                                                           FreightTM__Driver__c = emp.Id, Quantity__c = 20, FreightTM__Commodity__c = 'MAT', FreightTM__Distance__c = 100.20, FreightTM__Remarks__c = 'Remarks',
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
                                                          
        insert load2;
        
        FreightTM__Site_Location__c tmplatLng = new FreightTM__Site_Location__c (FreightTM__Coordinates__latitude__s = 45.555, FreightTM__Coordinates__longitude__s = 54.212);
        insert tmplatLng;
        
        
    /*
        FreightTM__Load__c tload = [select Name, FreightTM__Driver__c
                                            from FreightTM__Load__c
                                            where FreightTM__Driver__r.Name =: load.FreightTM__Driver__r.Name 
                                            ];

        string tinputLoad = tload.Name; */
        
        test.startTest();
        
        
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load2);
        system.currentPageReference().getParameters().put('Id', load2.Id);
        driverLoad da = new driverLoad(stndCont); 
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock()); 
        da.lat_long = '45.555, 54.212';
        for(ContentVersion file : da.fileList)
        {
            file.Title = 'Test';
            file.VersionData = Blob.valueof('Test.pdf');
        }
        da.SaveFiles();
        //da.Back();
        //da.EditLoad();
        da.AddAttachs();
        da.storeCoordinates();
        
        System.assert(da.error_message.contains('file(s) uploaded successfully. ' + '\n' + 'Load has been updated.'));
        test.stopTest();    
    }   
    
    @isTest
    private static void Test3()
    {
        FreightTM__Employee__c emp = new FreightTM__Employee__c ( Name='Smith', FreightTM__Type__c = 'Driver', Title__c = 'Test', FreightTM__PIN__c = '0000', FreightTM__First_Name__c = 'Ethan');
        insert emp;
        
        //List<User> new_user = [SELECT Id, Name, MobilePhone, Phone, Username, Extension FROM User WHERE Username='emyers@yourempiregroup.com' LIMIT 1];
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(MobilePhone = '+12283651970', LastName = 'Appleseed', FirstName = 'Johnny', Alias = 'japp', Email = 'j.appleseed@mail.com', Username = 'j.appleseed@user.com', ProfileId = profileId.id, TimeZoneSidKey = 'GMT', 
                                LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey= 'en_US');
        
        Id record_type_id = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        FreightTM__Load__c load = new FreightTM__Load__c (RecordTypeId = record_type_id, FreightTM__Status__c = 'Arrived for Pickup', FreightTM__Dispatch__c = usr.Id, 
                                                           FreightTM__Driver__c = emp.Id, Quantity__c = 20, FreightTM__Commodity__c = 'MAT', FreightTM__Distance__c = 100.20, FreightTM__Remarks__c = 'Remarks',
                                                           FreightTM__Deadhead__c = 50.10, FreightTM__Driver_Remarks__c = 'Driver Remarks', Driver_reason_for_the_delay__c = 'Delay Reason', Delayed_Reason__c = 'Breakdown', 
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
        
        
        FreightTM__Site_Location__c tmplatLng = new FreightTM__Site_Location__c (FreightTM__Coordinates__latitude__s = 45.555, FreightTM__Coordinates__longitude__s = 54.212);
        insert tmplatLng;
        
        
        /*
        FreightTM__Load__c tload = [select Name, FreightTM__Driver__c
                                            from FreightTM__Load__c
                                            where FreightTM__Driver__r.Name =: load.FreightTM__Driver__r.Name 
                                            ];

        string tinputLoad = tload.Name; */
        
        test.startTest();
        
        
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        system.currentPageReference().getParameters().put('Id', load.Id);
        driverLoad da = new driverLoad(stndCont); 
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock()); 
        da.lat_long = '45.555, 54.212';
        da.storeSignatures();
        da.storeDeviceType();
        da.SaveFiles();
         da.clearPickup();
         da.clearDelivery();
        da.clearConsignee();
        da.StatusDispatched();
        da.StatusArrived();
        da.StatusDelayed();
        da.StatusArrivedDelivered();
        //da.Back();
        //da.EditLoad();
        da.AddAttachs();
        da.storeCoordinates();
        
        System.assert(da.error_message == 'Success: Load has been updated.');
        test.stopTest();    
    }
    
    @isTest
    private static void Test4()
    {
        FreightTM__Employee__c emp = new FreightTM__Employee__c ( Name='Smith', FreightTM__Type__c = 'Driver', Title__c = 'Test', FreightTM__PIN__c = '0000', FreightTM__First_Name__c = 'Ethan');
        insert emp;
        
        //List<User> new_user = [SELECT Id, Name, MobilePhone, Phone, Username, Extension FROM User WHERE Username='emyers@yourempiregroup.com' LIMIT 1];
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(MobilePhone = '+12283651970', LastName = 'Appleseed', FirstName = 'Johnny', Alias = 'japp', Email = 'j.appleseed@mail.com', Username = 'j.appleseed@user.com', ProfileId = profileId.id, TimeZoneSidKey = 'GMT', 
                                LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey= 'en_US');
        
        Id record_type_id = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        FreightTM__Load__c load = new FreightTM__Load__c (RecordTypeId = record_type_id, FreightTM__Status__c = 'Loaded in Transit', FreightTM__Dispatch__c = usr.Id, 
                                                           FreightTM__Driver__c = emp.Id, Quantity__c = 20, FreightTM__Commodity__c = 'MAT', FreightTM__Distance__c = 100.20, FreightTM__Remarks__c = 'Remarks',
                                                           FreightTM__Deadhead__c = 50.10, FreightTM__Driver_Remarks__c = 'Driver Remarks', Driver_reason_for_the_delay__c = 'Delay Reason', Delayed_Reason__c = 'Breakdown', 
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
        
        
        FreightTM__Site_Location__c tmplatLng = new FreightTM__Site_Location__c (FreightTM__Coordinates__latitude__s = 45.555, FreightTM__Coordinates__longitude__s = 54.212);
        insert tmplatLng;
        
        
        /*
        FreightTM__Load__c tload = [select Name, FreightTM__Driver__c
                                            from FreightTM__Load__c
                                            where FreightTM__Driver__r.Name =: load.FreightTM__Driver__r.Name 
                                            ];

        string tinputLoad = tload.Name; */
        
        test.startTest();
        
        
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        system.currentPageReference().getParameters().put('Id', load.Id);
        driverLoad da = new driverLoad(stndCont); 
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock()); 
        da.lat_long = '45.555, 54.212';
        da.storeSignatures();
        da.storeDeviceType();
        da.SaveFiles();
         da.clearPickup();
         da.clearDelivery();
        da.clearConsignee();
        da.StatusDispatched();
        da.StatusArrived();
        da.StatusDelayed();
        da.StatusArrivedDelivered();
        //da.Back();
        //da.EditLoad();
        da.AddAttachs();
        da.storeCoordinates();
        
        System.assert(da.error_message == 'Success: Load has been updated.');
        test.stopTest();    
    }
    
    @isTest
    private static void Test5()
    {
        FreightTM__Employee__c emp = new FreightTM__Employee__c ( Name='Smith', FreightTM__Type__c = 'Driver', Title__c = 'Test', FreightTM__PIN__c = '0000', FreightTM__First_Name__c = 'Ethan');
        insert emp;
        
        //List<User> new_user = [SELECT Id, Name, MobilePhone, Phone, Username, Extension FROM User WHERE Username='emyers@yourempiregroup.com' LIMIT 1];
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(MobilePhone = '+12283651970', LastName = 'Appleseed', FirstName = 'Johnny', Alias = 'japp', Email = 'j.appleseed@mail.com', Username = 'j.appleseed@user.com', ProfileId = profileId.id, TimeZoneSidKey = 'GMT', 
                                LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey= 'en_US');
        
        Id record_type_id = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        FreightTM__Load__c load = new FreightTM__Load__c (RecordTypeId = record_type_id, FreightTM__Status__c = 'Arrived for Delivery', FreightTM__Dispatch__c = usr.Id, 
                                                           FreightTM__Driver__c = emp.Id, Quantity__c = 20, FreightTM__Commodity__c = 'MAT', FreightTM__Distance__c = 100.20, FreightTM__Remarks__c = 'Remarks',
                                                           FreightTM__Deadhead__c = 50.10, FreightTM__Driver_Remarks__c = 'Driver Remarks', Driver_reason_for_the_delay__c = 'Delay Reason', Delayed_Reason__c = 'Breakdown', 
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
        
        
        FreightTM__Site_Location__c tmplatLng = new FreightTM__Site_Location__c (FreightTM__Coordinates__latitude__s = 45.555, FreightTM__Coordinates__longitude__s = 54.212);
        insert tmplatLng;
        
        
        /*
        FreightTM__Load__c tload = [select Name, FreightTM__Driver__c
                                            from FreightTM__Load__c
                                            where FreightTM__Driver__r.Name =: load.FreightTM__Driver__r.Name 
                                            ];

        string tinputLoad = tload.Name; */
        
        test.startTest();
        
        
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        system.currentPageReference().getParameters().put('Id', load.Id);
        driverLoad da = new driverLoad(stndCont); 
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock()); 
        da.lat_long = '45.555, 54.212';
        da.storeSignatures();
        da.storeDeviceType();
        da.SaveFiles();
         da.clearPickup();
         da.clearDelivery();
        da.clearConsignee();
        da.StatusDispatched();
        da.StatusArrived();
        da.StatusDelayed();
        da.StatusArrivedDelivered();
        //da.Back();
        //da.EditLoad();
        da.AddAttachs();
        da.storeCoordinates();
        da.redirect();
        
        System.assert(da.error_message == 'Success: Load has been updated.');
        test.stopTest();    
    }
    

}