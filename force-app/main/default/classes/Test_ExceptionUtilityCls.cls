@isTest
public with sharing class Test_ExceptionUtilityCls {
    @isTest
    public static void testException() {
        test.startTest();
        try {
        	ExceptionUtilityCls.throwCustomException(new List<String> {'This', 'is', 'an', 'exception'});
        } catch (Exception e) {
			System.debug('Exception for the exception...thx SF');
        }
        test.stopTest();
    }
}