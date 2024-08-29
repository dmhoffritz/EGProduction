({
	init : function(cmp, event, helper) {
        helper.fetchFiles(cmp);
        helper.fetchLoadStatus(cmp);
	},
    
    handleUploadFinished : function(cmp, event, helper) {
        console.log("Successfully uploaded Invoice");
        var uploadedFiles = event.getParam("files");
        helper.fetchFiles(cmp);
    },
    
    getFiles : function(cmp, event, helper) {
        helper.fetchFiles(cmp);
    }
})