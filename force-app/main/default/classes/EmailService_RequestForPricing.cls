/**
 * @description       : 
 * @author            : Derek Hoffritz
 * @group             : 
 * @last modified on  : 12-02-2023
 * @last modified by  : Derek Hoffritz
**/
global class EmailService_RequestForPricing implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
                                                            Messaging.InboundEnvelope env) {

        System.debug('Processing quote request...');
        
        // Create an InboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        // a list of carbon copy (CC) addresses, if any
        List<String> ccAddresses = email.ccAddresses;

        // Add the email plain text into the local variable
        String myPlainText = email.plainTextBody;
        System.debug('EMAIL BODY: ');
        System.debug(myPlainText);

        // Try to look up any Users based on the email from address
        // If there is more than one User with the same email address,
        // an exception will be thrown and the catch statement will be called.
        User requestingUser = new User();

        try {
            System.debug('SEARCHING FOR RELATIVE USER RECORD w/ EMAIL: ' + email.fromAddress);
            requestingUser = [SELECT Id, Name
                                FROM User
                                WHERE Email =: email.fromAddress AND UserType ='Standard'
                                LIMIT 1];
            System.debug('USER FOUND: ');
            System.debug(requestingUser);
        }
        // If an exception occurs when the query accesses
        // the User record, a QueryException is called.
        // The exception is written to the Apex debug log
        catch (QueryException e) {
            System.debug('Email Service Query Issue: ' + e);
        }

        // New RFP object to be created
        System.debug('Creating new RFP Object...');

        RFP__c newRFP = new RFP__c();

        try {
            newRFP = createRFP(email, requestingUser.Id);

            System.debug('New RFP Object: ');
            System.debug(newRFP);
        } catch (Exception e) {
            System.debug('Error whenever creating new RFP record: ' + e);
        }

        /*
        newRFP.Name = email.subject;
        newRFP.Email_Thread__c = email.htmlBody;
        newRFP.Sales_Rep__c = '0051Y00000BrZ0gQAF';
        insert newRFP;
        */

        //configure binary attachment handler
        //List<Attachment> attachments = new List<Attachment>();

        if(email.binaryAttachments != null && newRFP != null)
        {
            scrapeAttachments(email.binaryAttachments, newRFP.Id);
            /*
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment attachment = new Attachment();
                
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = newRFP.Id;
                attachments.add(attachment);
            }
            */
        } else {
            System.debug('Unable to scrape attachments...');
            System.debug('Either no attachments or RFP record not created');
        }

        /*
        if(attachments.size() > 0) {
            insert attachments;
        }
        */



        // Set the result to true. No need to send an email back to the user
        // with an error message
        result.success = true;

        // Return the result for the Apex Email Service
        return result;
    }

    global RFP__c createRFP(Messaging.InboundEmail mail, Id userId) {
        System.debug('CREATING RFP RECORD...');
        RFP__c newRFP = new RFP__c();
        Integer maxSubj = 80;
        String subj = '';
        if (mail.subject.length() > maxSubj) {
            subj = mail.subject.substring(0, maxSubj);
        } else {
            subj = mail.subject;
        }
        newRFP.Name = subj;
        String bod = '';
        Integer maxBody = 131072;
        if (mail.htmlBody.length() > maxBody) {
            bod = mail.htmlBody.substring(0, maxBody);
        } else {
            bod = mail.htmlBody;
        }
        newRFP.Email_Thread__c = bod;
        newRFP.OwnerId = userId;
        newRFP.SalesRep__c = userId;
        try {
            System.debug('INSERTING RFP RECORD: ');
            System.debug(newRFP);
            insert newRFP;
            return newRFP;
        } catch (Exception e) {
            System.debug('Issue whenever inserting new RFP record: ' + e);
            return new RFP__c();
        }
    }

    global void scrapeAttachments(List<Messaging.InboundEmail.BinaryAttachment> emailAttachments, Id parentId) {
        System.debug('Scraping Email Attachments...');
        List<Attachment> attachments = new List<Attachment>();
        for(Messaging.InboundEmail.BinaryAttachment bAttachment : emailAttachments) {
            Attachment attachment = new Attachment();
            attachment.Name = bAttachment.fileName;
            attachment.Body = bAttachment.body;
            attachment.ParentId = parentId;
            System.debug('Inserting following attachment: ');
            System.debug(attachment);
            attachments.add(attachment);

            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attachment.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.Title = attachment.Name;//Name of the file
            cVersion.VersionData = attachment.Body;//File content
            Insert cVersion;
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = attachment.ParentId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            if(parentId != null) {
            	Insert cDocLink;
            }

        }

        /*
        if(!attachments.isEmpty() && parentId != null) {
            System.debug('Inserting following ATTACHMENTS: ');
            System.debug(attachments);
            insert attachments;
        }
		*/
    }
}