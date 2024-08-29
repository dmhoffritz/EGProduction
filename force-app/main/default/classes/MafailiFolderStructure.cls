public with sharing class MafailiFolderStructure {
    
@InvocableMethod(Callout = true label='Create Google Drive Folder Structure' Description='Creates a Folder Structure on Google Drive')
    public static List<Result> createFolderStructureInvocable(List<Request> request){

        String folderName = request[0].folderName;
        String folderId = request[0].driveParentFolderId;
        String credentialName = request[0].credentialName;

        system.debug('folderName: ' + folderName);
        system.debug('folderId: ' + folderId);

        String body = '{mimeType: "application/vnd.google-apps.folder", name: "' + folderName + '", parents: ["' + folderId + '"]}';
        HttpResponse driveResponse = createDriveFolder(credentialName, body);
        DriveResponseWrapper response = DriveResponseWrapper.parse(driveResponse.getBody());

        Result result = new Result();
        result.createdFolderId = response.id;
        List<Result> responseWrapper= new List<Result>();
        responseWrapper.add(result);
        return responseWrapper;
    }

    public static HttpResponse createDriveFolder(String credentialName, String body){


        String url = 'callout:'+credentialName+'/drive/v3/files?supportsAllDrives=true&supportsTeamDrives=true';


        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(url);
        req.setBody(body);

        Http h = new Http();
        HttpResponse resp = h.send(req);
        return resp;
    }


    public class Request {
        @InvocableVariable(label='Google Drive Parent Folder Id' required=true)
        public String driveParentFolderId;
        @InvocableVariable(label='Name for the new Google Drive Folder' required=true)
        public String folderName;
        @InvocableVariable(label='Name of the named credential to be used' required=true)
        public String credentialName;
    }

    public class Result {
        @InvocableVariable(label='Id of the created Google Drive Folder')
        public String createdFolderId;
    }

}