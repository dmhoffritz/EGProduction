({
    isCanvasBlank:function (canvas) {
        var blank = document.createElement('canvas');
        blank.width = canvas.width;
        blank.height = canvas.height;
        return canvas.toDataURL() == blank.toDataURL();
    },
    
    saveSignature:function(component){        
        var action = component.get("c.uploadSignature");
        var vSplit=document.getElementById("divsign").toDataURL().split(',')[1]; 
        //var vSplit=document.getElementById("divsign").toDataURL().replace(/^data:image\/(png|jpg);base64,/, ""); encodeURIComponent(vSplit)
        action.setParams({ 
            recordId: component.get("v.loadId"),
            b64SignData: document.getElementById("divsign").toDataURL(),
            signatureOwner: component.get("v.signatureType")
        });
        action.setCallback(this, function(e) {          
            if(e.getState()=='SUCCESS'){
                alert('Signature Saved Successfully!');
                location.reload();
            }  
            else{
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(action); 
    },
 })