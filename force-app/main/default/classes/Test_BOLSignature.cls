@isTest(SeeAllData=false)
public class Test_BOLSignature {
    @istest
    public static void TestBOLSignature(){
        
        FreightTM__load__c objload = new freightTM__load__c ( FreightTM__pickup_city__c='Irvine', Shipper_Signature__c = '12365859658djdytdystdys', Pickup_Signature__c = '12365859658djdytdystdys',
                                                            Receiver_Signature__c = '12365859658djdytdystdys');
        insert objload;
        
        
        
        ApexPages.StandardController sc =new ApexPages.StandardController(objload);
        System.currentPagereference().getParameters().put('id',objload.id);
        
        BOLSignature b = new BOLSignature(sc);
        
    }
    
 @istest
    public static void TestBOLSignature2(){
        FreightTM__load__c objload = new freightTM__load__c ( FreightTM__pickup_city__c='Irvine');
        insert objload;
        
         ApexPages.StandardController sc =new ApexPages.StandardController(objload);
        System.currentPagereference().getParameters().put('id',objload.id);
        
        BOLSignature b = new BOLSignature(sc);
        
        b.Save2();
        b.clearPickup();
        b.clearDelivery();
        b.clearDriverSign();
        
    }
    
 @istest
    public static void TestBOLSignature3() {
        FreightTM__load__c objload = new freightTM__load__c ( FreightTM__pickup_city__c='Irvine', 
                                                             Shipper_Signature__c = '<p><span style="color: rgb(62, 62, 60);"><img src="https://yourempiregroup--ethandev--c.documentforce.com/servlet/rtaImage?eid=a2a7X000000YuCg&amp;feoid=00N1Y00000IvgUk&amp;refid=0EM7X000000DSeY"></img></span></p>', 
                                                             Pickup_Signature__c = '<p><span style="color: rgb(62, 62, 60);"><img src="https://yourempiregroup--ethandev--c.documentforce.com/servlet/rtaImage?eid=a2a7X000000YuCg&amp;feoid=00N1Y00000IvgUk&amp;refid=0EM7X000000DSeY"></img></span></p>',
                                                             Receiver_Signature__c = '<p><span style="color: rgb(62, 62, 60);"><img src="https://yourempiregroup--ethandev--c.documentforce.com/servlet/rtaImage?eid=a2a7X000000YuCg&amp;feoid=00N1Y00000IvgUk&amp;refid=0EM7X000000DSeY"></img></span></p>');
        insert objload;
        
        
        
        ApexPages.StandardController sc =new ApexPages.StandardController(objload);
        System.currentPagereference().getParameters().put('id',objload.id);
        
        BOLSignature b = new BOLSignature(sc);
        b.Save2();
        
    }
}