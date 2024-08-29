/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-30-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest(SeeAllData=false)
public class Test_RateConSignature {
    @istest
    public static void TestRateConSignature(){
        
        FreightTM__Carrier__c objcarrier = new FreightTM__Carrier__c ( FreightTM__Primary_Contact__c='Mark', FreightTM__Cargo_Insurance_Expiration__c = Date.newInstance(2050, 2, 17), FreightTM__Liability_Insurance_Expiration__c = Date.newInstance(2050, 1, 1));
		insert objcarrier;
        
        FreightTM__load__c objload = new freightTM__load__c ( FreightTM__pickup_city__c='irvine', FreightTM__Carrier_Obj__c = objcarrier.Id);
		insert objload;
        

        ApexPages.StandardController sc =new ApexPages.StandardController(objload);
        System.currentPagereference().getParameters().put('id',objload.id);
        
        RateConSignatureV2 b = new RateConSignatureV2(sc);
        
        b.Save2();
        b.clearPickup();
        b.clearDelivery();
        
    }

}