public class EmailRateConSign {
   
    public id loadid {get; set;}
    public FreightTM__Load__c load {get; set;}
    public Organization coOrg {get; set;}
    public Double offset {get; set;}


   // public List<ContentDocumentLink> cDocLinkList; //all File links under a Load record
   // public List<ContentVersion> cvfileList {get; set;} //all File details under a Load record
  //  public List<id> ConDocIds; //all File ContentVersionIds under a Load record
    
    //Invoice Email Template
    public String subject {get; set;} //email subject
    public String body {get; set;} //plain text email body
    public String emailAddr {get; set;} //entered email addresses, split with comma
    public List<String> emailAddrList; //email address list


    
    
   // public List<String> checkboxFileList {get;set;}  //holds the values of the selected checkboxes for Files
    
    public EmailRateConSign(ApexPages.StandardController stndCont) //constructor
    {
        loadid = ApexPages.currentPage().getParameters().get('id');
        load = [Select Name, FreightTM__Invoice_Status__c, FreightTM__Invoiced_On__c,
                FreightTM__Factoring__c, FreightTM__Rate__c, FreightTM__Total__c, FreightTM__Truck__c, FreightTM__Truck__r.Name,
                FreightTM__Confirmation_Number__c, FreightTM__Status__c, FreightTM__Load_Canceled__c, FreightTM__Carrier_Obj__c, FreightTM__Carrier_Obj__r.FreightTM__Email__c,
                FreightTM__Distance__c, FreightTM__Remarks__c, FreightTM__Total_Miles__c, FreightTM__Carrier_Obj__r.Name,
                FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c,
                FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, FreightTM__Pickup_Arrival__c, Pickup_By__c, FreightTM__Pickup_By_Appointment__c,
                FreightTM__Pickup_Ref__c, FreightTM__Pickup_Remarks__c, FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c,
                FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c, FreightTM__Delivery_Arrival__c, Deliver_By__c, FreightTM__Delivery_By_Appointment__c,
                FreightTM__Delivery_Ref__c, FreightTM__Delivery_Remarks__c, Driver_Email__c, FreightTM__Calendar_Load__c, FreightTM__Driver__r.Name,
                FreightTM__Total_Line_Items__c, (select Id, Name, FreightTM__Load__c, FreightTM__Amount__c, FreightTM__Description__c, 
                                                 FreightTM__Number_of_Units__c, FreightTM__Type__c, FreightTM__Unit_Price__c from FreightTM__Line_Items__r)
                from FreightTM__Load__c where id =: loadid];
        
        
        coOrg = [Select o.Street, o.City, o.State, o.PostalCode, o.Phone, o.Name, o.Id, o.Fax, o.Country, o.Address From Organization o];
        
        User currUser = [Select Id,Signature from User where Id=:userinfo.getuserId()];
            string userSignature = currUser.Signature;
             if (String.isNotBlank(userSignature)) {
                 userSignature = userSignature.replace('\n','<br>');
}

        TimeZone tz = UserInfo.getTimeZone();
        offset = tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
                     
        
       // checkboxFileList = new List<String>(); //create new list of Files checkboxes
        
     /*  cDocLinkList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: loadid];
        cvfileList = new List<ContentVersion>();
        
        for(ContentDocumentLink cDocLink : cDocLinkList) {
            ContentVersion cvfile = [SELECT Title, FileType FROM ContentVersion WHERE ContentDocumentId =: cDocLink.ContentDocumentId];
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
            
            subject = coOrg.Name + ' Electronic RateCon ' + Load.FreightTM__Carrier_Obj__r.Name + ' For Load #: ' + Load.Name; //'Update'+' '+ load.FreightTM__Calendar_Load__c;
        
        EmailAddr = load.FreightTM__Carrier_Obj__r.FreightTM__Email__c;
        
        system.debug('EmailAddrList stndC' + EmailAddrList.size());
        
        String PickupBy = ''; if(Load.Pickup_By__c != null) { PickupBy = Load.Pickup_By__c.format('EEE, MMM d yyyy: h:mm, a z'); }
        String DeliverBy = ''; if(Load.Deliver_By__c != null) { DeliverBy = Load.Deliver_By__c.format('EEE, MMM d yyyy: h:mm, a z'); }
        
        body = 'Dear ' + load.FreightTM__Carrier_Obj__r.Name + ', \n\n';
        body += '<b>' + 'Please click on the following link to view your RateCon form for Agreement: ' + '</b>' + ' \n' + '<a href="http://yourempiregroup.secure.force.com/ratecon/RateConSignatureV2VFP?id='+Load.Id+'">VIEW RATECON</a>' + '\n\n';
        body += 'Load #: ' + Load.Name + ' \n'; 
        body += 'Pickup By: ' + PickupBy + ' \n';
        body += 'Deliver By: ' + DeliverBy + ' \n\n';
        body += '<b>THE FOLLOWING STEPS ARE REQUIRED IN ORDER TO RECEIVE PAYMENT. PLEASE READ THE INSTRUCTIONS CAREFULLY</b>' + '\n';
        body += 'After you save this RateCon Agreement, the driver will receive a text message link on his/her mobile device, which the driver will be required to click on and complete the following steps:' + '\n';
        body += '    1.) Driver to click on "Arrived for Pickup" once at the pickup location to obtain the "Shipper Signature" from the onsite shipping contact, then click save.' + '\n';
        body += '    2.) IF delayed, the driver is required to update his/her status, add comments, select the new ETA, and click save.' + '\n';
        body += '    3.) Driver to click on "Arrived for Delivery" once at the delivery location to obtain the "Receiver Signature" from the onsite receiving contact AND "Driver Signature", then click save.' + '\n\n';
        body += '<b>It must be a representative of the shipper and receiver that signs the mobile device. Once we have all three signatures, the load will automatically be updated to Delivered and you will immediately receive an email copy of the Signed BOL.</b>' + '\n';
        
        body += '\n';
        
        if(Load.FreightTM__Remarks__c != null){
            body += '<b>Delivery Instructions: </b>' + Load.FreightTM__Remarks__c + ' \n\n';
        }
        body += 'If you have any questions, please call me directly at the number below.' + ' \n';
        
        body += '\n';
        
        body += 'Thank you,  \n';
        body += coOrg.Name + '\n' + coOrg.Street + '\n' + coOrg.City + ', ' + coOrg.State + ' ' + coOrg.PostalCode + '\n' + coOrg.Phone + '\n';
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
    
    public PageReference Send(){
        
        getSubject();    
        getBody();
        getEmailAddr();
        
        String body = body.replace('\n', '<br />');

        
        //define email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        
        email.setSubject(subject);
        
       // system.debug('EmailAddrList Send before ' + EmailAddrList.size());
        
        EmailAddrList = EmailAddr.split(',');
        email.setToAddresses(EmailAddrList); 
        
        
       // system.debug('EmailAddrList After ' + EmailAddrList.size());
       // system.debug('EmailAddr ' + EmailAddr);
        
        
        email.setHtmlBody(body); //ERROR: does not display HTML content, only Plain Text of email template
        email.setPlainTextBody(body);
        
        email.setSaveAsActivity(true);
        
        
        //send email
        try {
            if(load.FreightTM__Carrier_Obj__r.FreightTM__Email__c == null){ //&& load.FreightTM__Factoring__c == false
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please fill in Carrier Email on Load record'));  
            }
            else {
                if(load.Driver_Email__c != null || emailAddr != '') { //|| load.FreightTM__Factoring__c == true

                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    //log email history activity
                    EmailMessage emailMsg = new EmailMessage();
                    
                    system.debug('EmailAddrList Size ' + EmailAddrList.size());
                    
                    emailMsg.ToAddress = EmailAddr;
                    
                    /* /////////////////////////////// */
                    
                    emailMsg.Subject = subject;
                    emailMsg.HtmlBody = body;
                    emailMsg.TextBody = body;
                    emailMsg.MessageDate = system.now(); //datetime.now(); 
                    emailMsg.RelatedToId = loadid;
                    emailMsg.FromAddress = UserInfo.getUserEmail(); // UserInfo.getOrganizationName()
                    emailMsg.FromName = UserInfo.getName();
                    emailMsg.Status = '3';
                    insert emailMsg;
                                        
                    //success message
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Email has been sent'));
                    return null;
                }
                else {
                    //error message
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Carrier\'s email is missing or not in the system'));
                    return null;
                }
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Error ' + e));
            throw e;
        }
        
        return null;
    }
    
}