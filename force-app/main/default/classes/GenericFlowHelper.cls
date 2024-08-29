public class GenericFlowHelper {
	@InvocableMethod(label='create records' description='Create records.')
    public static List<FlowWrapper> createRecords(List<FlowWrapper> flowData) {
        List<FlowWrapper> fwList = new List<FlowWrapper>();
        Set<ID> recordIDSet = new Set<Id>();
        for(FlowWrapper fw : flowData)
            recordIDSet.add(fw.recordId);
        String sObjectName = flowData[0].recordId.getsobjecttype().getDescribe().getName();
        Map<String,Schema.SObjectField> objfields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        String query = 'SELECT ';
        query += String.join(new List<String>(objfields.KeySet()),',');
        query += ' FROM '+sObjectName+' WHERE ID IN : recordIDSet';
        List<sObject> sobjList = new List<sObject>();
        Integer currentRecord = 0;
        
        for(Sobject sob : Database.query(query)) {
            FlowWrapper fw = new FlowWrapper();
            for(Integer co = 1 ; co<= flowData[currentRecord].count; co++) {
                Sobject newObj = sob.clone(false, true, false, false);
                sobjList.add(newObj);
            }
            fw.sObjectList = sobjList;
            fw.isSuccess = true;
            fw.recordId = sob.Id;
            fw.count = flowData[currentRecord].count;
            fwList.add(fw);
            currentRecord++;
        }
        
        insert sobjList;
        return fwList;
    }
    
    public class FlowWrapper {
        @InvocableVariable(required=true)
        Public Id recordId;
        @InvocableVariable(required=true)
        Public Integer count;
		@InvocableVariable
        Public List<sObject> sObjectList;
		@InvocableVariable
        Public boolean isSuccess;        
    }
}