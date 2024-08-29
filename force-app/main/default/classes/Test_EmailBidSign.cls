@isTest(SeeAllData=false)
public class Test_EmailBidSign {
    
    @isTest
	public static void Test_EmailBidSign()
	//static testMethod void Test_EmailInvoicewithSelectedAttachments()
    {
        
        FreightTM__Employee__c emp = new FreightTM__Employee__c(FreightTM__PIN__c='1234', Name='Smith', FreightTM__Type__c = 'Driver', Title__c = 'Chief Executive Officer');
        insert emp;

        Account testAccount = new Account(Name = 'Test Account', AccountPriority__c = 'Standard');
        insert testAccount;

        String stndContactId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Standard_Contact').getRecordTypeId();
        Contact testContact = new Contact(RecordTypeId = stndContactId, FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id, Importance__c = 'TBD', Email='testcontact@gmail.com');
        insert testContact; 

        //Powerline_Project
        String pwrProjectId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Powerline_Project').getRecordTypeId();
        Project__c testProject = new Project__c(RecordTypeId = pwrProjectId, Project_Name__c = 'Test Project', Stage__c = 'Planning', Division__c = 'Powerline', Utility_Gas_Company__c = testAccount.Id);
        insert testProject;

        Date today = Date.today();
        //Multiple_Bidders
        String multipleBidderId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Multiple_Bidders').getRecordTypeId();
        Opportunity bid = new Opportunity(RecordTypeId = multipleBidderId, Name = 'Test Opportunity', AccountId = testAccount.Id, StageName = 'New', CloseDate = today, Primary_Contact__c = testContact.Id, OwnerId = UserInfo.getUserId());
        insert bid;

        id bidId = System.currentPagereference().getParameters().put('id', bid.id);

        // Call Constructor
		test.startTest();        
		ApexPages.StandardController stndCont = new ApexPages.StandardController(bid);
        EmailBidSign da = new EmailBidSign(stndCont); //calling constructor
        System.currentPagereference().getParameters().put('id', bid.Id);
		
        //system.test.startTest();
        //test.startTest();
        //da.bidId = System.currentPagereference().getParameters().put('id', bid.Id);
        //da.cvfileList
        
            
        Opportunity bidOpp = [SELECT Id, Name, Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.Email FROM Opportunity];
        
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
        //system.assert(f);

        //System.assertEquals(bid.Id, da.bid.Id);


        test.stopTest();
        //system.test.stopTest();
    }
}