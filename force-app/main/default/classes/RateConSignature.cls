global virtual without sharing class RateConSignature {
    
    // global FreightTM__Load__c loadRec {get; set;}
    global FreightTM__Load__c loadRec {get; set;}
    global FreightTM__Carrier__c carrierRec {get; set;}
    global list<FreightTM__Stop__c> stops{get;set;}
    global String pickupSignature {get;set;}
    global String deliverySignature {get;set;}
    global Boolean isShowPickupSignature {get; set;}
    global Boolean isShowDeliverySignature {get; set;}
    global String carrierPrint {get;set;}
     global String msgs {get; set;}
    global Boolean msg {get; set;}
     global Double offset {get; set;}
    
    global RateConSignature(ApexPages.StandardController stndCont) {
        
       
        
        
        // loadRec = (FreightTM__Load__c)stndCont.getRecord();
        loadRec = [select Id, Name, FreightTM__Driver__c, Confirmation_Number__c,
                   FreightTM__Driver__r.Name, FreightTM__Driver__r.FreightTM__PIN__c, FreightTM__Calendar_Load__c, FreightTM__Driver__r.FreightTM__First_Name__c,
                   FreightTM__Carrier_Obj__r.Name, FreightTM__Carrier_Obj__r.FreightTM__Phone__c, FreightTM__Carrier_Obj__r.FreightTM__Fax__c, FreightTM__Carrier_Obj__r.FreightTM__Primary_Contact__c, FreightTM__Driver__r.FreightTM__Phone__c,
                   FreightTM__Confirmation_Number__c, FreightTM__Status__c, FreightTM__Load_Canceled__c, Quantity__c, FreightTM__Commodity__c, FreightTM__Driver__r.FreightTM__Email__c,
                   FreightTM__Distance__c, FreightTM__Remarks__c, FreightTM__Total_Miles__c, FreightTM__Driver_Remarks__c, FreightTM__Weight__c, FreightTM__Pickup_Email__c,
                   FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c, Mat_Type__c, Mat_Grade__c, FreightTM__Pickup_Contact__c, FreightTM__Pickup_Phone__c,
                   FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, FreightTM__Pickup_Arrival__c, FreightTM__Pickup_By_Appointment__c,FreightTM__Carrier_Obj__r.FreightTM__Email__c,
                   FreightTM__Pickup_Ref__c, FreightTM__Pickup_Remarks__c,  FreightTM__Delivery_Contact__c, FreightTM__Delivery_Phone__c, FreightTM__Delivery_Email__c, Carrier_Signature__c,
                   FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c, FreightTM__Rate_to_Carrier__c,Driver_Name__c,Driver_Phone__c,Reference_Number__c,
                   FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c, FreightTM__Delivery_Arrival__c, FreightTM__Delivery_By_Appointment__c,RateCon_Signing_Date__c,
                   FreightTM__Delivery_Ref__c, FreightTM__Delivery_Remarks__c, Pickup_Signature__c, Delivery_Signature__c
                   from FreightTM__Load__c where Id =: apexpages.currentpage().getparameters().get('id')];
        
        
         stops = [select Id, Name,  FreightTM__Type__c, FreightTM__Arrival__c, FreightTM__Address__c, FreightTM__City__c, FreightTM__State__c, FreightTM__Zip_Code__c,
                   FreightTM__Country__c, FreightTM__Contact__c, FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Remarks__c 
                     FROM FreightTM__Stop__c 
                     where FreightTM__Load__r.Id =:ApexPages.currentPage().getParameters().get('id')];
        
        
        carrierRec = [select Id, Name,FreightTM__Primary_Contact__c 
                     FROM FreightTM__Carrier__c 
                     where Id =:loadRec.FreightTM__Carrier_Obj__c];   
        
         TimeZone tz = UserInfo.getTimeZone();
        
        offset = tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        
            /*pickupSignature = null;
            deliverySignature = null;
            // Add Pickup Signature Image
            if ((pickupSignature == null || pickupSignature == '') && (loadRec.Dispatcher_Signature__c != null && loadRec.Dispatcher_Signature__c != '')){ 
                
                String str = loadRec.Dispatcher_Signature__c;
                List<String> part = str.split('"');
                pickupSignature = part[1];
                isShowPickupSignature = true;
            }else{
                isShowPickupSignature = false;
            }
            
            // Add Delivery Signature Image
            if ((deliverySignature == null || deliverySignature == '') && (loadRec.Dispatcher_Signature__c != null && loadRec.Dispatcher_Signature__c != '')){ 
                
                String str = loadRec.Dispatcher_Signature__c;
                List<String> part = str.split('"');
                deliverySignature = part[1];
                isShowDeliverySignature = true;
            }else{
                isShowDeliverySignature = false;
            }*/
        

        
        //List<FreightTM__Load__c> pickup = [Select Pickup_Signature__c From FreightTM__Load__c Where id = :loadRec.Id];
        //List<FreightTM__Load__c> delivery = [Select Delivery_Signature__c From FreightTM__Load__c Where id = :loadRec.Id];
        
        // Add Pickup Signature Image
        /*if ((pickup[0].Pickup_Signature__c != null && pickup[0].Pickup_Signature__c != '')){ 

String str = pickup[0].Pickup_Signature__c;
List<String> part = str.split('"');
pickupSignature = part[1];      
system.debug(pickupSignature);
}

// Add Delivery Signature Image
if ((delivery[0].Delivery_Signature__c != null && delivery[0].Delivery_Signature__c != '')){ 

String str = delivery[0].Delivery_Signature__c;
List<String> part = str.split('"');
deliverySignature = part[1];
}*/
    }
    
    global PageReference Save() {
        
        system.debug('Load Id ' + apexpages.currentpage().getparameters().get('id'));
        
        
        if (pickupSignature != null && pickupSignature != ''){ 
            
            system.debug(pickupSignature);
            
            loadRec.Carrier_Signature__c = '<img src="'+ pickupSignature +'">';
            isShowPickupSignature = true;
        }else{
            loadRec.Carrier_Signature__c = '';
        }
        
        /*if (deliverySignature != null && deliverySignature != ''){ 
            
            system.debug(deliverySignature);
            
            loadRec.Delivery_Signature__c = '<img src="'+ deliverySignature +'">';
            isShowDeliverySignature = true;
            
        }else{
            loadRec.Delivery_Signature__c = '';
        }*/
       carrierRec.FreightTM__Primary_Contact__c = loadRec.FreightTM__Carrier_Obj__r.FreightTM__Primary_Contact__c;
        
        update loadRec;
        update carrierRec;
       // update carrierRec;
            msgs = 'Success: Load has been updated.';
            msg = true;
        
        return null;
        
        
    }
    
    public PageReference  clearPickup() {
        
        isShowPickupSignature = false;
        pickupSignature = '';
        return null;
    }
    
    public PageReference  clearDelivery() {
        
        isShowDeliverySignature = false;
        deliverySignature = '';    
        return null;
    }
}