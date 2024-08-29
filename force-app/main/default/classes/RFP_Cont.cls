public without sharing class RFP_Cont {

    //method designed to get default list of product options for requestor to use in RFP form
    /*
    @AuraEnabled(cacheable = true)
    public static List<Product2> getHighPriorityMats() {
        try {
            List<Product2> products = [SELECT Id, Name, 
                                        SellType__c, Family, Product_Type__c
                                        FROM Product2 WHERE 
                                        Priority_Product__c = true
                                        ORDER BY Priority__c ASC];

            return products;
        } catch(QueryException e) {
            System.debug('Exception whenever fetching high priority mats: ' + e);
            throw new AuraHandledException(e.getMessage());
        } 
    }

    public with sharing class ProductWrapper {
        @AuraEnabled
        public String productId {get; set;}

        @AuraEnabled
        public String productName {get; set;}

        @AuraEnabled
        public Integer qty {get; set;}

        @AuraEnabled
        public String grade {get; set;}

        @AuraEnabled
        public Integer duration {get; set;}

        public ProductWrapper() {
            this.productId = '';
            this.productName = '';
            this.qty = 0;
            this.grade  = '';
            this.duration = 0;
        }

        public ProductWrapper(String productId, String productName, Integer qty, String grade, Integer duration) {
            this.productId = productId;
            this.productName = productName;
            this.qty = qty;
            this.grade = grade;
            this.duration = duration;
        }
    }

    @AuraEnabled(cacheable = true) // 
    public static List<RFP_Item__c> getProducts(List<ProductWrapper> products, List<String> sellTypeOptions) {
        List<RFP_Item__c> productsToReturn = new List<RFP_Item__c>();
        for (String sellType: sellTypeOptions) {
            for (ProductWrapper prod: products) {
                Product2 idToAdd = [SELECT Id
                                FROM Product2
                                WHERE Name =: prod.productName
                                AND SellType__c =: sellType
                                LIMIT 1];
                RFP_Item__c item = new RFP_Item__c(Product__c = idToAdd.Id, Quantity__c = prod.qty, MAT_Grade__c = prod.grade);
                if (sellType == 'Lease' || sellType == 'Rental') {
                    item.Duration__c = prod.duration;
                }
                productsToReturn.add(item);
            }
        }
        return productsToReturn;
    }
    */


    public with sharing class ProductFilters {
        @AuraEnabled
        public String sellType {get; set;}

        @AuraEnabled
        public String productType {get; set;}
    }

    public with sharing class OptionWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public OptionWrapper() {
            this.label = '';
            this.value = '';
        }

        public OptionWrapper(String option, String productId) {
            this.label = option;
            this.value = productId;
        }
    }

    @AuraEnabled (cacheable = true)
    public static List<OptionWrapper> getProductNameOptions(ProductFilters filters) {
        List<OptionWrapper> options = new List<OptionWrapper>();
        try {
            List<Product2> productOptions = [SELECT Id, Name
                            FROM Product2
                            WHERE Family = 'Mat Sales'
                            AND SellType__c =: filters.sellType
                            AND Product_Type__c =: filters.productType];
            for (Product2 p : productOptions) {
                options.add(new OptionWrapper(p.Name, p.Id));
            }
            return options;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public with sharing class ServiceWrapper {
        @AuraEnabled
        public List<Product2> accessServices {get; set;}
        @AuraEnabled
        public List<Product2> clearingServices {get; set;}
        @AuraEnabled
        public List<Product2> environmentalServices {get; set;}
        @AuraEnabled
        public List<Product2> matServices {get; set;}

        public ServiceWrapper() {
            this.accessServices = new List<Product2>();
            this.clearingServices = new List<Product2>();
            this.environmentalServices = new List<Product2>();
            this.matServices = new List<Product2>();
        }

        public void populateServices() {
            try {
                this.accessServices = [SELECT Id, Name
                                        FROM Product2
                                        WHERE Family = 'Services' AND
                                        Product_Type__c = 'Access'];
                this.clearingServices = [SELECT Id, Name
                                        FROM Product2
                                        WHERE Family = 'Services' AND
                                        Product_Type__c = 'Clearing'];
                this.environmentalServices = [SELECT Id, Name
                                                FROM Product2
                                                WHERE Family = 'Services' AND
                                                Product_Type__c = 'Environmental'];
                this.matServices = [SELECT Id, Name
                                    FROM Product2
                                    WHERE Family = 'Services' AND
                                    Product_Type__c = 'Mat Handling'];
            } catch (QueryException e) {
                System.debug('Error whenever querying for relative services options....' + e);
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    @AuraEnabled(cacheable = true)
    public static ServiceWrapper fetchServiceOptions(){
        try {
            ServiceWrapper services = new ServiceWrapper();
            services.populateServices();

            return services;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


}