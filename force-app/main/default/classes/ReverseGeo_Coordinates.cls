public class ReverseGeo_Coordinates  {
    
    public static String jsonResults;

    //method used to bring in coordinate values and break them down for HTTP callout
    @InvocableMethod(label='Reverse Geocode Location Object')
    public static void evaluateCoords(List<String> locationID) {
        
        List<FreightTM__Facility__c> testFacility = [SELECT Geolocation__Latitude__s, Geolocation__Longitude__s, FreightTM__City__c, FreightTM__Country__c, County_Parish__c,
                                                     FreightTM__State__c, FreightTM__Street__c, FreightTM__Zip_Code__c
                                                     FROM FreightTM__Facility__c
                                                     WHERE ID=: locationID LIMIT 1];
        
        
        if(testFacility.size() > 0) {
            String latitude = String.valueOf(testFacility[0].Geolocation__latitude__s);
            String longitude = String.valueOf(testFacility[0].Geolocation__longitude__s);
            
            String coords = latitude + ',' + longitude;
            parseJSONResponse(coords, locationID[0]);
        }
        else {
            system.debug('Coordinates: ');
            system.debug(testFacility[0].Geolocation__latitude__s + testFacility[0].Geolocation__longitude__s);
        }
       
    } //end evaluateCoords 
    
    @future(callout=true)
    //method used to parse the JSON response from google's geocode HTTP callout
    public static void parseJSONResponse(String address, String locationId) {
        //FreightTM Key (Not Working)
        //String key='AIzaSyA1LzmP-MEyPNoOelRYwzZrLTf8bDn7ogU';
        
        //Map Plotter Key (Working)
        String key = 'GoogleAPIKeyHere';
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
        parseResults(jsonResults, locationId);
    } //end parseJSONResponse
	
    //method used to properly evaluate JSON response and store them into our own field values
    public static void parseResults(String jsonres, String location_id) {
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
          	Store city, state, zip, & county fields in proper Location fields
         */
        
        FreightTM__Facility__c curr_location = new FreightTM__Facility__c(Id = location_id);
        
        curr_location.FreightTM__Street__c = parsedStreet;
        curr_location.FreightTM__City__c = parsedCity;
        curr_location.FreightTM__State__c = parsedState;
        curr_location.FreightTM__Zip_Code__c = parsedZip;
        curr_location.County_Parish__c = parsedCounty;
        curr_location.FreightTM__Country__c = 'United States';
        
        update curr_location; 
    }//end parseResults
}//end ReverseGeo_apicall
