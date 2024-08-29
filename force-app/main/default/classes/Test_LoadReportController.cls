/**
 * @description       : 
 * @author            : Ethan Myers
 * @group             : 
 * @last modified on  : 02-21-2023
 * @last modified by  : Ethan Myers
**/
@isTest
public class Test_LoadReportController {
    @TestSetup
     static void makeData(){
        Account testAccount = new Account(
            Name = 'Test Account',
            AccountPriority__c = 'Standard'
        );
        insert testAccount;

        FreightTM__Trip__c testJob = new FreightTM__Trip__c(
            Status__c = 'Active',
            City__c = 'Hattiesburg',
            State__c = 'MS',
            Customer__c = testAccount.Id,
            Start_Date__c = Date.newInstance(2022, 1, 1),
            Freight_In_Amount__c = 100,
            Freight_Out_Amount__c = 100,
            Job__c = '23001'
        );
        insert testJob;

        //prep order
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        Product2 testProduct1 = new Product2(
            Name = '8x4x18',
            Family = 'Mat Sales',
            Product_Type__c = 'Digging Mat',
            SellType__c = 'Lease'
        );
        insert testProduct1;

        Product2 testProduct2 = new Product2(
            Name = '8x4x16',
            Family = 'Mat Sales',
            Product_Type__c = 'Laminated Mat',
            SellType__c = 'Purchase'
        );
        insert testProduct2;

        Product2 testProduct3 = new Product2(
            Name = '8x4x20',
            Family = 'Mat Sales',
            Product_Type__c = 'Digging Mat',
            SellType__c = 'Purchase'
        );
        insert testProduct3;

        WorkOrder testOrder = new WorkOrder(
            Job__c = testJob.Id,
            Pricebook2Id = standardPricebook.Id,
            City = 'Hattiesburg',
            Street = '140 Mayfair Rd',
            State = 'Mississippi',
            PostalCode = '39402',
            Country = 'United States'
        );
        insert testOrder;

        PriceBookEntry testEntry1 = new PricebookEntry(
            PriceBook2Id = testOrder.Pricebook2Id,
            Product2Id = testProduct1.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testEntry1;

        PriceBookEntry testEntry2 = new PriceBookEntry(
            PriceBook2Id = testOrder.Pricebook2Id,
            Product2Id = testProduct2.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testEntry2;

        PriceBookEntry testEntry3 = new PriceBookEntry(
            PriceBook2Id = testOrder.Pricebook2Id,
            Product2Id = testProduct3.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testEntry3;

        WorkOrderLineItem testItem1 = new WorkOrderLineItem(
            WorkOrderId = testOrder.Id,
            Product__c = testProduct1.Id,
            PricebookEntryId = testEntry1.Id,
            Quantity = 400,
            MatGrade__c = 'A',
            Product_Family__c = 'Mat Sales',
            ProductType__c = 'Digging Mat',
            Sell_Type__c = 'Lease',
            UnitPrice = 100,
            FreightCostType__c = 'Cost + 10%',
            FreightIn__c = 0,
            FreightOut__c = 0 
        );
        insert testItem1;

        WorkOrderLineItem testItem2 = new WorkOrderLineItem(
            WorkOrderId = testOrder.Id,
            Product__c = testProduct2.Id,
            PricebookEntryId = testEntry2.Id,
            Quantity = 250,
            MatGrade__c = 'A',
            Product_Family__c = 'Mat Sales',
            ProductType__c = 'Laminated Mat',
            Sell_Type__c = 'Purchase',
            UnitPrice = 100,
            FreightCostType__c = 'Flat Fee per Load',
            FreightIn__c = 100,
            FreightOut__c = 100 
        );
        insert testItem2;

        WorkOrderLineItem testItem3 = new WorkOrderLineItem(
            WorkOrderId = testOrder.Id,
            Product__c = testProduct3.Id,
            PricebookEntryId = testEntry3.Id,
            Quantity = 1000,
            MatGrade__c = 'B',
            Product_Family__c = 'Mat Sales',
            ProductType__c = 'Digging Mat',
            Sell_Type__c = 'Purchase',
            UnitPrice = 100,
            FreightCostType__c = 'Flat Fee Per Mat',
            FreightIn__c = 100,
            FreightOut__c = 100 
        );
        insert testItem3;

        //prep load
        FreightTM__Facility__c testPickupLocation = new FreightTM__Facility__c(
            Name = 'Test Pickup Facility',
            Location_Type__c = 'Yard'
        );
        insert testPickupLocation;

        FreightTM__Facility__c testDeliveryLocation = new FreightTM__Facility__c(
            Name = 'Test Delivery Facility',
            Location_Type__c = 'Job',
            Job__c = testJob.Id
        );
        insert testDeliveryLocation;

        Date pastFriday = Date.today().toStartOfWeek().addDays(-7);
        List<FreightTM__Load__c> loadsToInsert = new List<FreightTM__Load__c>();
        FreightTM__Load__c testLoad1 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testPickupLocation.Id,
            FreightTM__DeliveryFacility__c = testDeliveryLocation.Id,
            Sales_Order_Line_Item__c = testItem1.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Receiver_Date__c = pastFriday,
            Load_Template__c = true
        );
        loadsToInsert.add(testLoad1);

        FreightTM__Load__c testLoad2 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testDeliveryLocation.Id,
            FreightTM__DeliveryFacility__c = testPickupLocation.Id,
            Sales_Order_Line_Item__c = testItem1.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Receiver_Date__c = pastFriday,
            Load_Template__c = false,
            FreightTM__Rate_to_Carrier__c = 500
        );
        loadsToInsert.add(testLoad2);

        FreightTM__Load__c testLoad3 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testDeliveryLocation.Id,
            FreightTM__DeliveryFacility__c = testDeliveryLocation.Id,
            Sales_Order_Line_Item__c = testItem1.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Receiver_Date__c = pastFriday,
            Load_Template__c = false,
            FreightTM__Rate_to_Carrier__c = 0
        );
        loadsToInsert.add(testLoad3);

        insert loadsToInsert;

        List<Item__c> itemsToInsert = new List<Item__c>();
        Item__c loadItem1 = new Item__c(
            Load__c = testLoad1.Id,
            Delivery_Order__c = testOrder.Id,
            Delivery_Item__c = testItem1.Id,
            Quantity__c = 18,
            Grade__c = 'A'
        );
        itemsToInsert.add(loadItem1);

        Item__c loadItem2 = new Item__c(
            Load__c = testLoad2.Id,
            Pickup_Order__c = testOrder.Id,
            Pickup_Item__c = testItem1.Id,
            Quantity__c = 18,
            Grade__c = 'New',
            Inventory_Reviewed__c = false,
            PM_Approved__c = false
        );
        itemsToInsert.add(loadItem2);

        Item__c loadItem3 = new Item__c(
            Load__c = testLoad3.Id,
            Product__c = testProduct1.Id,
            Quantity__c = 17,
            Grade__c = 'B',
            Inventory_Reviewed__c = false,
            PM_Approved__c = false
        );
        //itemsToInsert.add(loadItem3);

        Item__c loadItem4 = new Item__c(
            Load__c = testLoad3.Id,
            Pickup_Order__c = testOrder.Id,
            Pickup_Item__c = testItem1.Id,
            Quantity__c = 17,
            Grade__c = 'A',
            Inventory_Reviewed__c = true,
            PM_Approved__c = false
        );
        itemsToInsert.add(loadItem4);

        insert itemsToInsert;
    }

