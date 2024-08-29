public with sharing class ZMapInventory {
    
    @AuraEnabled(cacheable=true)
    public static List<Inventory_Location__c> getInventory() {
        List<Inventory_Location__c> inv = [Select Id, 
                                                Name, 
                                                Inventory_Location_Type__c, 
                                                Geolocation__latitude__s, 
                                                Geolocation__longitude__s, 
                                                New_Total_Quantity__c, 
                                                Weighted_Avg_Cost_New__c 
                                            from Inventory_Location__c];
        return inv;
    }

}