/**
 * @description       : 
 * @author            : Ethan Myers
 * @group             : 
 * @last modified on  : 02-24-2023
 * @last modified by  : Ethan Myers
**/
public without sharing class CarrierPortal_Cont {
    public String user_id {get; set;} //id of user to pass into components
    public String carrier_id {get; set;} //id of carrier to pass into components
    public String record_id {get; set;}
    public String username {get; set;} 
    public String password {get; set;}
    public String first_name {get; set;}
    public String last_name {get; set;}
    public String user_email {get; set;}
    
    private Id carrier_type_id {get; set;}
    private Id factorer_type_id {get; set;}
    private Id carrier_not_factoring_id {get; set;}
    private Id brokerer_type_id {get; set;}
    
    public String recordType {get; set;}
    
    //Page triggers
    public Boolean login_page {get; set;}
    public Boolean home_page {get; set;}
    public Boolean load_page {get; set;}
    
    
    public class ContentWrapper {
        @AuraEnabled
        public String fileName {get;set;}
        @AuraEnabled
        public String fileURL {get;set;}
        @AuraEnabled 
        public Id docID {get; set;}
        
        public ContentWrapper(String fileName, String fileUrl, Id docID) {
            this.fileName = fileName;
            this.fileURL = fileUrl;
            this.docID = docID;
        }
    }
    
    public Boolean msg {get; set;}
    public String msgs {get; set;}
    
    
    
    public CarrierPortal_Cont() {
        system.debug('INITIALIZING CARRIER PORTAL');
        user_id = '';
    	recordType = '';
        carrier_id = '';
        username = '';
        password = '';
        first_name = '';
        last_name = '';
        user_email = '';
        login_page = true;
        home_page = false;
        load_page = false;    
    
    
    }
    
    public PageReference Login() {
        
        factorer_type_id = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Factoring_Company').getRecordTypeId();
        carrier_type_id = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Carrier_Factoring').getRecordTypeId();
        carrier_not_factoring_id = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Carrier_Not_Factoring').getRecordTypeId();
        brokerer_type_id = Schema.SObjectType.Portal_User_Registration__c.getRecordTypeInfosByDeveloperName().get('Broker').getRecordTypeId();

        List<Portal_User_Registration__c> check_user = [SELECT Id, Carrier__r.Id, FactoringCompany__r.Id, FirstName__c, LastName__c, Email__c, RecordTypeId FROM Portal_User_Registration__c WHERE Email__c =: username AND Password__c =: password];
        
        if(check_user.size() > 0) {
            if(check_user[0].RecordTypeId == carrier_type_id) {
                //carrier_id = String.valueOf(check_user[0].Carrier__r.Id);
                
                record_id = String.valueOf(check_user[0].Carrier__r.Id);
                recordType = 'Carrier_Factoring';
                System.debug('User w/ ID: ' + check_user[0].Id + ' successfully logged in');
                
            } else if(check_user[0].RecordTypeId == factorer_type_id) {
                //carrier_id = String.valueOf(check_user[0].Carrier__r.Id);
                record_id = String.valueOf(check_user[0].FactoringCompany__r.Id);
                recordType = 'Factoring_Company';
                System.debug('User w/ ID: ' + check_user[0].Id + ' successfully logged in');
            } else if(check_user[0].RecordTypeId == carrier_not_factoring_id) {
                record_id = String.valueOf(check_user[0].Carrier__r.Id);
                recordType = 'Carrier_Not_Factoring';
                System.debug('User w/ ID: ' + check_user[0].Id + ' successfully logged in');
            } else if(check_user[0].RecordTypeId == brokerer_type_id) {
                record_id = String.valueOf(check_user[0].Carrier__r.Id);
                recordType = 'Broker';
                System.debug('User w/ ID: ' + check_user[0].Id + ' successfully logged in');
            }
            user_id = String.valueOf(check_user[0].Id);
            first_name = check_user[0].FirstName__c;
            last_name = check_user[0].LastName__c;
            user_email = check_user[0].Email__c;
            home_page = true;
            login_page = false;
            
        } else {
            System.debug('Unsuccessful Login');
            msgs = 'User Not Found...check spelling';
            msg = true;
        }
        return null;
    }

    public PageReference redirectHome() {
        
        return null;
    }

    @AuraEnabled(cacheable=true) 
    public static List<FreightTM__Load__c> findDisputes(String recordId) {
        String recordType = (Id.valueOf(recordId)).getSobjectType().getDescribe().getName();
        
        if(recordType == 'FreightTM__Carrier__c') {
            List<FreightTM__Load__c> loadsRelatedToCarrier = new List<FreightTM__Load__c>();
            loadsRelatedToCarrier = [SELECT Id, Name, 
                                     FreightTM__Carrier_Obj__c, EstimatedPaymentDate__c, Vendor_Invoice__c, Record_Link__c, FreightTM__Carrier_Obj__r.Name,Invoice__c, Driver_Name__c, Driver_Phone__c,
                                     FreightTM__Customer__c,FreightTM__Carrier__c, CreatedDate, FreightTM__Commodity__c,Pickup_By__c,Deliver_By__c, 
                                     FreightTM__Driver__c, FreightTM__Driver__r.Name, FreightTM__Calendar_Load__c, FreightTM__Driver__r.FreightTM__First_Name__c, 
                                     FreightTM__Confirmation_Number__c, FreightTM__Status__c, FreightTM__Load_Canceled__c, FreightTM__Billed_On__c,
                                     FreightTM__Distance__c, FreightTM__Remarks__c, FreightTM__Total_Miles__c, FreightTM__Rate_to_Carrier__c,                   
                                     FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c,FreightTM__Pay_Status__c, 
                                     FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, FreightTM__Pickup_Arrival__c, FreightTM__Pickup_By_Appointment__c, Carrier_Signature__c,
                                     FreightTM__Pickup_Ref__c, FreightTM__Pickup_Remarks__c, FreightTM__Bill_Status__c,                  
                                     FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c, FreightTM__Total_Rate_to_Carrier__c,
                                     FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c, FreightTM__Delivery_Arrival__c, FreightTM__Delivery_By_Appointment__c, 
                                     FreightTM__Delivery_Ref__c, FreightTM__Delivery_Remarks__c, FreightTM__Number_of_Pallets__c, 
                                     Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s, Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s,
                                     FreightTM__Weight__c, Quantity__c, Reference_Number__c, FreightTM__Length__c, FreightTM__Width__c, FreightTM__Height__c, DisputeReason__c, Covered__c
                                     FROM FreightTM__Load__c WHERE FreightTM__Carrier_Obj__r.Id =: recordId AND FreightTM__Bill_Status__c =: 'Dispute' AND CreatedDate > 2022-01-01T00:00:00.000Z ORDER BY Name DESC];
            return loadsRelatedToCarrier;
        } else if(recordType == 'Factoring_Company__c') {
            List<FreightTM__Load__c> loadsRelatedToFactoringComp = new List<FreightTM__Load__c>();
            List<Id> carrierIds = new List<Id>();
            List<FreightTM__Carrier__c> factoredCarriers = [SELECT Id FROM FreightTM__Carrier__c WHERE FactoringCompany_obj__r.Id =: recordId];
            if(factoredCarriers.size() != 0) {
                for(FreightTM__Carrier__c ref_carrier : factoredCarriers) {
                    carrierIds.add(ref_carrier.Id);
                }
                loadsRelatedToFactoringComp = [SELECT Id, Name, 
                                               FreightTM__Carrier_Obj__c, EstimatedPaymentDate__c, Vendor_Invoice__c, Record_Link__c, FreightTM__Carrier_Obj__r.Name,Invoice__c, Driver_Name__c, Driver_Phone__c,
                                               FreightTM__Customer__c,FreightTM__Carrier__c, CreatedDate, FreightTM__Commodity__c,Pickup_By__c,Deliver_By__c, 
                                               FreightTM__Driver__c, FreightTM__Driver__r.Name, FreightTM__Calendar_Load__c, FreightTM__Driver__r.FreightTM__First_Name__c, 
                                               FreightTM__Confirmation_Number__c, FreightTM__Status__c, FreightTM__Load_Canceled__c, FreightTM__Billed_On__c,
                                               FreightTM__Distance__c, FreightTM__Remarks__c, FreightTM__Total_Miles__c, FreightTM__Rate_to_Carrier__c,                   
                                               FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c,FreightTM__Pay_Status__c, 
                                               FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, FreightTM__Pickup_Arrival__c, FreightTM__Pickup_By_Appointment__c, Carrier_Signature__c,
                                               FreightTM__Pickup_Ref__c, FreightTM__Pickup_Remarks__c, FreightTM__Bill_Status__c,                  
                                               FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c, FreightTM__Total_Rate_to_Carrier__c,
                                               FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c, FreightTM__Delivery_Arrival__c, FreightTM__Delivery_By_Appointment__c, 
                                               FreightTM__Delivery_Ref__c, FreightTM__Delivery_Remarks__c, FreightTM__Number_of_Pallets__c, 
                                               Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s, Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s,
                                               FreightTM__Weight__c, Quantity__c, Reference_Number__c, FreightTM__Length__c, FreightTM__Width__c, FreightTM__Height__c, DisputeReason__c, Covered__c
                                               FROM FreightTM__Load__c WHERE FreightTM__Carrier_Obj__r.Id IN: carrierIds AND FreightTM__Bill_Status__c =: 'Dispute' AND CreatedDate > 2022-01-01T00:00:00.000Z ORDER BY Name DESC];
            }
            return loadsRelatedToFactoringComp;
        } else {
            return null;
        }
    }
    
    /* Home Component Aura Methods */
    @AuraEnabled(cacheable=true)
    public static List<FreightTM__Load__c> getRelatedLoads(String recordId) {
        String recordType = (Id.valueOf(recordId)).getSobjectType().getDescribe().getName();
        
        if(recordType == 'FreightTM__Carrier__c') {
            List<FreightTM__Load__c> loadsRelatedToCarrier = new List<FreightTM__Load__c>();
            loadsRelatedToCarrier = [SELECT Id, Name, 
                                     FreightTM__Carrier_Obj__c, EstimatedPaymentDate__c, Vendor_Invoice__c, Record_Link__c, FreightTM__Carrier_Obj__r.Name,Invoice__c, Driver_Name__c, Driver_Phone__c,
                                     FreightTM__Customer__c,FreightTM__Carrier__c, CreatedDate, FreightTM__Commodity__c,Pickup_By__c,Deliver_By__c, 
                                     FreightTM__Driver__c, FreightTM__Driver__r.Name, FreightTM__Calendar_Load__c, FreightTM__Driver__r.FreightTM__First_Name__c, 
                                     FreightTM__Confirmation_Number__c, FreightTM__Status__c, FreightTM__Load_Canceled__c, FreightTM__Billed_On__c,
                                     FreightTM__Distance__c, FreightTM__Remarks__c, FreightTM__Total_Miles__c, FreightTM__Rate_to_Carrier__c,                   
                                     FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c,FreightTM__Pay_Status__c, 
                                     FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, FreightTM__Pickup_Arrival__c, FreightTM__Pickup_By_Appointment__c, Carrier_Signature__c,
                                     FreightTM__Pickup_Ref__c, FreightTM__Pickup_Remarks__c, FreightTM__Bill_Status__c,                  
                                     FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c, FreightTM__Total_Rate_to_Carrier__c,
                                     FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c, FreightTM__Delivery_Arrival__c, FreightTM__Delivery_By_Appointment__c, 
                                     FreightTM__Delivery_Ref__c, FreightTM__Delivery_Remarks__c, FreightTM__Number_of_Pallets__c, 
                                     FreightTM__PickupFacility__r.Location_Type__c, Pickup_Ref_Job__c, FreightTM__DeliveryFacility__r.Location_Type__c, Delivery_Ref_Job__c,
                                     Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s, Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s,
                                     FreightTM__Weight__c, Quantity__c, Reference_Number__c, FreightTM__Length__c, FreightTM__Width__c, FreightTM__Height__c, DisputeReason__c, Covered__c
                                     FROM FreightTM__Load__c WHERE FreightTM__Carrier_Obj__r.Id =: recordId AND CreatedDate > 2022-01-01T00:00:00.000Z AND FreightTM__Pay_Status__c != 'Processed for Payment' ORDER BY Name DESC]; 
            return loadsRelatedToCarrier;
        } else if(recordType == 'Factoring_Company__c') {
            List<FreightTM__Load__c> loadsRelatedToFactoringComp = new List<FreightTM__Load__c>();
            List<Id> carrierIds = new List<Id>();
            List<FreightTM__Carrier__c> factoredCarriers = [SELECT Id FROM FreightTM__Carrier__c WHERE FactoringCompany_obj__r.Id =: recordId];
            if(factoredCarriers.size() != 0) {
                for(FreightTM__Carrier__c ref_carrier : factoredCarriers) {
                    carrierIds.add(ref_carrier.Id);
                }
                loadsRelatedToFactoringComp = [SELECT Id, Name, 
                                               FreightTM__Carrier_Obj__c, EstimatedPaymentDate__c, Vendor_Invoice__c, Record_Link__c, FreightTM__Carrier_Obj__r.Name,Invoice__c, Driver_Name__c, Driver_Phone__c,
                                               FreightTM__Customer__c,FreightTM__Carrier__c, CreatedDate, FreightTM__Commodity__c,Pickup_By__c,Deliver_By__c, 
                                               FreightTM__Driver__c, FreightTM__Driver__r.Name, FreightTM__Calendar_Load__c, FreightTM__Driver__r.FreightTM__First_Name__c, 
                                               FreightTM__Confirmation_Number__c, FreightTM__Status__c, FreightTM__Load_Canceled__c, FreightTM__Billed_On__c,
                                               FreightTM__Distance__c, FreightTM__Remarks__c, FreightTM__Total_Miles__c, FreightTM__Rate_to_Carrier__c,                   
                                               FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c,FreightTM__Pay_Status__c, 
                                               FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, FreightTM__Pickup_Arrival__c, FreightTM__Pickup_By_Appointment__c, Carrier_Signature__c,
                                               FreightTM__Pickup_Ref__c, FreightTM__Pickup_Remarks__c, FreightTM__Bill_Status__c,                  
                                               FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c, FreightTM__Total_Rate_to_Carrier__c,
                                               FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c, FreightTM__Delivery_Arrival__c, FreightTM__Delivery_By_Appointment__c, 
                                               FreightTM__Delivery_Ref__c, FreightTM__Delivery_Remarks__c, FreightTM__Number_of_Pallets__c, 
                                     			FreightTM__PickupFacility__r.Location_Type__c, Pickup_Ref_Job__c, FreightTM__DeliveryFacility__r.Location_Type__c, Delivery_Ref_Job__c,
                                               Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s, Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s,
                                               FreightTM__Weight__c, Quantity__c, Reference_Number__c, FreightTM__Length__c, FreightTM__Width__c, FreightTM__Height__c, DisputeReason__c, Covered__c
                                               FROM FreightTM__Load__c WHERE FreightTM__Carrier_Obj__r.Id IN: carrierIds AND CreatedDate > 2022-01-01T00:00:00.000Z AND FreightTM__Pay_Status__c != 'Processed for Payment' ORDER BY Name DESC];
            }
            return loadsRelatedToFactoringComp;
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static FreightTM__Load__c getLoad(String recordId) {
        List<FreightTM__Load__c> loadRec = [SELECT Id, Name, (select Name, FreightTM__Load__c, FreightTM__Load__r.Name, FreightTM__Address__c, FreightTM__By_Appointment__c, FreightTM__City__c, FreightTM__Country__c,
                                                              FreightTM__Reference__c, FreightTM__Arrival__c, FreightTM__Remarks__c, FreightTM__State__c, FreightTM__Type__c, FreightTM__Zip_Code__c from FreightTM__Stops__r order by FreightTM__Arrival__c), 
                                            FreightTM__Carrier_Obj__c, FreightTM__Carrier_Obj__r.Name,Invoice__c, Driver_Name__c, Driver_Phone__c,
                                            FreightTM__Customer__c,FreightTM__Carrier__c, CreatedDate, FreightTM__Commodity__c,Pickup_By__c,Deliver_By__c, FreightTM__Delivery_Contact__c, FreightTM__Delivery_Email__c, FreightTM__Delivery_Phone__c, FreightTM__DeliveryFacility__r.Name,  
                                            FreightTM__Driver__c, FreightTM__Driver__r.Name, FreightTM__Calendar_Load__c, FreightTM__Driver__r.FreightTM__First_Name__c, 
                                            FreightTM__Confirmation_Number__c, FreightTM__Status__c, FreightTM__Load_Canceled__c, FreightTM__Billed_On__c,
                                            FreightTM__Distance__c, FreightTM__Remarks__c, FreightTM__Total_Miles__c, FreightTM__Rate_to_Carrier__c,FreightTM__Total_Rate_to_Carrier__c,                   
                                            FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c,FreightTM__Pay_Status__c, 
                                            FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, FreightTM__Pickup_Arrival__c, FreightTM__Pickup_By_Appointment__c, Carrier_Signature__c,
                                            FreightTM__Pickup_Ref__c, FreightTM__Pickup_Remarks__c, FreightTM__Bill_Status__c, FreightTM__PickupFacility__r.Name, FreightTM__Pickup_Contact__c, FreightTM__Pickup_Phone__c, FreightTM__Pickup_Email__c,                   
                                            FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c, 
                                            FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c, FreightTM__Delivery_Arrival__c, FreightTM__Delivery_By_Appointment__c, 
                                            FreightTM__Delivery_Ref__c, FreightTM__Delivery_Remarks__c, FreightTM__Number_of_Pallets__c, 
                                            FreightTM__Carrier_Obj__r.FreightTM__Billing_City__c, FreightTM__Carrier_Obj__r.Billing_Contact__c, FreightTM__Carrier_Obj__r.Billing_Phone__c,
                                            FreightTM__Carrier_Obj__r.Billing_Email__c, FreightTM__Carrier_Obj__r.FreightTM__Billing_State_Province__c, 
                                            FreightTM__Carrier_Obj__r.FreightTM__Billing_Address__c, FreightTM__Carrier_Obj__r.FreightTM__Billing_Zip_Code__c,
                                            FreightTM__Carrier_Obj__r.FactoringCompany_obj__r.Name, BOL_Signed__c,
                                     		FreightTM__PickupFacility__r.Location_Type__c, Pickup_Ref_Job__c, FreightTM__DeliveryFacility__r.Location_Type__c, Delivery_Ref_Job__c,
                                            Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s, Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s,
                                            FreightTM__Weight__c, Quantity__c, Reference_Number__c, FreightTM__Length__c, FreightTM__Width__c, FreightTM__Height__c, Covered__c
                                            FROM FreightTM__Load__c WHERE Id =: recordId];
        return loadRec[0];

    }
    
    @AuraEnabled
    public static FreightTM__Site_Location__c getDriverLoc(String recordId) {
        List<FreightTM__Site_Location__c> driverLocation = [SELECT FreightTM__Coordinates__latitude__s, FreightTM__Coordinates__longitude__s
                                                            FROM FreightTM__Site_Location__c WHERE FreightTM__Load__r.Id =: recordId
                                                            ORDER BY Location_Date_Time__c DESC LIMIT 1];
        return driverLocation[0];
    }
    
    @AuraEnabled 
    public static List<ContentWrapper> queryLoadFiles(String recordId) {
        List<ContentWrapper> fileList = new List<ContentWrapper>();
        try {
            List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
            List<Id> contentDocIds = new List<Id>();
            
            List<ContentVersion> cvfileList = new List<ContentVersion>();
            if(contentDocList != null && contentDocList.size() > 0) {
                for(ContentDocumentLink cDocLink : contentDocList) {
                    contentDocIds.add(cDocLink.ContentDocumentId);
                }
                for(ContentDistribution cd : [SELECT Name, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution WHERE RelatedRecordId = : recordId]) {
                    fileList.add(new ContentWrapper(cd.Name, cd.DistributionPublicUrl, cd.ContentDocumentId));
                }
                
            }
            
            
        }catch(DmlException ex) {
            ApexPages.addMessages(ex); //error messages
        }
        return fileList;
    }
    
    @AuraEnabled
    public static Id saveTheFile(String rec_id, String fileName, String base64Data, String label, String invoiceNum) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion cv = new ContentVersion(
            versionData = EncodingUtil.base64Decode(base64Data),
            title = label + '__' + fileName,
            pathOnClient =  '/' + fileName,
            FirstPublishLocationId = rec_id,
            IsMajorVersion = false
        );
        insert cv; 
        system.debug('SUCCESSFULLY INSERTED ContentVersion w/ ID: ' + cv.id);
        ContentDistribution cd = new ContentDistribution(
            Name = cv.title,
            ContentVersionId = cv.id,
            PreferencesAllowViewInBrowser = true,
            RelatedRecordId = rec_id,
            PreferencesAllowOriginalDownload = true
        );
        
        try {
            insert cd;
            ContentDistribution recordLink = [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE Id =: cd.Id];
            FreightTM__Load__c ref_load = [SELECT Id, Name, FreightTM__Status__c, FreightTM__Bill_Status__c, Vendor_Invoice__c FROM FreightTM__Load__c WHERE Id =: rec_id];
            if(label == 'Invoice') {
                ref_load.Vendor_Invoice__c = invoiceNum;
                ref_load.FreightTM__Bill_Status__c = 'Bill/POD Received';
                ref_load.Carrier_Invoice_URL__c = recordLink.DistributionPublicUrl;
                update ref_load;  
            } else if(label == 'PoD') {
                if(ref_load.FreightTM__Status__c == 'Arrived for delivery') {
                    ref_load.FreightTM__Status__c = 'Delivered';
                } 
                ref_load.POD_URL__c = recordLink.DistributionPublicUrl;
                update ref_load;
            }
        } catch(Exception e) {
            system.debug('Error whenever uploading file');
            system.debug('Exception: ' + e);
        }
        
        return cv.Id;
    }
    
    @AuraEnabled
    public static Id saveTheChunk(String rec_id, String fileName, String base64Data, String fileId, String docLabel, String invoiceNum) { 
        if (fileId == '') {
            fileId = saveTheFile(rec_id, fileName, base64Data, docLabel, invoiceNum);
        } else {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion contentVersion = [
            SELECT Id, versionData
            FROM ContentVersion
            WHERE Id = :fileId
        ];
        String existingBody = EncodingUtil.base64Encode(contentVersion.versionData);
        contentVersion.versionData = EncodingUtil.base64Decode(existingBody + base64Data); 
        update contentVersion;   
    }
    
    
    @AuraEnabled
    public static void updateLoads(List<FreightTM__Load__c> loadsToUpdate) {
        try {
            update loadsToUpdate;
        } catch(Exception e) {
            throw new AuraHandledException('Error updating loads: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Factoring_Company__c fetchFactorer(String user_id) {
        Factoring_Company__c factorer = new Factoring_Company__c();
        List<Portal_User_Registration__c> user = [SELECT Id, FirstName__c, LastName__c, Email__c, Password__c, ConfirmPassword__c, FactoringCompany__r.Id FROM Portal_User_Registration__c WHERE Id=: user_id];
        if(user.size() > 0) {
            List<Factoring_Company__c> factorer_query = [SELECT Id, Name, PrimaryContact__c,
                                                        City__c, Email__c, Phone__c, State__c,
                                                        Street__c
                                                         FROM Factoring_Company__c WHERE Id =: user[0].FactoringCompany__r.Id];
            if(factorer_query.size() > 0) {
                return factorer_query[0];
            } else {
                system.debug('No factorer related to user');
                factorer.Name = 'NOT FOUND';
                return factorer;
            }
        } else {
            system.debug('No factorer related to user');
            factorer.Name = 'NOT FOUND';
            return factorer;
        }
    }
    
    @AuraEnabled
    public static Boolean saveFactorer(Factoring_Company__c updatedFactorer) {
        try {
            update updatedFactorer;
            return true;
        } catch(Exception e) {
            system.debug('ERROR SAVING FACTORING COMPANY INFO');
            system.debug('Exception: ' + e);
            return false;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static FreightTM__Carrier__c fetchCarrier(String user_id) {
        FreightTM__Carrier__c carrier = new FreightTM__Carrier__c();
        system.debug('PASSED USER ID: ' + user_id);
        List<Portal_User_Registration__c> user = [SELECT Id, FirstName__c, LastName__c, Email__c, Password__c, ConfirmPassword__c, Carrier__r.Id FROM Portal_User_Registration__c WHERE Id=: user_id];
        if(user.size() > 0) {
            List<FreightTM__Carrier__c> carrier_query = [SELECT Id, Name, FreightTM__Email__c, FreightTM__Phone__c, FreightTM__On_boarding_Status__c,
                                                         FreightTM__Primary_Contact__c, FreightTM__Title__c, FreightTM__MC_MX_FF_Number__c,
                                                         FreightTM__USDOT_Number__c, FreightTM__SCAC_Code__c, FreightTM__Federal_ID__c, FreightTM__Fax__c,
                                                         FreightTM__Website__c, FreightTM__Number_of_Drivers__c, FreightTM__Cargo_Insurance_Amount__c, 
                                                         FreightTM__Cargo_Insurance_Expiration__c, FreightTM__Liability_Insurance_Amount__c, FreightTM__Liability_Insurance_Expiration__c,
                                                         Billing_Contact__c, Billing_Phone__c, Billing_Email__c, FreightTM__Billing_Address__c, FreightTM__Billing_City__c,
                                                         FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c
                                                         FROM FreightTM__Carrier__c WHERE Id =: user[0].Carrier__r.Id];
            if(carrier_query.size() > 0) {
                return carrier_query[0];
            } else {
                system.debug('No carrier related to user');
                carrier.Name = 'CARRIER NOT FOUND';
                return carrier;
            }
            
        } else {
            system.debug('No carrier related to user');
            carrier.Name = 'USER NOT FOUND';
            return carrier;
            
        }
    }
    
    @AuraEnabled
    public static Boolean saveCarrier(String carrierId, String carrierContact, String carrierPhone,
                                        String carrierTitle, String carrierEmail, String carrierWeb,
                                        String carrierFax, String billingContact, String billingStreet,
                                        String billingEmail, String billingPhone, String billingCity,
                                        String billingState, String billingZip) {
        try {
            FreightTM__Carrier__c relativeCarrier = [SELECT Id, Name, FreightTM__Primary_Contact__c, FreightTM__Phone__c, FreightTM__Title__c,
                                                        FreightTM__Email__c, FreightTM__Website__c, FreightTM__Fax__c, Billing_Contact__c,
                                                        Billing_Phone__c, Billing_Email__c, FreightTM__Billing_Address__c, FreightTM__Billing_City__c,
                                                        FreightTM__Billing_State_Province__c, FreightTM__Billing_Zip_Code__c
                                                        FROM FreightTM__Carrier__c WHERE Id =: carrierId LIMIT 1];
            relativeCarrier.FreightTM__Primary_Contact__c = carrierContact;
            relativeCarrier.FreightTM__Phone__c = carrierPhone;
            relativeCarrier.FreightTM__Title__c = carrierTitle;
            relativeCarrier.FreightTM__Email__c = carrierEmail;
            relativeCarrier.FreightTM__Phone__c = carrierPhone;
            relativeCarrier.FreightTM__Website__c = carrierWeb;
            relativeCarrier.FreightTM__Fax__c = carrierFax;
            relativeCarrier.Billing_Contact__c = billingContact;
            relativeCarrier.Billing_Phone__c = billingPhone;
            relativeCarrier.Billing_Email__c = billingEmail;
            relativeCarrier.FreightTM__Billing_Address__c = billingStreet;
            relativeCarrier.FreightTM__Billing_City__c = billingCity;
            relativeCarrier.FreightTM__Billing_State_Province__c = billingState;
            relativeCarrier.FreightTM__Billing_Zip_Code__c = billingZip;
            update relativeCarrier;
            return true;
        } catch(Exception e) {
            system.debug('Update User Exception: ' + e);
            return false;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Portal_User_Registration__c fetchUser(String user_id) {
        system.debug('PASSED USER ID: ' + user_id);
        List<Portal_User_Registration__c> user = [SELECT Id, FirstName__c, LastName__c, Email__c, Phone__c, Password__c, ConfirmPassword__c, Carrier__r.Id FROM Portal_User_Registration__c WHERE Id=: user_id];
        if(user.size() > 0) {
            return user[0];
        } else {
            system.debug('No user returned');
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean saveUser(Portal_User_Registration__c updatedUser) {
        try {
            update updatedUser;
            return true;
        } catch(Exception e) {
            system.debug('Update User Exception: ' + e);
            return false;
        }
    }
    
    public class SearchResult {
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public String recordName {get; set;}
        @AuraEnabled 
        public String iconName {get; set;}
        @AuraEnabled 
        public String subHeading1 {get; set;}
        @AuraEnabled
        public String subHeading2 {get; set;}

        public SearchResult() {
            this.recordId = '';
            this.recordName = '';
            this.iconName = '';
            this.subHeading1 = '';
            this.subHeading2 = '';
        }

        public SearchResult(String recordId, String recordName, String iconName, String subHeading1, String subHeading2) {
            this.recordId = recordId;
            this.recordName = recordName;
            this.iconName = iconName;
            this.subHeading1 = subHeading1;
            this.subHeading2 = subHeading2;
        }
    }
    
    @AuraEnabled
    public static List<SearchResult> portalSearch(String carrierId, String searchTerm) {
        String recordType = (Id.valueOf(carrierId)).getSobjectType().getDescribe().getName();

        List<SearchResult> results = new List<SearchResult>();
        try {
            if (recordType == 'FreightTM__Carrier__c') {

            
                searchTerm = '%' + searchTerm + '%';
                List<FreightTM__Load__c> loads = [SELECT Id, Name, Vendor_Invoice__c, FreightTM__Calendar_Load__c, Reference_Number__c
                                        FROM FreightTM__Load__c 
                                        WHERE FreightTM__Carrier_Obj__c =: carrierId 
                                        AND (Name LIKE: searchTerm OR Reference_Number__c LIKE: searchTerm)
                                        ORDER BY Name
                                        LIMIT 5];

                for (FreightTM__Load__c load : loads) {
                    results.add(new SearchResult(load.Id, load.Name, 'custom:custom98', load.Reference_Number__c, load.FreightTM__Calendar_Load__c));
                } 
            }
            return results;
        } catch (Exception e) {
            throw new AuraHandledException('Error searching within portal: ' + e.getMessage());
        }
    }

    /* Method to query records using SOQL*/
    @AuraEnabled
    public static List<SearchResult> getRecentlyViewed(String carrierId){
        String recordType = (Id.valueOf(carrierId)).getSobjectType().getDescribe().getName();
        List<SearchResult> results = new List<SearchResult>();
        try {
            if (recordType == 'FreightTM__Carrier__c') {

                List<FreightTM__Load__c> loads = [SELECT Id, Name, FreightTM__Calendar_Load__c, Vendor_Invoice__c, Reference_Number__c
                                                            FROM FreightTM__Load__c
                                                            WHERE FreightTM__Carrier_Obj__c =: carrierId
                                                            ORDER BY CreatedDate DESC
                                                            LIMIT 5];

                for (FreightTM__Load__c load : loads) {
                    results.add(new SearchResult(load.Id, load.Name, 'custom:custom98', load.Reference_Number__c, load.FreightTM__Calendar_Load__c));
                }
            }

            return results;
        } catch (Exception e) {
            throw new AuraHandledException('Error searching within portal: ' + e.getMessage());
        }
    }
    
    
}