public virtual without sharing class driverPortal_Cont {
    public String recordId {get; set;}
    public FreightTM__Load__c load {get; set;}
    public String lat_long {get; set;} //variable to store tracked location data
    public driverPortal_Cont(ApexPages.StandardController stndCont) {
        recordId = ApexPages.currentPage().getParameters().get('id');
        load = [SELECT Id, Name, FreightTM__Status__c
                FROM FreightTM__Load__c
                WHERE Id =: recordId];
    }

    //method used to store records of coordinates generated on VF page
    public void storeCoordinates() {
        System.debug('Storing coordinates for load w/ ID: ' + recordId);
        System.debug(lat_long);

        String coord = lat_long;
        FreightTM__Site_Location__c coordsToStore = new FreightTM__Site_Location__c (FreightTM__Coordinates__latitude__s = double.valueof(coord.substringBefore(',')), 
                                                                                    FreightTM__Coordinates__longitude__s = double.valueof(coord.substringAfter(',')),
                                                                                    FreightTM__Load__c = recordId);
        System.debug('Site Location record to store: ');
        System.debug(coordsToStore);
        try {
            insert coordsToStore;
        } catch (DmlException e) {
            System.debug('The following exception occurred whenever inserting site location: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static FreightTM__Load__c getLoadData(String recordId){
        try {
            FreightTM__Load__c loadToReturn = [SELECT Id, Name, 
                                                FreightTM__Calendar_Load__c, FreightTM__Status__c,
                                                Dispatcher_Carrier__c, FreightTM__Dispatch__r.MobilePhone, FreightTM__Dispatch__r.Name,
                                                FreightTM__Remarks__c, Carrier_Phone__c,FreightTM__Carrier_Obj__r.Name,FreightTM__Carrier_Obj__r.Broker__c,
                                                Pickup_Signature__c, Driver_Name__c, Driver_Phone__c, Date__c,
                                                FreightTM__PickupFacility__r.Name,
                                                FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c, FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c,
                                                Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s,
                                                FreightTM__Pickup_Ref__c, Pickup_Ref_Job__c, FreightTM__Pickup_Remarks__c, Pickup_By__c,
                                                Shipper_Signature__c, FreightTM__Pickup_Contact__c, FreightTM__Pickup_Phone__c, Shipper_Date__c,
                                                FreightTM__DeliveryFacility__r.Name, 
                                                FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c, FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c,
                                                Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s,
                                                FreightTM__Delivery_Ref__c, Delivery_Ref_Job__c, FreightTM__Delivery_Remarks__c, Deliver_By__c,
                                                Receiver_Signature__c, FreightTM__Delivery_Contact__c, FreightTM__Delivery_Phone__c, Receiver_Date__c,
                                                Quantity__c, FreightTM__Commodity__c, Mat_Type_Picklist__c,
                                                (SELECT Id, Quantity__c, Commodity__c, Grade__c, Commodity_BOL__c, Notes__c FROM Items__r)
                                                FROM FreightTM__Load__c 
                                                WHERE Id =: recordId];
            return loadToReturn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateLoadStatus(String recordId, String status) {
        try {
            FreightTM__Load__c loadToSave = [SELECT Id, Name, FreightTM__Status__c
                                                FROM FreightTM__Load__c
                                                WHERE Id =: recordId];

            //void any updates that are requested when load is past update requested to be made.
            //if status is trying to be updated as arrived for pickup,
                //then we check for load's status to be any status latter to arrived for pickup
                //and return null if so
            //if load's status is marked as delivered, we will always return null

            if ((status == 'Arrived for pickup' && 
                    (loadToSave.FreightTM__Status__c == 'Loaded In Transit' ||
                    loadToSave.FreightTM__Status__c == 'Delayed') ||
                    loadToSave.FreightTM__Status__c == 'Arrived for delivery') || loadToSave.FreightTM__Status__c == 'Delivered') {
                        return;
                }


            loadToSave.FreightTM__Status__c = status;
            update loadToSave;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void uploadSignature(String recordId, String b64SignData, String signatureOwner){
        try {
            FreightTM__Load__c loadToSave = [SELECT Id, Name, FreightTM__Status__c,
                                              Pickup_Signature__c, Shipper_Signature__c, Receiver_Signature__c
                                              FROM FreightTM__Load__c
                                              WHERE Id =: recordId];
            if (loadToSave.FreightTM__Status__c == 'Delivered') {
                return;
            }
            if(signatureOwner == 'Driver') {
                loadToSave.Pickup_Signature__c = '<img src="' + b64SignData + '">';
                update loadToSave;
            } else if (signatureOwner == 'Pickup') {
                loadToSave.Shipper_Signature__c  = '<img src="' + b64SignData + '">';
                update loadToSave;
            } else if (signatureOwner == 'Delivery') {
                loadToSave.Receiver_Signature__c = '<img src="' + b64SignData + '">';
                update loadToSave;
            }

        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}