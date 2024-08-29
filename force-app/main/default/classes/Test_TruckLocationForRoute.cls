@istest
public class Test_TruckLocationForRoute {
	@istest
    public static void TruckLocationTest(){
        
        Account walmart= new account(name='Walmart');
    	insert walmart;
     
        FreightTM__load__c objload = new freightTM__load__c ( FreightTM__pickup_city__c='irvine',FreightTM__Confirmation_Number__c='999',FreightTM__Pickup_Date__c= Date.Today() ,FreightTM__delivery_Date__c= date.today(),  FreightTM__Rate__c=2500, FreightTM__Pay_Date__c=date.today(),FreightTM__Distance__c=690);
		insert objload;
        
        FreightTM__Site_Location__c stop = new FreightTM__Site_Location__c ( FreightTM__load__c = objload.id, FreightTM__Coordinates__latitude__s = 34, FreightTM__Coordinates__longitude__s = -117);
		insert stop;
        
        ApexPages.StandardController sc =new ApexPages.StandardController(objload);
        System.currentPagereference().getParameters().put('id',objload.id);
        
        TruckLocationForRoute b = new TruckLocationForRoute(sc);
        Test.setMock(HttpCalloutMock.class, new Test_driverLocation_mock()); 
        //getLocations();
    }
}