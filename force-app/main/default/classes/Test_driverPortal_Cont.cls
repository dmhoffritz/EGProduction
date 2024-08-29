@isTest(SeeAllData=false)
public class Test_driverPortal_Cont {

    @TestSetup
    static void makeData() {
        Id standardRecType = Schema.SobjectType.FreightTM__Load__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        FreightTM__Load__c testLoad = new FreightTM__Load__c(RecordTypeId = standardRecType, 
                                                                FreightTM__Status__c = 'Dispatched');
        insert testLoad;
    }
    
    @isTest
    public static void testPageLoad() {
        test.startTest();
        FreightTM__Load__c load = [SELECT Id, Name, FreightTM__Status__c
                                    FROM FreightTM__Load__c];
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        System.currentPageReference().getParameters().put('Id', load.Id);
        driverPortal_Cont portal = new driverPortal_Cont(stndCont);
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock());
        portal.lat_long = '45.55, -54.212';
        portal.storeCoordinates();
        test.stopTest();
    }

    @isTest
    private static void testLoadFetch() {
        test.startTest();
        FreightTM__Load__c load = [SELECT Id
                                    FROM FreightTM__Load__c];
        Test.setMock(HttpCalloutMock.class, new Test_driverLoad_mock());
        FreightTM__Load__c returnedLoad = driverPortal_Cont.getLoadData(String.valueOf(load.Id));
        test.stopTest();
    }

    @isTest
    private static void testStatusUpdate() {
        test.startTest();
        FreightTM__Load__c load = [SELECT Id
                                    FROM FreightTM__Load__c];
        driverPortal_Cont.updateLoadStatus(String.valueOf(load.Id), 'Arrived for pickup');
        load.FreightTM__Status__c = 'Delivered';
        update load;
        driverPortal_Cont.updateLoadStatus(String.valueOf(load.Id), 'Arrived for delivery');
        test.stopTest();
    }

    @isTest
    private static void testSignatureUploads() {
        test.startTest();
        FreightTM__Load__c load = [SELECT Id
                                    FROM FreightTM__Load__c];
        String signature = 'https://yourempiregroup--ethandev2--c.documentforce.com/servlet/rtaImage?eid=a2a02000000Lqtf&amp;feoid=00N1Y00000IvXDZ&amp;refid=0EM02000000LB1T';
        driverPortal_Cont.uploadSignature(String.valueOf(load.Id), signature, 'Driver');
        load.FreightTM__Status__c = 'Arrived for pickup';
        update load;
        driverPortal_Cont.uploadSignature(String.valueOf(load.Id), signature, 'Pickup');
        load.FreightTM__Status__c = 'Arrived for delivery';
        update load;
        driverPortal_Cont.uploadSignature(String.valueOf(load.Id), signature, 'Delivery');
        test.stopTest();
    }
}