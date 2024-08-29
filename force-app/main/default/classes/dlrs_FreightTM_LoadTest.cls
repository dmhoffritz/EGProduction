/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_FreightTM_LoadTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_FreightTM_LoadTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new FreightTM__Load__c());
    }
}