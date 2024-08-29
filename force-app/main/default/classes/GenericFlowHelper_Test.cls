@isTest
public class GenericFlowHelper_Test {
    static testmethod void positiveTest() {
        Account acc = new Account(Name = 'NewsTechnologyStuff');
        insert acc;
        
        List<GenericFlowHelper.FlowWrapper> fwList = new List<GenericFlowHelper.FlowWrapper>();
        GenericFlowHelper.FlowWrapper fw = new GenericFlowHelper.FlowWrapper();
        fw.count = 10;
        fw.recordId = acc.Id;
        fwList.add(fw);
        
        List<GenericFlowHelper.FlowWrapper> outputList = GenericFlowHelper.createRecords(fwList);
        System.assert(outputList[0].isSuccess);
    }
}