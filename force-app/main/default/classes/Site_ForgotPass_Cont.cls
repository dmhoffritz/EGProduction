global without sharing class Site_ForgotPass_Cont {
    public String username {get; set;} //used to check for username in Portal User Reg records
    private List<Portal_User_Registration__c> checkRecords {get; set;} //query Portal User Reg records
    @TestVisible private String temp_pass {get; set;} //generate random password and store as user temp-pass
    public Integer noMatch {get; set;} //check if record was found or not
    
  
    global void checkUser() {
        //Relate email to user records
        checkRecords = [SELECT Id, Temp_Password__c, Email__c FROM Portal_User_Registration__c WHERE Email__c=: username];
        
        if(checkRecords.size() > 0) {
            //Generate random temp password
            Integer len = 8;
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            temp_pass = key.substring(0, len);
            
            //Store temp password
            checkRecords[0].Temp_Password__c = temp_pass;
            update checkRecords[0];
            
            //Execute flow to send verification e-mail
            //Flow will need recordId to execute
            Map<String,String> inputs = new Map<String, String>();
            inputs.put('recordId', String.valueOf(checkRecords[0].Id));
            
            Flow.Interview.Portal_User_Registration_Forgot_Password call_flow = new Flow.Interview.Portal_User_Registration_Forgot_Password(inputs);
            call_flow.start();

            //Match was found
            noMatch = 1;
                        
        }
        
        else {
            noMatch = 2;
        }
    }
    

}