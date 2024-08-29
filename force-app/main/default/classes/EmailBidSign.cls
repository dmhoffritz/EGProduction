public class EmailBidSign {
    /*
    PARAMETERS RECEIVED FROM URL
    */
    public id bidId {get; set;}
    public Opportunity bid {get; set;}
    public List<String> cDocLinkIds {get; set;}
    /*
    END PARAMETERS RECEIVED FROM URL
    */

    public Organization coOrg {get; set;}
    public Double offset {get; set;}
    public List<String> attachmentIds {get; set;}


    public List<ContentDocumentLink> cDocLinkList; //all File links under a Load record
    public List<ContentVersion> cvfileList {get; set;} //all File details under a Load record
    public List<id> ConDocIds; //all File ContentVersionIds under a Load record
    public List<Attachment> attachments; //list for inserting attachments under email history activity record
   // public List<ContentDocumentLink> cDocLinkList; //all File links under a Load record
   // public List<ContentVersion> cvfileList {get; set;} //all File details under a Load record
  //  public List<id> ConDocIds; //all File ContentVersionIds under a Load record
    
    //Invoice Email Template
    public String subject {get; set;} //email subject
    public String body {get; set;} //plain text email body
    public String emailAddr {get; set;} //entered email addresses, split with comma
    public List<String> emailAddrList; //email address list
    
    public List<String> checkboxFileList {get;set;}  //holds the values of the selected checkboxes for Files
    
    public EmailBidSign(ApexPages.StandardController stndCont) //constructor
    {
        bidId = ApexPages.currentPage().getParameters().get('id');
        bid = [SELECT Name, Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.Email
                from Opportunity where id =: bidId];
        
        //String tempIds = ApexPages.currentPage().getParameters().get('cDocLinkIds');
        //cDocLinkIds = tempIds.split(',');
        /*
        attachmentIds = new List<Id>();
        try {
            ContentDocumentLink cDocLInk = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: bid.Id ORDER By SystemModstamp DESC LIMIT 1];
            /*
            for (ContentDocumentLink cdl : cDocLinks) {
                ContentVersion cv = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =: cdl.ContentDocumentId];
                cvs.add(cv);
            }
            ContentVersion cVersion = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =: cDocLink.ContentDocumentId];
            attachmentIds.add(cVersion.Id);
        } catch(Exception e) {
            System.debug('Error whenever fetching content document links for bid w/ id: ' + bid.Id +'\n' + 'Error: ' + e.getMessage());
        }
        */
        checkboxFileList = new List<String>(); //create new list of Files checkboxes
        
        //query all Files under a Load record
        /* /////////////// */
        cDocLinkList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: bidId];
        cvfileList = new List<ContentVersion>();
        
        for(ContentDocumentLink cDocLink : cDocLinkList) {
            ContentVersion cvfile = new ContentVersion();
            try {
                cvfile = [SELECT Title, FileExtension FROM ContentVersion WHERE ContentDocumentId =: cDocLink.ContentDocumentId AND Document_Type__c = 'Quote' ORDER BY ContentModifiedDate DESC LIMIT 1];
            } catch(QueryException e) {
                System.debug('Error whenever querying for Content Version: ' + e.getMessage());
            }
            //ContentVersion cvfile = [SELECT Title, PathOnClient, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId =: cDocLink.ContentDocumentId];
            
            if (cvfile != null) {
                cvfileList.add(cvfile);
            }
            //cvfileList = [SELECT Title, PathOnClient, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId =: cDocLink.ContentDocumentId AND IsLatest = true];
        }
        /* /////////////// */
        
        //grab ContentDocumentId of all Files under a Load record
        /* /////////////// */
        ConDocIds = new List<id>();
        
        for(ContentDocumentLink cDocLink : cDocLinkList) 
        {
            ConDocIds.add(cDocLink.ContentDocumentId);
        }
        
        coOrg = [Select o.Street, o.City, o.State, o.PostalCode, o.Phone, o.Name, o.Id, o.Fax, o.Country, o.Address From Organization o];
        
        User currUser = [Select Id,Signature from User where Id=:userinfo.getuserId()];
            string userSignature = currUser.Signature;
             if (String.isNotBlank(userSignature)) {
                 userSignature = userSignature.replace('\n','<br>');
            }

        TimeZone tz = UserInfo.getTimeZone();
        offset = tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        
       // checkboxFileList = new List<String>(); //create new list of Files checkboxes
        
     /*  cDocLinkList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: bidId];
        cvfileList = new List<ContentVersion>();
        
        for(ContentDocumentLink cDocLink : cDocLinkList) {
            ContentVersion cvfile = [SELECT Title, FileExtension FROM ContentVersion WHERE ContentDocumentId =: cDocLink.ContentDocumentId];
            cvfileList.add(cvfile);
        }
        
        //grab ContentDocumentId of all Files under a Load record
        ConDocIds = new List<id>();
        
        for(ContentDocumentLink cDocLink : cDocLinkList) 
        {
            ConDocIds.add(cDocLink.ContentDocumentId);
        }*/
        
        EmailAddrList = new List<String>();
        EmailAddr ='' ;
        EmailAddrList = new String[]{ EmailAddr };
            
            subject = coOrg.Name + ':' + ' Quote Request - ' + bid.Name; //'Update'+' '+ load.FreightTM__Calendar_Load__c;
        
        EmailAddr = bid.Primary_Contact__r.Email;
        
        system.debug('EmailAddrList stndC' + EmailAddrList.size());
        
        body =  bid.Primary_Contact__r.Name + ', \n\n';
        body += 'Please see attached quote for bid: ' + bid.Name + '\n\n';
        
        body += '\n';
        
        body += 'If you have any questions, please call me directly at the number below.' + ' \n';
        
        body += '\n';
        
        body += 'Thank you,  \n';
    }
    
    
    String Name = UserInfo.getName();
    String UserEmail = UserInfo.getUserEmail();

    public String getSubject() {
        this.subject = subject;
        return subject;
    }
    
    public String getBody() {
        this.body = body;
        return body;
    }
    
    public String getEmailAddr(){
        this.EmailAddr = EmailAddr;
        return EmailAddr;
    }

    
    //create list of checkboxes for Files
    public List<selectOption> getSelectedFiles() { 

        List<selectOption> fileOptions = new List<selectOption>();
        
        //grab ContentDocumentId of all Files under a Load record
        /* /////////////// */
        /*
        List<id> ConDocIds = new List<id>();
        
        for(ContentDocumentLink cDocLink : cDocLinkList) 
        {
            ConDocIds.add(cDocLink.ContentDocumentId);
        }
        */
        /* /////////////// */
        
        system.debug('FileList ' + checkboxFileList.size());

        //for(integer i=0; i < cvfileList.size(); i++) {
        for(ContentVersion cv : [SELECT Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :ConDocIds AND Document_Type__c = 'Quote']) 
        {   
            fileOptions.add(new selectOption(string.valueof(cv.ContentDocumentId),string.valueof(cv.Title + '.' + cv.FileExtension))); // selectOption = (value,label)
            //fileOptions.add(new selectOption(string.valueof(cv.Title),string.valueof(cv.Title + '.' + cv.FileExtension))); // selectOption = (value,label)
            //fileOptions.add(new selectOption(string.valueof(cv.Title + ',' + cv.ContentDocumentId),string.valueof(cv.Title + '.' + cv.FileExtension))); // selectOption = (value,label)
        }

        //fileOptions.add(new selectOption('Invoice_' + load.Invoice_Number__c + '.pdf', 'Invoice_' + load.Invoice_Number__c + '.pdf'));
        
        //have invoice option be selected by default
        checkboxFileList = new List<String>(); //create new list of Files checkboxes
        //checkboxFileList = new List<String>{ 'Invoice_' + load.Invoice_Number__c + '.pdf' }; //create new list of Files checkboxes

        return fileOptions;
    }
    
    //get selected checkboxes for Files
    public String[] getCheckboxFileList() {
        return checkboxFileList;
    }
    //set selected checkboxes for Files
    public void setCheckboxFileList(String[] checkboxFileList) {
        this.checkboxFileList = checkboxFileList;
    }
    
    public PageReference Send(){
        
        getSubject();    
        getBody();
        getEmailAddr();
        
        String hbody = body.replace('\n', '<br />');
        
        //define email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        
        email.setSubject(subject);
        
       // system.debug('EmailAddrList Send before ' + EmailAddrList.size());
        
        EmailAddrList = EmailAddr.split(',');
        email.setToAddresses(EmailAddrList); 
        
        
       // system.debug('EmailAddrList After ' + EmailAddrList.size());
       // system.debug('EmailAddr ' + EmailAddr);
        
        
        email.setHtmlBody(hbody); //ERROR: does not display HTML content, only Plain Text of email template
        email.setPlainTextBody(body);

        email.setEntityAttachments(attachmentIds);
        
        email.setSaveAsActivity(true);
        
        //create Email Attachment List to add Files to
        List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
        
        system.debug('FileList Selected ' + checkboxFileList.size());
        
        //query for selected checkboxes and assign File to email attachment
        for(integer i=0; i < checkboxFileList.size(); i++) {
            
            /*
            String addressFull  = 'F-206, Daffodils, Magarpatta, Pune, India, 411028';
            String[] address     = addressFull.split(',');
            String houseNumber         =     address[0]; 
            String buildingName          =    address[1];
            */
            
            for(ContentVersion cv : [SELECT Title, PathOnClient, FileExtension, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :ConDocIds AND ContentDocumentId =: checkboxFileList[i]]) 
            //for(ContentVersion cv : [SELECT Title, PathOnClient, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId IN :ConDocIds AND Title =: checkboxFileList[i]])           
            {   
                Messaging.EmailFileAttachment efatt = new Messaging.EmailFileAttachment();
                efatt.setFileName(cv.Title + '.' + cv.FileExtension);
                blob ebody = cv.VersionData;
                efatt.setBody(ebody);
                //efatt.setBody(cv.VersionData);
                //efatt.setContentType();
                efaList.add(efatt);
                //fileAttachments.add(efatt); 
                system.debug('Email Info ' + cv.VersionData + ' ' + cv.Title + ' ' +  cv.FileExtension);
                system.debug('Email Attach ' + efatt); 
                
                /*
                blob ebody = cv.VersionData;
                string filename = 'Test_' + cv.Title + '.' + cv.FileExtension;
                //create email attachment
                efaList.add(new Messaging.EmailFileAttachment( 
                    //setFileName('Test_' + cv.Title + '.' + cv.FileExtension),
                    setFileName(filename),
                    //setBody(Blob.valueOf(cv.VersionData))
                    //blob ebody = cv.VersionData,
                    setBody(ebody)
                    //setBody(cv.VersionData)
                    //setContentType()
                ));
                system.debug('Email Attach ' + cv.VersionData + ' ' + cv.Title + ' ' +  cv.FileExtension);
                */
            }

        }
        email.setFileAttachments(efaList);   

        //send email
        try {
                if(bid.Primary_Contact__r.Email != null || emailAddr != '') { //|| load.FreightTM__Factoring__c == true

                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    //log email history activity
                    EmailMessage emailMsg = new EmailMessage();
                    
                    system.debug('EmailAddrList Size ' + EmailAddrList.size());
                    
                    emailMsg.ToAddress = EmailAddr;
                    
                    /* /////////////////////////////// */
                    
                    emailMsg.Subject = subject;
                    emailMsg.HtmlBody = hbody;
                    emailMsg.TextBody = body;
                    emailMsg.MessageDate = system.now(); //datetime.now(); 
                    emailMsg.RelatedToId = bidId;
                    emailMsg.FromAddress = UserInfo.getUserEmail(); // UserInfo.getOrganizationName()
                    emailMsg.FromName = UserInfo.getName();
                    emailMsg.Status = '3';
                    insert emailMsg;
                                        
                    //success message
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Email has been sent'));

                    Opportunity bidRec = [SELECT Id, StageName FROM Opportunity WHERE Id =: bidId];
                    bidRec.StageName = 'Submitted';
                    update bidRec;

                    return null;
                }

            }
        
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Error ' + e));
            throw e;
        }
        
        return null;
    }
    
}