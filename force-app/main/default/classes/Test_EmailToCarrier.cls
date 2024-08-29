@isTest(SeeAllData=false)
public class Test_EmailToCarrier {
    
    @isTest
	public static void Test_EmailToCarrier()
	//static testMethod void Test_EmailInvoicewithSelectedAttachments()
    {
        //Start test - changes governor limit context to that of button trigger rather than test
        
        //Data prep
        //List Load Record
        
        FreightTM__Employee__c emp = new FreightTM__Employee__c(FreightTM__PIN__c='1234', Name='Smith', FreightTM__Type__c = 'Driver', Title__c = 'Chief Executive Officer');
        insert emp;
        
        FreightTM__Carrier__c car = new FreightTM__Carrier__c(Name = 'MJ Transport', FreightTM__Email__c = 'info@mjtransport.com');
        insert car;
        
        /*
        FreightTM__Load__c load = new FreightTM__Load__c(FreightTM__Driver__c = emp.Id, 
            FreightTM__Driver__r = new FreightTM__Employee__c(id = emp.id, Name = emp.Name));
        insert load;
		*/
        FreightTM__Load__c load = new FreightTM__Load__c(FreightTM__Carrier_Obj__c = car.Id, 
                                                         FreightTM__Carrier_Obj__r = new FreightTM__Carrier__c(id = car.id, Name = car.Name)); 
        insert load;
        
       // FreightTM__Load__c load = new FreightTM__Load__c(FreightTM__Carrier__c = car.Id, 
        //    FreightTM__Driver__r = new FreightTM__Employee__c(id = emp.id, Name = emp.Name), 
         //   FreightTM__Invoice_Status__c = '', FreightTM__Invoiced_On__c = null);
           // FreightTM__Customer__c = acct.Id, FreightTM__Customer__r = new Account(id = acct.id, Name = acct.Name, Email__c = acct.Email__c));
      //  insert load;
        //Email_Template_Id__c = '00X5C000000tgNP',

        id loadid = System.currentPagereference().getParameters().put('id', load.id);
        
        //query loads to retrieve Load Name
        /*
        FreightTM__Load__c tload = [select Name, FreightTM__Driver__c//, FreightTM__Driver__r.Name, FreightTM__Driver__r.PIN__c
                                            from FreightTM__Load__c
                                            where id =: loadid];
        */

        // Call Constructor
		test.startTest();        
		ApexPages.StandardController stndCont = new ApexPages.StandardController(load);
        EmailToCarrierwithSelectedAttachments da = new EmailToCarrierwithSelectedAttachments(stndCont); //calling constructor
        System.currentPagereference().getParameters().put('id', load.id);
		
        //system.test.startTest();
        //test.startTest();
        //da.loadid = System.currentPagereference().getParameters().put('id', load.id);
        //da.cvfileList
        
        
		FreightTM__Load__c tload = [select Name, FreightTM__Driver__c, FreightTM__Carrier_Obj__c, FreightTM__Carrier_Obj__r.Name, FreightTM__Carrier_Obj__r.FreightTM__Email__c
                                    		//FreightTM__Driver__r.Name, FreightTM__Driver__r.PIN__c
                                            from FreightTM__Load__c
                                            where id =: da.loadid];        
        
        //public List<ContentDocumentLink> cDocLinkList {get; set;} //all Files links under a Load record
       
        
        //Invoice Email Template
        da.subject = 'Test Email Subject';
        da.body = 'Test Plain Text Body';
        //da.hbody = 'Test HTML Body';
        //da.EmailTemplateID = load.Email_Template_Id__c;
        //da.et = [Select Id, Name, Subject, Body, HtmlValue FROM EmailTemplate WHERE Id =: da.EmailTemplateID];
        
        for(ContentVersion cv : da.cvfileList)
        {
            cv.Title = 'Test';
            cv.VersionData = Blob.valueof('Test.pdf');
        }
        //da.fileName = 'Test';
        //da.fileBody = Blob.valueof(pdfString);
        //Integer size = pdfBlob.size();

        /*
        System.assertEquals('1234', da.inputPin);
        System.assertEquals('Smith', da.inputLName);
        //System.assertEquals(tload.Name, da.inputLoad);
        System.assert(da.Match == true);
        System.assert(da.loadrec.size() > 0);
        System.assert(da.msg == false);
        System.assert(da.msgs == null);
        //System.debug('Load ' + da.inputLoad);
        */
        da.getSelectedFiles();
        da.getCheckboxFileList();
        da.Send();

        //System.assert(da.msgs.contains('file(s) uploaded successfully. ' + '\n' + 'Load has been updated.'));
        //System.assert(da.msgs == 'Please enter a PIN.');
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean f = false;
        for(Apexpages.Message msg:msgs){
            if(msg.getDetail().contains('Email (with 2 attachments) has been sent')) f = true;
        }
        system.assert(f);

        System.assertEquals(load.id, da.load.id);


        test.stopTest();
        //system.test.stopTest();
    }
}