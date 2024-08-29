/**
 * @description       : Controller used to handle load / item query from AR reporting component.
 * @author            : Ethan Myers
 * @group             : 
 * @last modified on  : 02-23-2023
 * @last modified by  : Ethan Myers
**/
public with sharing class LoadReportController {
    public LoadReportController() {

    }

    //used to organize item filters available from lwc
    public with sharing class FilterWrapper {

        @AuraEnabled
        public String declaredFilter {get; set;}

        @AuraEnabled
        public Date receiverDate {get; set;}

        @AuraEnabled
        public String recordType {get; set;}

        @AuraEnabled
        public String projectManager {get; set;}

        @AuraEnabled
        public String pickupJob {get; set;}

        @AuraEnabled
        public String deliveryJob {get; set;}

        @AuraEnabled
        public String order {get; set;}

        @AuraEnabled
        public String deliveryLocation {get; set;}

        @AuraEnabled
        public String commodity {get; set;}

        @AuraEnabled
        public String sellType {get; set;}

        @AuraEnabled
        public String grade {get; set;}


        public FilterWrapper() {
            this.declaredFilter = '';
            this.receiverDate = null;
            this.recordType = '';
            this.projectManager = '';
            this.pickupJob = '';
            this.deliveryJob = '';
            this.order = '';
            this.deliveryLocation = '';
            this.commodity = '';
            this.sellType = '';
            this.grade = '';
        }

        public FilterWrapper(String declaredFilter, Date receiverDate, String recordType, String projectManager, String pickupJob, String deliveryJob, String order, String deliveryLocation, String commodity, String sellType, String grade) {
            this.declaredFilter = declaredFilter;
            this.receiverDate = receiverDate;
            this.recordType = recordType;
            this.projectManager = projectManager;
            this.pickupJob = pickupJob;
            this.deliveryJob = deliveryJob;
            this.order = order;
            this.deliveryLocation = deliveryLocation;
            this.commodity = commodity;
            this.sellType = sellType;
            this.grade = grade;
        }
    }

    //object to store picklist values for filter picklists
    public with sharing class OptionWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public OptionWrapper() {
            this.label = '';
            this.value = '';
        }

        public OptionWrapper(String option, String value) {
            this.label = option;
            this.value = value;
        }
    }

    //wrapper used to store summary of items included in table
    public with sharing class ItemSummary {
        @AuraEnabled
        public Integer loadCount {get; set;}
        @AuraEnabled
        public Decimal commodityCount {get; set;}
        @AuraEnabled
        public Decimal totalRate {get; set;}
        @AuraEnabled
        public Decimal totalPrice {get; set;}

        public ItemSummary() {
            this.loadCount = 0;
            this.commodityCount = 0;
            this.totalRate = 0.0;
            this.totalPrice = 0.0;
        }
    }

    //wrapper classed used to display relational data within lightning-datatable component
    public with sharing class ItemForTable {
        @AuraEnabled
        public String itemId {get; set;}
        @AuraEnabled
        public String loadId {get; set;}
        @AuraEnabled
        public String loadLink {get; set;}
        @AuraEnabled
        public Date shipperDate {get; set;}
        @AuraEnabled
        public Date receiverDate {get; set;}
        @AuraEnabled 
        public String recordType {get; set;}
        @AuraEnabled
        public String loadNumber {get; set;}
        @AuraEnabled
        public String lane {get; set;}
        @AuraEnabled
        public String deliveryAddress {get; set;}
        @AuraEnabled
        public String carrier {get; set;}
        @AuraEnabled
        public String pickupCustomer {get; set;}
        @AuraEnabled
        public String pickupPm {get; set;}
        @AuraEnabled
        public String pickupRef {get; set;}
        @AuraEnabled
        public String pickupOrder {get; set;}
        @AuraEnabled
        public String deliveryCustomer {get; set;}
        @AuraEnabled
        public String deliveryPm {get; set;}
        @AuraEnabled
        public String deliveryRef {get; set;}
        @AuraEnabled
        public String deliveryOrder {get; set;}
        @AuraEnabled
        public String jobClass {get; set;}
        @AuraEnabled
        public Decimal quantity {get; set;}
        @AuraEnabled
        public String commodity {get; set;}
        @AuraEnabled
        public String grade {get; set;}

        @AuraEnabled
        public Decimal aGrade {get; set;}
        @AuraEnabled
        public Decimal bGrade {get; set;}
        @AuraEnabled
        public Decimal newGrade {get; set;}
        @AuraEnabled
        public Decimal aFour {get; set;}
        @AuraEnabled
        public Decimal aThree {get; set;}
        @AuraEnabled
        public Decimal bTwo {get; set;}
        @AuraEnabled
        public Decimal bOne {get; set;}
        @AuraEnabled
        public Decimal cull {get; set;}
        @AuraEnabled
        public String pickupSellType {get; set;}
        @AuraEnabled
        public String sellType {get; set;}
        @AuraEnabled
        public String pickupCostType {get; set;}
        @AuraEnabled
        public String deliveryCostType {get; set;}
        @AuraEnabled
        public Decimal freightIn {get; set;}
        @AuraEnabled
        public Decimal unitPrice {get; set;}
        @AuraEnabled
        public Decimal subtotal {get; set;}
        @AuraEnabled
        public Decimal rateToCarrier {get; set;}
        @AuraEnabled
        public String invoiceNumber {get; set;}
        @AuraEnabled
        public DateTime invoiceDate {get; set;}
        @AuraEnabled
        public String rejectedBy {get; set;}
        @AuraEnabled
        public DateTime rejectedOn {get; set;}
        @AuraEnabled
        public String rejectionComments {get; set;}

        public ItemForTable() {
            this.itemId = null;
            this.loadId = null;
            this.loadLink = null;
            this.shipperDate = null;
            this.receiverDate = null;
            this.recordType = null;
            this.loadNumber = null;
            this.lane = null;
            this.deliveryAddress = null;
            this.carrier = null;
            this.quantity = 0;
            this.commodity = null;
            this.grade = null;
            this.aGrade = 0;
            this.bGrade = 0;
            this.newGrade = 0;
            this.aFour = 0;
            this.aThree = 0;
            this.bTwo = 0;
            this.bOne = 0;
            this.cull = 0;
            this.pickupSellType = null;
            this.sellType = null;
            this.pickupCostType = null;
            this.deliveryCostType = null;
            this.freightIn = 0.0;
            this.rateToCarrier = 0.0;
            this.unitPrice = 0.0;
            this.subtotal = 0.0;
            this.pickupCustomer = null;
            this.pickupPm = null;
            this.pickupRef = null;
            this.pickupOrder = null;
            this.deliveryCustomer = null;
            this.deliveryPm = null;
            this.deliveryRef = null;
            this.deliveryOrder = null;
            this.jobClass = null;
            this.invoiceNumber = null;
            this.invoiceDate = null;
            this.rejectedBy = null;
            this.rejectedOn = null;
            this.rejectionComments = null;
        }

        public ItemForTable (Item__c item) {
            this.itemId = item.Id;
            this.loadId = item.Load__r.Id;
            this.loadLink = item.Load__r.Record_Link__c;
            this.shipperDate = Date.valueOf(item.Load__r.Shipper_Date__c);
            this.receiverDate = Date.valueOf(item.Load__r.Receiver_Date__c);
            this.recordType = item.Load__r.RecordType.Name;
            this.loadNumber = item.Load__r.Name;
            this.lane = item.Load__r.FreightTM__Calendar_Load__c;
            this.deliveryAddress = item.Load__r.Delivery_Address__c;
            this.carrier = item.Load__r.FreightTM__Carrier_Obj__r.Name;
            this.pickupCustomer = item.PickupCustomer__c;
            if (item.Pickup_Order__r.Project_Manager__r.Name != null) {
                this.pickupPm = item.Pickup_Order__r.Project_Manager__r.Name;
            } else {
                this.pickupPm = '';
            }
            this.deliveryCustomer = item.DeliveryCustomer__c;
            if (item.Delivery_Order__r.Project_Manager__r.Name != null) {
                this.deliveryPm = item.Delivery_Order__r.Project_Manager__r.Name;
            } else {
                this.deliveryPm = '';
            }
            this.quantity = item.Quantity__c;
            this.commodity = item.Commodity__c;
            this.grade = item.Grade__c;
            this.aGrade = item.A_Grade__c;
            this.bGrade = item.B_Grade__c;
            this.newGrade = item.New__c;
            this.aFour = item.A_Four__c;
            this.aThree = item.A_Three__c;
            this.bTwo = item.B_Two__c;
            this.bOne = item.B_One__c;
            this.cull = item.Cull__c;
            this.pickupSellType = item.Pickup_Item__r.Sell_Type__c;
            this.sellType = item.Sell_Type__c;
            this.pickupCostType = item.Pickup_Item__r.FreightCostType__c;
            this.deliveryCostType = item.Delivery_Item__r.FreightCostType__c;
            if (item.Delivery_Item__r.FreightIn__c != null) {
                this.freightIn = item.Delivery_Item__r.FreightIn__c;
            } else {
                this.freightIn = 0.0;
            }
            if (item.Load__r.FreightTM__Total_Rate_to_Carrier__c != null) {
                this.rateToCarrier = item.Load__r.FreightTM__Total_Rate_to_Carrier__c;
            } else {
                this.rateToCarrier = 0.0;
            }

            if (item.Unit_Price__c != null) {
                this.unitPrice = item.Unit_Price__c;
            } else {
                this.unitPrice = 0.0;
            }

            if (item.Subtotal__c != null) {
                this.subtotal = item.Subtotal__c;
            } else {
                this.subtotal = 0.0;
            }
            this.pickupRef = item.Load__r.FreightTM__Pickup_Ref__c;
            this.pickupOrder = item.Pickup_Order__r.Purchase_Order_Number__c;
            this.deliveryRef = item.Load__r.FreightTM__Delivery_Ref__c;
            this.deliveryOrder = item.Delivery_Order__r.Purchase_Order_Number__c;
            this.jobClass = item.Job_Classification_Delivery__c;
            this.invoiceNumber = item.Mat_Invoice__c;
            this.invoiceDate = item.Mat_Invoice_Date__c;
            this.rejectedBy = item.Rejected_By__c;
            this.rejectedOn = item.Rejected_On__c;
            this.rejectionComments = item.Rejection_Comments__c;
        }
    }

    //organizes load data + splits up customer and job options per query
    public with sharing class LoadReportWrapper {
        @AuraEnabled
        public List<Item__c> items {get; set;}
        @AuraEnabled
        public ItemSummary summary {get; set;}
        @AuraEnabled
        public List<ItemForTable> itemsForTable {get; set;}
        @AuraEnabled
        public List<OptionWrapper> pmOptions {get; set;}
        @AuraEnabled
        public List<OptionWrapper> pickupOptions {get; set;}
        @AuraEnabled
        public List<OptionWrapper> deliveryOptions {get; set;}
        @AuraEnabled
        public List<OptionWrapper> orderOptions {get; set;}
        @AuraEnabled
        public List<OptionWrapper> locationOptions {get; set;}
        @AuraEnabled
        public List<OptionWrapper> commodityOptions {get; set;}

        FilterWrapper filters {get; set;}

        public LoadReportWrapper(FilterWrapper filters) {
            System.debug('Initializing Load Report Wrapper class...');
            this.items = new List<Item__c>();
            this.summary = new ItemSummary();
            this.itemsForTable = new List<ItemForTable>();
            this.pmOptions = new List<OptionWrapper>();
            this.pickupOptions = new List<OptionWrapper>();
            this.deliveryOptions = new List<OptionWrapper>();
            this.orderOptions = new List<OptionWrapper>();
            this.locationOptions = new List<OptionWrapper>();
            this.commodityOptions = new List<OptionWrapper>();
            this.filters = filters;
        }

        public void fetchItems() {
            System.debug('Fetching items for Load Report Wrapper...');
            FilterWrapper tempFilters = this.filters;
            System.debug('Applying the following filters: ');
            System.debug(tempFilters);
            if (tempFilters.declaredFilter == null || tempFilters.declaredFilter == '') {
                System.debug('No filtered declared...pause data collection');
                return;
            }
            String query = 'SELECT Id, Name, Load__r.Id, Load__r.Name, Load__r.RecordType.Name, Load__r.Shipper_Date__c, Load__r.Receiver_Date__c, Load__r.FreightTM__Pickup_Ref__c, Pickup_Order__r.Purchase_Order_Number__c,';
            query += 'Load__r.FreightTM__Calendar_Load__c, Load__r.Delivery_Address__c,';
            query += 'Load__r.FreightTM__Delivery_Ref__c, Delivery_Order__r.Purchase_Order_Number__c,Pickup_Order__r.Project_Manager__r.Name, Delivery_Order__r.Project_Manager__r.Name,';
            query += 'Quantity__c, Commodity__c, Grade__c,A_Grade__c,B_Grade__c,Cull__c,';
            query += 'New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Total__c, Ungraded__c, Graded__c,';
            query += 'Sell_Type__c, Pickup_Item__r.Sell_Type__c,Pickup_Item__r.FreightCostType__c,Unit_Price__c,Subtotal__c,';
            query += 'Job_Classification_Delivery__c,Load__r.FreightTM__Carrier_Obj__r.Name,';
            query += 'Delivery_Item__r.FreightCostType__c,Delivery_Item__r.FreightIn__c,Load__r.FreightTM__Total_Rate_to_Carrier__c,';
            query += 'PickupCustomer__c, DeliveryCustomer__c,Mat_Invoice__c,Mat_Invoice_Date__c, Inventory_Reviewed__c, Load__r.Record_Link__c, ';
            query += 'Rejected_By__c, Rejected_On__c, Rejection_Comments__c ';
            query += 'FROM Item__c WHERE Load__r.RecordType.Name != \'Equipment\' AND Load__r.Load_Template__c = false'; //filtering out items which do not have their Invoice # marked 

            if (tempFilters.declaredFilter != '' && tempFilters.declaredFilter != null) {
                System.debug('Applying following filter declared outside controller: ');
                System.debug(tempFilters.declaredFilter);
                query += ' AND ' + tempFilters.declaredFilter;
            }

            String dateFilter = '';
            String recTypeFilter = '';
            String pmFilter = '';
            String pickupFilter = '';
            String deliveryFilter = '';
            String salesOrderFilter = '';
            String locationFilter = '';
            String commodityFilter = '';
            String sellTypeFilter = '';
            String gradeFilter = '';

            try {
                if (tempFilters.receiverDate != null) {
                    Integer day = tempFilters.receiverDate.day();
                    Integer month = tempFilters.receiverDate.month();
                    Integer yr = tempFilters.receiverDate.year();
                    Datetime startTime = DateTime.newInstance(yr, month, day, 01, 01, 01);
                    Datetime endTime = DateTime.newInstance(yr, month, day, 23, 59, 59);
                    String startDate = startTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    String endDate = endTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    dateFilter = ' AND Load__r.Receiver_Date__c > ' + startDate + ' AND Load__r.Receiver_Date__c < ' + endDate;
                    System.debug('Applying following receiver date filter: ' + dateFilter);
                    query += dateFilter;
                }
                if (tempFilters.recordType != null && tempFilters.recordType != '' && tempFilters.recordType != 'ALL') {
                    recTypeFilter = ' AND Load__r.RecordType.Name = \'' + String.escapeSingleQuotes(tempFilters.recordType) + '\'';
                    System.debug('Applying the following record type filter: ' + recTypeFilter);
                    query += recTypeFilter;
                }
                if (tempFilters.projectManager != null && tempFilters.projectManager != '' && tempFilters.projectManager != 'ALL') {
                    pmFilter = ' AND (Delivery_Order__r.Project_Manager__r.Name = \'' + String.escapeSingleQuotes(tempFilters.projectManager) + '\'';
                    pmFilter += ' OR Pickup_Order__r.Project_Manager__r.Name = \'' + String.escapeSingleQuotes(tempFilters.projectManager) + '\')';
                    System.debug('Applying following project manager filter: ' + pmFilter);
                    query += pmFilter;
                }
                if (tempFilters.pickupJob != null && tempFilters.pickupJob != '' && tempFilters.pickupJob != 'ALL') {
                    pickupFilter = ' AND Load__r.FreightTM__Pickup_Ref__c = \'' + String.escapeSingleQuotes(tempFilters.pickupJob) + '\'';
                    System.debug('Applying following pickup job filter: ' + pickupFilter);
                    query += pickupFilter;
                }

                if (tempFilters.deliveryJob != null && tempFilters.deliveryJob != '' && tempFilters.deliveryJob != 'ALL') {
                    deliveryFilter = ' AND Load__r.FreightTM__Delivery_Ref__c = \'' + String.escapeSingleQuotes(tempFilters.deliveryJob) + '\'';
                    System.debug('Applying following delivery job filter: ' + deliveryFilter);
                    query += deliveryFilter;
                }
                
                if (tempFilters.order != null && tempFilters.order != '' && tempFilters.order != 'ALL') {
                    salesOrderFilter = ' AND (Pickup_Order__r.Purchase_Order_Number__c = \'' + String.escapeSingleQuotes(tempFilters.order) + '\'';
                    salesOrderFilter += ' OR Delivery_Order__r.Purchase_Order_Number__c = \'' + String.escapeSingleQuotes(tempFilters.order) + '\')';
                    System.debug('Applying following po # to filter: ' + salesOrderFilter);
                    query += salesOrderFilter;
                }

                if (tempFilters.deliveryLocation != null && tempFilters.deliveryLocation != '' && tempFilters.deliveryLocation != 'ALL') {
                    locationFilter = ' AND Load__r.Delivery_Address__c = \'' + String.escapeSingleQuotes(tempFilters.deliveryLocation) + '\'';
                    System.debug('Applying the following delivery address filter: ' + locationFilter);
                    query += locationFilter;
                }
                if (tempFilters.commodity != null && tempFilters.commodity != '' && tempFilters.commodity != 'ALL') {
                    commodityFilter = ' AND Commodity__c =  \'' + String.escapeSingleQuotes(tempFilters.commodity) + '\'';
                    System.debug('Applying following commodity filter: ' + commodityFilter);
                    query += commodityFilter;
                }
                if (tempFilters.sellType != null && tempFilters.sellType != '' && tempFilters.sellType != 'ALL') {
                    sellTypeFilter = ' AND Sell_Type__c = \'' + String.escapeSingleQuotes(tempFilters.sellType) + '\'';
                    System.debug('Applying following sell type filter: ' + sellTypeFilter);
                    query += sellTypeFilter;
                }
                if (tempFilters.grade != null && tempFilters.grade != '' && tempFilters.grade != 'ALL') {
                    gradeFilter = ' AND Grade__c = \'' + String.escapeSingleQuotes(tempFilters.grade) + '\'';
                    System.debug('Applying following grade filter: ' + gradeFilter);
                    query += gradeFilter;
                }
                query += ' ORDER BY Load__r.Receiver_Date__c ASC NULLS LAST, Load__r.Name ASC';
                System.debug('Finalized Query: ');
                System.debug(query);
                this.items = Database.query(query);
                System.debug('Item Results: ');
                System.debug(this.items);

            } catch (Exception e) {
                System.debug('Unable to query loads for AR report...Exception: ' + e.getMessage());
            }
        }

        //method used to apply all item data to encapsulated ItemForTable class to properly display as datatable
        //method also evaluates items as they are being looped to count loads, quantities, and carrier rates
        public void storeItemsForTable() {
            List<ItemForTable> itemsForTable = new List<ItemForTable>();
            ItemSummary summary = new ItemSummary();
            List<String> addressedLoads = new List<String>();
            for (Item__c item : this.items) {
                ItemForTable i = new ItemForTable(item);
                itemsForTable.add(i);
                if (addressedLoads.contains(item.Load__r.Name) == false) {
                    addressedLoads.add(item.Load__r.Name);
                    summary.loadCount += 1;
                    summary.totalRate += i.rateToCarrier;
                }
                summary.totalPrice += i.subtotal;
                summary.commodityCount += item.Quantity__c;
            }
            this.summary = summary;
            this.itemsForTable = itemsForTable;
        }

        public void organizeOptions() {
            List<OptionWrapper> pmOptions = new List<OptionWrapper>();
            List<String> addedPms = new List<String>();
            List<OptionWrapper> pickupOptions = new List<OptionWrapper>();
            List<String> addedPickups = new List<String>();
            List<OptionWrapper> deliveryOptions = new List<OptionWrapper>();
            List<String> addedDeliveries = new List<String>();
            List<OptionWrapper> orderOptions = new List<OptionWrapper>();
            List<String> addedOrders = new List<String>();
            List<OptionWrapper> locationOptions = new List<OptionWrapper>();
            List<String> addedLocations = new List<String>();
            List<OptionWrapper> commodityOptions = new List<OptionWrapper>();
            List<String> addedCommodities = new List<String>();
            pmOptions.add(new OptionWrapper('--ALL--', 'ALL'));
            pickupOptions.add(new OptionWrapper('--ALL--', 'ALL'));
            deliveryOptions.add(new OptionWrapper('--ALL--', 'ALL'));
            orderOptions.add(new OptionWrapper('--ALL--', 'ALL'));
            locationOptions.add(new OptionWrapper('--ALL--', 'ALL'));
            commodityOptions.add(new OptionWrapper('--ALL--', 'ALL'));

            for (Item__c item : this.items) {

                if (item.Pickup_Order__r.Project_Manager__r.Name != null) {
                    if (addedPms.contains(item.Pickup_Order__r.Project_Manager__r.Name) == false) {
                        addedPms.add(item.Pickup_Order__r.Project_Manager__r.Name);
                    }
                }
                if (item.Delivery_Order__r.Project_Manager__r.Name != null) {
                    if (addedPms.contains(item.Delivery_Order__r.Project_Manager__r.Name) == false) {
                        addedPms.add(item.Delivery_Order__r.Project_Manager__r.Name);
                    }
                }

                if (item.Load__r.FreightTM__Pickup_Ref__c != null) {
                    if (addedPickups.contains(item.Load__r.FreightTM__Pickup_Ref__c) == false) {
                        addedPickups.add(item.Load__r.FreightTM__Pickup_Ref__c);
                    }
                }

                if (item.Load__r.FreightTM__Delivery_Ref__c != null) {
                    if (addedDeliveries.contains(item.Load__r.FreightTM__Delivery_Ref__c) == false) {
                        addedDeliveries.add(item.Load__r.FreightTM__Delivery_Ref__c);
                    }
                }

                if (item.Pickup_Order__r.Purchase_Order_Number__c != null) {
                    if (addedOrders.contains(item.Pickup_Order__r.Purchase_Order_Number__c) == false) {
                        addedOrders.add(item.Pickup_Order__r.Purchase_Order_Number__c);
                    }
                }

                if (item.Delivery_Order__r.Purchase_Order_Number__c != null) {
                    if (addedOrders.contains(item.Delivery_Order__r.Purchase_Order_Number__c) == false) {
                        addedOrders.add(item.Delivery_Order__r.Purchase_Order_Number__c);
                    }
                }

                if (item.Load__r.Delivery_Address__c != null && item.Load__r.Delivery_Address__c != '') {
                    if (addedLocations.contains(item.Load__r.Delivery_Address__c) == false) {
                        addedLocations.add(item.Load__r.Delivery_Address__c);
                    }
                }

                if (item.Commodity__c != null) {
                    if (addedCommodities.contains(item.Commodity__c) == false) {
                        addedCommodities.add(item.Commodity__c);
                    }
                }
 
            }

            addedPms.sort();
            for (Integer i = 0; i < addedPms.size(); i++) {
                pmOptions.add(new OptionWrapper(addedPms[i], addedPms[i]));
            }

            addedPickups.sort();
            for (Integer i = 0; i < addedPickups.size(); i++) {
                pickupOptions.add(new OptionWrapper(addedPickups[i], addedPickups[i]));
            }

            addedDeliveries.sort();
            for (Integer i = 0; i < addedDeliveries.size(); i++) {
                deliveryOptions.add(new OptionWrapper(addedDeliveries[i], addedDeliveries[i]));
            }

            addedOrders.sort();
            for (Integer i = 0; i < addedOrders.size(); i++) {
                orderOptions.add(new OptionWrapper(addedOrders[i], addedOrders[i]));
            }
            
            addedLocations.sort();
            for (Integer i = 0; i < addedLocations.size(); i++) {
                locationOptions.add(new OptionWrapper(addedLocations[i], addedLocations[i]));
            }
            addedCommodities.sort();
            for (Integer i = 0; i < addedCommodities.size(); i++) {
                commodityOptions.add(new OptionWrapper(addedCommodities[i], addedCommodities[i]));
            }
            this.pmOptions = pmOptions;
            this.pickupOptions = pickupOptions;
            this.deliveryOptions = deliveryOptions;
            this.orderOptions = orderOptions;
            this.locationOptions = locationOptions;
            this.commodityOptions = commodityOptions;
        }




    }


    @AuraEnabled (cacheable=true)
    public static LoadReportWrapper fetchLoads(FilterWrapper filters) {
        System.debug('Accepting following filters from lwc: ');
        System.debug(filters);
        LoadReportWrapper loadReport = new LoadReportWrapper(filters);
        loadReport.fetchItems();
        loadReport.storeItemsForTable();
        loadReport.organizeOptions();

        System.debug('LOAD REPORT PREPARED');
        System.debug('LOAD REPORT: ');
        System.debug(loadReport);
        return loadReport;
    }

}