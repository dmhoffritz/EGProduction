@isTest
global class Test_MafailiFolderStructure_mock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        String json = '{'+
                ' \"kind\": \"drive#file\",'+
                ' \"id\": \"1hm7y7AfkCJQq5Ce7tRUP-IA0iBWdGu7N\",'+
                ' \"name\": \"Untitled\",'+
                ' \"mimeType\": \"application/octet-stream\",'+
                ' \"teamDriveId\": \"0AKUzqkSGCHb3Uk9PVA\",'+
                ' \"driveId\": \"0AKUzqkSGCHb3Uk9PVA\"'+
                '}';

        res.setBody(json);
        return res;
    }
}