/**
 * @description       : 
 * @author            : Derek Hoffritz
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : Derek Hoffritz
**/
trigger ProjectStageUpdatesFromOpps on Opportunity (before insert, before update, after insert, after update) {
    Set<Id> projectIds = new Set<Id>();
    Map<Id, Decimal> projectOpportunitiesProbability = new Map<Id, Decimal>();
    List<Opportunity> projectOpportunities;

    if (Trigger.isInsert) {
        for (Opportunity opp : Trigger.new) {
            if (opp.Project_Bidopp__c != null) {
                projectIds.add(opp.Project_Bidopp__c);
            }
        }
    }

    if (Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
            if (opp.Project_Bidopp__c != oldOpp.Project_Bidopp__c || opp.StageName != oldOpp.StageName) {
                projectIds.add(opp.Project_Bidopp__c);
            }
        }
    }

    if (!projectIds.isEmpty()) {
        projectOpportunities = [SELECT Id, Probability, StageName, Project_Bidopp__c FROM Opportunity WHERE Project_Bidopp__c IN :projectIds];
        for (Project__c project : [SELECT Id, Stage__c FROM Project__c WHERE Id IN :projectIds]) {
            Decimal maxProbability = 0;
            for (Opportunity opp : projectOpportunities) {
                if (opp.Project_Bidopp__c == project.Id) {
                    maxProbability = Math.max(maxProbability, opp.Probability);
                }
            }
            project.Probability__c = maxProbability;
            projectOpportunitiesProbability.put(project.Id, maxProbability);
        }

            for (Opportunity opp : Trigger.new) {
                List<Project__c> projectQuery = [SELECT Id, Stage__c, Probability__c, Project_Start_Date__c, Project_End_Date__c, BidStatus__c FROM Project__c WHERE Id = :opp.Project_Bidopp__c LIMIT 1];
                if(!projectQuery.isEmpty()) {
                    Project__c project = projectQuery[0];
                    Decimal maxProbability = projectOpportunitiesProbability.get(opp.Project_Bidopp__c);
                    Boolean budgetaryOpportunityExists = false;
                    Boolean bidLostExists = false;
                    Boolean bidWonExists = false;
                    for (Opportunity opportunity : projectOpportunities) {
                        if (opp.Project_Bidopp__c == opportunity.Project_Bidopp__c) {
                            if (opportunity.StageName == 'Budgetary Estimate') {
                                budgetaryOpportunityExists = true;
                            }
                            if (opportunity.StageName == 'Bid Lost') {
                                bidLostExists = true;
                            }
                            if (opportunity.StageName == 'Bid Won') {
                                bidWonExists = true;
                        }
                    }
                    
                    try {
                        if (!projectOpportunities.isEmpty()) {
                            if (maxProbability >= 5 && maxProbability <= 15) {
                                project.Stage__c = 'Out for Bid';
                            } else if (maxProbability == 20) {
                                if (project.Project_Start_Date__c < System.today()) {
                                    project.Stage__c = 'In Progress';
                                } else {
                                    project.Stage__c = 'Shortlisted';
                                }
                            } else if (maxProbability >= 30 && maxProbability <= 100) {
                                if (project.Project_Start_Date__c < System.today()) {
                                    project.Stage__c = 'In Progress';
                                } else {
                                    project.Stage__c = 'Contract Awarded';
                                }
                            } else if (maxProbability == 0) {
                                if (project.Project_Start_Date__c < System.today()) {
                                    project.Stage__c = 'In Progress';
                                } else if (budgetaryOpportunityExists) {
                                    project.Stage__c = 'Budgetary';
                                }
                            }    
                        }
                    

                        if (bidLostExists == true) {
                            project.BidStatus__c = 'Lost';
                        } else if (bidWonExists == true) {
                            project.BidStatus__c = 'Won';
                        } else {
                            project.BidStatus__c = null;
                        }

                        update project;
                    } catch (DmlException e) {
                        System.debug('A DML error has occurred: ' + e.getMessage());
                    }
                }
            }
        }
    }
}