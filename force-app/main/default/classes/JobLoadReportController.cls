/**
 * @description       : Controller used to handle load / item query from AR reporting component.
 * @author            : Ethan Myers
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Ethan Myers
**/
public with sharing class JobLoadReportController {
    public JobLoadReportController() {

    }

    //used to organize load filters available from lwc
    public with sharing class FilterWrapper {

        @AuraEnabled
        public String jobId {get; set;}

        @AuraEnabled
        public Boolean showPickups {get; set;}

        @AuraEnabled
        public Boolean showDeliveries {get; set;}

        @AuraEnabled
        public String status {get; set;}

        @AuraEnabled
        public Date startDate {get; set;}

        @AuraEnabled
        public Date endDate {get; set;}


        public FilterWrapper() {
            this.jobId = null;
            this.showPickups = false;
            this.showDeliveries = false;
            this.status = '';
            this.startDate = null;
            this.endDate = null;
        }

        public FilterWrapper(String jobId, Boolean showPickups, Boolean showDeliveries, String status, Date startDate, Date endDate) {
            this.jobId = jobId;
            this.showPickups = showPickups;
            this.showDeliveries = showDeliveries;
            this.status = status;
            this.startDate = startDate;
            this.endDate = endDate;

        }
    }

    //object to store picklist values for customer and job picklists
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

    //wrapper classed used to display relational data within lightning-datatable component
    public with sharing class ItemForTable {
        @AuraEnabled
        public String loadId {get; set;}
        @AuraEnabled
        public String loadLink {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String loadNumber {get; set;}
        @AuraEnabled
        public String freightLane {get; set;}
        @AuraEnabled
        public Decimal quantity {get; set;}
        @AuraEnabled
        public String commodity {get; set;}
        @AuraEnabled
        public String grade {get; set;}
        @AuraEnabled
        public String sellType {get; set;}
        @AuraEnabled
        public String carrier {get; set;}
        @AuraEnabled
        public Decimal rateToCarrier {get; set;}
        @AuraEnabled
        public Decimal distance {get; set;}
        @AuraEnabled
        public Date receiverDate {get; set;}    
        @AuraEnabled
        public String invoiceNumber {get; set;}

        public ItemForTable (FreightTM__Load__c load) {
            this.loadId = load.Id;
            this.loadLink = load.Record_Link__c;
            this.status = load.FreightTM__Status__c;
            this.loadNumber = load.Name;
            this.freightLane = load.FreightTM__Calendar_Load__c;
            if (load.Qty__c == 0 || load.Qty__c == null) {
                this.quantity = load.Quantity__c;
            } else {
                this.quantity = load.Qty__c;
            }
            this.commodity = load.FreightTM__Commodity__c;
            this.carrier = load.FreightTM__Carrier_Obj__r.Name;
            if (load.FreightTM__Total_Rate_to_Carrier__c != null) {
                this.rateToCarrier = load.FreightTM__Total_Rate_to_Carrier__c;
            } else {
                this.rateToCarrier = 0.0;
            }
            if (load.FreightTM__Distance__c != null) {
                this.distance = load.FreightTM__Distance__c;
            } else {
                this.distance = 0.0;
            }
            this.receiverDate = Date.valueOf(load.Receiver_Date__c);
            this.invoiceNumber = '';
            for (Integer i = 0; i < load.Items__r.size(); i++) {
                if (load.Items__r[i].Mat_Invoice__c != null && load.Items__r[i].Mat_Invoice__c != '') {
                    this.invoiceNumber = load.Items__r[i].Mat_Invoice__c;
                }
            }
            

        }
    }

    //organizes load data + splits up customer and job options per query
    public with sharing class LoadReportWrapper {
        @AuraEnabled
        public List<FreightTM__Load__c> loads {get; set;}
        @AuraEnabled
        public List<ItemForTable> itemsForTable {get; set;}

        FilterWrapper filters {get; set;}

        public LoadReportWrapper(FilterWrapper filters) {
            System.debug('Initializing Load Report Wrapper class...');
            this.loads = new List<FreightTM__Load__c>();
            this.filters = filters;
        }

        public void fetchItems() {
            System.debug('Fetching items for Load Report Wrapper...');
            FilterWrapper tempFilters = this.filters;
            System.debug('Applying the following filters: ');
            System.debug(tempFilters);
            String query = 'SELECT Id, Name,';
            query += 'Receiver_Date__c, FreightTM__Calendar_Load__c,FreightTM__Status__c,Record_Link__c,';
            query += 'Qty__c, FreightTM__Commodity__c,Quantity__c,';
            query += 'FreightTM__Carrier_Obj__r.Name, FreightTM__Total_Rate_to_Carrier__c,FreightTM__Distance__c,';
            query += 'Delivery_Ref_Job__c, Pickup_Ref_Job__c, ';
            query += '(SELECT Id, Name, Quantity__c, Commodity__c,';
            query += 'Mat_Invoice__c, Mat_Invoice_Date__c, Unit_Price__c, Subtotal__c, Sell_Type__c ';
            query += 'FROM Items__r) ';
            query += 'FROM FreightTM__Load__c WHERE Load_Template__c = false AND FreightTM__Status__c !=\'' + String.escapeSingleQuotes('Canceled') + '\''; 

            //Apply filter depending on which load list is being referenced
            if (tempFilters.showDeliveries == true && tempFilters.jobId != null) {
                query += ' AND Delivery_Ref_Job__c = \'' + String.escapeSingleQuotes(tempFilters.jobId) + '\'';
            } 
            if (tempFilters.showPickups == true && tempFilters.jobId != null) {
                query += ' AND Pickup_Ref_Job__c = \'' + String.escapeSingleQuotes(tempFilters.jobId) + '\'';
            }
            
            String statusFilter = '';
            String dateFilter = '';
            if (tempFilters.startDate != null) {
                Integer day = tempFilters.startDate.day();
                Integer month = tempFilters.startDate.month();
                Integer yr = tempFilters.startDate.year();
                Datetime startTime = DateTime.newInstance(yr, month, day, 01, 01, 01);
                String startDate = startTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                System.debug('Applying following start date to filter: ' + startDate);
                query += ' AND Receiver_Date__c > ' + startDate;
            }

            if (tempFilters.endDate != null) {
                Integer day = tempFilters.endDate.day();
                Integer month = tempFilters.endDate.month();
                Integer yr = tempFilters.endDate.year();
                Datetime endTime = DateTime.newInstance(yr, month, day, 23, 59, 59);
                String endDate = endTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                System.debug('Applying following end date to filter: ' + endDate);
                query += ' AND Receiver_Date__c < ' + endDate;
            }

            try {
                if (tempFilters.status != null && tempFilters.status != '' && tempFilters.status != 'ALL') {
                    if (tempFilters.status == 'In Route') {
                        statusFilter = ' AND (FreightTM__Status__c = \'Arrived for pickup\' OR FreightTM__Status__c = \'Loaded In Transit\' OR FreightTM__Status__c = \'Delayed\' OR FreightTM__Status__c = \'Arrived for delivery\')';
                    } else {
                        statusFilter = ' AND FreightTM__Status__c = \'' + String.escapeSingleQuotes(tempFilters.status) + '\'';
                    }
                    System.debug('Applying following status filter: ' + statusFilter);
                    query += statusFilter;
                }

                query += ' ORDER BY FreightTM__Status__c ASC, Receiver_Date__c ASC NULLS LAST, Name ASC';
                System.debug('Finalized Query: ');
                System.debug(query);
                this.loads = Database.query(query);
                System.debug('Load Results: ');
                System.debug(this.loads);

            } catch (Exception e) {
                System.debug('Unable to query loads for AR report...Exception: ' + e.getMessage());
            }
        }

        public void storeItemsForTable() {
            List<ItemForTable> itemsForTable = new List<ItemForTable>();
            for (FreightTM__Load__c load : this.loads) {
                ItemForTable i = new ItemForTable(load);
                itemsForTable.add(i);
            }
            this.itemsForTable = itemsForTable;
        }

        public void organizeOptions() {

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


    @AuraEnabled (cacheable=true)
    public static List<FreightTM__Load__c> fetchTemplates(String jobId) {
        System.debug('Querying load templates for job w/ ID: ' + jobId);
        try {
            return [SELECT Id, Name, Record_Link__c,
                        FreightTM__Calendar_Load__c, Qty__c, FreightTM__Commodity__c, 
                        Pickup_By__c, Deliver_By__c
                        FROM FreightTM__Load__c
                        WHERE (Delivery_Ref_Job__c =: jobId OR Pickup_Ref_Job__c =: jobId) AND Load_Template__c = true AND CreatedDate > 2023-03-05T23:01:01+01:00
                        ORDER BY CreatedDate ASC, Name ASC]; //fetch all templates related to job created after sales order release (Mar. 5, 2023)
        } catch (QueryException e) {
            System.debug('Error fetching load templates: ' + e.getMessage());
            throw new AuraHandledException('Error fetching load templates: ' + e.getMessage());
        }
    }

}