//Set Distance

//APEX
//==================================================================

public class Set_Distance {
    
    public static boolean inFutureContext = false;
    public static List<FreightTM__Load__c> load;
    //public static Decimal distance {get;set;}
    public static Decimal totaldist {get;set;}
    public static String jsonResults;
    
    /* Constructor */
    //public set_distance() {}

    @invocablemethod
    public static void Set_Distance(list<id> loadid) {
        
        List<String> stops;
        
        load = [select id, Name, LastModifiedDate, (select Id, Name, FreightTM__Address__c, FreightTM__City__c, FreightTM__State__c from FreightTM__stops__r),
                Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s, Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s, 
                FreightTM__Distance__c, FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c, FreightTM__Delivery_Address__c, FreightTM__Delivery_City__c, FreightTM__Delivery_State__c
                from FreightTM__Load__c 
                where id in :loadid order by LastModifiedDate desc limit 1];
        
        /*
        string origin = load[0].FreightTM__Pickup_Address__c + ',' + load[0].FreightTM__Pickup_City__c + ',' + load[0].FreightTM__Pickup_State__c;
        string destination = load[0].FreightTM__Delivery_Address__c + ',' + load[0].FreightTM__Delivery_City__c + ',' + load[0].FreightTM__Delivery_State__c;
        system.debug('origin:'+ origin);
        
        for(integer i = 0; i < load[0].freightTM__Stops__r.size(); i++) {
            origin = origin + '|' + load[0].freightTM__stops__r[i].freightTM__Address__c + ', ' + load[0].freightTM__stops__r[i].freightTM__City__c + ', ' + load[0].freightTM__stops__r[i].FreightTM__State__c;
            destination = destination + '|' + load[0].freightTM__stops__r[i].freightTM__Address__c + ', ' + load[0].freightTM__stops__r[i].freightTM__City__c + ', ' + load[0].freightTM__stops__r[i].FreightTM__State__c;
        }
        
        //Remove special characters that would break calculation code like #
        if (origin.contains('#')) {
            string ori = origin.replace('#','');
            origin = ori.replace(' ','+');
            system.debug('origin-#:'+ origin);
        }
        else {
            origin = origin.replace(' ','+');
            system.debug('origin2-normal:'+ origin);
        }
        if (destination.contains('#')) {
            string desti = destination.replace('#','');
            destination = desti.replace(' ','+') ;
            system.debug('destination-#:'+ destination);
        }
        else {
            destination = destination.replace(' ','+');
            system.debug('destination2-normal:'+ destination);
        }
       
        Qdistance distancecalc = new Qdistance(origin, destination );
        ID jobID = System.enqueueJob(distancecalc); 
        load.FreightTM__Distance__c = distancecalc.distance ;*/ 
        
        string origin = load[0].Pickup_Lat_Long__latitude__s + '+' + load[0].Pickup_Lat_Long__longitude__s;
        string destination = load[0].Delivery_Lat_Long__latitude__s + '+' + load[0].Delivery_Lat_Long__longitude__s;
        
        
       if (!inFutureContext) {
            googleMap(origin, destination, loadid);   
       }      
        
    }
    
    
    @future(callout=true)
    public static void googlemap (String address1, String address2, list<id> loadid){
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        req.setMethod('GET');
        
        String url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
            + '?origins=' + address1
            + '&destinations=' + address2
            + '&mode=driving'
            + '&sensor=false'
            + '&language=en'
            + '&units=imperial'
            + '&key=AIzaSyA1LzmP-MEyPNoOelRYwzZrLTf8bDn7ogU';
        
        //this needs to be added to above:   + '&key=[customer’s google maps key]';
        
        
        req.setEndPoint(url);
        
        HTTPResponse resp = http.send(req);
        System.debug('resp: ' + resp);
        jsonResults = resp.getBody().replace('\n', '');
        System.debug('jsonResults: ' + jsonResults);
        //parsedistance (jsonResults) ;
        parsejson(jsonResults);
        
        System.debug('totaldist:' + totaldist);
        
        List<FreightTM__Load__c> load = [Select Id, FreightTM__Distance__c, LastModifiedDate 
                                  from FreightTM__Load__c 
                                  where id in :loadid order by LastModifiedDate desc Limit 1];
        
        List<FreightTM__Load__c> loadLocked = [SELECT Id, FreightTM__Distance__c, LastModifiedDate 
                                                from FreightTM__Load__c where id =:load[0].Id FOR UPDATE];
        loadLocked[0].FreightTM__Distance__c = 0;
        loadLocked[0].FreightTM__Distance__c = totaldist;
        inFutureContext = true;
        update loadLocked;
        
        /*
        load[0].FreightTM__Distance__c = 0;
        load[0].FreightTM__Distance__c = totaldist;
        inFutureContext = true;
        update load[0];  */
    }
    
    public static void parsejson (string jsonres) {
        totaldist = 0;
        
        List<String> jsonorigins = jsonres.split('elements');
        //List<String> jsondestinations = jsonorigins.split('},');
        
        for (Integer i = 1; i < jsonorigins.size()-1; i++) {
            
            List<String> jsonOD = jsonorigins[i].split('status');
            jsonOD[i] = jsonOD[i].replace('{', ', ');
            jsonOD[i] = jsonOD[i].replace('}', ', ');
            jsonOD[i] = jsonOD[i].replace('[', ', ');
            jsonOD[i] = jsonOD[i].replace(']', ', ');
            jsonOD[i] = jsonOD[i].replace(' :',':');
            jsonOD[i] = jsonOD[i].replace('"', '');
            
            List<String> jsonSections = jsonOD[i].split(', ');
            
            for (Integer ii = 0; ii < jsonSections.size(); ii++) {
                jsonSections[ii] = jsonSections[ii].trim();
                
                if (jsonSections[ii].contains('distance:')) {
                    string distanc = jsonSections[ii + 1];
                    distanc = distanc.replace('text: ', '');
                    distanc = distanc.replace(' mi', '');
                    distanc = distanc.replace(' ft', '');
                    distanc = distanc.replace(',', '');
                    distanc = distanc.trim();
                    System.debug('distanc:' + distanc);
                    totaldist += Decimal.valueOf(distanc) ;
                    //System.debug('distance:1' + totaldist);
                }   
            }
        }
        
        integer j = jsonorigins.size()-1;
        List<String> jsonOD = jsonorigins[j].split('status');
        
        jsonOD[0] = jsonOD[0].replace('{', ', ');
        jsonOD[0] = jsonOD[0].replace('}', ', ');
        jsonOD[0] = jsonOD[0].replace('[', ', ');
        jsonOD[0] = jsonOD[0].replace(']', ', ');
        jsonOD[0] = jsonOD[0].replace(' :',':');
        jsonOD[0] = jsonOD[0].replace('"', '');
        
        List<String> jsonSections = jsonOD[0].split(', ');
        
        for (Integer jj = 0; jj < jsonSections.size(); jj++) {
            jsonSections[jj] = jsonSections[jj].trim();
            
            if (jsonSections[jj].contains('distance:')) {
                string distanc = jsonSections[jj + 1];
                distanc = distanc.replace('text: ', '');
                distanc = distanc.replace(' mi', '');
                distanc = distanc.replace(' ft', '');
                distanc = distanc.replace(',', '');
                distanc = distanc.trim();
                totaldist += Decimal.valueOf(distanc) ;
                //System.debug('distance:1' + totaldist);
            }   
        }
    }

 }