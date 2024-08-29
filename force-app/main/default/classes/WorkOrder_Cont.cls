/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : Ethan Myers
**/
public without sharing class WorkOrder_Cont {

    @AuraEnabled
    public static List<WorkOrder> getOrders(String recordId){
        String objectName = '';
        List<WorkOrder> orders = new List<WorkOrder>();
        
        try {
            orders = [SELECT Id, WorkOrderNumber, Status, TotalPrice,
                      Job__r.Id, Job__r.Name, Purchase_Order_Number__c,Record_Link__c,
                      (SELECT Id, LineItemNumber, WorkOrder.WorkOrderNumber,
                       WorkOrder.Job__c, WorkOrderId, 
                       Quantity, Status, Commodity__c,
                       Product_Description__c, Sell_Type__c, Product_Family__c, ProductType__c,
                       Product__c, Product__r.Name, Product__r.Family, Product__r.Product_Type__c,
                       Product__r.SellType__c, MatGrade__c,
                       Attrition__c, FreightCostType__c,
                       UnitPrice, FreightIn__c, FreightOut__c,
                       FreightInQtyBooked__c, Qty_Filled__c, FreightInQtyInRoute__c, FreightInQtyOrdered__c, FreightIn_QuantityLefttoBook__c, FreightIn_TotalRateToCarrier__c,
                       FreightOutQtyBooked__c, FreightOutQtyDelivered__c, FreightOutQtyInRoute__c, FreightOutQtyOrdered__c, FreightOutQuantityLefttoBook__c, FreightOut_TotalRateToCarrier__c,
                       FulfilledDeliveries__c, CompletePickups__c, CompleteDeliveries__c
                       FROM WorkOrderLineItems
                       ORDER BY Status)
                      FROM WorkOrder
                      WHERE Job__r.Id =: recordId
                      ORDER BY CreatedDate];
            
            return orders;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static WorkOrder getOrder(String orderId){
        String objectName = '';
        WorkOrder order = new WorkOrder();
        
        try {
            order = [SELECT Id, WorkOrderNumber, Status, TotalPrice,
                      Job__r.Id, Job__r.Name, Purchase_Order_Number__c,Record_Link__c,
                      (SELECT Id, LineItemNumber, WorkOrder.WorkOrderNumber,
                       WorkOrder.Job__c, WorkOrderId, 
                       Quantity, Status, Commodity__c,
                       Product_Description__c, Sell_Type__c, Product_Family__c, ProductType__c,
                       Product__c, Product__r.Name, Product__r.Family, Product__r.Product_Type__c,
                       Product__r.SellType__c, MatGrade__c,
                       Attrition__c, FreightCostType__c,
                       UnitPrice, FreightIn__c, FreightOut__c,
                       FreightInQtyBooked__c, Qty_Filled__c, FreightInQtyInRoute__c, FreightInQtyOrdered__c, FreightIn_QuantityLefttoBook__c, FreightIn_TotalRateToCarrier__c,
                       FreightOutQtyBooked__c, FreightOutQtyDelivered__c, FreightOutQtyInRoute__c, FreightOutQtyOrdered__c, FreightOutQuantityLefttoBook__c, FreightOut_TotalRateToCarrier__c,
                       FulfilledDeliveries__c, CompletePickups__c, CompleteDeliveries__c
                       FROM WorkOrderLineItems
                       ORDER BY Status)
                      FROM WorkOrder
                      WHERE Id =: orderId];
            
            return order;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static void updateOrderStatus(String orderId, String orderStatus){
        try {
            WorkOrder order = [SELECT Id, Status
                                FROM WorkOrder
                                WHERE Id =: orderId];
            order.Status = orderStatus;
            update order;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}