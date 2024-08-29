//Set Distance Test

@istest(seeAllData=False)
public class Test_SetDistance {

	@istest
    public static void Test_SetDistance(){
        
        Account walmart= new account(name='Walmart');
    	insert walmart;
     
        FreightTM__load__c objload = new freightTM__load__c ( FreightTM__pickup_address__c='20 main',FreightTM__pickup_city__c='irvine',FreightTM__pickup_state__c='CA',FreightTM__delivery_address__c='20 main',FreightTM__delivery_city__c='san diego',FreightTM__delivery_state__c='CA',FreightTM__Confirmation_Number__c='999',FreightTM__Pickup_Date__c= Date.Today() ,FreightTM__delivery_Date__c= date.today(),  FreightTM__Rate__c=2500, FreightTM__Pay_Date__c=date.today(),FreightTM__Distance__c=690);
		insert objload;
        
        FreightTM__stop__c stop = new freightTM__stop__c ( FreightTM__load__c=objload.id,FreightTM__Address__c='200 main', FreightTM__City__c='irvine', FreightTM__State__c='CA' );
		insert stop;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objload);
        System.currentPagereference().getParameters().put('id',objload.id);
        
        list<id> loadid = new list<id>{objload.id};
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_SetDistance_mock());
        //HttpResponse res = CalloutClass.getInfoFromExternalService(myCase.Id);
        Test.stopTest();
            
        //Set_Distance b = new Set_Distance();
        Set_Distance.Set_Distance(loadid);
        //Set_Distance.btnCalculateDistance_Click(loadid);
        //Direction b = new Direction();
        //freightTM__load__c f=  b.getload();
    }
}