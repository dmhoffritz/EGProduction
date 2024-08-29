({
    computePercentages: function (cmp) {
        /*
        let qtyRequested = cmp.get("v.Item.Quantity");
        let qtyDelivered = cmp.get("v.Item.CompleteDeliveries__c");
        let qtyPickup = cmp.get("v.Item.CompletePickups__c");

        let percentDelivered = (qtyDelivered / qtyRequested) * 100;
        if (percentDelivered > 100) {
            percentDelivered = 100;
        }
        percentDelivered = Math.round(percentDelivered);

        let percentPickup = (qtyPickup / qtyRequested) * 100;
        if (percentPickup > 100) {
            percentPickup = 100;
        } 
        percentPickup = Math.round(percentPickup);

        cmp.set("v.percentDeliveries", percentDelivered);
        cmp.set("v.percentPickups", percentPickup);
        */

        if (cmp.get("v.Item.CompleteDeliveries__c") > 100) {
            cmp.set("v.percentDeliveries", '100');
        } else {
            cmp.set("v.percentDeliveries", cmp.get("v.Item.CompleteDeliveries__c"));
        }

        if (cmp.get("v.Item.CompletePickups__c") > 100) {
            cmp.set("v.percentPickups", '100');
        } else {
            cmp.set("v.percentPickups", cmp.get("v.Item.CompletePickups__c"));
        }

        let deliveryAmount = 0;
        if (cmp.get("v.Item.Qty_Filled__c") == undefined) {
            deliveryAmount = 0;
        } else {
            deliveryAmount = cmp.get("v.Item.Qty_Filled__c");
        }
        cmp.set("v.deliveryQty", deliveryAmount);
        
        let pickupAmount = 0;
        if (cmp.get("v.Item.FreightOutQtyInRoute__c") == undefined && cmp.get("v.Item.FreightOutQtyDelivered__c") == undefined) {
            pickupAmount = 0;
        } else if (cmp.get("v.Item.FreightOutQtyInRoute__c") != undefined && cmp.get("v.Item.FreightOutQtyDelivered__c") == undefined) {
            pickupAmount = cmp.get("v.Item.FreightOutQtyInRoute__c");
        } else if (cmp.get("v.Item.FreightOutQtyInRoute__c") == undefined && cmp.get("v.Item.FreightOutQtyDelivered__c") != undefined) {
            pickupAmount = cmp.get("v.Item.FreightOutQtyDelivered__c");
        } else {
            pickupAmount = cmp.get("v.Item.FreightOutQtyInRoute__c") + cmp.get("v.Item.FreightOutQtyDelivered__c");
        }
        
        cmp.set("v.pickupQty", pickupAmount);
    },

    organizeBadges : function(cmp, event) {
        let cmpTarget = cmp.find('statusBadge');
        let itemStatus = cmp.get("v.status");
        if (itemStatus == 'New' || itemStatus == 'Delivery In Progress' || itemStatus == 'Pickup In Progress') {
            $A.util.addClass(cmpTarget, 'yellowBadge');
        } else if (itemStatus == 'Fulfilled' || itemStatus == 'Completed') {
            $A.util.addClass(cmpTarget, 'greenBadge');
        } else if (itemStatus == 'Canceled') {
            $A.util.addClass(cmpTarget, 'redBadge');
        }
    },

    /*
    checkSelections: function (cmp) {
        let selections = cmp.get("v.selectedItems");
        console.log("The following items have been selected: ");
        console.log(selections);
        if (selections.includes(cmp.get("v.itemId"))) {
            console.log("Item w/ ID: " + cmp.get("v.itemId") + " found within selection");
            cmp.set("v.selected", true);
        } else {
            console.log("Item w/ ID: " + cmp.get("v.itemId") + " NOT found within selection");
            cmp.set("v.selected", false);
        }
    }
    */
})