@isTest
global class Test_CarrierPortal_mock implements HttpCalloutMock{

      	global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{   "destination_addresses" : [      "20 Main St, San Diego, CA 92173, USA",      "Main St, Irvine, CA 92614, USA"   ],   "origin_addresses" : [ "Main St, Irvine, CA 92614, USA", "Main St, Irvine, CA 92614, USA" ],   ');
        return res;
      }
  
}