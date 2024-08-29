@isTest
private class SDAddToMassMergeTest {
    @isTest
    private static void SDAddToMassMergeTest() {
        Integer numJobsToCreate = 20;
        List<FreightTM__Load__c> selectedLoads = [
            SELECT Id, Name
            FROM FreightTM__Load__c
            LIMIT :numJobsToCreate
        ];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(selectedLoads);
        ssc.setSelected(selectedLoads);                                                                 
        SDAddToMassMerge sdatmm = new SDAddToMassMerge(ssc);
        String objectNameTest = '[SDAddToMassMerge Test]';
        sdatmm.createMassMergeJobs();
        Integer numJobsCreated = Database.countQuery(
            'SELECT COUNT() '
            + 'FROM SDOC__SDJob__c '
            + 'WHERE SDOC__ObjApiName__c=\'' + objectNameTest + '\''
        );
        // System.assert(numJobsCreated == numJobsToCreate);
    }
}