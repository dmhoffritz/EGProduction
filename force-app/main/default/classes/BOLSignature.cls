/* ***********************************************************
Name        : BOLSignature
Author      : ASUCCINI LLC.               
*********************************************************** */

global virtual without sharing class BOLSignature {

    public BOLSignature(ApexPages.StandardSetController controller) {

    }

    
    global FreightTM__Load__c loadRec {get; set;}
    global list<FreightTM__Stop__c> stops{get;set;}
    global Boolean showItems {get; set;} //variable used to let page know whether it needs to display old commodity fields or updated load item list
    global String pickupContact {get; set;}
    global String pickupSignature {get;set;}
    global String deliveryContact {get; set;}
    global String deliverySignature {get;set;}
    global String DriverSignature {get;set;}
    global Boolean isShowPickupSignature {get; set;}
    global Boolean isShowDeliverySignature {get; set;}
    global Boolean isShowDriverSignature {get; set;}
    global String msgs {get; set;}
    global Boolean msg {get; set;}
    global Double offset {get; set;}
    global String splitShipperSignature {get; set;}
    global String splitDriverSignature {get; set;}
    global String splitReceiverSignature {get; set;}

    
    global BOLSignature(ApexPages.StandardController stndCont) {
        TimeZone tz = UserInfo.getTimeZone(); //set timezone relative to user context
        offset = tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);

        String loadId = ApexPages.CurrentPage().getParameters().get('id'); //reference to loadid passed through URL parameter
        queryLoadRecord(loadId);

        organizeSignatures();

        organizeContacts();

    }


    /*
        SALES ORDER COMMODITY UPDATE (WINTER 2022): 
        Prior to Sales Order release, all commodity data 
        was stored as open-box fields on load record...
        Post Sales Order release, all commodity data
        is stored as related list of item records to 
        properly define qty, commodity, and grades of 
        each item hauled on load...
        The following script is used to bind historical data 
        with new data...
        We do so by identifying whether load has related items.
        If so, we will display items in list on BOL.
        If not, we will display legacy commodity fields to 
        maintain integrity with previous BOL forms.
    */

    //method used to query load data relative to BOL being referenced
    global void queryLoadRecord(String recordId) {
        //query load and populate record data in global loadRec resource variable
        loadRec = [select Id, Name, FreightTM__Status__c, FreightTM__Total_Miles__c,
                   FreightTM__Customer__r.Name, FreightTM__Customer__r.Phone,
                   FreightTM__Carrier_Obj__r.Name, FreightTM__Carrier_Obj__r.FreightTM__Phone__c, FreightTM__Carrier_Obj__r.FreightTM__Email__c, 
                   Driver_Phone__c, Driver_Name__c, 
                   (SELECT Id, Quantity__c, Commodity__c, Grade__c, Commodity_BOL__c, Notes__c FROM Items__r),
                   Quantity__c, Mat_Grade_Conversion__c, FreightTM__Weight__c, FreightTM__Requirements__c, 
                   Pickup_By__c, 
                   FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c, 
                   FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, 
                   Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s,
                   FreightTM__Pickup_Ref__c, 
                   Pickup_Site_Contact__r.Name, Pickup_Phone__c, FreightTM__Pickup_Contact__c, 
                   FreightTM__Pickup_Remarks__c, FreightTM__Pickup_Phone__c,
                   Deliver_By__c,
                   FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c,
                   FreightTM__Delivery_Zip_Code__c,FreightTM__Delivery_Country__c,
                   Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s,
                   FreightTM__Delivery_Ref__c, 
                   Delivery_Site_Contact__r.Name, Delivery_Phone__c, FreightTM__Delivery_Contact__c,
                   FreightTM__Delivery_Remarks__c,FreightTM__Delivery_Phone__c,
                   FreightTM__Remarks__c,
                   Pickup_Signature__c, Date__c,
                   Shipper_Signature__c, Shipper_Date__c,
                   Receiver_Signature__c, Receiver_Date__c, 
                   Delivery_Signature__c
                   from FreightTM__Load__c where Id =: recordId];
        
        
            
        //identify any stops included in load haul
        stops = [select Id, Name,  FreightTM__Type__c, FreightTM__Arrival__c, FreightTM__Address__c, FreightTM__City__c, FreightTM__State__c, FreightTM__Zip_Code__c,
                 FreightTM__Country__c, FreightTM__Contact__c, FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Remarks__c, FreightTM__Reference__c 
                 FROM FreightTM__Stop__c 
                 where FreightTM__Load__r.Id =: recordId];

    }

    //use queried load record to organize signature pad fields
    global void organizeSignatures() {
        if(loadRec.Shipper_Signature__c != null) {
            splitShipperSignature = loadRec.Shipper_Signature__c;
            if(splitShipperSignature.contains('<p>')) {
                List<String> split_shipper1 = splitShipperSignature.split(';">');
                List<String> split_shipper2 = split_shipper1[1].split('</span>');
                loadRec.Shipper_Signature__c = split_shipper2[0];
                splitShipperSignature = split_shipper2[0];
            }
        }
        
        if(loadRec.Pickup_Signature__c != null) {
            splitDriverSignature = loadRec.Pickup_Signature__c;
            if(splitDriverSignature.contains('<p>')) {
                List<String> split_driver1 = splitDriverSignature.split(';">');
                List<String> split_driver2 = split_driver1[1].split('</span>');
                loadRec.Pickup_Signature__c = split_driver2[0];
                splitDriverSignature = split_driver2[0];
            }
        }
        
        if(loadRec.Receiver_Signature__c != null) {
            splitReceiverSignature = loadRec.Receiver_Signature__c;
            if(splitReceiverSignature.contains('<p>')) {
                List<String> split_receiver1 = splitReceiverSignature.split(';">');
                List<String> split_receiver2 = split_receiver1[1].split('</span>');
                loadRec.Receiver_Signature__c = split_receiver2[0];
                splitReceiverSignature = split_receiver2[0];
            }
        }
        
        pickupSignature = null;
        deliverySignature = null;
        DriverSignature = null;
        // Add Pickup Signature Image
        if ((pickupSignature == null || pickupSignature == '') && (loadRec.Shipper_Signature__c != null && loadRec.Shipper_Signature__c != '')){ 
            
            String str = loadRec.Shipper_Signature__c;
            List<String> part = str.split('"');
            if(part.size() > 1){
            pickupSignature = part[1];
            isShowPickupSignature = true;
                }
        }else{
            isShowPickupSignature = false;
        }
        
        // Add Driver Signature Image
        if ((DriverSignature == null || DriverSignature == '') && (loadRec.Pickup_Signature__c != null && loadRec.Pickup_Signature__c != '')){ 
            
            String str = loadRec.Pickup_Signature__c;
            List<String> part = str.split('"');
             if(part.size() > 1){
            DriverSignature = part[1];
            isShowDriverSignature = true;
             }
        }else{
            isShowDriverSignature = false;
        }
        

        // Add Delivery Signature Image
        if ((deliverySignature == null || deliverySignature == '') && (loadRec.Receiver_Signature__c != null && loadRec.Receiver_Signature__c != '')){ 
            
            String str = loadRec.Receiver_Signature__c;
            List<String> part = str.split('"');
             if(part.size() > 1){
            deliverySignature = part[1];
            isShowDeliverySignature = true;
             }
        }else{
            isShowDeliverySignature = false;
        }


    }

    //method used to properly reference pickup / delivery contact info
    global void organizeContacts() {
        if (loadRec.FreightTM__Pickup_Contact__c != null) {
            pickupContact = loadRec.FreightTM__Pickup_Contact__c;
        } else {
            pickupContact = loadRec.Pickup_Site_Contact__r.Name;
        }

        if (loadRec.FreightTM__Delivery_Contact__c != null) {
            deliveryContact = loadRec.FreightTM__Delivery_Contact__c;
        } else {
            deliveryContact = loadRec.Delivery_Site_Contact__r.Name;
        }
    }
    
    //method called out from page to store signatures filled out from form
    global PageReference Save2() {
        
        system.debug('Load Id ' + apexpages.currentpage().getparameters().get('id'));
        FreightTM__Load__c loadToUpdate = new FreightTM__Load__c(Id = apexpages.currentpage().getparameters().get('id'));
        
        if (pickupSignature != null && pickupSignature != ''){ 
            
            system.debug(pickupSignature);
            
            loadToUpdate.Shipper_Signature__c = '<img src="'+ pickupSignature +'">';
            isShowPickupSignature = true;
        }else{
         //   loadRec.Shipper_Signature__c = '';
        }
        
        if (DriverSignature != null && DriverSignature != ''){ 
            
            system.debug(DriverSignature);
            
            loadToUpdate.Pickup_Signature__c = '<img src="'+ DriverSignature +'">';
            isShowDriverSignature = true;
        }else{
         //   loadRec.Pickup_Signature__c = '';
        }
        
        
        
        
        if (deliverySignature != null && deliverySignature != ''){ 
            
            system.debug(deliverySignature);
            
            loadToUpdate.Receiver_Signature__c = '<img src="'+ deliverySignature +'">';
            isShowDeliverySignature = true;
            
        }else{
        //    loadRec.Receiver_Signature__c = '';
        }

        if (pickupContact != null && pickupContact != '') {
            system.debug('Updating pickup contact for load: ' + loadRec.Name);
            loadToUpdate.FreightTM__Pickup_Contact__c = pickupContact;
        } 

        if (deliveryContact != null && deliveryContact != '') {
            system.debug('Updating delivery contact for load: ' + loadRec.Name);
            loadToUpdate.FreightTM__Delivery_Contact__c = deliveryContact;
        }
        update loadToUpdate;
        
         msgs = 'Success: Load has been updated.';
            msg = true;
        
        return null;
        
        
    }
    
    global PageReference  clearPickup() {
        
        isShowPickupSignature = false;
        pickupSignature = '';
        return null;
    }
    
    global PageReference  clearDriverSign() {
        
        isShowDriverSignature = false;
        DriverSignature = '';
        return null;
    }
    
    global PageReference  clearDelivery() {
        
        isShowDeliverySignature = false;
        deliverySignature = '';    
        return null;
    }
    
    

}