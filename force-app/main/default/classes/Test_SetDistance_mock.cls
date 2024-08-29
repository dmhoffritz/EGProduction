@isTest
global class Test_SetDistance_mock implements HttpCalloutMock{

      	global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{   "destination_addresses" : [      "20 Main St, San Diego, CA 92173, USA",      "Main St, Irvine, CA 92614, USA"   ],   "origin_addresses" : [ "Main St, Irvine, CA 92614, USA", "Main St, Irvine, CA 92614, USA" ],   "rows" : [      {         "elements" : [            {               "distance" : {                  "text" : "99.2 mi",                  "value" : 159704               },               "duration" : {                  "text" : "1 hour 32 mins",                  "value" : 5490               },               "status" : "OK"            },            {               "distance" : {                  "text" : "1 ft",                  "value" : 0               },               "duration" : {                  "text" : "1 min",                  "value" : 0               },               "status" : "OK"            }         ]     },      {         "elements" : [            {               "distance" : {                  "text" : "99.2 mi",                  "value" : 159704               },               "duration" : {                  "text" : "1 hour 32 mins",                  "value" : 5490               },               "status" : "OK"            },            {               "distance" : {                  "text" : "1 ft",                  "value" : 0               },               "duration" : {                  "text" : "1 min",                  "value" : 0               },               "status" : "OK"            }         ]      }   ],   "status" : "OK"}');
        return res;
      }
  
}