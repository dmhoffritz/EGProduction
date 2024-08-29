/*
        Apex Class - driverLoad
        Implementation - Controller extension for 'driverLoad' VF page
*/


global virtual without sharing class driverLoad {
    
    private final FreightTM__Load__c load; //variable to store active load record for controller evaluation
    public string lat_long {get;set;} //latitude and longitude coordinates in text variable
    global string device_type {get; set;} //variable which reads the type of device being used to render VF page
    global List<ContentVersion> fileList {get; set;} //list of files uploaded from VF page
    global Boolean status_assigned {get; set;} //boolean to check if current status is assigned
    global Boolean status_dispatched {get; set;} //boolean to check if current status is dispatched
    global Boolean status_pickup {get; set;} //boolean to check if current status is arrived for pickup
    global Boolean status_pickedup {get; set;} //boolean to check if current 
    global Boolean status_loaded {get; set;} //boolean to check if current status is loaded in transit
    public Boolean status_delayed {get; set;} //boolean to check if current status is delayed
    global Boolean status_delivery {get; set;} //boolean to check if current status is arrived for delivery
    global Boolean status_delivered {get; set;} //boolean to check if current status is delivered
    global String error_message {get; set;} //error message
    global Boolean reset_message {get; set;} //check if message has reset or not
    global Boolean file_add {get; set;}  //Default set to false. If file(s) were attached, set to true
    global List<FreightTM__Load__c> loadRec {get; set;} //variable to store load records to pass into VF page
    global List<FreightTM__Stop__c> stopRec {get; set;} //variable to store stop records to grab from VF page
    global String driver_signature {get;set;} //driver signature stored as text
    global String shipper_signature {get;set;} //pickup contact signature stored as text
    global String receiver_signature {get;set;} //delivery contact signature stored as text
    global Boolean driver_sign_isFull {get; set;} //boolean to check if driver signature is empty
    global Boolean shipper_sign_isFull {get; set;} //boolean to track whether pickup contact has signed or not
    global Boolean receiver_sign_isFull {get; set;} //boolean to track whether delivery contact has signed or not
    global Boolean driver_sign_isEmpty {get; set;} //boolean to track whether driver has signed or not
    global Boolean shipper_sign_isEmpty {get; set;} //boolean to check if pickup signature is empty
    global Boolean receiver_sign_isEmpty {get; set;} //boolean to check if delivery signature is empty
    global Boolean signature_access {get; set;} //boolean to track whether signature pad is to be displayed or not
    global Double offset {get; set;} //variable to fix datetime field to match timezone
    global String pickup_street {get; set;} //string to store pickup street
    global String pickup_city {get; set;} //string to store pickup city
    global String pickup_state {get; set;} //string to store pickup state
    global String delivery_street {get; set;} //string to store delivery street
    global String delivery_city {get; set;} //string to store delivery city
    global String delivery_state {get; set;} //string to store delivery state
    global String new_num {get; set;} //string to store dispatchers phone #
    global String pickup_lat {get; set;} //string to store pickup latitude
    global String pickup_long {get; set;} //string to store pickup longitude
    global String delivery_lat {get; set;} //string to store delivery latitude
    global String delivery_long {get; set;} //string to store delivery longitude
   
    
    public driverLoad(ApexPages.StandardController stndCont) {
        
         TimeZone tz = UserInfo.getTimeZone();
         offset = tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);

        
        fileList = new List<ContentVersion>();
        fileList.add(new ContentVersion());
        file_add = false;
        
    
        
        //Initialize all load record data to pass into VF page
        loadRec = [select Id, Name, FreightTM__Driver__c, Confirmation_Number__c, RecordTypeId, RecordType.DeveloperName,
                   FreightTM__Driver__r.Name, FreightTM__Driver__r.FreightTM__PIN__c, FreightTM__Calendar_Load__c, FreightTM__Driver__r.FreightTM__First_Name__c,
                   
                   FreightTM__Confirmation_Number__c, FreightTM__Status__c, FreightTM__Load_Canceled__c, Quantity__c, FreightTM__Commodity__c,
                   FreightTM__Distance__c, FreightTM__Remarks__c, FreightTM__Total_Miles__c, FreightTM__Driver_Remarks__c,Driver_reason_for_the_delay__c, Delayed_Reason__c,
                   
                   FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c, Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s, Mat_Type__c, Mat_Grade__c,
                   FreightTM__Pickup_Zip_Code__c, FreightTM__Pickup_Country__c, FreightTM__Pickup_Arrival__c, Pickup_By__c, FreightTM__Pickup_By_Appointment__c,
                   FreightTM__Pickup_Ref__c, FreightTM__Pickup_Remarks__c, Driver_Name__c, Date__c,FreightTM__Pickup_Contact__c,FreightTM__Pickup_Phone__c,Shipper_Date__c,
                   
                   FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c, Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s, FreightTM__Delivery_Contact__c,FreightTM__Delivery_Phone__c,Receiver_Date__c,
                   FreightTM__Delivery_Zip_Code__c, FreightTM__Delivery_Country__c, FreightTM__Delivery_Arrival__c, Deliver_By__c, FreightTM__Delivery_By_Appointment__c,
                   FreightTM__Delivery_Ref__c, FreightTM__Delivery_Remarks__c, ETA__c, Pickup_Signature__c, Shipper_Signature__c, Receiver_Signature__c,
                   
                   FreightTM__Dispatch__r.Name, FreightTM__Dispatch__r.MobilePhone, FreightTM__Dispatch__r.Phone, FreightTM__Dispatch__r.Extension
                   
                   from FreightTM__Load__c where Id =: apexpages.currentpage().getparameters().get('id')];
                   
        //Initialize all load record data needed for this controller           
        load = [SELECT Id, FreightTM__Confirmation_Number__c, FreightTM__Total_Miles__c, RecordType.DeveloperName,
                FreightTM__Status__c, Pickup_Signature__c, Shipper_Signature__c, Receiver_Signature__c,
                Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s
                FROM FreightTM__Load__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')];
                
        //Initialize Address data from loadRec
        pickup_street = loadRec[0].FreightTM__Pickup_Address__c;
        pickup_city = loadRec[0].FreightTM__Pickup_City__c;
        pickup_state = loadRec[0].FreightTM__Pickup_State__c;
        delivery_street = loadRec[0].FreightTM__Delivery_Address__c;
        delivery_city = loadRec[0].FreightTM__Delivery_City__c;
        delivery_state = loadRec[0].FreightTM__Delivery_State__c;
        
        //Define the load's status through boolean variables
        if (load.FreightTM__Status__c == 'Assigned'){
            status_assigned = true;}else{
                status_assigned = false;}
        
        if (load.FreightTM__Status__c == 'Dispatched'){
            status_dispatched = true;}else{
                status_dispatched = false;}
        
        if (load.FreightTM__Status__c == 'Arrived for pickup'){
            status_pickup = true;}else{
                status_pickup = false;}
                
        if (load.FreightTM__Status__c == 'Loaded In Transit'){
            status_loaded = true;}else{
                status_loaded = false;}
                
        if (load.FreightTM__Status__c == 'Delayed'){
            status_delayed = true;}else{
                status_delayed = false;}
        
        if (load.FreightTM__Status__c == 'Arrived for delivery'){
            status_delivery = true;}else{
                status_delivery = false;}
                
        if (load.FreightTM__Status__c == 'Delivered'){
            status_delivered = true;}else{
                status_delivered = false;}
        
        //determine whether signatures are empty for dispatched, pickup and delivery stages
        if ((load.Pickup_Signature__c == null || load.Pickup_Signature__c == '')  &&  load.FreightTM__Status__c == 'Dispatched'){
            driver_sign_isEmpty = true;}else{
                driver_sign_isEmpty = false;}
        
        if (load.Shipper_Signature__c == null || load.Shipper_Signature__c == '' && load.FreightTM__Status__c == 'Arrived for pickup'){
            shipper_sign_isEmpty = true;}else{
                shipper_sign_isEmpty = false;}
        
        if (load.Receiver_Signature__c == null || load.Receiver_Signature__c == '' && load.FreightTM__Status__c == 'Arrived for delivery'){
            receiver_sign_isEmpty = true;}else{
                receiver_sign_isEmpty = false;}
        
        //lets VF know when driver is on a page where signatures are required
        if (load.FreightTM__Status__c == 'Assigned' || load.FreightTM__Status__c == 'Dispatched' ||load.FreightTM__Status__c == 'Arrived for pickup' || load.FreightTM__Status__c == 'Arrived for delivery'){
                signature_access = true;}else{
                    signature_access = false;}
                     
        //generate records any time a driver stops mid-route
        if(loadRec.size() > 0)
        { 
            for(integer i = 0; i < loadRec.size(); i++) {
                stopRec = [select Name, FreightTM__Load__c, FreightTM__Load__r.Name, FreightTM__Load__r.Id, FreightTM__Address__c, FreightTM__By_Appointment__c, FreightTM__City__c, FreightTM__Country__c,
                           FreightTM__Reference__c, FreightTM__Arrival__c, FreightTM__Remarks__c, FreightTM__State__c, FreightTM__Type__c, FreightTM__Zip_Code__c
                           from FreightTM__Stop__c where FreightTM__Load__c =: loadRec[i].id
                           order by FreightTM__Arrival__c asc]; 
            }
            
            
            driver_signature = null;
            shipper_signature = null;
            receiver_signature = null;
            // Add Pickup Signature Image
            if ((driver_signature == null || driver_signature == '') && (loadRec[0].Pickup_Signature__c != null && loadRec[0].Pickup_Signature__c != '')){ 
                
                String str = loadRec[0].Pickup_Signature__c;
                List<String> part = str.split('"');
                driver_signature = part[1];
                driver_sign_isFull = true;
            }else{
                driver_sign_isFull = false;
            }
            
            // Add Delivery Signature Image
            if ((shipper_signature == null || shipper_signature == '') && (loadRec[0].Shipper_Signature__c != null && loadRec[0].Shipper_Signature__c != '')){ 
                
                String str = loadRec[0].Shipper_Signature__c;
                List<String> part = str.split('"');
                shipper_signature = part[1];
                shipper_sign_isFull = true;
            }else{
                shipper_sign_isFull = false;
            }
            
            // Add Consignee Signature Image
            if ((receiver_signature == null || receiver_signature == '') && (loadRec[0].Receiver_Signature__c != null && loadRec[0].Receiver_Signature__c != '')){ 
                
                String str = loadRec[0].Receiver_Signature__c;
                List<String> part = str.split('"');
                receiver_signature = part[1];
                receiver_sign_isFull = true;
            }else{
                receiver_sign_isFull = false;
            }
            
        }
        else
        {
            reset_message = false;
        }
        
        if (loadRec[0].FreightTM__Dispatch__r.MobilePhone != null) {
            new_num = loadRec[0].FreightTM__Dispatch__r.MobilePhone;
            if(new_num.contains('+')) {
                new_num = new_num.replace('+', '');
                new_num = new_num.replace(' ', '');
                new_num = new_num.substring(1, new_num.length() - 0);
            }
            
        } else {
            new_num = ''; 
          }
        
        pickup_lat = String.valueOf(loadRec[0].Pickup_Lat_Long__latitude__s);
        pickup_long = String.valueOf(loadRec[0].Pickup_Lat_Long__longitude__s);
        delivery_lat = String.valueOf(loadRec[0].Delivery_Lat_Long__latitude__s);
        delivery_long = String.valueOf(loadRec[0].Delivery_Lat_Long__longitude__s);
    }
   
    //method to store device type upon inital page load
    public PageReference storeDeviceType(){
    
        device_type = Apexpages.currentPage().getParameters().get('device');
        system.debug(device_type);
        return null;
    }
    
    //method used to store records of coordinates generated on VF page
    public void storeCoordinates(){ 
        
        system.debug(lat_long);
        
        string coordinate = lat_long;
        FreightTM__Site_Location__c temp_lat_long = new FreightTM__Site_Location__c (FreightTM__Coordinates__latitude__s = double.valueof(coordinate.substringBefore(',')),
                                                                                 FreightTM__Coordinates__longitude__s = double.valueof(coordinate.substringAfter(',')),
                                                                                 FreightTM__Load__c = load.Id);
        system.debug(temp_lat_long);
        try {
            insert temp_lat_long; 
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        system.debug(temp_lat_long);
    }
    
    //for additional file attachments
    global PageReference AddAttachs() { 
        try { 
            fileList.add(new ContentVersion());
        } catch(DmlException ex) {
            ApexPages.addMessages(ex); //error messages
            return null;
        } 
        return null;
    }

    public Boolean isDelivered() {
        FreightTM__Load__c loadToCheck = [SELECT Id, Name, FreightTM__Status__c
                                            FROM FreightTM__Load__c
                                            WHERE Id =: load.Id];
        if (loadToCheck.FreightTM__Status__c == 'Delivered') {
            return true;
        } else {
            return false;
        }
    }
   
    //update dispatched status
    global PageReference StatusDispatched() {
        if (!isDelivered()) {
            load.FreightTM__Status__c = 'Dispatched';
            update load;
        }
        return null;
    }

    //update pickup status
    global PageReference StatusArrived() {
        if (!isDelivered()) {
            load.FreightTM__Status__c = 'Arrived for pickup';
            update load;
        }
        return null;
    }
    
    //update delayed status
    global PageReference StatusDelayed() {
        if (!isDelivered()) {
            load.FreightTM__Status__c = 'Delayed';
            update load;
        }
        return null; 
    }
    
    //update delivered status
    global PageReference StatusArrivedDelivered() {
        if (!isDelivered()) {
            load.FreightTM__Status__c = 'Arrived for delivery';
            update load;
        }
        return null;
    }
   
    //method used to store signature images
    global PageReference storeSignatures() {
        
        system.debug('Load Id ' + apexpages.currentpage().getparameters().get('id'));
        
        try { 
            if(loadRec.size() > 0 && !isDelivered()) {
            
                /*
                if (load.RecordType.DeveloperName == 'Customer_Pickup' && driver_signature != null && driver_signature != ''){ 
                    
                    system.debug(driver_signature);
                    
                    loadRec[0].Pickup_Signature__c = '<img src="'+ driver_signature +'">';
                    driver_sign_isFull = true;
                     update loadRec;
                }else{}
				*/
                
                if (driver_signature != null && driver_signature != ''){ 
                    
                    system.debug(driver_signature);
                    
                    loadRec[0].Pickup_Signature__c = '<img src="'+ driver_signature +'">';
                    driver_sign_isFull = true;
                    update loadRec;
                }else{}
                
                if (shipper_signature != null && shipper_signature != ''){ 
                    
                    system.debug(shipper_signature);
                    loadRec[0].Shipper_Signature__c = '<img src="'+ shipper_signature +'">';
                    shipper_sign_isFull = true;
                    update loadRec;
                }else{}
                
                if (receiver_signature != null && receiver_signature != ''){ 
                    
                    system.debug(receiver_signature);
                    loadRec[0].Receiver_Signature__c = '<img src="'+ receiver_signature +'">';
                    receiver_sign_isFull = true;
                     update loadRec;
                }else{}
                
                if (load.FreightTM__Status__c != 'Arrived for pickup' && load.FreightTM__Status__c != 'Arrived for delivery'){ 
                    update loadRec;}
                
             
                
            }
        } catch(DmlException ex) { return null;} 
        
        return null;
    }
    
    //method used to store file attachments
    global PageReference SaveFiles() {
        
        system.debug('Load Id ' + apexpages.currentpage().getparameters().get('id'));
        
        try { 
            if(loadRec.size() > 0) {
                List<ContentVersion> conVers = new List<ContentVersion>(); //to upload attached files as Salesforce Files, not Notes & Attachments //// multi files
                
                //Insert ContentVersion, to upload attached files as Salesforce Files. ContentVersion is the child of ContentDocument
                for(ContentVersion file : fileList)
                {
                    if(file.Title != null && file.VersionData != null) {
                        file_add = true; //if file(s) were attached, set flag to true and update Load record in the next if statement
                        //add to attachments list with Load id
                        conVers.add(new ContentVersion(
                            ContentLocation = 'S', // S specify this document is in SF, use E for external files
                            Origin = 'H', //C-Content Origin. H-Chatter Origin
                            OwnerId = UserInfo.getUserId(), //Owner of the file
                            PathOnClient = file.Title, // The files name, extension is very important here which will help the file in preview
                            Title = 'DriverPortal_' + loadRec[0].Id + '_' + file.Title, // Display name of the file -- hack
                            //Title = file.Title, // Display name of the file -- no hack
                            VersionData = file.VersionData // Blob file
                        )); 
                    }
                }
                
                insert conVers; //trigger ContentDocumentLink between File and Load Record 
                
                system.debug('CV ' + conVers);
                
                if(file_add == true) { //to update Load record once, if file(s) were attached
                    
                    update loadRec;
                    error_message = 'Success: ' + conVers.size() + ' file(s) uploaded successfully. ' + '\n' + 'Load has been updated.';
                    reset_message = true;
                }
                if(file_add == false) {
                    update loadRec;
                    error_message = 'Success: Load has been updated.';
                    reset_message = true;
                }
            }
        } catch(DmlException ex) {
            ApexPages.addMessages(ex); //error messages
            reset_message = true;
            return null;
        } finally { //to avoid "Maximum view state size limit (170KB) exceeded" error 
            
            for(ContentVersion file : fileList)
            {
                file.Title = null;
                file.VersionData = null;
            }
            
        }
        return null;
    }
    
    //method used to clear pickup signature data
    public PageReference  clearPickup() {
        
        driver_sign_isFull = false;
        driver_signature = '';
        return null;
    }
    
    //method used to clear delivery signature data
    public PageReference  clearDelivery() {
        
        shipper_sign_isFull = false;
        shipper_signature = '';    
        return null;
    }
    
    //method used to clear consignee signature data
    public PageReference  clearConsignee() {
        
        receiver_sign_isFull = false;
        receiver_signature = '';    
        return null;
    }
    
    //for VF page refresh
    global PageReference redirect(){
       PageReference pr = new PageReference('https://yourempiregroup.secure.force.com/BOLWithSignature_PDF?id=' + Load.Id); //PRODUCTION: https://yourempiregroup.secure.force.com/BOLWithSignature_PDF?id=' + Load.Id)
       return pr;
    }
    
    //redirect customer pickup BOL
    public PageReference redirect_customerPickup() {
        PageReference customer_pickup = new PageReference('https://yourempiregroup.secure.force.com/BOL_CustomerPickup_PDF?id=' + Load.Id); //PRODUCTION: https://yourempiregroup.secure.force.com/BOL_CustomerPickup_PDF?id=' + Load.Id)
        return customer_pickup;
        
    }
    
    //redirect customer pickup driver portal
    public PageReference checkRecordType() {
    
        if(loadRec[0].RecordType.DeveloperName == 'Customer_Pickup') {
           PageReference cp = new PageReference('https://yourempiregroup.secure.force.com/driverLoad_CustomerPickup?id=' + Load.Id); //PRODUCTION: https://yourempiregroup.secure.force.com/driverLoad_CustomerPickup?id=' + Load.Id)
           return cp;
        }
        
        else { return null; }
    }
}