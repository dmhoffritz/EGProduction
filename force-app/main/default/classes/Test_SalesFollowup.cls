/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-07-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Test_SalesFollowup {
    
    @TestSetup
    static void makeData(){
        Account testAccount = new Account(
            Name = 'Test Account',
            AccountPriority__c = 'Standard'
        );
        insert testAccount;


        String multipleBidderId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Multiple_Bidders').getRecordTypeId();

        Opportunity testOpp1 = new Opportunity(
            RecordTypeId = multipleBidderId,
            Account = testAccount,
            Name = 'Test Bid 1',
            StageName = 'Submitted',
            OwnerId = UserInfo.getUserId(),
            CloseDate = Date.today().addDays(5),
            Bid_Due_Date__c = Date.today(),
            SubmittedOn__c = Date.newInstance(2022, 9, 1),
            QuoteReceived__c = false
        );
        insert testOpp1;

        Task testTask1 = new Task(
            OwnerId = UserInfo.getUserId(),
            Subject = 'Test Task',
            Status = 'Not Started',
            Priority = 'Normal',
            WhatId = testOpp1.Id,
            Type = 'Bid Followup 24'
        );
        insert testTask1;
    }

    @isTest
    private static void testTaskFetch() {
        test.startTest();
        List<SalesFollowup.TaskWrapper> tasks = SalesFollowup.getTasks();
        test.stopTest();
    }

    @isTest
    private static void testOppFetch() {
        test.startTest();
        List<Opportunity> oppList = SalesFollowup.getUpcomingBids();
        test.stopTest();
    }

    @isTest
    private static void testOppStatusUpdate() {
        test.startTest();
        Opportunity oppTest = [SELECT Id FROM Opportunity LIMIT 1];
        SalesFollowup.updateBidStatus(String.valueOf(oppTest.Id), 'No Bid');
        SalesFollowup.updateBidStatus(String.valueOf(oppTest.Id), 'Contractor Lost');
        //SalesFollowup.updateBidStatus(String.valueOf(oppTest.Id), 'Bid Won');
        //SalesFollowup.updateBidStatus(String.valueOf(oppTest.Id), 'Bid Lost');

        test.stopTest();
    }
}