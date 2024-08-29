/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

({

// Your renderer method overrides go here
    afterRender : function(component, helper) {
        this.superAfterRender();
        // Write your custom code here. 
        var autoLaunchFlow = component.get("v.autoLaunchFlow");
        if(autoLaunchFlow)
        {
            helper.showModal(component,event,helper);
        }
    }

})