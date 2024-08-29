@isTest
public class Test_RFP_Cont {

    @testSetup
    static void makeData() {

        Product2 matProduct1 = new Product2(
            Name = '8x4x18',
            Family = 'Mat Sales',
            Product_Type__c = 'Digging Mat',
            SellType__c = 'Purchase'
        );
        insert matProduct1;

        Product2 matProduct2 = new Product2(
            Name = '8x4x16',
            Family = 'Mat Sales',
            Product_Type__c = 'Laminated Mat',
            SellType__c = 'Purchase'
        );
        insert matProduct2;

        Product2 matProduct3 = new Product2(
            Name = '8x4x20',
            Family = 'Mat Sales',
            Product_Type__c = 'Digging Mat',
            SellType__c = 'Purchase'
        );
        insert matProduct3;

        Product2 serviceProduct1 = new Product2(
            Name = 'Rock',
            Family = 'Services',
            Product_Type__c = 'Access',
            SellType__c = 'Purchase'
        );
        insert serviceProduct1;

        Product2 serviceProduct2 = new Product2(
            Name = 'Herbicide',
            Family = 'Services',
            Product_Type__c = 'Clearing',
            SellType__c = 'Purchase'
        );
        insert serviceProduct2;

        Product2 serviceProduct3 = new Product2(
            Name = 'Cleanup',
            Family = 'Services',
            Product_Type__c = 'Environmental',
            SellType__c = 'Purchase'
        );
        insert serviceProduct3;

        Product2 serviceProduct4 = new Product2(
            Name = 'Mat Removal',
            Family = 'Services',
            Product_Type__c = 'Mat Handling',
            SellType__c = 'Purchase'
        );
        insert serviceProduct4;




    }

    /*
    @isTest
    private static void testHighPriority() {
        test.startTest();
        List<Product2> products = RFP_Cont.getHighPriorityMats();
        test.stopTest();
    }

    @isTest
    private static void testProductFetch() {
        test.startTest();
        RFP_Cont.ProductWrapper wrap = new RFP_Cont.ProductWrapper();
        List<RFP_Cont.ProductWrapper> wrappers = new List<RFP_Cont.ProductWrapper>();
        RFP_Cont.ProductWrapper wrapper1 = new RFP_Cont.ProductWrapper('', '8x4x18', 20, 'A', 3);
        RFP_Cont.ProductWrapper wrapper2 = new RFP_Cont.ProductWrapper('', '8x4x20', 100, 'New', 0);
        wrappers.add(wrapper1);
        wrappers.add(wrapper2);
        List<String> sellTypes = new List<String>();
        sellTypes.add('Purchase');
        List<RFP_Item__c> items = RFP_Cont.getProducts(wrappers, sellTypes);
        test.stopTest();
    } */

    @isTest
    private static void testServiceFetch() {
        test.startTest();
        RFP_Cont.ServiceWrapper wrap = new RFP_Cont.ServiceWrapper();
        wrap = RFP_Cont.fetchServiceOptions();
        test.stopTest();
    }

    @isTest
    private static void testMatFetch() {
        test.startTest();
        RFP_Cont.ProductFilters filters = new RFP_Cont.ProductFilters();
        filters.sellType = 'Purchase';
        filters.productType = 'Digging Mat';
        RFP_Cont.OptionWrapper opt = new RFP_Cont.OptionWrapper();
        List<RFP_Cont.OptionWrapper> opts = RFP_Cont.getProductNameOptions(filters);
        test.stopTest();
    }
}