@isTest
public with sharing class Test_EmailService_RFP {
// Success Case
    public static testMethod void EmailService_RequestForPricingTest(){
       
       
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
       
        email.subject = 'TEST SUBJECT';
        email.fromName = 'test test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.Phone:123456 Bye';
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1]; 
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'),
        Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;
        envelope.fromAddress = 'user@acme.com';
       


        // setup controller object
        EmailService_RequestForPricing catcher = new EmailService_RequestForPricing();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);   

   
    }
    // Error Case 1
     public static testMethod void EmailService_RequestForPricingTestError1(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        email.subject = 'testSubject';
        email.fromName = 'test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.Phone:123456 Bye';
        envelope.fromAddress = 'user@acme.com';

        EmailService_RequestForPricing catcher = new EmailService_RequestForPricing();
        catcher.handleInboundEmail(email, envelope);

     
     }

     // Error Case 2
    public static testMethod void EmailService_RequestForPricingTestError2(){
       
       
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
       

        email.subject = 'test';
        email.fromName = 'test test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only.Phone:123456 Bye';
        envelope.fromAddress = 'user@acme.com';
       


        // setup controller object
        EmailService_RequestForPricing catcher = new EmailService_RequestForPricing();
        catcher.handleInboundEmail(email, envelope);
   
    }
   
    //Error Case 3
     public static testMethod void EmailService_RequestForPricingTestError3(){
       
       
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
       
        email.subject = 'TEST SUBJECT 2';
        email.fromName = 'test test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
        envelope.fromAddress = 'user@acme.com';
       


        // setup controller object
        EmailService_RequestForPricing catcher = new EmailService_RequestForPricing();
        catcher.handleInboundEmail(email, envelope);
   
    }
}