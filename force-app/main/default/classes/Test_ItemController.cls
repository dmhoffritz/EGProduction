/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Test_ItemController {

    @testSetup 
    static void makeData() {
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
        Product2 testProduct2 = new Product2(
            Name = '8x4x16',
            Family = 'Mat Sales',
            Product_Type__c = 'Laminated Mat',
            SellType__c = 'Purchase'
        );
        Product2 testProduct3 = new Product2(
            Name = '8x4x20',
            Family = 'Mat Sales',
            Product_Type__c = 'Digging Mat',
            SellType__c = 'Purchase'
        );
        insert new List<Product2> {testProduct1, testProduct2, testProduct3};

        PriceBookEntry testEntry1 = new PricebookEntry(
            PriceBook2Id = standardPricebook.Id,
            Product2Id = testProduct1.Id,
            UnitPrice = 100,
            IsActive = true
        );
        PriceBookEntry testEntry2 = new PriceBookEntry(
            PriceBook2Id = standardPricebook.Id,
            Product2Id = testProduct2.Id,
            UnitPrice = 100,
            IsActive = true
        );
        PriceBookEntry testEntry3 = new PriceBookEntry(
            PriceBook2Id = standardPricebook.Id,
            Product2Id = testProduct3.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert new List<PricebookEntry>{testEntry1, testEntry2, testEntry3};

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
        insert new List<WorkOrderLineItem>{testItem1, testItem2, testItem3};

        //prep load
        FreightTM__Facility__c testPickupLocation = new FreightTM__Facility__c(
            Name = 'Test Pickup Facility',
            Location_Type__c = 'Yard'
        );
        FreightTM__Facility__c testDeliveryLocation = new FreightTM__Facility__c(
            Name = 'Test Delivery Facility',
            Location_Type__c = 'Job',
            Job__c = testJob.Id
        );
        insert new List<FreightTM__Facility__c>{testPickupLocation, testDeliveryLocation};

            //Yard -> Job Movement
        FreightTM__Load__c testLoad1 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testPickupLocation.Id,
            FreightTM__DeliveryFacility__c = testDeliveryLocation.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Quantity__c = 17
        );
        //Job -> Yard Movement
        FreightTM__Load__c testLoad2 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testDeliveryLocation.Id,
            FreightTM__DeliveryFacility__c = testPickupLocation.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Quantity__c = 10
        );
        
        //Job -> Job Movement
        FreightTM__Load__c testLoad3 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testDeliveryLocation.Id,
            FreightTM__DeliveryFacility__c = testDeliveryLocation.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId()
        );
        
        //Yard -> Yard Movement
        FreightTM__Load__c testLoad4 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testPickupLocation.Id,
            FreightTM__DeliveryFacility__c = testPickupLocation.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId()
        );
        insert new List<FreightTM__Load__c>{testLoad1, testLoad2, testLoad3, testLoad4};

        Item__c testLoadItem1 = new Item__c(
            Quantity__c = 17,
            Grade__c = 'A',
            Pickup_Order__c = null,
            Pickup_Item__c = null,
            Delivery_Order__c = testOrder.Id,
            Delivery_Item__c = testItem1.Id,
            Load__c = testLoad1.Id
        );
        Item__c testLoadItem2 = new Item__c(
            Quantity__c = 17,
            Grade__c = 'A',
            Pickup_Order__c = null,
            Pickup_Item__c = null,
            Delivery_Order__c = testOrder.Id,
            Delivery_Item__c = testItem2.Id,
            Load__c = testLoad2.Id
        );
        Item__c testLoadItem3 = new Item__c(
            Quantity__c = 17,
            Grade__c = 'A',
            Pickup_Order__c = null,
            Pickup_Item__c = null,
            Delivery_Order__c = testOrder.Id,
            Delivery_Item__c = testItem3.Id,
            Load__c = testLoad3.Id
        );
       Item__c testLoadItem4 = new Item__c(
            Quantity__c = 17,
            Grade__c = 'A',
            Pickup_Order__c = null,
            Pickup_Item__c = null,
            Delivery_Order__c = testOrder.Id,
            Delivery_Item__c = testItem3.Id,
            Load__c = testLoad4.Id
        );
       Item__c testLoadItem5 = new Item__c(
            Quantity__c = 17,
            Grade__c = 'A',
            Pickup_Order__c = null,
            Pickup_Item__c = null,
            Delivery_Order__c = testOrder.Id,
            Delivery_Item__c = testItem1.Id,
            Load__c = testLoad4.Id
        );
       Item__c testLoadItem6 = new Item__c(
            Quantity__c = 17,
            Grade__c = 'A',
            Pickup_Order__c = null,
            Pickup_Item__c = null,
            Delivery_Order__c = testOrder.Id,
            Delivery_Item__c = testItem2.Id,
            Load__c = testLoad4.Id
        );
       Item__c testLoadItem7 = new Item__c(
            Quantity__c = 17,
            Grade__c = 'A',
            Pickup_Order__c = null,
            Pickup_Item__c = null,
            Delivery_Order__c = testOrder.Id,
            Delivery_Item__c = testItem3.Id,
            Load__c = testLoad4.Id
        );
        insert new List<Item__c>{testLoadItem1, testLoadItem2, testLoadItem3, testLoadItem4, testLoadItem5, testLoadItem6, testLoadItem7};
    }


    @isTest
    private static void testYardToJob() {
        test.startTest();
        FreightTM__Load__c load = [SELECT Id
                                            FROM FreightTM__Load__c 
                                            WHERE FreightTM__PickupFacility__r.Location_Type__c = 'Yard'
                                           		AND FreightTM__DeliveryFacility__r.Location_Type__c = 'Job'];
        ItemController.LoadItemData returnList = ItemController.getItems(string.valueOf(load.Id));
        test.stopTest();
    }
    
    @isTest
    private static void testJobToYard() {
        test.startTest();
        FreightTM__Load__c load = [SELECT Id
                                            FROM FreightTM__Load__c 
                                            WHERE FreightTM__PickupFacility__r.Location_Type__c = 'Job'
                                           		AND FreightTM__DeliveryFacility__r.Location_Type__c = 'Yard'];
        ItemController.LoadItemData returnList = ItemController.getItems(string.valueOf(load.Id));
        test.stopTest();
    }
    
    @isTest
    private static void testJobToJob() {
        test.startTest();
        FreightTM__Load__c load = [SELECT Id
                                            FROM FreightTM__Load__c 
                                            WHERE FreightTM__PickupFacility__r.Location_Type__c = 'Job'
                                           		AND FreightTM__DeliveryFacility__r.Location_Type__c = 'Job'];
        ItemController.LoadItemData returnList = ItemController.getItems(string.valueOf(load.Id));
        test.stopTest();
    }
    
    @isTest
    private static void testYardToYard() {
        test.startTest();
        FreightTM__Load__c load = [SELECT Id
                                            FROM FreightTM__Load__c 
                                            WHERE FreightTM__PickupFacility__r.Location_Type__c = 'Yard'
                                           		AND FreightTM__DeliveryFacility__r.Location_Type__c = 'Yard'];
        ItemController.LoadItemData returnList = ItemController.getItems(string.valueOf(load.Id));
        
        ItemController.ItemOptionWrapper itemOpt = new ItemController.ItemOptionWrapper();
        ItemController.OptionWrapper opt = new ItemController.OptionWrapper();
        test.stopTest();
    }
    @isTest
    private static void testItemUpdate() {
        test.startTest();
        Item__c testItem = [SELECT Id FROM Item__c LIMIT 1];
        ItemController.updateItem(testItem);
        test.stopTest();
    }
    
    @isTest
    private static void testItemDeletion() {
        test.startTest();
        Item__c testItem = [SELECT Id FROM Item__c LIMIT 1];
        ItemController.deleteItem(testItem);
        test.stopTest();
    }
    
    /*
    @isTest
    private static void testLocationUpdate() {
        test.startTest();
        FreightTM__Load__c yardToYard = [SELECT Id
                                            FROM FreightTM__Load__c 
                                            WHERE FreightTM__PickupFacility__r.Location_Type__c = 'Yard'
                                           		AND FreightTM__DeliveryFacility__r.Location_Type__c = 'Yard'];
        FreightTM__Load__c jobToYard = [SELECT Id
                                            FROM FreightTM__Load__c 
                                            WHERE FreightTM__PickupFacility__r.Location_Type__c = 'Job'
                                           		AND FreightTM__DeliveryFacility__r.Location_Type__c = 'Yard'];
        FreightTM__Load__c yardToJob = [SELECT Id
                                            FROM FreightTM__Load__c 
                                            WHERE FreightTM__PickupFacility__r.Location_Type__c = 'Yard'
                                           		AND FreightTM__DeliveryFacility__r.Location_Type__c = 'Job'];
        FreightTM__Load__c jobToJob = [SELECT Id
                                            FROM FreightTM__Load__c 
                                            WHERE FreightTM__PickupFacility__r.Location_Type__c = 'Job'
                                           		AND FreightTM__DeliveryFacility__r.Location_Type__c = 'Job'];
        FreightTM__Facility__c jobLocation = [SELECT Id, Job__c FROM FreightTM__Facility__c WHERE Location_Type__c = 'Job' LIMIT 1];
        FreightTM__Facility__c yardLocation = [SELECT Id, Job__c FROM FreightTM__Facility__c WHERE Location_Type__c = 'Yard' LIMIT 1];
        yardToYard.FreightTM__DeliveryFacility__c = jobLocation.Id; //updated to yard to job
        jobToYard.FreightTM__PickupFacility__c = yardLocation.Id; //updated to yard to yard
        yardToJob.FreightTM__PickupFacility__c = jobLocation.Id; //updated to job to job
        jobToJob.FreightTM__DeliveryFacility__c = yardLocation.Id; //updated to job to yard
        update new List<FreightTM__Load__c>{yardToYard, jobToYard, yardToJob, jobToJob};
        test.stopTest();
    }
*/

}