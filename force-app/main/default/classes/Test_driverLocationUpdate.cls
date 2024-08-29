@isTest(SeeAllData=false)
public class Test_driverLocationUpdate {
    
    @isTest
    public static void Test_driverLocationUpdate()
    {
        
        
        
        FreightTM__Employee__c emp = new FreightTM__Employee__c( Name='Smith', FreightTM__Type__c = 'Driver');
        insert emp;
        
        FreightTM__Load__c load = new FreightTM__Load__c(FreightTM__Driver__c = emp.Id, Driver_Email__c = 'info@mjtransport.com',
                                                         FreightTM__Driver__r = new FreightTM__Employee__c(id = emp.id, Name = emp.Name)); 
        insert load;
        
        id loadid = System.currentPagereference().getParameters().put('id', load.id);
        
        test.startTest();
        ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        driverLocationUpdate da = new driverLocationUpdate(stndCont); 
        System.currentPagereference().getParameters().put('id', load.id);
        
        
        
        /* FreightTM__Load__c tload = [select Name, FreightTM__Driver__c, FreightTM__Calendar_Load__c, FreightTM__Driver__r.Name, Driver_Email__c
from FreightTM__Load__c
where id =: da.loadid];   */     
        
        
        
        da.subject = 'Test Email Subject';
        da.body = 'Test Plain Text Body';
        da.EmailAddr = 'info@mjtransport.com';
        System.assertEquals('info@mjtransport.com', da.EmailAddr);
        
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