//workaround for Guest User License permission
trigger ContentVersion_DocumentLink on ContentVersion (after insert) {
    for(Integer i = 0; i<trigger.new.size(); i++) {
        if(trigger.new[i].Title.split('_')[0] == 'DriverPortal') {
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = trigger.new[i].ContentDocumentId; ///Add ContentDocumentId
            cDocLink.LinkedEntityId = Id.valueOf(trigger.new[i].Title.split('_')[1]);//Add attachment to load id
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert cDocLink; 
        }
    }
}