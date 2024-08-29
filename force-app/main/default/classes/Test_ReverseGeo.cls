@isTest(seeAllData = false)
public class Test_ReverseGeo {

    @isTest
    public static void testLoadObj() {
        
        //start by creating a load to store related location list
        FreightTM__Load__c testLoad = new FreightTM__Load__c();
        insert testLoad;
        
        //initialize site location object
        FreightTM__Site_Location__c testSite = new FreightTM__Site_Location__c(FreightTM__Coordinates__latitude__s = 31.318687233403793, FreightTM__Coordinates__longitude__s = -89.36327820423644, 
                                                                               FreightTM__Load__c = testLoad.Id);
        insert testSite;
        
        //insert id into standard controller for reference
        ApexPages.StandardController sc = new ApexPages.StandardController(testLoad);
        System.currentPagereference().getParameters().put('id',testLoad.id);
        
        //store load id as list to pass
        List<String> loadId = new List<String>();
        loadId.add(testSite.FreightTM__Load__c);
        
        //setup mock callout for google geocoding api
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Geocode_HTTP_Sample');
        mock.setStatusCode(200);
        mock.setHeader('Contnet-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
       
        
        //test reverse geo class
        test.startTest();
        ReverseGeo_LoadID.evaluateCoords(loadId);
        test.stoptest();
    }
   
    
    @isTest
    public static void testLocationObj() {
        //start by creating a location
        FreightTM__Facility__c testLocation = new FreightTM__Facility__c();
        insert testLocation;
       	
        testLocation.Geolocation__Latitude__s = 31.318687233403793;
        testLocation.Geolocation__Longitude__s = -89.36327820423644;
        
        update testLocation;
        
        //insert id into standard controller for reference
        ApexPages.StandardController sc = new ApexPages.StandardController(testLocation);
        System.currentPagereference().getParameters().put('id',testLocation.id);
        
        //store load id as list to pass
        List<String> locationIds = new List<String>();
        locationIds.add(testLocation.Id);
        
        //setup mock callout for google geocoding api
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Geocode_HTTP_Sample');
        mock.setStatusCode(200);
        mock.setHeader('Contnet-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
       
        
        //test reverse geo class
        test.startTest();
        ReverseGeo_Coordinates.evaluateCoords(locationIds);
        test.stoptest();
       
    }
}