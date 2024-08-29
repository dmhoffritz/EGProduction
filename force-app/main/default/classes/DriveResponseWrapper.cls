public class DriveResponseWrapper {
    
    public String kind;
    public String id;
    public String name;
    public String mimeType;
    public String teamDriveId;
    public String driveId;


    public static DriveResponseWrapper parse(String json) {
        return (DriveResponseWrapper) System.JSON.deserialize(json, DriveResponseWrapper.class);
    }
}