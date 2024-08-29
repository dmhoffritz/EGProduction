/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Ethan Myers
**/
public without sharing class LoadsBatchMill_V2 {
    public List<FreightTM__Load__c> loadList {get;set;}
    public List<Item__c> allItems {get; set;}
    public List<FreightTM__Trip__c> curr_job {get; set;}
    private ApexPages.StandardSetController standardController;
    private List<String> loadIds = new List<String>();
    public list<FreightTM__Load__c> loadRec {get; set;}
    public list<FreightTM__Stop__c> stops{get;set;}
    public String pickupSignature {get;set;}
    public list<String> deliverySignature {get;set;}
    public list<String> DriverSignature {get;set;}
    public Boolean isShowPickupSignature {get; set;}
    public Boolean isShowDeliverySignature {get; set;}
    public Boolean isShowDriverSignature {get; set;}
    public Double offset {get; set;}
    public String fullURL {get; set;}



    public LoadsBatchMill_V2(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
        loadList = new List<FreightTM__Load__c>();
        for (FreightTM__Load__c load : (List<FreightTM__Load__c>)standardController.getSelected()){ 
            loadIds.add(load.Id);
        }

        if (loadIds.size() > 0 == false) {
            String idsFromUrl = ApexPages.CurrentPage().getParameters().get('recordIds');
            loadIds = idsFromUrl.split(',');
        }
                
        loadList = [SELECT Name, Pickup_By__c, Quantity__c, FreightTM__Commodity__c, E_BOL_Link__c, Mat_Grade_Conversion__c, MatGradetoDisplayonMillBOL__c FROM FreightTM__Load__c WHERE ID IN: loadIds];
        
        loadRec = [select Id, Name, FreightTM__Status__c, 
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
                   from FreightTM__Load__c where Id IN: loadIds];
        
        allItems = [SELECT Id, Quantity__c, Commodity__c, Grade__c, Notes__c, Load__c, Load__r.Name, Load__r.Pickup_By__c FROM Item__c
                        WHERE Load__c IN: loadIds];
        
        stops = [select Id, Name,  FreightTM__Type__c, FreightTM__Arrival__c, FreightTM__Address__c, FreightTM__City__c, FreightTM__State__c, FreightTM__Zip_Code__c,
                 FreightTM__Country__c, FreightTM__Contact__c, FreightTM__Phone__c, FreightTM__Email__c, FreightTM__Remarks__c, FreightTM__Reference__c 
                 FROM FreightTM__Stop__c 
                 WHERE ID IN: loadIds];
        
        
         TimeZone tz = UserInfo.getTimeZone();
         offset = tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        
          for(Integer i = 0; i < loadRec.size(); i++) {
            loadRec[i].pickupSignature__c = null;
            loadRec[i].deliverySignature__c = null;
            loadRec[i].driverSignature__c = null;

        // Add Pickup Signature Image
        if ((loadRec[i].pickupSignature__c == null || loadRec[i].pickupSignature__c == '') && (loadRec[i].Shipper_Signature__c != null && loadRec[i].Shipper_Signature__c != '')){ 
            
            String str = loadRec[i].Shipper_Signature__c;
            List<String> part = str.split('"');
            if(part.size() > 1){
            loadRec[i].pickupSignature__c = part[1];
            isShowPickupSignature = true;
                }
        }else{
            isShowPickupSignature = false;
        }
        
        // Add Driver Signature Image
        if ((loadRec[i].driverSignature__c == null || loadRec[i].driverSignature__c == '') && (loadRec[i].Pickup_Signature__c != null && loadRec[i].Pickup_Signature__c != '')){ 
            
            String str = loadRec[i].Pickup_Signature__c;
            List<String> part = str.split('"');
             if(part.size() > 1){
            loadRec[i].driverSignature__c = part[1];
            isShowDriverSignature = true;
             }
        }else{
            isShowDriverSignature = false;
        }

        // Add Delivery Signature Image
        if ((loadRec[i].deliverySignature__c == null || loadRec[i].deliverySignature__c == '') && (loadRec[i].Receiver_Signature__c != null && loadRec[i].Receiver_Signature__c != '')){ 
            
            String str = loadRec[i].Receiver_Signature__c;
            List<String> part = str.split('"');
             if(part.size() > 1){
            loadRec[i].deliverySignature__c = part[1];
            isShowDeliverySignature = true;
             }
        }else{
            isShowDeliverySignature = false;
        }
        

        
    }
        }
}