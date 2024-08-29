public with sharing class ExceptionUtilityCls {

    public class CustomException extends Exception{}

    @invocableMethod(label='Custom Exception' description='Invoke custom exception method.' category='Exception Handling')
    public static void throwCustomException(List<String> exceptionMessage) {
        throw new CustomException('Exception hac occured in the process /flow '+
                                  'Please contact your system adminstrator : '+ exceptionMessage[0] );
    }
}