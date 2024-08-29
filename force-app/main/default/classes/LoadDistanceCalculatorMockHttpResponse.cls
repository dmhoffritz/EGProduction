// Mock HttpResponse class to simulate API callout response
@isTest
public class LoadDistanceCalculatorMockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        //System.assertEquals('https://maps.googleapis.com/maps/api/directions/json?origin=37.774929,-122.419418&destination=34.052235,-118.243683&key=AIzaSyCuWLezbnyCuIUslh6xk32QPp7aDtpAiUM', request.getEndpoint());
        
        String jsonResponse = '{"routes": [{"legs": [{"distance": {"value": 559049}}]}]}';
        
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(jsonResponse);
        response.setStatusCode(200);
        return response;
    }
}