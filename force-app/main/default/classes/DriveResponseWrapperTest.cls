@isTest
public with sharing class DriveResponseWrapperTest {

    static testMethod void testParse() {
        String json = '{'+
                ' \"kind\": \"drive#file\",'+
                ' \"id\": \"1hm7y7AfkCJQq5Ce7tRUP-IA0iBWdGu7N\",'+
                ' \"name\": \"Untitled\",'+
                ' \"mimeType\": \"application/octet-stream\",'+
                ' \"teamDriveId\": \"0AKUzqkSGCHb3Uk9PVA\",'+
                ' \"driveId\": \"0AKUzqkSGCHb3Uk9PVA\"'+
                '}';
        DriveResponseWrapper obj = DriveResponseWrapper.parse(json);
        System.assert(obj != null);
    }
}