/**
 * @description       : Controller used to get / set server data from sales followup components
 * @author            : Ethan Myers
 * @group             : 
 * @last modified on  : 12-12-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class SalesFollowup {

    public class TaskWrapper {
        @AuraEnabled
        public Task task {get; set;}

        @AuraEnabled
        public Opportunity bid {get; set;}


        public TaskWrapper() {
            this.task = new Task();
            this.bid = new Opportunity();
        }

        public void addTask(Task task) {
            this.task = task;
            this.bid = [SELECT Id, Name, OwnerId,
                        StageName, AccountId, Account_Name__c, Account.Name,
                        CloseDate, Project_Location__c,
                        Primary_Contact__c, Primary_Contact__r.Id, Primary_Contact__r.Name,
                        Primary_Contact__r.MobilePhone, Primary_Contact__r.Email,
                        QuoteReceived__c, SubmittedOn__c
                        FROM Opportunity
                        WHERE Id =: task.WhatId];
        }

    }


    /*
        METHOD USED TO QUERY ALL BID TASKS NOT YET COMPLETED OR EXPIRED FOR CURRENT USER
    */
    @AuraEnabled
    public static List<TaskWrapper> getTasks() {
        List<Task> followupTasks = new List<Task>();
        List<TaskWrapper> tasksToReturn = new List<TaskWrapper>();
        try {
            followupTasks = [SELECT What.Id, What.Name, Who.Id, Who.Name, ActivityDate, Subject, Type
                        FROM Task 
                        WHERE OwnerId =: UserInfo.getUserId()
                        AND Status = 'Not Started'
                        AND (Type = 'Bid Followup 24' OR Type = 'Bid Followup 7 Days' OR Type = 'Bid Followup to Project Start')
                        ORDER BY ActivityDate ASC
                        LIMIT 10];
            for (Task task : followupTasks) {
                TaskWrapper newTask = new TaskWrapper();
                newTask.addTask(task);
                tasksToReturn.add(newTask);
            }
            return tasksToReturn;
        } catch (Exception e) {
            System.debug('Error whenever fetching bids requiring quote confirmation: ' + e.getMessage());
            throw new AuraHandledException('Error whenever fetching bids requiring quote confirmation: ' + e.getMessage());
        }
    }

    /*
        METHOD USED TO CAPTURE UPCOMING BIDS (proj start date < 30 days from today)
        THAT DO NOT HAVE A CLOSED STATUS

        Note: Method should return bids owned by current user
    */
    @AuraEnabled
    public static List<Opportunity> getUpcomingBids() {
        List<Opportunity> opps = new List<Opportunity>();
        try {
            opps = [SELECT Id, Name, OwnerId,
                        StageName, Account_Name__c, 
                        CloseDate, Project_Location__c
                        FROM Opportunity 
                        WHERE StageName != 'No Bid' AND StageName != 'Contractor Lost' AND StageName != 'Bid Won' AND StageName != 'Bid Lost'
                        AND OwnerId =: UserInfo.getUserId()
                        AND CloseDate = NEXT_N_DAYS:30 
                        ORDER BY CloseDate ASC];
            return opps;
        } catch(Exception e) {
            System.debug('Error querying for upcoming bids: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateBidStatus(String bidId, String status) {
        try {
            Opportunity opp = [SELECT Id, StageName 
                                FROM Opportunity
                                WHERE Id =: bidId];
            opp.StageName = status;
            update opp;
            return;
        } catch(Exception e) {
            System.debug('Error updating bid status: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}