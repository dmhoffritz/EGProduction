@isTest
public class Test_WorkOrder_Cont {
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
            Freight_Out_Amount__c = 100
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
            SellType__c = 'Purchase'
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
            Sell_Type__c = 'Purchase',
            UnitPrice = 100,
            FreightCostType__c = 'Cost + 10%',
            FreightIn__c = 100,
            FreightOut__c = 100 
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

        FreightTM__Load__c testLoad1 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testPickupLocation.Id,
            FreightTM__DeliveryFacility__c = testDeliveryLocation.Id,
            Sales_Order_Line_Item__c = testItem1.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Quantity__c = 18,
            Mat_Grade__c = 'A'
        );
        insert testLoad1;

        FreightTM__Load__c testLoad2 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testDeliveryLocation.Id,
            FreightTM__DeliveryFacility__c = testPickupLocation.Id,
            Sales_Order_Line_Item__c = testItem1.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Quantity__c = 17,
            Mat_Grade__c = 'A'
        );
        insert testLoad2;

        FreightTM__Load__c testLoad3 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testDeliveryLocation.Id,
            FreightTM__DeliveryFacility__c = testDeliveryLocation.Id,
            Sales_Order_Line_Item__c = testItem1.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Quantity__c = 16,
            Mat_Grade__c = 'A'
        );
        insert testLoad3;
    }

    @isTest
    private static void testGetOrders() {
        //pass jobId to aura enabled getOrders fcn
        //fcn returns list of WorkOrders
        test.startTest();
        FreightTM__Trip__c job = [SELECT Id
                                    FROM FreightTM__Trip__c];
        List<WorkOrder> returnList = WorkOrder_Cont.getOrders(string.valueOf(job.Id));
        System.assertEquals(true, returnList.size() > 0);
        WorkOrder order = WorkOrder_Cont.getOrder(String.valueOf(returnList[0].Id));
        System.assertEquals(returnList[0], order);
        test.stopTest();
    }

    @isTest
    private static void testOrderStatusUpdate() {
        test.startTest();
        FreightTM__Trip__c job = [SELECT Id
                                    FROM FreightTM__Trip__c];
        WorkOrder order = [SELECT Id
                            FROM WorkOrder
                            WHERE Job__c =: job.Id];
        WorkOrder_Cont.updateOrderStatus(string.valueOf(order.Id), 'In Progress');
        test.stopTest();
    }
}