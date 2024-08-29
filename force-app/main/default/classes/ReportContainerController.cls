public with sharing class ReportContainerController {
    @AuraEnabled(cacheable=true)
    public static String getReportMetadata ( Id reportId){
       String str = JSON.serializePretty(Reports.ReportManager.runReport( reportId, true ) );
//    public static String getReportMetadata (){
//       String str = JSON.serializePretty(Reports.ReportManager.runReport( '00O2w000004yUp4EAE', true ) );
       System.debug('KN0:' + str);
       return str;
    }
}