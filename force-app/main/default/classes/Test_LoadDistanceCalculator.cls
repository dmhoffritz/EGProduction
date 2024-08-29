@isTest
public class Test_LoadDistanceCalculator {

    @isTest
    public static void testLoadDistanceCalculation() {
        // Create a test FreightTM__Load__c record
        FreightTM__Load__c testLoad = new FreightTM__Load__c(
            Pickup_Lat_Long__latitude__s = 37.774929,
            Pickup_Lat_Long__longitude__s = -122.419418,
            Delivery_Lat_Long__latitude__s = 34.052235,
            Delivery_Lat_Long__longitude__s = -118.243683
        );
        insert testLoad;

        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new LoadDistanceCalculatorMockHttpResponse());

        // Invoke the loadDistanceCalculation method
        Test.startTest();
        List<String> loadIds = new List<String>{ testLoad.Id };
        LoadDistanceCalculator.loadDistanceCalculation(loadIds);
        Test.stopTest();

        // Verify the distance has been updated on the test record
        testLoad = [SELECT Id, FreightTM__Distance__c FROM FreightTM__Load__c WHERE Id = :testLoad.Id];
        Integer expectedDistance = LoadDistanceCalculator.convertMetersToMiles(559049); // Distance between San Francisco and Los Angeles
        System.assertEquals(expectedDistance, testLoad.FreightTM__Distance__c);
    }
}