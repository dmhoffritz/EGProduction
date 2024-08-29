/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Ethan Myers
**/
global virtual without sharing class RateConSignatureV2 {
    
    // global FreightTM__Load__c loadRec {get; set;}
    global FreightTM__Load__c loadRec {get; set;}
    global FreightTM__Carrier__c carrierRec {get; set;}
    global list<FreightTM__Stop__c> stops{get;set;}
    global String commodity {get; set;}
    global String pickupSignature {get;set;}
    global String deliverySignature {get;set;}
    global Boolean isShowPickupSignature {get; set;}
    global Boolean isShowDeliverySignature {get; set;}
    global String carrierPrint {get;set;}
     global String msgs {get; set;}
    global Boolean msg {get; set;}
     global Double offset {get; set;}
    
    global RateConSignatureV2(ApexPages.StandardController stndCont) {
        
       
        
        
        // loadRec = (FreightTM__Load__c)stndCont.getRecord();
        loadRec = [select Id, Name, FreightTM__Status__c, FreightTM__Total_Miles__c, FreightTM__Total_Rate_to_Carrier__c,
                   FreightTM__Customer__r.Name, FreightTM__Customer__r.Phone,
                   FreightTM__Carrier_Obj__r.Name, FreightTM__Carrier_Obj__r.FreightTM__Primary_Contact__c, FreightTM__Carrier_Obj__r.FreightTM__Phone__c, FreightTM__Carrier_Obj__r.FreightTM__Email__c, 
                   Driver_Phone__c, Driver_Name__c, FreightTM__Driver__r.FreightTM__Phone__c,
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
                   FreightTM__Delivery_Ref__c, FreightTM__Delivery_Phone__c,
                   Delivery_Site_Contact__r.Name, Delivery_Phone__c, FreightTM__Delivery_Contact__c,
                   FreightTM__Delivery_Remarks__c,
                   FreightTM__Remarks__c,
                   Carrier_Signature__c, Reference_Number__c, RateCon_Signing_Date__c
                   from FreightTM__Load__c where Id =: apexpages.currentpage().getparameters().get('id')];

         stops = [select Id, Name,  FreightTM__Type__c, FreightTM__Arrival__c, FreightTM__Address__c, FreightTM__City__c, FreightTM__State__c, FreightTM__Zip_Code__c,
                   FreightTM__Country__c, FreightTM__Contact__c, FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Reference__c, FreightTM__SFacility__c, FreightTM__Load__c, FreightTM__Remarks__c 
                     FROM FreightTM__Stop__c 
                     where FreightTM__Load__r.Id =:ApexPages.currentPage().getParameters().get('id')];
        
        
        carrierRec = [select Id, Name,FreightTM__Primary_Contact__c 
                     FROM FreightTM__Carrier__c 
                     where Id =:loadRec.FreightTM__Carrier_Obj__c];   
        
        TimeZone tz = UserInfo.getTimeZone();
        
        offset = tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    

            pickupSignature = null;
            deliverySignature = null;
            // Add Pickup Signature Image
            if ((pickupSignature == null || pickupSignature == '') && (loadRec.Carrier_Signature__c != null && loadRec.Carrier_Signature__c != '')){ 
                
                String str = loadRec.Carrier_Signature__c;
                List<String> part = str.split('"');
                pickupSignature = part[1];
                isShowPickupSignature = true;
            }else{
                isShowPickupSignature = false;
            }
            
            // Add Delivery Signature Image
          /*  if ((deliverySignature == null || deliverySignature == '') && (loadRec.Dispatcher_Signature__c != null && loadRec.Dispatcher_Signature__c != '')){ 
                
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
    
    global PageReference Save2() {
        
        system.debug('Load Id ' + apexpages.currentpage().getparameters().get('id'));
        FreightTM__Load__c loadToSave = [SELECT Id, Name, Carrier_Signature__c, Driver_Name__c,
                                            Driver_Phone__c, Reference_Number__c, FreightTM__Status__c
                                            FROM FreightTM__Load__c 
                                            WHERE Id =: loadRec.Id];
        loadToSave.Driver_Name__c = loadRec.Driver_Name__c;
        loadToSave.Driver_Phone__c = loadRec.Driver_Phone__c;
        loadToSave.Reference_Number__c = loadRec.Reference_Number__c;

        
        
        if (loadRec.Carrier_Signature__c == null || loadRec.Carrier_Signature__c == ''){ 
            
            system.debug(pickupSignature);
            
            loadToSave.Carrier_Signature__c = '<img src="'+ pickupSignature +'">';
            loadToSave.RateCon_Signing_Date__c = Datetime.now();
            isShowPickupSignature = true;
        }else{
            loadToSave.Carrier_Signature__c = '';
        }
        
        /*if (deliverySignature != null && deliverySignature != ''){ 
            
            system.debug(deliverySignature);
            
            loadRec.Delivery_Signature__c = '<img src="'+ deliverySignature +'">';
            isShowDeliverySignature = true;
            
        }else{
            loadRec.Delivery_Signature__c = '';
        }*/
       carrierRec.FreightTM__Primary_Contact__c = loadRec.FreightTM__Carrier_Obj__r.FreightTM__Primary_Contact__c;
        
        if(loadToSave.FreightTM__Status__c != 'Delivered') {
            update loadToSave;
            update carrierRec;
            msgs = 'Success: Load has been updated.';
            msg = true;
        }

        
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