({
    init: function (cmp, evnt, helper) {
        let cell = cmp.get("v.contactCell");
        if (cell != undefined) {
            let updatedCell = cell.replace(/[^+\d]+/g, "");
            cmp.set("v.contactCell", updatedCell);
        }
        
        console.log("Following cell used to contact touchpoint: " + cell);
    },

    initCanvas: function (cmp, event, helper) {
        console.log("Signature pad script loaded!");
        let canvas = document.querySelector("canvas");
        let sigPad = new SignaturePad(canvas);
        sigPad.minWidth = 2;
        sigPad.maxWidth = 4;
        sigPad.toDataURL();
        window.onresize = resizeCanvas;
        resizeCanvas(sigPad);

        function resizeCanvas(canvas) {
            let ratio = Math.max(window.devicePixelRatio || 1, 1);
            canvas.width = canvas.offsetWidth * ratio;
            canvas.height = canvas.offsetHeight * ratio;
            canvas.getContext("2d").scale(ratio, ratio);
        }
    },
    
    SaveSignature:function(component,event,helper){
        var isblank=helper.isCanvasBlank(document.getElementById('divsign'));
        if(!isblank){            
            helper.saveSignature(component);
        }
        else{
            alert('Please Sign in the box');
        }
    },       
    closeModal: function (cmp, evt, helper) {
        let closeEvt = $A.get("e.c:closePopup");
        closeEvt.fire();
        cmp.destroy();

    },

    showSpinner: function(component, event, helper) {        
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){        
        component.set("v.Spinner", false);
    },
 })