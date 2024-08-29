/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-24-2023
 * @last modified by  : Ethan Myers
**/
public with sharing class ItemController {

    public class LoadItemData {
        @AuraEnabled
        public FreightTM__Load__c load {get; set;}

        @AuraEnabled
        public List<Item__c> items {get; set;}

        @AuraEnabled
        public List<OptionWrapper> commodityOptions {get; set;}

        @AuraEnabled
        public User usr {get; set;}

        public LoadItemData() {
            this.usr = [SELECT Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
            this.load = new FreightTM__Load__c();
            this.items = new List<Item__c>();
            this.commodityOptions = new List<OptionWrapper>();
        }
    }


    @AuraEnabled
    public static LoadItemData getItems(String loadId) {
        System.debug('Getting item data for load w/ ID: ' + loadId);
        LoadItemData itemData = new LoadItemData();
        itemData.load = [SELECT Id, Name, RecordType.DeveloperName, RecordType.Name, Pickup_Ref_Job__c, Delivery_Ref_Job__c, Invoiced_Item_Count__c, NumberofItems__c FROM FreightTM__Load__c WHERE Id =: loadId];
        itemData.items = [SELECT Id, Commodity__c, Load__c, 
                            Quantity__c, Grade__c, Graded__c,
                            Ungraded__c, New__c, A_Four__c, A_Three__c, B_Two__c, B_One__c, Cull__c, 
                            Delivery_Order__c, Delivery_Item__c, Pickup_Order__c, Pickup_Item__c, 
                            Equipment__c, Product__c,
                            PM_Approved_On__c, PM_Approved__c, PM_Approver__c, Moved_in_QB__c, 
                            Rejected_By__c, Rejected_On__c, Rejected__c, Rejection_Comments__c, TriggerRollup__c,
                            Notes__c, 
                            Mat_Invoice__c,
                            LoadStatus__c, ReceiverDate_DLRS__c 
                            FROM Item__c WHERE Load__c =: loadId];
        itemData.commodityOptions = getCommodityOptions(itemData.load);

        System.debug('Returning following load: ');
        System.debug(itemData.load);
        System.debug('Returning following items: ');
        System.debug(itemData.items);
        System.debug('Returning following commodity options: ');
        System.debug(itemData.commodityOptions);

        return itemData;
    }


    public class OptionWrapper {
        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        @AuraEnabled
        public String pickupOrder {get; set;}

        @AuraEnabled
        public String pickupItem {get; set;}

        @AuraEnabled
        public String deliveryOrder {get; set;}

        @AuraEnabled
        public String deliveryItem {get; set;}

        public OptionWrapper() {
            this.label = null;
            this.value = null;
            this.pickupOrder = null;
            this.pickupItem = null;
            this.deliveryOrder = null;
            this.deliveryItem = null;
        }

        public OptionWrapper(String label, String value, String pickupOrder, String pickupItem, String deliveryOrder, String deliveryItem) {
            this.label = label;
            this.value = value;
            this.pickupOrder = pickupOrder;
            this.pickupItem = pickupItem;
            this.deliveryOrder = deliveryOrder;
            this.deliveryItem = deliveryItem;
        }
    }

    public class ItemOptionWrapper {
        public String orderId {get; set;}
        public String itemId {get; set;}

        public ItemOptionWrapper() {
            this.orderId = null;
            this.itemId = null;
        }

        public ItemOptionWrapper(Id orderId, Id itemId) {
            this.orderId = String.valueOf(orderId);
            this.itemId = String.valueOf(itemId);
        }
    }

    public static List<OptionWrapper> getCommodityOptions(FreightTM__Load__c load) {
        System.debug('Fetching commodity options for the following load: ');
        System.debug(load);
        List<OptionWrapper> options = new List<OptionWrapper>();

        //determine if function needs to filter by equipment or mats by evaluating load's record type
        String productFamilyFilter = evaluateLoadRecordType(load);

        //load is moving from one job to another job...enforce commodity options to be on both ends
        if (load.Delivery_Ref_Job__c != null && load.Pickup_Ref_Job__c != null) {
            System.debug('Noticing that load is picking up and delivering into a job. Querying related sales order line items on both sides...');
            List<WorkOrderLineItem> pickupItems = [SELECT Id, WorkOrderId, Commodity__c FROM WorkOrderLineItem WHERE Job__c =: load.Pickup_Ref_Job__c AND Product_Family__c =: productFamilyFilter];
            List<WorkOrderLineItem> deliveryItems = [SELECT Id,  WorkOrderId, Commodity__c FROM WorkOrderLineItem WHERE Job__c =: load.Delivery_Ref_Job__c AND Product_Family__c =: productFamilyFilter];

            //map pickup commodities with their respective line item id
            pickupItems = returnUniqueItems(pickupItems);
            Map<String, ItemOptionWrapper> pickupCommodities = new Map<String, ItemOptionWrapper>();
            for (WorkOrderLineItem item : pickupItems) {
                pickupCommodities.put(item.Commodity__c, new ItemOptionWrapper(item.WorkOrderId, item.Id));
            }
            //map delivery commdoities with their respective line item id
            deliveryItems = returnUniqueItems(deliveryItems);
            Map<String, ItemOptionWrapper> deliveryCommodities = new Map<String, ItemOptionWrapper>();
            for (WorkOrderLineItem item : deliveryItems) {
                deliveryCommodities.put(item.Commodity__c, new ItemOptionWrapper(item.WorkOrderId, item.Id));
            }

            //loop larger line item set to ensure all items get scanned
            if (pickupItems.size() > deliveryItems.size()) {
                for (WorkOrderLineItem pickupItem : pickupItems) {
                    if (deliveryCommodities.containsKey(pickupItem.Commodity__c)) {
                        ItemOptionWrapper itemOpt = deliveryCommodities.get(pickupItem.Commodity__c);
                        options.add(new OptionWrapper(pickupItem.Commodity__c, pickupItem.Commodity__c, pickupItem.WorkOrderId, pickupItem.Id, itemOpt.orderId, itemOpt.itemId)); //add option for picklist, storing order + line item ids for reference
                    }
                }
            } else {
                for (WorkOrderLineItem deliveryItem : deliveryItems) {
                    if (pickupCommodities.containsKey(deliveryItem.Commodity__c)) {
                        ItemOptionWrapper itemOpt = pickupCommodities.get(deliveryItem.Commodity__c);
                        options.add(new OptionWrapper(deliveryItem.Commodity__c, deliveryItem.Commodity__c, itemOpt.orderId, itemOpt.itemId, deliveryItem.WorkOrderId, deliveryItem.Id)); //add option for picklist, storing order + line item ids for reference
                    }
                }
            }
        } else if (load.Delivery_Ref_Job__c != null) {  //check for if load is moving into job    
            System.debug('Noticing that load is delivering into job. Querying related Sales Order Line Items...');      
            List<WorkOrderLineItem> items = [SELECT Id, WorkOrderId, Commodity__c FROM WorkOrderLineItem WHERE Job__c =: load.Delivery_Ref_Job__c AND Product_Family__c =: productFamilyFilter]; //store mat items related to delivery job
            items = returnUniqueItems(items); //cleanse item list to ensure only one of each commodity displays
            for (WorkOrderLineItem item : items) {
                options.add(new OptionWrapper(item.Commodity__c, item.Commodity__c, null, null, item.WorkOrderId, item.Id)); //add option for picklist, storing order + line item ids for reference
            }

        } else if (load.Pickup_Ref_Job__c != null) { // check if load is picking up from job
            System.debug('Noticing that load is picking up from job. Querying related Sales Order Line Items...');      
            List<WorkOrderLineItem> items = [SELECT Id, WorkOrderId, Commodity__c FROM WorkOrderLineItem WHERE Job__c =: load.Pickup_Ref_Job__c AND Product_Family__c =: productFamilyFilter]; //store mat items related to delivery job
            items = returnUniqueItems(items); //cleanse item list to ensure only one of each commodity displays
            for (WorkOrderLineItem item : items) {
                options.add(new OptionWrapper(item.Commodity__c, item.Commodity__c, item.WorkOrderId, item.Id, null, null));
            }
        } else {
            //no jobs to reference to pull in line item data
            System.debug('No jobs referenced...');
        }
        //options.add(new OptionWrapper('Other', 'Other', null, null, null, null));

        System.debug('Outputting following options: ');
        System.debug(options);

        return options;

    }

    //method used to return 'Equipment' if load is of type Equipment and 'Mat Sales' if not
    public static String evaluateLoadRecordType(FreightTM__Load__c load) {
        if (load.RecordType.Name == 'Equipment') {
            return 'Equipment';
        } else {
            return 'Mat Sales';
        }
    }

    //method used to return single reference for each unique commodity in list of sales order line items
    public static List<WorkOrderLineItem> returnUniqueItems(List<WorkOrderLineItem> items) {
        List<WorkOrderLineItem> returnItems = new List<WorkOrderLineItem>();
        List<String> commodities = new List<String>();
        for (WorkOrderLineItem item : items) {
            if (!commodities.contains(item.Commodity__c)) {
                commodities.add(item.Commodity__c);
                returnItems.add(item);
            }
        }
        return returnItems;
    }

    @AuraEnabled
    public static Item__c updateItem(Item__c item) {
        try {
            System.debug('Updating the following load item: ');
            System.debug(item);
            upsert item;
            return [SELECT Id, Commodity__c FROM Item__c WHERE Id =: item.Id];
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating item\'s commodity: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteItem(Item__c item) {
        try {
            System.debug('Deleting the following load item: ');
            System.debug(item);
            delete item;
        } catch (DmlException e) {
            throw new AuraHandledException('Error deleting item: ' + e.getMessage());
        }
    }
    
    /*
    

    public class FlowInputs {
        @InvocableVariable (label='Job Id' description='Id of job updated on load')
        public String jobId;

        @InvocableVariable (label='Load Id' description='Id of load updated. Used to fetch items.')
        public String loadId;

        @InvocableVariable (label = 'Pickup?' description='Check box if load\'s pickup job reference was updated')
        public Boolean pickup;

        @InvocableVariable (label = 'Delivery?' description='Check box if load\'s delivery job reference was updated')
        public Boolean delivery;
    }

    public class FlowOutputs {
        @InvocableVariable (label='Error?' description='Outputs true if there was issue adjusting commodities')
        public Boolean error;

        @InvocableVariable (label='Error Message' description='Message describing why error occurred. Either system or missing info.')
        public String errorMessage;

        public FlowOutputs() {
            this.error = false;
            this.errorMessage = '';
        }
    } 

    @InvocableMethod(label='Load Job Update: Apply New SOLI Ref to Commodities' description='Whenever job references update on load. This method will take the updated job reference (pickup or delivery) and apply respective SOLI references to commodity item(s) if found. Method will return a boolean to note whether new items were found or not')
    public static List<FlowOutputs> updateCommodityReferences(List<FlowInputs> inputs) {
        System.debug('Noticing load job ref update...adjusting load item SOLI references');
        //start by gathering flow inputs
        String jobId = '';
        String loadId = '';
        Boolean pickup = false;
        Boolean delivery = false;
        for (FlowInputs input : inputs) {
            jobId = input.jobId;
            loadId = input.loadId;
            pickup = input.pickup;
            delivery = input.delivery;
        }

        //fetch related load record
        FreightTM__Load__c load = [SELECT Id, Name, Pickup_Ref_Job__c, Delivery_Ref_Job__c 
                                    FROM FreightTM__Load__c
                                    WHERE Id =: loadId];

        System.debug('Updating following load: ');
        System.debug(load);
        List<Item__c> itemsToUpdate = new List<Item__c>();
        Boolean error;
        String errorMessage;
        //loop all commodity items to update their order references
        for (Item__c item : [SELECT Id, Name, Commodity__c, Load__c, Pickup_Order__c, Pickup_Item__c, Delivery_Order__c, Delivery_Item__c FROM Item__c WHERE Load__c =: loadId]) {
            if (pickup == true) {
                System.debug('Pickup ref noted as updated...');
                //check if picup job is empty...if so, null out pickup fields
                if (jobId == null || jobId == '') {
                    System.debug('Ref updated as empty/null value...nulling out pickup order and item on load item');
                    item.Pickup_Order__c = null;
                    item.Pickup_Item__c = null;
                    itemsToUpdate.add(item);
                    continue; //jump to next loop
                }
                //fetch all sales order line items related to pickup job
                try {
                    WorkOrderLineItem pickupItem = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE Job__c =: jobId AND Commodity__c =: item.Commodity__c];
                    System.debug('Found the following pickup item from updated pickup job:');
                    System.debug(pickupItem);
                    item.Pickup_Order__c = pickupItem.WorkOrderId;
                    item.Pickup_Item__c = pickupItem.Id;
                } catch (QueryException e) {
                    System.debug('No matching commodities found on pickup job...');
                    error = true;
                    errorMessage = 'Unable to update commodity\'s pickup reference. No matching commodities found on pickup job.';
                    item.Pickup_Order__c = null;
                    item.Pickup_Item__c = null;
                }
                itemsToUpdate.add(item);

            }

            if (delivery == true) {
                System.debug('Delivery ref noted as updated...');
                //check if delivery job is empty...if so, null out delivery fields
                if (jobId == null || jobId == '') {
                    System.debug('Ref updated as empty/null value...nulling out delivery order and item on load item');
                    item.Delivery_Order__c = null;
                    item.Delivery_Item__c = null;
                    itemsToUpdate.add(item);
                    continue; //jump to next loop
                }
                //fetch all sales order line items related to delivery job
                try {
                    WorkOrderLineItem deliveryItem = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE Job__c =: jobId AND Commodity__c =: item.Commodity__c];
                    System.debug('Found the following delivery item from updated delivery job:');
                    System.debug(deliveryItem);
                    item.Delivery_Order__c = deliveryItem.WorkOrderId;
                    item.Delivery_Item__c = deliveryItem.Id;
                } catch (QueryException e) {
                    System.debug('No matching commodities found on delivery job...');
                    error = true;
                    errorMessage = 'Unable to update commodity\'s delivery reference. No matching commodities found on delivery job.';
                    item.Delivery_Order__c = null;
                    item.Delivery_Item__c = null;
                }
                itemsToUpdate.add(item);

            }
        }

        try {
            update itemsToUpdate;
        } catch(DmlException e) {
            error = true;
            errorMessage = 'System error whenever updating items: ' + e.getMessage();
        }

        List<FlowOutputs> outputs = new List<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
        output.error = error;
        output.errorMessage = errorMessage;

        return outputs;
    }
*/

}