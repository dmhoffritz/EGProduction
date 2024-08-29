import { LightningElement, wire, track } from 'lwc';
//import { LightningElement, wire, track } from 'lwc';

import getInventory from '@salesforce/apex/ZMapInventory.getInventory';


export default class MapInventory extends LightningElement {

    @track mapMarkers = [];
    @track record;

    @wire(getInventory)
    wiredInventory({ error, data }) {
        if (data) {
            this.record = data;
            console.log(data)
            let tempMarkers = [];
            for (var i in data) {
                let marker = {
                    'location': {
                        'Latitude': data[i].Geolocation__Latitude__s,
                        'Longitude': data[i].Geolocation__Longitude__s
                    },
                    'title': data[i].Name,
                    'description': (
                        'Grade/Total Qty./Weighted Avg. Cost' +
                        '<br/>' +
                        'New: ' + data[i].New_Total_Quantity__c + '/' + data[i].Weighted_Avg_Cost_New__c +
                        '<br/>' +
                        'A: ' + 'to be done' +
                        '<br/>' +
                        'B: ' + 'to be done'
                    ),
                    'icon': (data[i].Inventory_Location_Type__c == 'Project' ? 'standard:account' : 'standard:location')
                };
                tempMarkers.push(marker);
            }

            this.mapMarkers = tempMarkers;

            //    console.log(JSON.stringify(data, null, '\t'));           
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }

}