    @isTest
    private static void testProcessingCount() {
        test.startTest();
        LoadProcessingController.LoadAnalysis analysis = LoadProcessingController.analyzeLoads();
        test.stopTest();
    }

    @isTest 
    private static void testLoadProcessingReport() {
        FreightTM__Trip__c job = [SELECT Id, Name, Job__c FROM FreightTM__Trip__c LIMIT 1];
        WorkOrder order = [SELECT Id, Purchase_Order_Number__c FROM WorkOrder LIMIT 1];
        test.startTest();
//Inventory_Reviewed__c = false
        LoadReportController.FilterWrapper filters = new LoadReportController.FilterWrapper();
        filters.declaredFilter = 'Inventory_Reviewed__c = false';
        LoadReportController.ItemForTable item = new LoadReportController.ItemForTable();
        LoadReportController.FilterWrapper filters2 = new LoadReportController.FIlterWrapper('Inventory_Reviewed__c = true AND PM_Approved__c = false', null, null, null, null, null, null,null, null, null, null);
        LoadReportController.fetchLoads(filters);
        LoadReportController.fetchLoads(filters2);
        test.stopTest();
    }
    
    @isTest
    private static void testJobLoadReport() {
        FreightTM__Trip__c job = [SELECT Id, Name FROM FreightTM__Trip__c LIMIT 1];
        test.startTest();
        JobLoadReportController.FilterWrapper filters = new JobLoadReportController.FilterWrapper(String.valueOf(job.Id), true, false, null, null, null);
        JobLoadReportController.fetchLoads(filters);
        JobLoadReportController.FilterWrapper filters2 = new JobLoadReportController.FilterWrapper();
        filters2.jobId = String.valueOf(job.Id);
        filters2.showDeliveries = true;
        filters2.showPickups = false;
        filters2.startDate = Date.today().toStartOfWeek().addDays(-14);
        filters2.endDate = Date.today().toStartOfWeek().addDays(-5);
        JobLoadReportController.fetchLoads(filters2);
        JobLoadReportController.fetchTemplates(String.valueOf(job.Id));
        test.stopTest();
    }
}