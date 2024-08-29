/**
 * @description       : 
 * @author            : Ethan Myers
 * @group             : 
 * @last modified on  : 02-22-2023
 * @last modified by  : Ethan Myers
**/
public with sharing class LoadProcessingController {
    public LoadProcessingController() {

    }

    public with sharing class LoadAnalysis {
        @AuraEnabled
        public Integer inventoryCount {get; set;}
        @AuraEnabled
        public Integer pmCount {get; set;}
        @AuraEnabled
        public Integer qbCount {get; set;}
        @AuraEnabled
        public Integer invoicingCount {get; set;}
        @AuraEnabled
        public Integer rejectedCount {get; set;}

        public LoadAnalysis() {
            Date pastSaturday = Date.today().toStartOfWeek().addDays(-1);
            System.debug('Calculating following date as last saturday: ' + String.valueOf(pastSaturday));
            try {
                this.inventoryCount = [SELECT COUNT() FROM Item__c WHERE Load__r.RecordType.Name != 'Equipment' AND Load__r.FreightTM__Status__c = 'Delivered' AND Load__r.Load_Template__c = false AND Inventory_Reviewed__c = false AND Rejected__c = false];
                this.pmCount = [SELECT COUNT() FROM Item__c WHERE Load__r.RecordType.Name != 'Equipment' AND Inventory_Reviewed__c = true AND PM_Approved__c = false AND Rejected__c = false];
                this.qbCount = [SELECT COUNT() FROM Item__c WHERE Load__r.RecordType.Name != 'Equipment' AND PM_Approved__c = true AND Moved_in_QB__c = false AND Rejected__c = false];
                this.invoicingCount = [SELECT COUNT() FROM Item__c WHERE Load__r.RecordType.Name != 'Equipment' AND Moved_in_QB__c = true AND (Mat_Invoice__c = null OR Mat_Invoice__c = '') AND Rejected__c = false];
                this.rejectedCount = [SELECT COUNT() FROM Item__c WHERE Load__r.RecordType.Name != 'Equipment' AND Rejected__c = true];
            } catch (QueryException e) {
                throw new AuraHandledException('Error initializing load analysis...' + e.getMessage());
            }
        }
    }

    @AuraEnabled (cacheable = true)
    public static LoadAnalysis analyzeLoads() {
        LoadAnalysis analysis = new LoadAnalysis();
        return analysis;
    }
}