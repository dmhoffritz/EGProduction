public class LoadDistanceCalculator {
    // Google Maps API configuration
    private static final String API_ENDPOINT = 'https://maps.googleapis.com/maps/api/directions/json';
    private static final String API_KEY = 'AIzaSyCuWLezbnyCuIUslh6xk32QPp7aDtpAiUM'; 

    public class DistanceCalculationResult {
        private Id loadId;
        private Integer distance;
        
        public Id getLoadId() {
            return loadId;
        }
        
        public void setLoadId(Id loadId) {
            this.loadId = loadId;
        }
        
        public Integer getDistance() {
            return distance;
        }
        
        public void setDistance(Integer distance) {
            this.distance = distance;
        }
    }
    

    @InvocableMethod(label='Calculate Load Distance')
    public static void loadDistanceCalculation(List<String> loadId) {
        for (String i : loadId) {
            calculateDistance(Id.valueOf(i));
        }
    }
    
    @future(callout=true)
    public static void calculateDistance(Id loadId) {
        FreightTM__Load__c load = [SELECT Id, Pickup_Lat_Long__latitude__s, Pickup_Lat_Long__longitude__s, Delivery_Lat_Long__latitude__s, Delivery_Lat_Long__longitude__s
                                    FROM FreightTM__Load__c
                                    WHERE Id = :loadId];
        
        String requestUrl = prepareRequestUrl(load);
        DistanceCalculationResult result = makeCallout(requestUrl);
        
        updateLoad(load, result);
    }
    
    private static String prepareRequestUrl(FreightTM__Load__c load) {
        String originLat = String.valueOf(load.Pickup_Lat_Long__latitude__s);
        String originLng = String.valueOf(load.Pickup_Lat_Long__longitude__s);
        String destLat = String.valueOf(load.Delivery_Lat_Long__latitude__s);
        String destLng = String.valueOf(load.Delivery_Lat_Long__longitude__s);
        
        return API_ENDPOINT + '?origin=' + originLat + ',' + originLng + '&destination=' + destLat + ',' + destLng + '&key=' + API_KEY;
    }
    
    private static DistanceCalculationResult makeCallout(String requestUrl) {
        DistanceCalculationResult result = new DistanceCalculationResult();
        
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(requestUrl);
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                result = processResponse(responseData);
            } else {
                // Handle non-200 HTTP response status codes
                System.debug('Error in API callout. Status code: ' + response.getStatusCode() + ', Body: ' + response.getBody());
            }
        } catch (Exception e) {
            // Handle exceptions during API callout
            System.debug('Exception during API callout: ' + e.getMessage());
        }
        
        return result;
    }
    
    private static DistanceCalculationResult processResponse(Map<String, Object> responseData) {
        DistanceCalculationResult result = new DistanceCalculationResult();
        
        if (responseData.containsKey('routes')) {
            List<Object> routes = (List<Object>) responseData.get('routes');
            if (routes.size() > 0) {
                Map<String, Object> route = (Map<String, Object>) routes[0];
                if (route.containsKey('legs')) {
                    List<Object> legs = (List<Object>) route.get('legs');
                    if (legs.size() > 0) {
                        Map<String, Object> leg = (Map<String, Object>) legs[0];
                        if (leg.containsKey('distance')) {
                            Map<String, Object> distance = (Map<String, Object>) leg.get('distance');
                            if (distance.containsKey('value')) {
                                Integer value = (Integer) distance.get('value');
                                result.setDistance(convertMetersToMiles(value));
                            }
                        }
                    }
                }
            }
        }
        
        return result;
    }
    
    public static Integer convertMetersToMiles(Integer meters) {
        Double miles = meters * 0.000621371; // 1 meter = 0.000621371 miles
        return (Integer) Math.round(miles);
    }
    
    private static void updateLoad(FreightTM__Load__c load, DistanceCalculationResult result) {
        if (result != null) {
            load.FreightTM__Distance__c = result.getDistance();
        }
        
        update load;
    }
}