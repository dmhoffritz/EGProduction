@isTest
public class Test_MafailiFolderStructure {

    @isTest 
    public static void testGoogleDriveConnection() {
        Test.setMock(HttpCalloutMock.class, new Test_MafailiFolderStructure_mock()); 
        MafailiFolderStructure.Request req = new MafailiFolderStructure.Request();
        req.driveParentFolderId = '0';
        req.folderName = 'Test Folder 01';
        req.credentialName = 'Google_Drive_Salesforce_Connect';
        List<MafailiFolderStructure.Request> requests = new List<MafailiFolderStructure.Request>();
        requests.add(req);
        test.startTest();
        List<MafailiFolderStructure.Result> response = MafailiFolderStructure.createFolderStructureInvocable(requests);
        test.stopTest();
    }
}