/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-05-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ReverseGeo_LoadID  {
    
    public static String jsonResults;

    //method used to bring in coordinate values and break them down for HTTP callout
    @InvocableMethod(label='Reverse Geocode Last Location')
    public static void evaluateCoords(List<String> loadId) {
        //Query tracked location related list
        List<FreightTM__Site_Location__c> tracked_locs = [SELECT FreightTM__Coordinates__latitude__s, FreightTM__Coordinates__longitude__s
													      FROM FreightTM__Site_Location__c WHERE FreightTM__Load__r.Id in: loadId
														  ORDER BY Location_Date_Time__c DESC LIMIT 1];
        
        if(tracked_locs.size() > 0) {
        	//Store lat & long as string variables
        	String latitude = String.valueOf(tracked_locs[0].FreightTM__Coordinates__latitude__s);
        	String longitude = String.valueOf(tracked_locs[0].FreightTM__Coordinates__longitude__s);
        
        	//Combine coords into proper form for HTTP callout
        	String coords = latitude + ',' + longitude;
            
            
            //Need to check for future or batch context to properly cascade program
            /*
            if(System.isFuture() || System.isBatch()) {
                parseJSON_NotFuture(coords, loadId[0]);
            } else if(Limits.getFuturecalls() < Limits.getLimitFutureCalls()) {
                parseJSONResponse(coords, loadId[0]);
            } else {system.debug('Cannot perform future call');} */
            parseJSONResponse(coords, loadID[0], latitude, longitude);
            
        	
        } //end if
    } //end evaluateCoords
    
    //method used to parse the JSON response from google's geocode HTTP callout
    @future(callout=true)
    public static void parseJSONResponse(String address, String loadId, String latitude, String longitude) {
        //FreightTM Key (Not Working)
    	//String key='AIzaSyA1LzmP-MEyPNoOelRYwzZrLTf8bDn7ogU';
        
    	//Map Plotter Key (Working)
        String key = 'AIzaSyCuWLezbnyCuIUslh6xk32QPp7aDtpAiUM';
        Http httpProtocol = new Http();
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();
        // Set the endpoint URL.
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+address+'&key='+key;
        request.setEndPoint(endpoint);
        // Set the HTTP verb to GET.
        request.setMethod('GET');
        // Send the HTTP request and get the response.
        // The response is in JSON format.
        HttpResponse response = httpProtocol.send(request);
        System.debug('####Body : '+response.getBody());
        
        //parse JSON Results
        jsonResults = response.getBody().replace('\n', '');
        parseResults(jsonResults, loadId, latitude, longitude);
    } //end parseJSONResponse
    
    //method to use if not in future context
    /*
    public static void parseJSON_NotFuture(String address, String loadId) {
    	//FreightTM Key (Not Working)
    	//String key='AIzaSyA1LzmP-MEyPNoOelRYwzZrLTf8bDn7ogU';
        
    	//Map Plotter Key (Working)
        String key = 'AIzaSyCuWLezbnyCuIUslh6xk32QPp7aDtpAiUM';
        Http httpProtocol = new Http();
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();
        // Set the endpoint URL.
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='+address+'&key='+key;
        request.setEndPoint(endpoint);
        // Set the HTTP verb to GET.
        request.setMethod('GET');
        // Send the HTTP request and get the response.
        // The response is in JSON format.
        HttpResponse response = httpProtocol.send(request);
        System.debug('####Body : '+response.getBody());
        
        //parse JSON Results
        jsonResults = response.getBody().replace('\n', '');
        parseResults(jsonResults, loadId);
    } end parseJSON_NotFuture*/
	
    //method used to properly evaluate JSON response and store them into our own field values
    public static void parseResults(String jsonres, String load_id, String latitude, String longitude) {
        system.debug('PARSING JSON RESULTS...');

        String parsedStreetNum;
        String parsedRoute;
        String parsedStreet;
        String parsedCity;
        String parsedState;
        String parsedZip;
        String parsedCounty;

        //Parse city, state, zip, and county from JSON results
		Map<String,Object> deserializedJSON = (Map<String,Object>)JSON.deserializeUntyped(jsonres); //convert strings into objects
        List<object> results = (List<Object>)deserializedJSON.get('results'); //list containing each instance of JSON result block
        Map<String,Object> address = (Map<String,Object>)results[0]; //check first block which contains city, state, zip, & county
        List<object> address_components = (List<Object>)address.get('address_components'); //List values stored under address_components
        Integer i = 0;
        for(Object check_address : address_components) {
            Map<String,Object> c = (Map<String,Object>)check_address;
            String c_type = String.valueOf(c.get('types'));
            System.debug('Check ' + i + ': ' + c_type);
            i += 1;
            if(c_type.contains('street_number')) {
                parsedStreetNum = String.valueOf(c.get('short_name'));
                System.debug('CAPTURED STREET: ' + parsedStreetNum);
            }
            else if(c_type.contains('route')) {
                parsedRoute = String.valueOf(c.get('short_name'));
                System.debug('CAPTURED ROUTE: ' + parsedRoute);
            }
            else if(c_type.contains('locality') || c_type.contains('sublocality')) {
                parsedCity = String.valueOf(c.get('short_name'));
                System.debug('CAPTURED CITY: ' + parsedCity);
            } 
            
            else if(c_type.contains('administrative_area_level_1')) {
                parsedState = String.valueOf(c.get('short_name'));
                System.debug('CAPTURED STATE: ' + parsedState);
            } 
            
            else if(c_type.contains('(postal_code)')) {
                parsedZip = String.valueOf(c.get('short_name'));
                System.debug('CAPTURED ZIP: ' + parsedZip);
            }
            
            else if(c_type.contains('administrative_area_level_2') || c_type.contains('administrative_area_level_3')) {
                parsedCounty = String.valueOf(c.get('short_name'));
                System.debug('CAPTURED COUNTY: ' + parsedCounty);
            } 
        }
        if(parsedStreetNum != null || parsedRoute != null) {
            parsedStreet = parsedStreetNum + ' ' + parsedRoute;
            system.debug('CAPTURED STREET: ' + parsedStreet);
        }

        if(parsedStreet == null || parsedStreet == '') {
            parsedStreet = 'NOT FOUND';
            System.debug('STREET NOT FOUND');
        }
        
        if(parsedCity == null || parsedCity == '') {
            parsedCity = 'NOT FOUND';
            system.debug('CITY NOT FOUND');
        }
        
        if(parsedState == null || parsedState == '') {
            parsedState = '';
            system.debug('STATE NOT FOUND');
        }
        
        if(parsedZip == null || parsedZip == '') {
            parsedZip = 'NOT FOUND';
            system.debug('ZIP NOT FOUND');
        }
        
        if(parsedCounty == null || parsedCounty == '') {
            parsedCounty = 'NOT FOUND';
            system.debug('COUNTY NOT FOUND');
        }
		
        /*
         	Need to store city, state, zip, & county in proper load fields within production
			
			Options:
				1. Update delivery facility
				2. Add last location fields on Load object
         */
        
        FreightTM__Load__c curr_load = new FreightTM__Load__c(Id = load_id);
        
        curr_load.LastLoc_Street__c = parsedStreet;
        curr_load.LastLoc_City__c = parsedCity;
        curr_load.LastLoc_State__c = parsedState;
        curr_load.LastLoc_Zip__c = parsedZip;
        curr_load.LastLoc_County__c = parsedCounty;
        curr_load.LastLocationLatitude__c = latitude;
        curr_load.LastLocationLongitude__c = longitude;

        
        update curr_load; 
    }//end parseResults
}//end ReverseGeo_loadID