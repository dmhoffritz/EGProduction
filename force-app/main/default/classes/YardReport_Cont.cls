public with sharing class YardReport_Cont {

    public with sharing class MovementBucket {
        @AuraEnabled
        public String jobIdentifier {get; set;}
        @AuraEnabled
        public List<Item__c> items {get; set;}

        public MovementBucket() {
            this.jobIdentifier = '';
            this.items = new List<Item__c>();
        }

        public MovementBucket(String jobIdentifier, List<Item__c> items) {
            this.jobIdentifier = jobIdentifier;
            this.items = items;
        }
    }

    public with sharing class MovementSummary {
        @AuraEnabled
        public Integer qtyCount {get; set;}
        @AuraEnabled
        public Integer ungradedCount {get; set;}
        @AuraEnabled
        public Integer loadCount {get; set;}

        public MovementSummary() {
            this.qtyCount = 0;
            this.ungradedCount = 0;
            this.loadCount = 0;
        }
    }

    public with sharing class Movement {
        @AuraEnabled
        public List<MovementBucket> movementRecords {get; set;}
        @AuraEnabled
        public MovementSummary movementSummary {get; set;}

        public Movement() {
            this.movementRecords = new List<MovementBucket>();
            this.movementSummary = new MovementSummary();
        }
    }

    public with sharing class ReportData {
        @AuraEnabled
        public Inventory_Report__c report {get; set;}
        @AuraEnabled
        public Movement matsUngraded {get; set;}
        @AuraEnabled
        public Movement matsReceived {get; set;}
        @AuraEnabled
        public Movement matsShipped {get; set;}
        @AuraEnabled
        public Movement matsGradedToday {get; set;}
        @AuraEnabled
        public List<Inventory_Counts__c> adjustments {get; set;}
        @AuraEnabled
        public List<Inventory_Counts__c> beginningInventory {get; set;}
        @AuraEnabled
        public List<Inventory_Counts__c> endingInventory {get; set;}

        public ReportData() {
            this.report = new Inventory_Report__c();
            this.matsUngraded = new Movement();
            this.matsReceived = new Movement();
            this.matsShipped = new Movement();
            this.matsGradedToday = new Movement();
            this.adjustments = new List<Inventory_Counts__c>();
            this.beginningInventory = new List<Inventory_Counts__c>();
            this.endingInventory = new List<Inventory_Counts__c>();
        }

        //method maps "Customer (City, State)" to respective list of items as to bucket items 
        public void organizeMovements(List<Item__c> items, String movement) {
            Map<String, List<Item__c>> movementMap = new Map<String, List<Item__c>>();     
            MovementSummary summary = new MovementSummary();
            String key = '';
            List<String> addressedLoads = new List<String>();
            for (Item__c item : items) {
                List<Item__c> itemsToPut = new List<Item__c>();
                if (movement == 'Received' || movement == 'Ungraded' || movement == 'Graded Today') {
                    key = item.Load__r.Pickup_Customer__c + ' (' + item.Load__r.FreightTM__PickupFacility__r.FreightTM__City__c + ', ' + item.Load__r.FreightTM__PickupFacility__r.FreightTM__State__c + ')';
                } else if (movement == 'Shipped') {
                    key = item.Load__r.Delivery_Customer__c + ' (' + item.Load__r.FreightTM__DeliveryFacility__r.FreightTM__City__c + ', ' + item.Load__r.FreightTM__DeliveryFacility__r.FreightTM__State__c + ')';
                }
                if (movementMap.containsKey(key) == false) {
                    itemsToPut.add(item);
                    movementMap.put(key, itemsToPut);
                } else {
                    itemsToPut = movementMap.get(key);
                    itemsToPut.add(item);
                    movementMap.put(key, itemsToPut);
                }
                if (item.Quantity__c != null) {
                    summary.qtyCount += Integer.valueOf(item.Quantity__c);
                }
                if (item.Ungraded__c != null) {
                    summary.ungradedCount += Integer.valueOf(item.Ungraded__c);
                }
                if (addressedLoads.contains(item.Load__r.Name) == false) {
                    addressedLoads.add(item.Load__r.Name);
                    summary.loadCount += 1;
                }
            }       
            List<MovementBucket> movements = new List<MovementBucket>();
            for (String jobIdentifier : movementMap.keySet()) {
                movements.add(new MovementBucket(jobIdentifier, movementMap.get(jobIdentifier)));
            }

            switch on movement {
                when 'Graded Today' {
                    this.matsGradedToday.movementRecords = movements;
                    this.matsGradedToday.movementSummary = summary;
                }
                when 'Received' {
                    this.matsReceived.movementRecords = movements;
                    this.matsReceived.movementSummary = summary;
                }
                when 'Shipped' {
                    this.matsShipped.movementRecords = movements;
                    this.matsShipped.movementSummary = summary;
                }
                when 'Ungraded' {
                    this.matsUngraded.movementRecords = movements;
                    this.matsUngraded.movementSummary = summary;
                }
            }

        }
    }
    
    
    public static Map<Id, String> productIdMap {get; set;} //returns Name value from keyed product Ids
    public static Map<String, Id> productNameMap {get; set;} //returns Id value from keyed product Names

    @AuraEnabled
    public static ReportData getReportData(String yardId, Date reportDate) {
        System.debug('Grabbing fresh set of report data...');

        ReportData payload = new ReportData();
        payload.report = [SELECT Id, Name, 
                    Empire_Mat_Employee__c, 
                    Date__c, Yard__c, Yard__r.Name,
                    Notes__c, Employee_Signature__c, Submitted_On__c, CreatedDate,
                    (SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.FileType FROM ContentDocumentLinks)
                    FROM Inventory_Report__c
                    WHERE Yard__c =: yardId
                    AND Created_Date__c =: reportDate
                    ORDER BY CreatedDate DESC
                    LIMIT 1];
        
        productIdMap = new Map<Id, String>();
        productNameMap = new Map<String, Id>();
        
        mapProducts();
        
        String res = recalculateReportTotals(String.valueOf(payload.report.Id));
        if (res != null) {
            throw new AuraHandledException('Error recalculating report totals: ' + res);
        }        

        //release date: 2023-05-17

        payload.organizeMovements([SELECT Load__c, Load__r.Name, Load__r.Id, Load__r.RecordType.Name, Load_Id__c, Load_Link__c, ReceiverDate__c,
                                Load__r.FreightTM__PickupFacility__c, PickupCustomer__c, Load__r.Pickup_Customer__c, Load__r.FreightTM__PickupFacility__r.FreightTM__City__c, Load__r.FreightTM__PickupFacility__r.FreightTM__State__c,
                                Quantity__c, Commodity__c,
                                Total__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c, Ungraded__c, Graded__c, Graded_On__c,
                                Load__r.Shipper_Signature__c, Load__r.Shipper_Date__c, Load__r.Receiver_Signature__c, Load__r.Receiver_Date__c
                                FROM Item__c 
                                WHERE Load__r.FreightTM__DeliveryFacility__c =: payload.report.Yard__c AND Graded__c = FALSE AND Load__r.RecordType.Name != 'Equipment' AND Load__r.Load_Template__c = FALSE
                                    AND DAY_ONLY(Load__r.Receiver_Date__c) >= 2023-05-17
                                ORDER BY Load__r.Receiver_Date__c ASC], 'Ungraded');

        payload.organizeMovements([SELECT Load__c, Load__r.Name, Load__r.Id, Load__r.RecordType.Name, Load_Id__c, Load_Link__c, ReceiverDate__c,
                                Load__r.FreightTM__PickupFacility__c, PickupCustomer__c, Load__r.Pickup_Customer__c, Load__r.FreightTM__PickupFacility__r.FreightTM__City__c, Load__r.FreightTM__PickupFacility__r.FreightTM__State__c,
                                Quantity__c, Commodity__c,
                                Total__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c, Ungraded__c, Graded__c, Graded_On__c,
                                Load__r.Shipper_Signature__c, Load__r.Shipper_Date__c, Load__r.Receiver_Signature__c, Load__r.Receiver_Date__c
                                FROM Item__c 
                                WHERE Load__r.FreightTM__DeliveryFacility__c =: payload.report.Yard__c AND DAY_ONLY(CONVERTTIMEZONE(Load__r.Receiver_Date__c)) =: reportDate AND Load__r.RecordType.Name != 'Equipment' AND Load__r.Load_Template__c = FALSE
                                ORDER BY Load__r.Receiver_Date__c ASC], 'Received');

        payload.organizeMovements([SELECT Load__c, Load__r.Name, Load__r.Id, Load__r.RecordType.Name, Load_Id__c, Load_Link__c, Shipper_Date__c,
                                Load__r.FreightTM__DeliveryFacility__c, DeliveryCustomer__c, Load__r.Delivery_Customer__c, Load__r.FreightTM__DeliveryFacility__r.FreightTM__City__c, Load__r.FreightTM__DeliveryFacility__r.FreightTM__State__c,
                                Quantity__c, Commodity__c,
                                Total__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c, Ungraded__c, Graded__c, Graded_On__c,
                                Load__r.Shipper_Signature__c, Load__r.Shipper_Date__c, Load__r.Receiver_Signature__c, Load__r.Receiver_Date__c
                                FROM Item__c WHERE Load__r.FreightTM__PickupFacility__c =: payload.report.Yard__c AND DAY_ONLY(CONVERTTIMEZONE(Load__r.Shipper_Date__c)) =: reportDate AND Load__r.RecordType.Name != 'Equipment' AND Load__r.Load_Template__c = FALSE
                                ORDER BY Load__r.Shipper_Date__c ASC], 'Shipped');

        payload.organizeMovements([SELECT Load__c, Load__r.Name, Load__r.Id, Load__r.RecordType.Name, Load_Id__c, Load_Link__c, ReceiverDate__c,
                                Load__r.FreightTM__PickupFacility__c, PickupCustomer__c, Load__r.Pickup_Customer__c, Load__r.FreightTM__PickupFacility__r.FreightTM__City__c, Load__r.FreightTM__PickupFacility__r.FreightTM__State__c,
                                Quantity__c, Commodity__c,
                                Total__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c, Ungraded__c, Graded__c, Graded_On__c,
                                Load__r.Shipper_Signature__c, Load__r.Shipper_Date__c, Load__r.Receiver_Signature__c, Load__r.Receiver_Date__c
                                FROM Item__c WHERE Load__r.FreightTM__DeliveryFacility__c =: payload.report.Yard__c AND DAY_ONLY(CONVERTTIMEZONE(Graded_On__c)) =: reportDate AND (NOT DAY_ONLY(CONVERTTIMEZONE(Load__r.Receiver_Date__c)) =: reportDate) AND Load__r.RecordType.Name != 'Equipment' AND Load__r.Load_Template__c = FALSE
                                ORDER BY Graded_On__c ASC], 'Graded Today');

        payload.adjustments = [SELECT Id, Name, Inventory_Report__c,
                                Type__c, Commodity_Lookup__c, Commodity_Lookup__r.Name, Commodity_Formula__c,
                                Total__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c, Comments__c
                                FROM Inventory_Counts__c
                                WHERE Inventory_Report__c =: payload.report.Id AND Type__c = 'Adjustment'
                                ORDER BY CreatedDate ASC];
        payload.beginningInventory = [SELECT Id, Name, Inventory_Report__c,
                                Type__c, Commodity_Lookup__c, Commodity_Lookup__r.Name, Commodity_Formula__c,
                                Total__c, Ungraded__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c, Comments__c
                                FROM Inventory_Counts__c
                                WHERE Inventory_Report__c =: payload.report.Id AND Type__c = 'Beginning'
                                ORDER BY Total__c DESC];
        payload.endingInventory = [SELECT Id, Name, Inventory_Report__c,
                                Type__c, Commodity_Lookup__c, Commodity_Lookup__r.Name, Commodity_Formula__c,
                                Total__c, Ungraded__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c, Comments__c
                                FROM Inventory_Counts__c
                                WHERE Inventory_Report__c =: payload.report.Id AND Type__c = 'Ending'
                                ORDER BY Total__c DESC];

        /* Default current user as employee if field is empty */
        if (payload.report.Empire_Mat_Employee__c == null || payload.report.Empire_Mat_Employee__c == '') {
            User usr = [SELECT FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
            payload.report.Empire_Mat_Employee__c = usr.FirstName + ' ' + usr.LastName;
        }

        System.debug('REPORT DATA: ');
        System.debug(payload.report);
        System.debug('OVERDUE DATA: ');
        System.debug(payload.matsUngraded);
        System.debug('RECEVED DATA: ');
        System.debug(payload.matsReceived);
        System.debug('SHIPPED DATA: ');
        System.debug(payload.matsShipped);
        System.debug('BEGINNNING INVENTORY: ');
        System.debug(payload.beginningInventory);
        System.debug('ADJUSTMENTS: ');
        System.debug(payload.adjustments);
        System.debug('ENDING INVENTORY: ');
        System.debug(payload.endingInventory);

        return payload;
    }
    
    public static void mapProducts() {
        for (Product2 mat : [SELECT Id, Name FROM Product2 WHERE Family = 'Mat Sales' AND SellType__c = 'Purchase']) {
            productIdMap.put(mat.Id, mat.Name);
            productNameMap.put(mat.Name, mat.Id);
        }
    }

    public static Id getProductId(String commodity) {
        System.debug('Fetching product id for commodity: ' + commodity);
        //retrieve related product record depending on indicated commodity record
        Id productId = productNameMap.get(commodity);
        System.debug('Found the following product Id:');
        System.debug(productId);
        if (productId != null) {
            return productId;
        } else {
            //route error properly
            return null;
        }
    }

    public static String getProductName(String productId) {
        System.debug('Fetching product name for id: ' + productId);
        String productName = productIdMap.get(productId);
        System.debug('Found the following product: ');
        System.debug(productName);
        if (productName != null) {
            return productName;
        } else {
            return null;
        }
    }

    public static Inventory_Counts__c cleanseNumberFields(Inventory_Counts__c countToCleanse) {
        if (countToCleanse.New__c == null) {
            countToCleanse.New__c = 0;
        }
        if (countToCleanse.A_Four__c == null) {
            countToCleanse.A_Four__c = 0;
        }
        if (countToCleanse.A_Three__c == null) {
            countToCleanse.A_Three__c = 0;
        }
        if (countToCleanse.B_Two__c == null) {
            countToCleanse.B_Two__c = 0;
        }
        if (countToCleanse.B_One__c == null) {
            countToCleanse.B_One__c = 0;
        }
        if (countToCleanse.Cull__c == null) {
            countToCleanse.Cull__c = 0;
        }
        if (countToCleanse.Rebuild__c == null) {
            countToCleanse.Rebuild__c = 0;
        }

        return countToCleanse;
    }

    public static Inventory_Counts__c calculateGrades(Inventory_Counts__c countToReturn, Inventory_Counts__c countToCalculate, String operand) {
        countToReturn = cleanseNumberFields(countToReturn);
        countToCalculate = cleanseNumberFields(countToCalculate);
        switch on operand {
            when '+' {
                countToReturn.New__c += countToCalculate.New__c;
                countToReturn.A_Four__c += countToCalculate.A_Four__c;
                countToReturn.A_Three__c += countToCalculate.A_Three__c;
                countToReturn.B_Two__c += countToCalculate.B_Two__c;
                countToReturn.B_One__c += countToCalculate.B_One__c;
                countToReturn.Rebuild__c += countToCalculate.Rebuild__c;
                countToReturn.Cull__c += countToCalculate.Cull__c;
            }
            when '-' {
                countToReturn.New__c -= countToCalculate.New__c;
                countToReturn.A_Four__c -= countToCalculate.A_Four__c;
                countToReturn.A_Three__c -= countToCalculate.A_Three__c;
                countToReturn.B_Two__c -= countToCalculate.B_Two__c;
                countToReturn.B_One__c -= countToCalculate.B_One__c;
                countToReturn.Rebuild__c -= countToCalculate.Rebuild__c;
                countToReturn.Cull__c -= countToCalculate.Cull__c;
            }
        }

        return countToReturn;
    }


    public static String recalculateReportTotals(String reportId) {
        System.debug('Updating report totals for report w/ ID: ' + reportId);
        String errorMessage = null;

        Inventory_Report__c report = [SELECT Id, Name, Date__c, Yard__c, Yard__r.Name FROM Inventory_Report__c WHERE Id =: reportId];
        if (report.Date__c != Date.today()) {
            return null;
        }
        // Create two maps to store the Beginning Inventory and Ending Inventory counts by Commodity
        Map<String, Inventory_Counts__c> beginningInventoryMap = new Map<String, Inventory_Counts__c>();
        Map<String, Inventory_Counts__c> movementMap = new Map<String, Inventory_Counts__c>(); //used to convert items shipped / received into inventory count data structure for summary
        Map<String, Inventory_Counts__c> adjustmentMap = new Map<String, Inventory_Counts__c>();
        Map<String, Inventory_Counts__c> endingInventoryMap = new Map<String, Inventory_Counts__c>();
        try {
            for (Inventory_Counts__c count : [SELECT Id, Type__c, Inventory_Report__c,  Commodity_Lookup__c, Commodity_Lookup__r.Name, Ungraded__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c FROM Inventory_Counts__c WHERE Inventory_Report__c =: reportId]) {
                if (count.Type__c == 'Beginning') {
                    beginningInventoryMap.put(count.Commodity_Lookup__r.Name, count);
                } else if (count.Type__c == 'Adjustment') {
                    if (adjustmentMap.containsKey(count.Commodity_Lookup__r.Name)) {
                        Inventory_Counts__c foundCount = adjustmentMap.get(count.Commodity_Lookup__r.Name);
                        foundCount = calculateGrades(foundCount, count, '+');
                        adjustmentMap.put(count.Commodity_Lookup__r.Name, foundCount); 
                    } else {
                        adjustmentMap.put(count.Commodity_Lookup__r.Name, count);
                    }
                } else if (count.Type__c == 'Ending') {
                    endingInventoryMap.put(count.Commodity_Lookup__c, count);
                } 
            }

            //looping all mat movements...pickup / delivery that ARE GRADED
            for (Item__c movement : [SELECT Commodity__c, Load__r.FreightTM__PickupFacility__c, Load__r.FreightTM__DeliveryFacility__c, 
                                        Total__c, Graded__c, Graded_On__c, Ungraded__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c FROM Item__c 
                                        WHERE ((Load__r.FreightTM__PickupFacility__c =: report.Yard__c AND (DAY_ONLY(CONVERTTIMEZONE(Load__r.Shipper_Date__c)) =: report.Date__c))
                                                    OR (Load__r.FreightTM__DeliveryFacility__c =: report.Yard__c AND (DAY_ONLY(CONVERTTIMEZONE(Load__r.Receiver_Date__c)) =: report.Date__c OR (DAY_ONLY(CONVERTTIMEZONE(Graded_On__c)) =: report.Date__c))))
                                            AND Graded__c = TRUE AND Load__r.RecordType.Name != 'Equipment' AND Load__r.Load_Template__c = FALSE]) 
            {
                String operand = '';
                if (movement.Load__r.FreightTM__PickupFacility__c != null && movement.Load__r.FreightTM__PickupFacility__c == report.Yard__c) {
                    operand = '-';
                } else if (movement.Load__r.FreightTM__DeliveryFacility__c != null && movement.Load__r.FreightTM__DeliveryFacility__c == report.Yard__c) {
                    operand = '+';
                }
                Inventory_Counts__c loopedCount = new Inventory_Counts__c(
                                                    Inventory_Report__c = reportId, 
                                                    Commodity_Lookup__c = getProductId(movement.Commodity__c), 
                                                    Type__c = 'Ending', 
                    								Ungraded__c = 0,
                                                    New__c = movement.New__c, 
                                                    A_Four__c = movement.A_Four__c, 
                                                    A_Three__c = movement.A_Three__c, 
                                                    B_Two__c = movement.B_Two__c, 
                                                    B_One__c = movement.B_One__c, 
                                                    Rebuild__c = movement.Rebuild__c,
                                                    Cull__c = movement.Cull__c);
                Inventory_Counts__c countToPut = new Inventory_Counts__c(                                                    
                                                    Inventory_Report__c = reportId, 
                                                    Commodity_Lookup__c = getProductId(movement.Commodity__c),
                                                    Type__c = 'Ending',
                    								Ungraded__c = 0,
                                                    New__c = 0, 
                                                    A_Four__c = 0, 
                                                    A_Three__c = 0, 
                                                    B_Two__c = 0, 
                                                    B_One__c = 0, 
                                                    Rebuild__c = 0,
                                                    Cull__c = 0);
                if (movementMap.containsKey(movement.Commodity__c) == false) {
                    countToPut = calculateGrades(countToPut, loopedCount, operand);
                } else {
                    Inventory_Counts__c foundCount = movementMap.get(movement.Commodity__c);
                    countToPut = calculateGrades(foundCount, loopedCount, operand);
                }
                movementMap.put(movement.Commodity__c, countToPut);
            }
        } catch (Exception e) {
            System.debug('Error occurred whenevering trying to recalculate counts for report w/ ID: ' + reportId);
            System.debug('Error trying to map counts / movements for total recalculation: ' + e.getMessage());
            errorMessage = 'Error occurred whenevering trying to recalculate counts for report w/ ID: ' + reportId + '\n';
            errorMessage += 'Error trying to map counts / movements for total recalculation: ' + e.getMessage();

            return errorMessage;
        }


        Map<String, Inventory_Counts__c> updatedInventoryMap = new Map<String, Inventory_Counts__c>();

        List<Inventory_Counts__c> countsToUpdate = new List<Inventory_Counts__c>();

        //copy beginning counts to begin report analysis
        for (Inventory_Counts__c beginningCount : beginningInventoryMap.values()) {
            if (updatedInventoryMap.containsKey(beginningCount.Commodity_Lookup__r.Name) == false) {
                //updated inventory map has not accounted for looped beginning count's commodity
                beginningCount.Id = null;
                beginningCount.Type__c = 'Ending'; //toggle type to show as ending
                beginningCount.Ungraded__c = 0; //reinitialize ungraded count as to re-evaluate all ungraded mats below
                updatedInventoryMap.put(beginningCount.Commodity_Lookup__r.Name, beginningCount);
            } else {
                Inventory_Counts__c foundCount = updatedInventoryMap.get(beginningCount.Commodity_Lookup__r.Name);
                foundCount = calculateGrades(foundCount, beginningCount, '+');
                updatedInventoryMap.put(beginningCount.Commodity_Lookup__r.Name, foundCount);
            }
        }

        //scan movements
        for (Inventory_Counts__c movementCount : movementMap.values()) {
            String commodity = getProductName(movementCount.Commodity_Lookup__c);
            if (updatedInventoryMap.containsKey(commodity) == false) {
                //updated inventory map has not account for looped movement's commodity
                updatedInventoryMap.put(commodity, movementCount);
            } else {
                Inventory_Counts__c foundCount = updatedInventoryMap.get(commodity);
                foundCount = calculateGrades(foundCount, movementCount, '+'); //always adding since we already summarized shipment vs. delivery designations
                updatedInventoryMap.put(commodity, foundCount);
            }
        }

        //scan adjustments
        for (Inventory_Counts__c adjustmentCount : adjustmentMap.values()) {
            if (updatedInventoryMap.containsKey(adjustmentCount.Commodity_Lookup__r.Name) == false) {
                //updated inventory map has not accounted for looped adjustment's commodity
                adjustmentCount.Id = null;
                adjustmentCount.Type__c = 'Ending';
                updatedInventoryMap.put(adjustmentCount.Commodity_Lookup__r.Name, adjustmentCount);
            } else {
                Inventory_Counts__c foundCount = updatedInventoryMap.get(adjustmentCount.Commodity_Lookup__r.Name);
                foundCount = calculateGrades(foundCount, adjustmentCount, '+');
                updatedInventoryMap.put(adjustmentCount.Commodity_Lookup__r.Name, foundCount);
            }
        }
        Date releaseDate = Date.newInstance(2023, 5, 17);
        //scan ungraded
        for (Item__c movement : [SELECT Commodity__c, Load__r.FreightTM__PickupFacility__c, Load__r.FreightTM__DeliveryFacility__c, 
                                 Total__c, Graded__c, Graded_On__c, Ungraded__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Rebuild__c, Cull__c FROM Item__c 
                                 WHERE Load__r.FreightTM__DeliveryFacility__c =: report.Yard__c AND Graded__c = FALSE AND Load__r.RecordType.Name != 'Equipment' AND Load__r.Load_Template__c = FALSE AND DAY_ONLY(CONVERTTIMEZONE(Load__r.Receiver_Date__c)) >= 2023-05-17]) 
        {
            Inventory_Counts__c countToPut = new Inventory_Counts__c(                                                    
                Inventory_Report__c = reportId, 
                Commodity_Lookup__c = getProductId(movement.Commodity__c),
                Type__c = 'Ending',
                Ungraded__c = 0);
            if (updatedInventoryMap.containsKey(movement.Commodity__c) == false) {
                countToPut.Ungraded__c = movement.Ungraded__c;
            } else {
                countToPut = updatedInventoryMap.get(movement.Commodity__c);
                countToPut.Ungraded__c += movement.Ungraded__c;
            }
            updatedInventoryMap.put(movement.Commodity__c, countToPut);
        }

        //remove ending counts that are no longer part of calculation
        List<Inventory_Counts__c> countsToDelete = new List<Inventory_Counts__c>();
        for (Inventory_Counts__c endingCount : endingInventoryMap.values()) {
            if (updatedInventoryMap.containsKey(endingCount.Commodity_Lookup__r.Name) == false) {
                countsToDelete.add(endingCount);
            }
        }

        //utilize existing ending inventory counts, if any
        for (Inventory_Counts__c updatedCount : updatedInventoryMap.values()) {
            System.debug('Looping following finalized count: ');
            System.debug(updatedCount);
            if (endingInventoryMap.containsKey(updatedCount.Commodity_Lookup__c)) {
                updatedCount.Id = endingInventoryMap.get(updatedCount.Commodity_Lookup__c).Id;
            } 
            countsToUpdate.add(updatedCount);

            System.debug('Adding following count to ending inventory upsert: ');
            System.debug(updatedCount);
        }

        try {
            if (countsToDelete.size() > 0) {
                delete countsToDelete;
            }
            upsert countsToUpdate;
            return null;
        } catch(DmlException e) {
            System.debug('Error occurred whenevering trying to recalculate counts for report w/ ID: ' + reportId);
            System.debug('Error whenever updating ending counts: ' + e.getMessage());
            errorMessage = 'Error occurred whenevering trying to recalculate counts for report w/ ID: ' + reportId + '\n';
            errorMessage += 'Error whenever updating ending counts: ' + e.getMessage();

            return errorMessage;
        }
    }

    public class FlowInputs {
        @InvocableVariable(label='Report ID')
        public String reportId;
    }

    public class FlowOutputs {
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(label='Recalculate Inventory Report Totals' description='Apex action to recalculate inventory report depending on beginning inventory levels and item movements')
    public static List<FlowOutputs> recalculateReportTotals_Invocable(List<FlowInputs> inputs) {

        String reportId = '';
        for (FlowInputs input : inputs) {
            reportId = input.reportId;
        }        
        

        List<FlowOutputs> outputs = new List<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
        output.errorMessage = null; 
        try {
            output.errorMessage = recalculateReportTotals(reportId);
        } catch (DmlException e) {
            System.debug('Error occurred whenever recalculating counts for report w/ Id: ' + reportId);
            System.debug('INVOCABLE ERROR: ' + e.getMessage());

            output.errorMessage = 'Error whenever recalculating counts: ' + e.getMessage();
        }

        outputs.add(output);

        return outputs;
    }



    @AuraEnabled
    public static void recalculateTotals(String reportId) {
        String res = recalculateReportTotals(reportId);
        if (res != null) {
            throw new AuraHandledException('Error recalculating report totals: ' + res);
        }
    }

    @AuraEnabled
    public static void updateItems(List<Item__c> itemsToUpdate) {
        try {
            update itemsToUpdate;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating item movements: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateCounts(List<Inventory_Counts__c> countsToUpdate) {
        try {
            update countsToUpdate;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating inventory count comments: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateLoad(FreightTM__Load__c loadToUpdate) {
        try {
            update loadToUpdate;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating load signature: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeReportReference(Item__c movement) {
        try {
            update movement;
        } catch (DmlException e) {
            System.debug('Error whenever removing report reference for movement:');
            System.debug(movement);
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error removing movement\'s report reference: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveReport(ReportData payload) {
        try {
            System.debug('Saving the following yard report data...');
            payload.report.Submitted_On__c = Datetime.now();
            System.debug('REPORT:');
            System.debug(payload.report);
            System.debug('MATS RECEIVED:');
            System.debug(payload.matsReceived);
            System.debug('MATS SHIPPED: ');
            System.debug(payload.matsShipped);
            System.debug('BEGINNING INVENTORY:');
            System.debug(payload.beginningInventory);
            System.debug('ENDING INVENTORY:');
            System.debug(payload.endingInventory);
            update payload.report;

            System.debug('Successfully inserted / updated yard report data!');
            return;
        } catch (DmlException e) {
            throw new AuraHandledException('Error performing DML on report data: ' + e.getMessage());
        }
    }

}