public class TruckLocationForRoute {
    
    list<FreightTM__Site_Location__c> Locations;
    public list<String> trucklocations {get;set;}
    public static FreightTM__Load__c load {get;set;}
    public string origin {get;set;}
    public string destination {get;set;}
    public TruckLocationForRoute(ApexPages.StandardController stndCont){
        trucklocations = new list<String>(); 
        
        load = [select Id, Name, FreightTM__Pickup_Address__c, FreightTM__Pickup_City__c, FreightTM__Pickup_State__c, FreightTM__Delivery_Address__c,
                FreightTM__Delivery_City__c, FreightTM__Delivery_State__c
                FROM FreightTM__Load__c 
                where Id =:ApexPages.currentPage().getParameters().get('id') ];
        
        origin = load.FreightTM__Pickup_Address__c + ', ' + load.FreightTM__Pickup_City__c + ', ' + load.FreightTM__Pickup_State__c;
        system.debug('origin ' + origin);
        destination = load.FreightTM__Delivery_Address__c + ', ' + load.FreightTM__Delivery_City__c + ', ' + load.FreightTM__Delivery_State__c ;
        
        Locations = [select Id, Name, FreightTM__Coordinates__latitude__s, FreightTM__Coordinates__longitude__s 
                     FROM FreightTM__Site_Location__c 
                     where FreightTM__Load__r.Id =:ApexPages.currentPage().getParameters().get('id') ORDER BY LocationNum__c];
        
        for (integer i = 0; i < Locations.size(); i++){
            if(Locations.size() != 0) {
                trucklocations.add( Locations[i].FreightTM__Coordinates__latitude__s + ', ' + Locations[i].FreightTM__Coordinates__longitude__s);
                if(i !=Locations.size()-1){
                    trucklocations.add('||');
                }
            }
        }
        system.debug('loc ' + trucklocations);
    }
    
    
    public list<FreightTM__Site_Location__c> getLocations() {
        Locations = [select Id, Name, FreightTM__Coordinates__latitude__s, FreightTM__Coordinates__longitude__s FROM FreightTM__Site_Location__c where id = :ApexPages.currentPage().getParameters().get('id') ];
        
        return Locations;        
    }
}