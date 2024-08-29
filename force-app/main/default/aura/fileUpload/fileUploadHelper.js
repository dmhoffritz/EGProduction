({
    MAX_FILE_SIZE: 4500000, /* 6 000 000 * 3/4 to account for base64 */
    CHUNK_SIZE: 950000, /* Use a multiple of 4 */

    save: function (component) {
        if(component.get("v.docType") == 'PoD') {
            var fileInput = component.find("pod_file").getElement();
        } else {
            var fileInput = component.find("file").getElement();
        }
        var file = fileInput.files[0];

        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
                'Selected file size: ' + file.size);
            return;
        }

        var fr = new FileReader();

        var self = this;
        fr.onload = function () {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);

            self.upload(component, file, fileContents);
        };

        fr.readAsDataURL(file);
    },
    upload: function (component, file, fileContents) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);

        // start with the initial chunk
        this.uploadChunk(component, file, fileContents, fromPos, toPos, '');
    },
    uploadChunk: function (component, file, fileContents, fromPos, toPos, attachId) {
        var action = component.get("c.saveTheChunk");
        var chunk = fileContents.substring(fromPos, toPos);
        //contentType: file.type,
        action.setParams({
            rec_id: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk),
            fileId: attachId,
            docLabel: component.get("v.docType"),
            invoiceNum: component.get("v.vendorInvoice")
        });

        var self = this;
        action.setCallback(this, function (a) {

            console.log('uploadChunk: Callback');
            attachId = a.getReturnValue();

            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);

            if (fromPos < toPos) {
                self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);
            } else {
                console.log('uploadChunk: done');
                component.set("v.showModal", false);
                component.set("v.fileName", "");
                var evt = $A.get("e.c:onsave");
                evt.fire();

                //self.showToast(component);
            }
        });

        $A.getCallback(function () {
            $A.enqueueAction(action);
        })();
    },
    
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    
    getFile: function(cmp) {
        if(cmp.get("v.docType") == 'PoD') {
            var inputFile = cmp.find("pod_file").getElement();
        } else {
            var inputFile = cmp.find("file").getElement();
        }
        var fl = inputFile.files[0];
        var fl_name = fl.name;
        cmp.set("v.fileName", fl_name);
    }

})