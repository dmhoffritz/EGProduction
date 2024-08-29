global virtual without sharing class Site_NewPassConfirm_Cont {
    public String temp_pass {get; set;}
    public String new_pass {get; set;}
    public String confirm_pass {get; set;}
    private List<Portal_User_Registration__c> checkUser {get; set;}
    public Integer noMatch {get; set;}
    public Boolean password_match {get; set;}

    
    global PageReference updatePass() {
        //Determine if temp_pass matches any of our records
        checkUser = [SELECT Id, Temp_Password__c, Password__c, ConfirmPassword__c FROM Portal_User_Registration__c WHERE Temp_Password__c=: temp_pass];
        
        //If record match then store new password into user record and nullify temp password field
        if(checkUser.size() > 0) {
            
            //Match found
            noMatch = 1;
            
            //Check to see that passwords match
            if(new_pass == confirm_pass) {
                password_match = true;
                checkUser[0].Password__c = new_pass;
                checkUser[0].ConfirmPassword__c = confirm_pass;
                checkUser[0].Temp_Password__c = '';
                update checkUser[0];
                
                //Return user to carrier portal login
                PageReference login_page = new PageReference('https://yourempiregroup.secure.force.com/carrier');
                return login_page;
            }
            else {
                password_match = false;
                return null;
            }

        }
        
        else {
            noMatch = 2;
            return null;
        }
        
    }
    
}