@isTest
public with sharing class Test_YardReport_Cont {
    @TestSetup
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

        FreightTM__Load__c testLoad1 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testPickupLocation.Id,
            FreightTM__DeliveryFacility__c = testDeliveryLocation.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Quantity__c = 17
        );
        FreightTM__Load__c testLoad2 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testDeliveryLocation.Id,
            FreightTM__DeliveryFacility__c = testPickupLocation.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId(),
            Quantity__c = 10
        );
        FreightTM__Load__c testLoad3 = new FreightTM__Load__c(
            FreightTM__PickupFacility__c = testDeliveryLocation.Id,
            FreightTM__DeliveryFacility__c = testDeliveryLocation.Id,
            RecordTypeId = Schema.SObjectType.FreightTM__Load__c.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId()
        );
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

        Inventory_Report__c report = new Inventory_Report__c(Yard__c = testPickupLocation.Id);
        insert report;

        Inventory_Counts__c beginning1 = new Inventory_Counts__c(
            Inventory_Report__c = report.Id, 
            Type__c = 'Beginning', 
            Commodity_Lookup__c = testProduct1.Id, 
            New__c = 10, 
            A_Four__c = 20, 
            A_Three__c = 30, 
            B_Two__c = 40, 
            B_One__c = 50, 
            Cull__c = 50
        );
        Inventory_Counts__c beginning2 = new Inventory_Counts__c(
            Inventory_Report__c = report.Id, 
            Type__c = 'Beginning', 
            Commodity_Lookup__c = testProduct2.Id, 
            New__c = 10, 
            A_Four__c = 20, 
            A_Three__c = 30, 
            B_Two__c = 40, 
            B_One__c = 50, 
            Cull__c = 50
        );
        Inventory_Counts__c ending1 = new Inventory_Counts__c(
            Inventory_Report__c = report.Id, 
            Type__c = 'Ending', 
            Commodity_Lookup__c = testProduct1.Id, 
            New__c = 10, 
            A_Four__c = 20, 
            A_Three__c = 30, 
            B_Two__c = 40, 
            B_One__c = 50, 
            Cull__c = 50
        );
        insert new List<Inventory_Counts__c>{beginning1, beginning2, ending1};
    }

    @isTest
    public static void testShipperSignature() {
        test.startTest();
        FreightTM__Facility__c yard = [SELECT Id FROM FreightTM__Facility__c WHERE Location_Type__c = 'Yard' LIMIT 1];
        YardReport_Cont.ReportData data = YardReport_Cont.getReportData(yard.Id, Date.today());
        System.assertEquals(0, data.matsShipped.movementRecords.size());
        FreightTM__Load__c load = [SELECT Id, (SELECT Id FROM Items__r) FROM FreightTM__Load__c WHERE FreightTM__PickupFacility__c =: yard.Id LIMIT 1];
        for (Integer i = 0; i < load.Items__r.size(); i++) {
            load.Items__r[i].A_Four__c = 10;
            load.Items__r[i].B_Two__c = 7;
        }
        update load.Items__r;
        load.Shipper_Signature__c = 'ShipperSignature';
        update load;
        YardReport_Cont.ReportData newData = YardReport_Cont.getReportData(yard.Id, Date.today());
        System.assertEquals(1, newData.matsShipped.movementRecords.size());
        test.stopTest();
    }

    @isTest
    public static void testReceiverSignature() {
        test.startTest();
        FreightTM__Facility__c yard = [SELECT Id FROM FreightTM__Facility__c WHERE Location_Type__c = 'Yard' LIMIT 1];
        YardReport_Cont.ReportData data = YardReport_Cont.getReportData(yard.Id, Date.today());
        System.assertEquals(0, data.matsReceived.movementRecords.size());
        FreightTM__Load__c load = [SELECT Id, (SELECT Id FROM Items__r) FROM FreightTM__Load__c WHERE FreightTM__DeliveryFacility__c =: yard.Id LIMIT 1];
        for (Integer i = 0; i < load.Items__r.size(); i++) {
            load.Items__r[i].A_Four__c = 10;
            load.Items__r[i].B_Two__c = 7;
        }
        update load.Items__r;
        load.Receiver_Signature__c = 'ReceiverSignature';
        update load;
        YardReport_Cont.ReportData newData = YardReport_Cont.getReportData(yard.Id, Date.today());
        System.assertEquals(1, newData.matsReceived.movementRecords.size());
        test.stopTest();
    }

    @isTest
    public static void testReportUpdates() {
        test.startTest();
        Inventory_Report__c rep = [SELECT Id, Yard__r.Id FROM Inventory_Report__c LIMIT 1];
        List<Item__c> itemsToUpdate = new List<Item__c>();
        Item__c itemToRemove = new Item__c();
        FreightTM__Load__c loadToUpdate = new FreightTM__Load__c();
        for (Item__c item : [SELECT Id, Load__c FROM Item__c WHERE Load__r.FreightTM__PickupFacility__c =: rep.Yard__r.Id]) {
            item.New__c = 18;
            item.A_Four__c = 0;
            item.A_Three__c = 0;
            item.B_Two__c = 0;
            item.B_One__c = 0;
            item.Cull__c = 0;
            itemsToUpdate.add(item);
            loadToUpdate.Id = item.Load__c;
            itemToRemove = item;
        }
        
        List<Inventory_Counts__c> countsToUpdate = new List<Inventory_Counts__c>();
        for (Inventory_Counts__c count : [SELECT Id FROM Inventory_Counts__c WHERE Inventory_Report__c =: rep.Id AND Type__c = 'Ending']) {
            count.Comments__c = 'Test Comments';
            countsToUpdate.add(count);
        }
		YardReport_Cont.updateLoad(loadToUpdate);
        YardReport_Cont.updateItems(itemsToUpdate);
        YardReport_Cont.removeReportReference(itemToRemove);
        YardReport_Cont.updateCounts(countsToUpdate);
        YardReport_Cont.ReportData reportData = YardReport_Cont.getReportData(String.valueOf(rep.Yard__r.Id), Date.today());
        reportData.report.Employee_Signature__c = 'EmployeeSignature';
        YardReport_Cont.saveReport(reportData);
        reportData = YardReport_Cont.getReportData(String.valueOf(rep.Yard__r.Id), Date.today());
        System.assertEquals('EmployeeSignature', reportData.report.Employee_Signature__c);
        test.stopTest();
    }
    
	@isTest
    public static void testReportAdjustments() {
        test.startTest();
        Inventory_Report__c rep = [SELECT Id, Yard__r.Id FROM Inventory_Report__c LIMIT 1];
        Product2 testProduct = [SELECT Id FROM Product2 WHERE SellType__c = 'Purchase' LIMIT 1];
		Inventory_Counts__c adjustment = new Inventory_Counts__c(Inventory_Report__c = rep.Id, Type__c = 'Adjustment', Commodity_Lookup__c = testProduct.Id, New__c = 20, A_Four__c = 30, Cull__c = -20);
        insert adjustment;
        YardReport_Cont.ReportData reportData = YardReport_Cont.getReportData(String.valueOf(rep.Yard__r.Id), Date.today());
	    test.stopTest();
    }

    @isTest
    public static void testTotalRecalculation() {
        test.startTest();
        Inventory_Report__c rep = [SELECT Id, Yard__r.Id FROM Inventory_Report__c LIMIT 1];
        List<Item__c> itemsToUpdate = new List<Item__c>();
        for (Item__c item : [SELECT Id, Load__r.FreightTM__PickupFacility__c, Load__r.FreightTM__DeliveryFacility__c FROM Item__c]) {
            List<Integer> randomNums = new List<Integer>();
            randomNums.add(0);
            for (Integer i = 0; i < 5; i++) {
                Integer randomNum = Integer.valueOf(Math.random() * 20);
                randomNums.add(randomNum);
            }
            randomNums.add(20);
            List<Integer> randomGrades = new List<Integer>();
            randomNums.sort();
            for (Integer i = 0; i < (randomNums.size() - 1); i++) {
                Integer randomGrade = randomNums[i + 1] - randomNums[i];
                randomGrades.add(randomGrade);
            }

            item.New__c = randomGrades[0];
            item.A_Four__c = randomGrades[1];
            item.A_Three__c = randomGrades[2];
            item.B_Two__c = randomGrades[3];
            item.B_One__c = randomGrades[4];
            item.Cull__C = randomGrades[5];
            itemsToUpdate.add(item);
        }

        update itemsToUpdate;

        YardReport_Cont.recalculateTotals(String.valueOf(rep.Id));
        test.stopTest();
    }

}