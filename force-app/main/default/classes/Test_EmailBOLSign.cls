@isTest(SeeAllData=false)
public class Test_EmailBOLSign {
    
    @isTest
    public static void TestEmailBOLSign()
    {
        
        
        
        FreightTM__Carrier__c emp = new FreightTM__Carrier__c(Name = 'TEST', FreightTM__Email__c = 'dhoffritz@yourempiregroup.com');
        insert emp;
        
        FreightTM__Load__c load = new FreightTM__Load__c(FreightTM__Carrier_Obj__c = emp.Id,
                                                         FreightTM__Carrier_Obj__r = new FreightTM__Carrier__c(id = emp.id, Name = emp.Name)); 
        insert load;
        
        id loadid = System.currentPagereference().getParameters().put('id', load.id);
        
        test.startTest();
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        EmailBOLSign da = new EmailBOLSign(stndCont); 
        System.currentPagereference().getParameters().put('id', load.id);
        
        
        
        /* FreightTM__Load__c tload = [select Name, FreightTM__Driver__c, FreightTM__Calendar_Load__c, FreightTM__Driver__r.Name, Driver_Email__c
from FreightTM__Load__c
where id =: da.loadid];   */     
        
        
        
        da.subject = 'Test Email Subject';
        da.body = 'Test Plain Text Body';
        da.EmailAddr = 'dhoffritz@yourempiregroup.com';
        System.assertEquals('dhoffritz@yourempiregroup.com', da.EmailAddr);
        
        da.Send();
        
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean f = false;
        for(Apexpages.Message msg:msgs){
            if(msg.getDetail().contains('Email has been sent')) f = true;
            
        }
        system.assert(f);
        
        // System.assertEquals(load.id, da.load.id);
        
        test.stopTest();
    }
    
    @isTest
    public static void TestEmailBOLSign_CPU()
    {
        
        
        
        FreightTM__Carrier__c emp = new FreightTM__Carrier__c(Name = 'TEST', FreightTM__Email__c = 'dhoffritz@yourempiregroup.com');
        insert emp;
        
        FreightTM__Load__c load = new FreightTM__Load__c(FreightTM__Carrier_Obj__c = emp.Id,
                                                         FreightTM__Carrier_Obj__r = new FreightTM__Carrier__c(id = emp.id, Name = emp.Name)); 
        insert load;
        
        id loadid = System.currentPagereference().getParameters().put('id', load.id);
        
        test.startTest();
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        EmailBOLSign_CPU da = new EmailBOLSign_CPU(stndCont); 
        System.currentPagereference().getParameters().put('id', load.id);
        
        
        
        /* FreightTM__Load__c tload = [select Name, FreightTM__Driver__c, FreightTM__Calendar_Load__c, FreightTM__Driver__r.Name, Driver_Email__c
from FreightTM__Load__c
where id =: da.loadid];   */     
        
        
        
        da.subject = 'Test Email Subject';
        da.body = 'Test Plain Text Body';
        da.EmailAddr = 'dhoffritz@yourempiregroup.com';
        System.assertEquals('dhoffritz@yourempiregroup.com', da.EmailAddr);
        
        da.Send();
        
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean f = false;
        for(Apexpages.Message msg:msgs){
            if(msg.getDetail().contains('Email has been sent')) f = true;
            
        }
        system.assert(f);
        
        // System.assertEquals(load.id, da.load.id);
        
        test.stopTest();
    }
}