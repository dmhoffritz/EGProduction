/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-27-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Test_LoadsBatchMill_V2 
{ 
    /*
    private static testMethod void testMethod1() 
    {
        List<FreightTM__Load__c> loadList = new List <FreightTM__Load__c>();
        
        FreightTM__Load__c testLoad = new FreightTM__Load__c();
        testLoad.FreightTM__Status__c='Assigned';
        loadList.add(testLoad);
        FreightTM__Load__c testLoad1 = new FreightTM__Load__c();
        testLoad1.FreightTM__Status__c='Dispatched';
        loadList.add(testLoad1);
        
        insert loadList;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Test_LoadsBatchMill_V2_mock());
            Test.setCurrentPage(Page.LoadsBatchMill_Selected);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(loadList);
            stdSetController.setSelected(loadList);
            LoadsBatchMill_V2 ext = new LoadsBatchMill_V2(stdSetController);
        Test.stopTest();
  }*/
    
  private static testMethod void testMethod2()
  {
       FreightTM__Employee__c emp = new FreightTM__Employee__c ( Name='Smith', FreightTM__Type__c = 'Driver', Title__c = 'Test', FreightTM__PIN__c = '0000', FreightTM__First_Name__c = 'Ethan');
        insert emp;
        
        //List<User> new_user = [SELECT Id, Name, MobilePhone, Phone, Username, Extension FROM User WHERE Username='emyers@yourempiregroup.com' LIMIT 1];
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'Appleseed', FirstName = 'Johnny', Alias = 'japp', Email = 'j.appleseed@mail.com', Username = 'j.appleseed@user.com', ProfileId = profileId.id, TimeZoneSidKey = 'GMT', 
                                LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey= 'en_US');
        
        Id record_type_id = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
        FreightTM__Load__c load = new FreightTM__Load__c (RecordTypeId = record_type_id, FreightTM__Status__c = 'Ordered', FreightTM__Dispatch__c = usr.Id, 
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
                                                           ETA__c = datetime.newInstance(2021, 10, 15, 8, 0, 0), Pickup_Signature__c = '<img src="https://yourempiregroup--ethandev2--c.documentforce.com/servlet/rtaImage?eid=a2a02000000Lqtf&amp;feoid=00N1Y00000IvXDZ&amp;refid=0EM02000000LB1T"></img>', 
                                                          Shipper_Signature__c = '<img src="https://yourempiregroup--ethandev2--c.documentforce.com/servlet/rtaImage?eid=a2a02000000Lqtf&amp;feoid=00N1Y00000IvXDZ&amp;refid=0EM02000000LB1T"></img>', 
                                                          Receiver_Signature__c = '<img src="https://yourempiregroup--ethandev2--c.documentforce.com/servlet/rtaImage?eid=a2a02000000Lqtf&amp;feoid=00N1Y00000IvXDZ&amp;refid=0EM02000000LB1T"></img>',
                                                           Mat_Grade__c = 'A');
        insert load;
        
        
        FreightTM__Site_Location__c tmplatLng = new FreightTM__Site_Location__c (FreightTM__Coordinates__latitude__s = 45.555, FreightTM__Coordinates__longitude__s = 54.212);
        insert tmplatLng;
      
        List<FreightTM__Load__c> testList = new List<FreightTM__Load__c>();
        testList.add(load);

      
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new Test_LoadsBatchMill_V2_mock());
            Test.setCurrentPage(Page.BatchLoadsMill);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testList);
            stdSetController.setSelected(testList);
            LoadsBatchMill_V2 ext = new LoadsBatchMill_V2(stdSetController);
  }
    
  
}