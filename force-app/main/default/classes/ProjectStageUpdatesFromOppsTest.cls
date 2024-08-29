/**
 * @description       : 
 * @author            : Derek Hoffritz
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : Derek Hoffritz
**/
@isTest
private class ProjectStageUpdatesFromOppsTest {
    @isTest static void testTrigger() {
        // Create a new Account
        Account account1 = new Account(
            Name = 'Asset Account 1',
            AccountPriority__c = 'Standard',
            Type = 'Asset Owner'
        );
        insert account1;

        // Create a new contractor company account
        Account account2 = new Account(
            Name = 'Contractor Account 2',
            AccountPriority__c = 'Standard',
            Type ='Contractor'
        );
        insert account2;

        // Create a new Project__c record
        Project__c project = new Project__c(
            Name = 'Test Project', 
            Stage__c = 'Out for Bid', 
            Project_Start_Date__c = System.today() + 30, 
            City__c = 'Slidell', 
            State__c = 'LA', 
            Utility_Gas_Company__c = account1.Id
        );
        insert project;

        // Create a new Opportunity record
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp 1',
            AccountId = account2.Id, 
            StageName = 'Requested', 
            Probability =5, 
            CloseDate = System.today() + 30, 
            Project_Bidopp__c = project.Id
        );
        insert opp1;

        Test.startTest();

        // Test update operation where Project_Start_Date__c is defaulted in the future and StageName is 'Shortlisted'
        opp1.StageName = 'Shortlisted';
        opp1.Probability = 20;
        System.debug('Debug: ' + opp1); // Print the state of the Opportunity record
        update opp1;
                
            // Assert that the Stage__c field of the Project record is updated to 'Shortlisted'
            Project__c updatedProject1 = [SELECT Stage__c, BidStatus__c FROM Project__c WHERE Id = :opp1.Project_Bidopp__c];
            System.debug('Debug: ' + updatedProject1); // Print the state of the Project__c record
            System.assertEquals('Shortlisted', updatedProject1.Stage__c, 'Incorrect Stage__c value');

        // Test update operation where Project_Start_Date__c is prior to today and StageName is 'Contractor Won'
        project.Project_Start_Date__c = System.today() - 10;
        update project;
        opp1.StageName = 'Contractor Won';
        opp1.Probability = 30;
        System.debug('Debug: ' + opp1); // Print the state of the Opportunity record
        update opp1;

            // Assert that the Stage__c field of the Project record is updated to 'In Progress'
            Project__c updatedProject3 = [SELECT Stage__c, BidStatus__c FROM Project__c WHERE Id = :opp1.Project_Bidopp__c];
            System.debug('Debug: ' + updatedProject3); // Print the state of the Project__c record
            System.assertEquals('In Progress', updatedProject3.Stage__c, 'Incorrect Stage__c value');

        // Test update operation where Project_Start_Date__c is prior to today and StageName is 'Bid Won'
        project.Project_Start_Date__c = System.today() - 30;
        update project;
        opp1.StageName = 'Bid Won';
        opp1.Probability = 100;
        System.debug('Debug: ' + opp1); // Print the state of the Opportunity record
        update opp1;

            // Assert that the Stage__c field of the Project record is updated to 'In Progress'
            Project__c updatedProject4 = [SELECT Stage__c, BidStatus__c FROM Project__c WHERE Id = :opp1.Project_Bidopp__c];
            System.debug('Debug: ' + updatedProject4); // Print the state of the Project__c record
            System.assertEquals('In Progress', updatedProject4.Stage__c, 'Incorrect Stage__c value');
            // Add an assertion to check that the BidStatus__c field on the Project record is 'Won'
            System.assertEquals('Won', updatedProject4.BidStatus__c, 'Incorrect BidStatus__c value');

        // Test update operation where Project_Start_Date__c is prior to today and StageName is 'Shortlisted'
        project.Project_Start_Date__c = System.today() - 1;
        update project;
        opp1.StageName = 'Shortlisted';
        opp1.Probability = 20;
        System.debug('Debug: ' + opp1); // Print the state of the Opportunity record
        update opp1;
                
            // Assert that the Stage__c field of the Project record is updated to 'Shortlisted'
            Project__c updatedProject2 = [SELECT Stage__c, BidStatus__c FROM Project__c WHERE Id = :opp1.Project_Bidopp__c];
            System.debug('Debug: ' + updatedProject2); // Print the state of the Project__c record
            System.assertEquals('In Progress', updatedProject2.Stage__c, 'Incorrect Stage__c value');
                
        Test.stopTest();

    /*  // Test update operation where Project_Bidopp__c and StageName fields change
        opp1.Project_Bidopp__c = project.Id;
        opp1.StageName = 'Bid Lost';
        opp1.Probability = 0;
        update opp1;

        // Test update operation where StageName field changes
        opp1.Project_Bidopp__c = project.Id;
        opp1.StageName = 'Bid Won';
        opp1.Probability = 100;
        update opp1;

        // Test update operation where StageName field changes
        opp1.Project_Bidopp__c = project.Id;
        opp1.StageName = 'Bid Lost';
        opp1.Probability = 0;
        update opp1;

        // Test update operation where StageName field changes
        opp1.Project_Bidopp__c = project.Id;
        opp1.StageName = 'Submitted';
        opp1.Probability = 10;
        update opp1;

        // Test update operation where StageName field changes
        opp1.Project_Bidopp__c = project.Id;
        opp1.StageName = 'Contractor Won';
        opp1.Probability = 30;
        update opp1;

        // Test update operation where StageName field changes
        opp1.Project_Bidopp__c = project.Id;
        opp1.StageName = 'Contractor Lost';
        opp1.Probability = 0;
        update opp1; 
*/
    }
}